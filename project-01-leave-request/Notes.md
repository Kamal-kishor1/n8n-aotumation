# Project 01 — Detailed Notes

This document explains the project for a beginner or non-technical student. It explains what each node does, why it exists, what information it receives, what it produces, and how the nodes work together.

---

# 1. What Are We Building?

Imagine an employee wants to take leave.

Normally someone might have to:

1. Receive the request.
2. Check the employee.
3. Check the employee's leave balance.
4. Ask a manager for approval.
5. Update the leave balance.
6. Tell the employee the result.

n8n automates these repetitive steps.

The basic idea is:

> A workflow moves information from one step to another and performs an action at each step.

---

# 2. Basic n8n Concepts

## Workflow

The workflow is the complete automation.

For this project, it represents the employee leave process.

## Node

A node performs one task.

Examples:

- Receive form data
- Calculate dates
- Search Google Sheets
- Make a decision
- Send an email

## Connection

The line between nodes means:

> When this node finishes, send its result to the next node.

## Expression

An expression reads or calculates dynamic information.

Example:

```javascript
{{ $('On form submission').item.json['Employee ID'] }}
```

This means:

> Take the Employee ID from the form submission.

It is different from typing a fixed value such as `101`.

---

# 3. Complete Workflow

```text
On Form Submission
        ↓
Date & Time
        ↓
Get row(s) in sheet
        ↓
IF — enough leave?
   ┌────┴────┐
 FALSE      TRUE
   ↓          ↓
Reject      Approval
Email       Email
              ↓
             Wait
              ↓
             IF1
          ┌───┴───┐
        TRUE     FALSE
          ↓        ↓
     Update Row  Rejection
          ↓       Email
     Approval
       Email
```

There are two decisions:

1. Does the employee have enough leave?
2. If yes, does the manager approve?

---

# 4. Node 1 — On Form Submission

## Purpose

This is the trigger and starting point.

It waits for an employee to submit the leave form.

The form provides information such as:

```text
Employee ID
Employee Name
Email
Leave Type
Start Date
End Date
Reason
```

## Why it is needed

n8n needs a starting event. The form submission tells n8n:

> A new leave request has arrived. Start the workflow.

## Example input

```json
{
  "Employee ID": "101",
  "Employee Name": "John Wick",
  "Email": "john750wick030@gmail.com",
  "Leave Type": "Casual Leave",
  "Start Date": "2026-08-14",
  "End Date": "2026-08-20",
  "Reason": "Personal work"
}
```

## Important concept

The output of this node becomes available to later nodes.

---

# 5. Node 2 — Date & Time

## Purpose

This node handles the date-related calculation.

The form gives a start date and an end date. The workflow needs the number of requested leave days.

Example:

```text
Start Date = 14 August
End Date   = 20 August
```

The workflow produces the leave-day value used later in the balance check.

## Why it is needed

The business rule needs a number:

```text
Available balance = 12
Requested days = 6
```

The dates themselves are not enough for that comparison.

---

# 6. Node 3 — Get row(s) in sheet

## Purpose

This node gets the employee's trusted information from Google Sheets.

Google Sheets acts as a simple database for the project.

The workflow uses the Employee ID to find the correct employee.

Example:

```text
Employee ID = 101
```

Possible row:

| Employee ID | Employee Name | Email | Department | Leave Balance |
|---|---|---|---|---:|
| 101 | John Wick | john750wick030@gmail.com | Engineering | 12 |

## Why it is important

The employee should not provide their own leave balance in the form.

The balance should come from a trusted record.

---

# 7. Node 4 — IF: Leave Balance Check

## Purpose

This is the first business decision.

The rule is:

```text
Leave Balance >= Requested Leave Days
```

Example:

```text
12 >= 9
TRUE
```

The request can continue.

Another example:

```text
5 >= 9
FALSE
```

The request is rejected.

## Why an IF node is useful

The IF node allows n8n to behave like a decision-maker.

Instead of a person checking the rule manually, the automation checks it.

---

# 8. TRUE Branch — Enough Leave

When the first IF is TRUE, the employee has enough leave.

The workflow moves to the manager approval process.

```text
IF TRUE
   ↓
Approval Email
```

---

# 9. Node 5 — Send an Email

## Purpose

This node sends the leave request to the person who must review it.

It uses the SMTP credential configured in n8n.

Important fields include:

```text
From Email
To Email
Subject
Email Body
```

## Dynamic values

Instead of typing a fixed employee email, an expression can be used:

```javascript
{{ $('On form submission').item.json['Email'] }}
```

That means the workflow can work for different employees.

## SMTP credential

The credential gives n8n permission to send email.

For Gmail SMTP, the project used:

```text
Host: smtp.gmail.com
Port: 465
User: Gmail account
Password: Google App Password
```

Do not put passwords or App Passwords in project documentation.

## Reusing credentials

One SMTP credential can be selected by multiple email nodes. A separate credential is not required for every email node.

---

# 10. Node 6 — Wait

## Purpose

Manager approval does not happen immediately.

The Wait node pauses the workflow until an external request resumes it.

The logical process is:

```text
Send approval request
        ↓
      WAIT
        ↓
Manager responds
        ↓
Workflow continues
```

## Configuration used

```text
Resume: On Webhook Call
HTTP Method: GET
Authentication: None
Response Code: 200
```

When the execution reaches the Wait node, n8n creates a resume URL for that waiting execution.

Calling that URL resumes the workflow.

## Important testing detail

A Wait resume URL belongs to a particular execution.

If the execution has already finished, the old URL cannot be reused. Start a new execution and use its new Wait URL.

---

# 11. Approval Information

The approval request supplies a value such as:

```text
approved=true
```

or:

```text
approved=false
```

The Wait node receives this as query data.

Example:

```json
{
  "query": {
    "approved": "true"
  }
}
```

Notice the quotation marks around `true`.

That means the incoming value is text/string data.

This distinction matters when configuring an IF node.

---

# 12. Node 7 — IF1: Manager Decision

## Purpose

This IF checks the manager's decision.

The value is read with:

```javascript
{{ $json.query.approved }}
```

The comparison is:

```text
is equal to
true
```

## TRUE branch

The manager approved the request.

```text
IF1 TRUE
   ↓
Update Row
```

## FALSE branch

The manager rejected the request.

```text
IF1 FALSE
   ↓
Rejection Email
```

## Important lesson

During testing, the approval value arrived as a string:

```text
"true"
```

not as a Boolean:

```text
true
```

Understanding the difference between text and Boolean values is important in automation.

---

# 13. Node 8 — Update row in sheet

## Purpose

After approval, the employee's leave balance must be reduced.

Example:

```text
Old balance = 12
Approved leave = 9
New balance = 3
```

The calculation used is similar to:

```javascript
{{
  Number($('Get row(s) in sheet').item.json['Leave Balance'])
  -
  Number($('Date & Time').item.json.leaveDays.days)
}}
```

## Why Number() is used

Values from forms and spreadsheets may arrive as text.

For example:

```text
"12"
"9"
```

`Number()` converts them to numbers:

```text
Number("12") - Number("9")
= 3
```

## Matching the correct employee

The update uses Employee ID as the matching field:

```javascript
{{ $('On form submission').item.json['Employee ID'] }}
```

This tells Google Sheets which employee's row should be updated.

## Important business order

The system should update the record before telling the employee that the approval was completed:

```text
Update record
    ↓
Send confirmation
```

---

# 14. Node 9 — Send an Email1

## Purpose

This is the final approval notification.

After the balance is updated, the employee receives confirmation.

Example subject:

```text
Leave Request Approved - John Wick
```

Possible email information:

```text
Employee
Leave Type
Start Date
End Date
Leave Days
Remaining Balance
Status
```

---

# 15. Node 10 — Send an Email2

## Purpose

This handles a manager rejection.

The path is:

```text
Wait
 ↓
IF1
 ↓ FALSE
 ↓
Send an Email2
```

No leave balance is deducted.

The employee receives a rejection notification.

---

# 16. Node 11 — Send an Email3

## Purpose

This handles insufficient leave balance.

The path is:

```text
First IF
 ↓ FALSE
 ↓
Send an Email3
```

The manager approval process is skipped.

Example:

```text
Available balance = 3
Requested leave = 7
```

The workflow immediately rejects the request.

No leave balance is deducted.

---

# 17. Why There Are Two Rejection Situations

They are different business cases.

## Insufficient balance

The employee does not have enough available leave.

```text
3 available
7 requested
```

The system automatically rejects the request.

## Manager rejection

The employee has enough leave, but the manager does not approve it.

In that case the workflow sends a rejection notification but does not deduct the leave balance.

This distinction is important in real HR automation.

---

# 18. Google Sheets

Google Sheets is being used as a simple data store.

## Employee sheet

Typical fields:

| Employee ID | Employee Name | Email | Department | Leave Balance |
|---|---|---|---|---:|
| 101 | John Wick | john750wick030@gmail.com | Engineering | 12 |

## Leave request sheet

Typical fields:

| Request ID | Employee ID | Leave Type | Start Date | End Date | Leave Days | Status |
|---|---|---|---|---|---:|---|
| LR-001 | 101 | Casual Leave | 2026-08-14 | 2026-08-20 | 6 | Pending |

The exact columns should match the Google Sheet used by the workflow.

---

# 19. Credentials

## Google Sheets

The Google Sheets nodes require an authorized Google credential.

The credential is created once and can be reused by multiple Google Sheets nodes.

## SMTP

The email nodes use the SMTP credential.

The SMTP test returned:

```text
250 2.0.0 OK
```

This confirms Gmail accepted the message.

Never store passwords or App Passwords in README or notes files.

---

# 20. Testing and Debugging Lessons

## Wait URL

A Wait resume URL belongs to its waiting execution.

If n8n says:

```text
The execution has finished already
```

do not reuse that URL.

Start a fresh workflow execution and use the new Wait URL.

## IF data types

Incoming URL query data may look like:

```json
"approved": "true"
```

The quotes indicate text.

This is different from:

```json
"approved": true
```

which is a Boolean.

Always inspect the actual node output before deciding how to configure a condition.

## Node not executed

If n8n says:

```text
Node was not executed.
The execution took a different path.
```

it does not necessarily mean the node is broken.

It usually means an earlier IF sent the execution through another branch.

---

# 21. Complete Example

Suppose:

```text
Employee = John Wick
Available Leave = 12
Requested Leave = 9
```

The workflow does:

```text
1. Employee submits form
2. Dates are processed
3. Employee 101 is found
4. Balance = 12
5. Requested = 9
6. 12 >= 9 → TRUE
7. Approval email sent
8. Workflow waits
9. Manager approves
10. IF1 → TRUE
11. Google Sheet balance becomes 3
12. Approval email sent
```

Final result:

```text
Leave Balance = 3
Request = Approved
Employee notified = Yes
```

---

# 22. What This Project Teaches

This project contains several patterns used in professional automation.

## Trigger

Something starts the process.

```text
Form submission
```

## Data lookup

Retrieve information from a data source.

```text
Google Sheets
```

## Business rule

Automatically check a rule.

```text
Balance >= Requested Days
```

## Human-in-the-loop

A human makes a decision.

```text
Manager approval
```

## Waiting

The workflow pauses until an event occurs.

```text
Wait
```

## Data update

Change stored information.

```text
Update Row
```

## Notification

Tell users what happened.

```text
Email
```

These patterns can be reused in many industries.

---

# 23. Beginner Mental Model

Think of the workflow as an HR employee:

```text
Form
=
Employee provides information

Google Sheet
=
HR records

IF
=
HR checks a rule

Email
=
HR sends a message

Wait
=
HR waits for the manager

Second IF
=
HR checks the manager's decision

Update Row
=
HR changes the record
```

This mental model makes n8n easier to understand.

---

# 24. Project Completion Checklist

- [x] n8n running in Docker
- [x] Leave form created
- [x] Leave request received
- [x] Leave days calculated
- [x] Employee lookup created
- [x] Leave balance check created
- [x] Insufficient-balance path created
- [x] Approval email created
- [x] SMTP credential configured
- [x] Wait node configured
- [x] Manager decision processed
- [x] Approved balance updated
- [x] Approval email tested
- [x] Manager rejection email created
- [x] Insufficient-balance email created
- [x] Workflow tested
- [x] Google Sheets tested
- [x] Email delivery tested
- [ ] Final screenshots added
- [ ] Exported workflow JSON saved

---

# 25. Final Status

**Project 01 — Leave Request Automation is completed and working.**

The remaining project-finalization tasks are:

1. Keep the exported workflow JSON in the project folder.
2. Add final screenshots.
3. Keep this README and notes file with the project.
