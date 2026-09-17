# Project 5 — IT Incident Automation Test Cases

All 11 planned test cases passed successfully.

| # | Test | Expected |
|---:|---|---|
| 1 | P1 / 150 affected users | P1 + DevOps |
| 2 | P2 / 50 affected users | P2 + DevOps |
| 3 | P3 / 10 affected users | P3 + DevOps |
| 4 | P4 / development | P4 |
| 5 | Database | Database |
| 6 | Network | Network |
| 7 | Security | Security |
| 8 | Verification failure | REOPENED |
| 9 | Exactly 100 users | P1 |
| 10 | Exactly 25 users | P2 |
| 11 | Exactly 1 user | P3 |

## Test Method

Each scenario was triggered through the n8n Webhook using a PowerShell HTTP POST request.

## Overall Result

**11/11 tests passed successfully.**

The successful path reached `CLOSED`, while the verification failure path correctly reached `REOPENED`.
