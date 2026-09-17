# Project 4 — Order Processing Automation

**Industry:** E-commerce / Order Fulfillment  
**Platform:** n8n (Docker)  
**Database:** PostgreSQL 16  
**Payment Gateway:** Razorpay Payments — Test Mode  
**Public Webhook Exposure:** Cloudflare Quick Tunnel (temporary)

## Project Status

**Functional implementation: COMPLETE and verified.**

Both payment outcomes were tested through the real integration path:

- Razorpay Test Mode → Cloudflare Quick Tunnel → n8n production webhook → SUCCESS branch
- Razorpay Test Mode → Cloudflare Quick Tunnel → n8n production webhook → FAILURE branch

The project is documented as a learning/portfolio implementation. The Cloudflare Quick Tunnel is temporary and must not be treated as the production hosting architecture.

## Architecture

```text
Workflow A — Database Setup
        ↓
Workflow B — Order Creation
        ↓
Order validation
        ↓
Inventory check
        ↓
Reserve inventory
        ↓
Create Razorpay Payment Link
        ↓
Store payment link
        ↓
Customer pays
        ↓
Razorpay webhook
        ↓
Workflow C — Payment Processing
   ┌───────────────┴────────────────┐
   │                                │
SUCCESS                            FAILED
   ↓                                ↓
Record payment                 Release inventory
   ↓                                ↓
Update order                   Mark payment failed
   ↓                                ↓
Create/Reuse shipment          Write workflow log
   ↓                                ↓
Update shipment                Failure email
   ↓
Update order shipment status
   ↓
Customer confirmation email
```

## Verified Results

### SUCCESS

Verified with a real Razorpay Test Mode Payment Link for `ORD-1012`:

- Payment completed: **SUCCESS**
- Payment was received by the n8n production webhook
- Order became `PAID`
- Shipment reached `SHIPPED`
- Customer confirmation email was accepted by Gmail (`250 2.0.0 OK`)

### FAILURE

Verified with a normal order ID (no special `FAIL` identifier):

- Razorpay failed-payment webhook was received
- Failed branch executed
- Inventory was released
- Order became `PAYMENT_FAILED`
- Payment became `FAILED`
- Workflow log was written
- Failure notification email executed after fixing n8n item pairing

## Important Permanent Fixes

### 1. Duplicate shipment protection

The real SUCCESS test initially exposed:

```text
duplicate key value violates unique constraint "shipments_pkey"
Key (shipment_id)=(SHP-ORD-1012) already exists.
```

This was not a temporary test workaround. It exposed a real idempotency requirement: payment webhooks may be delivered more than once.

The shipment creation logic must therefore be idempotent and must not create a second shipment for the same order. Prefer `ON CONFLICT (shipment_id) DO NOTHING` when the business rule is one shipment per order.

### 2. n8n branch item pairing

The failure notification initially used expressions such as:

```text
$('Payment Failed Status').item.json.order_id
```

After branching, n8n could not determine the paired item. The expression was changed to an explicit single-item reference:

```text
$('Payment Failed Status').first().json.order_id
```

The same approach was used for the Validate Webhook data used by the failure email.

## Screenshot Naming & Evidence

All screenshot filenames are intentionally based on the **node name or test purpose** so the project can be reproduced and documented consistently.

If a screenshot file is currently empty, it is a placeholder for a later screenshot. Do not rename the file; replace it with the actual screenshot using the same filename.

### Workflow A — Database Setup

| # | Node | Screenshot |
|---|---|---|
| 01 | Database Setup / Workflow Start | `screenshots/01-database-setup.png` |
| 02 | Create Order Table | `screenshots/02-create-order-table.png` |
| 03 | Create Inventory Table | `screenshots/03-create-inventory-table.png` |
| 04 | Create Payments Table | `screenshots/04-create-payments-table.png` |
| 05 | Create Shipments Table | `screenshots/05-create-shipments-table.png` |
| 06 | Create Workflow Logs | `screenshots/06-create-workflow-logs.png` |
| 07 | Seed Inventory | `screenshots/07-seed-inventory.png` |
| 08 | Verify Tables | `screenshots/08-verify-tables.png` |

### Workflow B — Order Creation

| # | Node | Screenshot |
|---|---|---|
| 09 | Order Webhook | `screenshots/09-order-webhook.png` |
| 10 | Validation Check | `screenshots/10-validation-check.png` |
| 11 | Validation Services | `screenshots/11-validation-services.png` |
| 12 | Order Validation | `screenshots/12-order-validation.png` |
| 13 | Create Order | `screenshots/13-create-order.png` |
| 14 | Inventory Check | `screenshots/14-inventory-check.png` |
| 15 | Inventory Available | `screenshots/15-inventory-available.png` |
| 16 | Reserve Inventory | `screenshots/16-reserve-inventory.png` |
| 17 | Merge | `screenshots/17-merge.png` |
| 18 | Create Razorpay Payment Link | `screenshots/18-create-razorpay-payment-link.png` |
| 19 | Store Payment Link | `screenshots/19-store-payment-link.png` |
| 20 | Customer Payment Notification | `screenshots/20-customer-payment-notification.png` |

### Workflow C — Payment Processing

| # | Node | Screenshot |
|---|---|---|
| 21 | Razorpay Payment Webhook | `screenshots/21-razorpay-payment-webhook.png` |
| 22 | Validate Webhook | `screenshots/22-validate-webhook.png` |
| 23 | Check Payment Already Processed | `screenshots/23-check-payment-already-processed.png` |
| 24 | Payment Already Processed | `screenshots/24-payment-already-processed.png` |
| 25 | Ignore Duplicate Payment | `screenshots/25-ignore-duplicate-payment.png` |
| 26 | Payment Successful | `screenshots/26-payment-successful.png` |
| 27 | Record Payment | `screenshots/27-record-payment.png` |
| 28 | Update Order Payment | `screenshots/28-update-order-payment-success.png` |
| 29 | Create Shipment | `screenshots/29-create-shipment-duplicate-error.png` |
| 30 | Update Shipment Status | `screenshots/30-update-shipment-status.png` |
| 31 | Update Order Shipment Status | `screenshots/31-update-order-shipment-status.png` |
| 32 | Customer Order Confirmation Email | `screenshots/32-customer-order-confirmation-email-success.png` |
| 33 | Release Inventory | `screenshots/33-release-inventory.png` |
| 34 | Payment Failed Status | `screenshots/34-payment-failed-status-and-logs.png` |
| 35 | Record Failed Payment | `screenshots/35-record-failed-payment.png` |
| 36 | Workflow Logs | `screenshots/36-workflow-logs.png` |
| 37 | Payment Failed Email | `screenshots/37-payment-failed-email-error.png` |

### Integration / Test Evidence

| # | Test | Screenshot |
|---|---|---|
| 38 | Successful Razorpay Payment | `screenshots/38-successful-payment-test.png` |
| 39 | Failed Razorpay Payment | `screenshots/39-failed-payment-test.png` |
| 40 | Duplicate Webhook Test | `screenshots/40-duplicate-webhook-test.png` |
| 41 | Insufficient Inventory Test | `screenshots/41-insufficient-inventory-test.png` |
| 42 | Final Database State | `screenshots/42-final-database-state.png` |
| 43 | Cloudflare Quick Tunnel | `screenshots/cloudflare-quick-tunnel.png` |
| 44 | Workflow Published | `screenshots/workflow-published.png` |

### Currently Captured Evidence

The package contains captured screenshots for the most important verification points, including the Razorpay checkout, Razorpay webhook creation, Cloudflare tunnel, published workflow, successful payment, successful order-payment update, shipment duplicate issue, success email, and failure-email pairing issue.

## Test Payloads

The JSON files under `test-payloads/` are **manual/offline test inputs only**. They are not substitutes for the real Razorpay webhook.

Real integration verification used Razorpay Test Mode and the production n8n webhook URL exposed through the temporary Cloudflare Quick Tunnel.

## Temporary Tunnel

The project was verified using:

```text
cloudflared tunnel --url http://localhost:5678
```

The generated `trycloudflare.com` hostname is temporary and changes when the Quick Tunnel is restarted. Keep the terminal running while testing.

Do not use a Quick Tunnel as the final production deployment strategy.

## Security

Never commit:

- Razorpay API keys
- Razorpay webhook secrets
- SMTP passwords/app passwords
- n8n encryption keys
- Cloudflare credentials
- `.env` files
- database passwords

For production, validate Razorpay webhook signatures before processing payment events.

## Project Structure

```text
project-4-order-processing/
├── README.md
├── Notes.md
├── .gitignore
├── workflow/
├── database/
├── screenshots/
├── test-payloads/
└── docs/
```
