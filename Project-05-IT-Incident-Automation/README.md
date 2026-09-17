# Project 5 — IT Incident Automation

## Overview

An n8n-based IT incident management automation for handling system alerts from detection through verified closure.

**Industry:** IT / DevOps / Cloud

## Incident Lifecycle

```text
System Alert
     ↓
Create Incident
     ↓
Determine Severity
     ↓
Assign Team
     ↓
Resolve Incident
     ↓
Verify
     ↓
Close / Reopen
```

## Objectives

- Receive an external system alert through a webhook.
- Create a unique incident record.
- Determine incident severity as P1, P2, P3, or P4.
- Assign the incident to the appropriate technical team.
- Record the resolution.
- Verify service health before closure.
- Reopen the incident when verification fails.
- Close the incident only after successful verification.
- Preserve the complete incident record throughout the workflow.

## Technologies

- n8n
- Webhook
- Code nodes
- Edit Fields (Set)
- IF node
- PowerShell
- JSON

## Workflow Architecture

![Full Workflow](screenshots/01-full-workflow.png)

## Node Documentation

### 1. Webhook

Receives the external system alert.

**Screenshot:** `screenshots/02-webhook-node.png`

![Webhook Node](screenshots/02-webhook-node.png)

Expected input contains fields such as:

```json
{
  "service": "Production API",
  "alert_type": "HTTP 500 Errors",
  "message": "Production API is returning 500 errors",
  "environment": "production",
  "affected_users": 150,
  "status": "firing"
}
```

### 2. Create Incident

Creates the initial incident record and generates a unique incident ID.

**Screenshot:** `screenshots/03-create-incident.png`

![Create Incident](screenshots/03-create-incident.png)

Initial incident state includes:

- Incident ID
- Service
- Alert type
- Message
- Environment
- Affected users
- Status
- Severity
- Assigned team
- Resolution
- Verification status
- Created timestamp

### 3. Determine Severity

Classifies the incident according to production impact and affected users.

**Screenshot:** `screenshots/04-determine-severity.png`

![Determine Severity](screenshots/04-determine-severity.png)

Severity rules:

| Condition | Severity |
|---|---|
| Production + 100+ affected users | P1 |
| Production + 25–99 affected users | P2 |
| Production + 1–24 affected users | P3 |
| Other/default conditions | P4 |

### 4. Assign Team

Routes incidents to the appropriate technical team.

**Screenshot:** `screenshots/05-assign-team.png`

![Assign Team](screenshots/05-assign-team.png)

Supported teams:

- DevOps
- Database
- Network
- Security
- IT Support fallback

### 5. Resolve Incident

Records the resolution and changes the incident to `RESOLVED`.

**Screenshot:** `screenshots/06-resolve-incident.png`

![Resolve Incident](screenshots/06-resolve-incident.png)

The incident remains open from a lifecycle perspective until verification succeeds.

### 6. Verification Check

Adds the service health result used to determine whether the incident can proceed to closure.

**Screenshot:** `screenshots/07-verification-check.png`

![Verification Check](screenshots/07-verification-check.png)

Current test configuration uses:

```text
service_health = UP
```

### 7. Service Healthy?

Checks whether the service health value is `UP`.

**Screenshot:** `screenshots/08-service-healthy.png`

![Service Healthy](screenshots/08-service-healthy.png)

The workflow has two branches:

```text
TRUE  → Verification Passed → Close Incident
FALSE → Verification Failed → REOPENED
```

### 8. Verification Passed

Records successful verification.

**Screenshot:** `screenshots/09-verification-passed.png`

![Verification Passed](screenshots/09-verification-passed.png)

Expected:

```text
verification_status = PASSED
```

### 9. Verification Failed

Handles a service that has not recovered.

**Screenshot:** `screenshots/10-verification-failed.png`

![Verification Failed](screenshots/10-verification-failed.png)

Expected:

```text
verification_status = FAILED
status = REOPENED
```

The incident must not be closed when verification fails.

### 10. Close Incident

Closes the incident only when verification has passed.

**Screenshot:** `screenshots/11-close-incident.png`

![Close Incident](screenshots/11-close-incident.png)

Expected:

```text
status = CLOSED
close_reason = Service recovery verified successfully
```

## Final Workflow Output

**Screenshot:** `screenshots/12-final-workflow-output.png`

![Final Workflow Output](screenshots/12-final-workflow-output.png)

Example successful result:

```json
{
  "incident_id": "INC-1787598194912",
  "service": "Production API",
  "alert_type": "HTTP 500 Errors",
  "severity": "P1",
  "assigned_team": "DevOps",
  "resolution": "Issue investigated and resolved by DevOps team.",
  "status": "CLOSED",
  "verification_status": "PASSED",
  "service_health": "UP",
  "close_reason": "Service recovery verified successfully"
}
```

## Testing

The workflow was tested end-to-end using PowerShell webhook requests.

See:

- `test-results/test-cases.md`
- Individual JSON result files in `test-results/`

### Test Coverage

| Test | Scenario | Expected Result |
|---:|---|---|
| 1 | P1 / 150 affected users | P1 + DevOps |
| 2 | P2 / 50 affected users | P2 + DevOps |
| 3 | P3 / 10 affected users | P3 + DevOps |
| 4 | P4 / development environment | P4 |
| 5 | Database incident | Database |
| 6 | Network incident | Network |
| 7 | Security incident | Security |
| 8 | Service health DOWN | REOPENED |
| 9 | Exactly 100 users | P1 |
| 10 | Exactly 25 users | P2 |
| 11 | Exactly 1 user | P3 |

**Result: 11/11 tests passed successfully.**

## Failure Handling

The workflow deliberately prevents premature closure:

```text
Resolved
   ↓
Verification
   ↓
Service Healthy?
   ├── YES → Passed → CLOSED
   │
   └── NO  → Failed → REOPENED
```

## Project Status

- [x] Alert intake
- [x] Incident creation
- [x] Severity determination
- [x] Team assignment
- [x] Incident resolution
- [x] Service verification
- [x] Failure/reopen path
- [x] Incident closure
- [x] End-to-end PowerShell testing
- [x] 11/11 test cases passed

## Screenshot Naming Convention

Capture screenshots later using the exact filenames listed in this README:

```text
01-full-workflow.png
02-webhook-node.png
03-create-incident.png
04-determine-severity.png
05-assign-team.png
06-resolve-incident.png
07-verification-check.png
08-service-healthy.png
09-verification-passed.png
10-verification-failed.png
11-close-incident.png
12-final-workflow-output.png
```

Place every screenshot inside the `screenshots/` folder.
