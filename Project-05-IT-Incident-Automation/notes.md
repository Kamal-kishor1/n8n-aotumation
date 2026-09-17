# Project 5 — IT Incident Automation Notes

## Purpose

This file contains detailed learning notes for the project.

## 1. Webhook

The Webhook is the entry point for the automation. An external monitoring system can send an HTTP POST request containing alert information.

Typical input:

- service
- alert_type
- message
- environment
- affected_users
- status

## 2. Create Incident

The Code node converts the alert into an incident record.

A unique incident ID is generated in the form:

`INC-<timestamp>`

Initial lifecycle values:

- status = OPEN
- severity = PENDING
- assigned_team = PENDING
- verification_status = PENDING

## 3. Determine Severity

Severity is calculated from production impact and affected users.

Rules:

- 100 or more affected users in production → P1
- 25–99 affected users in production → P2
- 1–24 affected users in production → P3
- Other conditions → P4

## 4. Assign Team

Routing is based on service and alert type.

- API/application/HTTP 500 → DevOps
- Database/SQL → Database
- Network/connectivity → Network
- Security/unauthorized → Security
- No recognized match → IT Support

## 5. Resolve Incident

The assigned team is recorded in the resolution message.

The incident becomes:

`RESOLVED`

Verification remains pending until the health check completes.

## 6. Verification

The workflow checks service health before allowing closure.

`UP` means the service is considered recovered.

`DOWN` means verification fails.

## 7. Reopen Path

If verification fails:

- verification_status = FAILED
- status = REOPENED

This prevents the workflow from falsely closing an incident whose service has not recovered.

## 8. Close Incident

The Close Incident node checks that verification has passed.

Only:

`verification_status = PASSED`

can result in:

`status = CLOSED`

## 9. Data Preservation

Every downstream Code node must preserve the existing incident object using the spread operator:

```javascript
{
  ...incident,
  new_field: value
}
```

This is important because replacing `$json` completely can accidentally remove earlier incident fields.

## 10. External Testing

PowerShell was used to send HTTP POST requests to the n8n Webhook.

This validates the workflow from outside n8n instead of relying only on manually entered test data.

## 11. Testing Strategy

Testing covered:

- Severity levels
- Team routing
- Boundary conditions
- Successful verification
- Failed verification
- Reopening
- Final closure
- Complete data preservation

## 12. Final Learning Outcome

This project demonstrates a basic IT/DevOps incident lifecycle:

Alert → Incident → Severity → Assignment → Resolution → Verification → Closure/Reopen.

It also demonstrates conditional workflow design, data transformation, failure handling, and external API triggering in n8n.
