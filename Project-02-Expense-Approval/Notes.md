# Project 02 Notes --- Expense Approval Automation

## Beginner Workflow

### Webhook Node

Receives expense JSON input.

Example fields:

-   employee
-   department
-   expense_type
-   amount
-   description

### Validation Node

Checks:

-   Employee exists
-   Amount exists
-   Amount greater than zero

### Amount Check Node

Business rule:

Amount \<= 5000: Automatic approval

Amount \> 5000: Manager approval

## Professional Workflow

### Google Sheets Trigger

Acts as external input source.

### PostgreSQL

Stores expense records permanently.

### Slack

Sends manager notification.

### Manager Approval API

Allows external approval decision.

APPROVED: Updates status to APPROVED

REJECTED: Updates status to REJECTED
