# Project 4 — Order Processing Automation — Detailed Notes

## 1. Objective

Build an industry-style e-commerce order-processing automation where an order is validated, inventory is reserved, a Razorpay Payment Link is created, and the final payment result controls fulfillment.

The important design principle is **state consistency**. A successful payment must not create a shipment unless the payment was actually accepted. A failed payment must release reserved inventory and must not create a shipment.

---

## 2. End-to-End Architecture

```text
Customer Order
    ↓
Workflow B — Order Creation
    ↓
Validation
    ↓
Inventory Check
    ↓
Reserve Inventory
    ↓
Razorpay Payment Link
    ↓
Customer Payment
    ↓
Razorpay Webhook
    ↓
Workflow C — Payment Processing
    ├── SUCCESS
    │     ↓
    │  Record Payment
    │     ↓
    │  Update Order Payment
    │     ↓
    │  Create/Reuse Shipment
    │     ↓
    │  Update Shipment Status
    │     ↓
    │  Update Order Shipment Status
    │     ↓
    │  Confirmation Email
    │
    └── FAILED
          ↓
       Release Inventory
          ↓
       Payment Failed Status
          ↓
       Workflow Log
          ↓
       Failure Email
```

---

## 3. Workflow A — Database Setup

Workflow A creates the persistent tables required by the other workflows.

### Orders

Stores the business order:

- `order_id`
- customer information
- product
- quantity
- amount
- order status
- payment status
- shipment status
- Razorpay payment-link information

### Inventory

Tracks:

- available stock
- reserved stock

Reservation is performed before payment because the customer may take time to pay.

### Payments

Stores payment events so that the workflow can detect duplicate webhook deliveries.

A useful unique key is `payment_id`.

### Shipments

Stores one shipment record for an order in this project:

```text
shipment_id = SHP-<order_id>
```

### Workflow Logs

Stores operational history such as:

```text
PAYMENT_FAILED
SUCCESS
FAILED
```

This makes troubleshooting and auditing easier.

---

## 4. Workflow B — Order Creation

### Order Webhook

Receives the incoming order request.

### Validation Check / Validation Services

Checks that required information exists and is valid, including the product and requested quantity.

### Order Validation

Branches the workflow into valid and invalid order paths.

### Create Order

Creates the initial order state:

```text
status = AWAITING_PAYMENT
payment_status = PENDING
shipment_status = NOT_CREATED
```

### Inventory Check

The business rule is:

```text
available_stock >= requested_quantity
```

A previous test showed why this condition matters: a quantity such as `100` must not be accepted when only a small number of units are available.

### Reserve Inventory

For quantity `q`:

```text
available_stock = available_stock - q
reserved_stock  = reserved_stock + q
```

### Merge

Combines the order information and inventory result needed by the payment-link creation step.

### Create Razorpay Payment Link

Creates the hosted Razorpay Payment Link.

Important values include:

```text
amount
currency = INR
customer name
customer email
reference_id = internal order_id
```

The Razorpay response includes a Payment Link ID and a hosted short URL.

### Store Payment Link

Persists:

```text
payment_link_id
payment_link_url
```

and leaves the order waiting for payment.

---

## 5. Workflow C — Real Razorpay Webhook

### Razorpay Payment Webhook

The n8n production webhook receives the real event.

The path used in this project was:

```text
/webhook/razorpay-payment-webhook
```

The public URL was exposed temporarily through Cloudflare Quick Tunnel.

### Validate Webhook

Extracts the relevant payment fields from the Razorpay event.

For successful Payment Links, the workflow handled `payment_link.paid`.

For failed payment attempts, the webhook was additionally configured for `payment.failed`.

### Check Payment Already Processed

Uses the payment ID to determine whether the payment was already recorded.

Conceptually:

```sql
SELECT EXISTS (
    SELECT 1
    FROM payments
    WHERE payment_id = '<payment_id>'
) AS payment_exists;
```

### Payment Already Processed

If `payment_exists = true`, the duplicate path prevents the payment from being processed again.

This is important because webhook providers may retry delivery.

---

## 6. SUCCESS Branch

### Record Payment

Creates the payment record using the Razorpay payment ID and related order/payment information.

### Update Order Payment

Changes the order to:

```text
status = PAID
payment_status = SUCCESS
```

### Create Shipment

Creates the shipment using a deterministic ID such as:

```text
SHP-ORD-1012
```

### Important Idempotency Fix

During the real Razorpay test, `Create Shipment` failed because:

```text
duplicate key value violates unique constraint "shipments_pkey"
Key (shipment_id)=(SHP-ORD-1012) already exists.
```

This was valuable because it exposed a real production-style issue rather than a test-only problem.

The correct design is to make shipment creation idempotent. For a one-shipment-per-order model, an appropriate pattern is:

```sql
INSERT INTO shipments (...)
VALUES (...)
ON CONFLICT (shipment_id)
DO NOTHING;
```

The workflow must not delete an existing shipment merely to make a test pass.

### Update Shipment Status

After the shipment exists, update it to:

```text
SHIPPED
```

### Update Order Shipment Status

The order becomes:

```text
shipment_status = SHIPPED
status = SHIPPED
```

### Customer Order Confirmation Email

The final customer notification includes the order, payment, shipment, courier, and tracking information.

The SMTP response was verified as:

```text
250 2.0.0 OK
```

which confirms the receiving mail server accepted the message.

---

## 7. FAILURE Branch

### Release Inventory

When payment fails, the reserved quantity is returned:

```text
available_stock = available_stock + quantity
reserved_stock  = reserved_stock - quantity
```

### Payment Failed Status

The order becomes:

```text
status = PAYMENT_FAILED
payment_status = FAILED
shipment_status = NOT_CREATED
```

No shipment should be created on this path.

### Workflow Logs

A failure log records the order ID, workflow step, status, and explanatory message.

### Payment Failure Notification

The customer receives a failure notification.

A pairing issue was encountered here because branch output was referenced with `.item`. The fix was to explicitly reference the single item with `.first()` where appropriate, for example:

```text
$('Payment Failed Status').first().json.order_id
```

and:

```text
$('Validate Webhook').first().json.email
```

This removes the ambiguous item-pairing error.

---

## 8. Real Razorpay Verification

The final integration test used:

```text
Razorpay Test Mode
        ↓
Payment Link
        ↓
Cloudflare Quick Tunnel
        ↓
n8n production webhook
```

### Successful Test

A real Test Mode payment completed for `ORD-1012`.

Observed result:

```text
Payment Completed
INR 15,000.00
```

The event reached n8n and the successful branch completed through customer email.

### Failed Test

A second normal order ID was used for the failed scenario. The order ID itself did not contain the word `FAIL`.

The failed payment event reached n8n after `payment.failed` was added to the Razorpay webhook subscription.

The failure branch released inventory, updated the order, logged the failure, and sent the notification.

---

## 9. Why Manual Test Payloads Were Used Earlier

Manual payloads were useful for developing and debugging individual nodes before connecting the real gateway.

They allowed verification of:

- expressions
- SQL queries
- IF conditions
- database updates
- email templates
- success/failure branching

But they are not the final integration.

The final verification used a real Razorpay Test Mode transaction and the production n8n webhook URL.

---

## 10. Cloudflare Quick Tunnel

The temporary tunnel command was:

```powershell
cloudflared tunnel --url http://localhost:5678
```

This exposed local n8n through a temporary `trycloudflare.com` hostname.

Important:

- keep the terminal running during the test
- the hostname is temporary
- restarting the Quick Tunnel normally creates a different hostname
- this is suitable for project verification, not permanent production hosting

---

## 11. Production Improvements

Before calling this design production-ready, add:

1. Razorpay webhook signature verification.
2. Database transactions for coupled order/inventory/payment updates.
3. Strong database constraints for state transitions.
4. Unique payment IDs and idempotency keys.
5. Idempotent shipment creation.
6. Retry-safe email handling.
7. Structured application logging.
8. Secret management instead of hard-coded credentials.
9. A permanent HTTPS webhook endpoint.
10. Monitoring and alerting for failed workflow executions.
11. Dead-letter/retry handling for events that cannot be processed immediately.
12. Clear reconciliation logic for payments that arrive late or out of order.

---

## 12. Final State Model

### Successful order

```text
status          = SHIPPED
payment_status  = SUCCESS
shipment_status = SHIPPED
```

### Failed order

```text
status          = PAYMENT_FAILED
payment_status  = FAILED
shipment_status = NOT_CREATED
```

### Payment duplicate

```text
payment_exists = true
→ do not record payment again
→ do not create another shipment
```

---

## 13. Final Verification Checklist

- [x] Database tables created
- [x] Order validation tested
- [x] Inventory availability tested
- [x] Inventory reservation tested
- [x] Razorpay Payment Link created
- [x] Payment Link stored
- [x] Real Razorpay Test Mode payment completed
- [x] Real Razorpay webhook reached n8n
- [x] Cloudflare temporary tunnel verified
- [x] Successful branch verified
- [x] Shipment flow verified
- [x] Success email verified
- [x] Failed payment webhook verified
- [x] Inventory release verified
- [x] Failed order status verified
- [x] Failure log verified
- [x] Failure email verified
- [x] Duplicate-payment protection implemented
- [x] Shipment duplicate issue identified and addressed as an idempotency requirement

---

## 14. Important Rule for Future Changes

Do not solve repeated webhook execution by deleting database records or changing order IDs just to make a test pass.

Instead, make every externally triggered operation safe to retry:

```text
Webhook retry
     ↓
Idempotency check
     ↓
Already processed?
   ├── YES → stop safely
   └── NO  → process once
```

That principle is the main reliability lesson from this project.
