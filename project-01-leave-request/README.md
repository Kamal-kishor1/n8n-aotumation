# Project 01 — Leave Request Automation

## Project Overview

This project is an HR leave-request automation built with n8n, Google Sheets, and email.

### Business Flow

```text
Employee submits leave form
        ↓
Calculate leave days
        ↓
Find employee
        ↓
Check leave balance
   ┌────┴────┐
 Enough    Not enough
   ↓           ↓
Approval     Reject
   ↓
Wait for manager
   ↓
Manager decision
 ┌──┴──┐
Yes    No
 ↓      ↓
Update  Reject
balance email
 ↓
Approval email
```

## Industry

**Human Resources (HR)**

The same automation pattern can be adapted for expense approvals, purchase requests, access requests, and other internal business processes.

## Technologies

- n8n — workflow automation
- Docker — local n8n runtime
- Google Sheets — employee/request data
- Gmail SMTP — email notifications
- Wait/Webhook — approval waiting mechanism

## Main Workflow

1. Receive leave request.
2. Calculate requested leave days.
3. Find the employee in Google Sheets.
4. Compare available balance with requested days.
5. Reject immediately when balance is insufficient.
6. Send an approval request when balance is sufficient.
7. Wait for the manager's decision.
8. Check the decision.
9. Deduct approved leave days from the employee's balance.
10. Send the final notification.

## Project Files

```text
project-01-leave-request/
├── README.md
├── notes.md
├── leave-request-automation.json
└── screenshots/
```

- `README.md` — project overview, workflow, verification, and screenshot index.
- `notes.md` — detailed beginner-friendly explanation of every node and configuration.
- `leave-request-automation.json` — exported n8n workflow.
- `screenshots/` — build and testing evidence.

---

# 4. Screenshot Documentation

Save screenshots inside:

```text
project-01-leave-request/screenshots/
```

Use the **exact filenames below** so the README remains organized.

| # | Screenshot filename | What to capture |
|---|---|---|
| 01 | `01-workflow-overview.png` | Complete n8n workflow showing all nodes and connections |
| 02 | `02-form-trigger.png` | On Form Submission node configuration |
| 03 | `03-form-output.png` | Test output showing submitted employee/leave data |
| 04 | `04-date-time-node.png` | Date & Time node configuration |
| 05 | `05-employee-sheet.png` | Google Sheets employee data used by the workflow |
| 06 | `06-get-employee-row.png` | Get row(s) in sheet node configuration |
| 07 | `07-leave-balance-if.png` | First IF node and its leave-balance condition |
| 08 | `08-insufficient-balance-email.png` | Email node for insufficient leave balance |
| 09 | `09-approval-email.png` | Manager approval email node |
| 10 | `10-smtp-credential.png` | SMTP credential configuration; hide/remove passwords or secrets |
| 11 | `11-wait-node.png` | Wait node configuration |
| 12 | `12-wait-webhook-output.png` | Wait node test data showing approval query |
| 13 | `13-manager-decision-if.png` | Second IF node checking manager approval |
| 14 | `14-update-leave-balance.png` | Google Sheets Update Row node configuration |
| 15 | `15-approved-email.png` | Final approval email node |
| 16 | `16-rejected-email.png` | Manager-rejection email node |
| 17 | `17-google-sheet-updated.png` | Google Sheet showing the updated leave balance |
| 18 | `18-approved-execution.png` | Successful approved workflow execution |
| 19 | `19-rejected-execution.png` | Successful manager-rejection execution |
| 20 | `20-insufficient-balance-execution.png` | Successful insufficient-balance execution |
| 21 | `21-email-success.png` | Successful email execution/output |
| 22 | `22-final-workflow.png` | Final clean workflow after testing |

## Screenshot References

The README will use the following structure when screenshots are added:

### 01 — Workflow Overview

![Complete workflow](screenshots/01-workflow-overview.png)

### 02 — Form Trigger

![Form trigger](screenshots/02-form-trigger.png)

### 03 — Form Output

![Form output](screenshots/03-form-output.png)

### 04 — Date & Time Node

![Date and time node](screenshots/04-date-time-node.png)

### 05 — Employee Sheet

![Employee sheet](screenshots/05-employee-sheet.png)

### 06 — Get Employee Row

![Get employee row](screenshots/06-get-employee-row.png)

### 07 — Leave Balance IF

![Leave balance IF](screenshots/07-leave-balance-if.png)

### 08 — Insufficient Balance Email

![Insufficient balance email](screenshots/08-insufficient-balance-email.png)

### 09 — Approval Email

![Approval email](screenshots/09-approval-email.png)

### 10 — SMTP Credential

![SMTP credential](screenshots/10-smtp-credential.png)

> Never include passwords, App Passwords, API keys, tokens, cookies, or other secrets in screenshots.

### 11 — Wait Node

![Wait node](screenshots/11-wait-node.png)

### 12 — Wait Webhook Output

![Wait webhook output](screenshots/12-wait-webhook-output.png)

### 13 — Manager Decision IF

![Manager decision IF](screenshots/13-manager-decision-if.png)

### 14 — Update Leave Balance

![Update leave balance](screenshots/14-update-leave-balance.png)

### 15 — Approved Email

![Approved email](screenshots/15-approved-email.png)

### 16 — Rejected Email

![Rejected email](screenshots/16-rejected-email.png)

### 17 — Updated Google Sheet

![Updated Google Sheet](screenshots/17-google-sheet-updated.png)

### 18 — Approved Execution

![Approved execution](screenshots/18-approved-execution.png)

### 19 — Rejected Execution

![Rejected execution](screenshots/19-rejected-execution.png)

### 20 — Insufficient Balance Execution

![Insufficient balance execution](screenshots/20-insufficient-balance-execution.png)

### 21 — Email Success

![Email success](screenshots/21-email-success.png)

### 22 — Final Workflow

![Final workflow](screenshots/22-final-workflow.png)

## Data

### Employee sheet

Typical fields:

- Employee ID
- Employee Name
- Email
- Department
- Leave Balance

### Leave request

Typical fields:

- Request ID
- Employee ID
- Employee Name
- Email
- Leave Type
- Start Date
- End Date
- Leave Days
- Reason
- Status
- Submitted At

## Approval Rule

```text
Available Leave Balance >= Requested Leave Days
```

Example:

```text
12 >= 9 → TRUE
```

After approval:

```text
New Balance = Old Balance - Approved Leave Days
12 - 9 = 3
```

## Verification

The workflow was tested for form submission, date calculation, employee lookup, balance checking, approval waiting, approval routing, Google Sheets update, rejection paths, and email delivery.

The SMTP test returned:

```text
250 2.0.0 OK
```

## Learning Outcomes

This project demonstrates:

- Triggers
- Data passing between nodes
- Google Sheets integration
- Expressions
- Business rules
- IF branching
- Human approval
- Waiting/resuming executions
- Database-style updates
- Email notifications
- Testing and debugging

## Status

**Project 01 — Leave Request Automation: Completed and working.**

Final documentation tasks:

- Add final screenshots.
- Keep the exported workflow JSON with the project.
