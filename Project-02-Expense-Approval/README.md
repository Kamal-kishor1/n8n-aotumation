# Project 02 --- Expense Approval Automation

Industry: Finance / Corporate Operations

## Overview

This project automates employee expense approval.

Architecture:

Employee Expense → Validation → Amount Check → Auto Approval OR Manager
Approval → Database Record → Notification

------------------------------------------------------------------------

# Workflow 1 --- Beginner Version

Technology:

-   n8n
-   Webhook Trigger
-   JSON Input
-   Google Sheets
-   Gmail

## Flow

Webhook → Validate Expense → Amount Check → Auto Approve / Manager
Approval → Record Result

## Screenshots

Save screenshots with these names:

![Beginner Workflow](screenshots/beginner_workflow_complete.png)

![Webhook Node](screenshots/beginner_webhook_node.png)

![Validation Node](screenshots/beginner_validation_node.png)

![Amount Check Node](screenshots/beginner_amount_check_node.png)

![Auto Approval Node](screenshots/beginner_auto_approve_node.png)

![Manager Approval Email
Node](screenshots/beginner_manager_email_node.png)

![Google Sheet Record](screenshots/beginner_google_sheet_result.png)

------------------------------------------------------------------------

# Workflow 2 --- Professional Industrial Version

Technology:

-   n8n
-   Google Forms
-   PostgreSQL
-   Slack
-   Webhook API

## Workflow 1: Expense Processing

Google Form → Google Sheets Trigger → Normalize Data → Validation →
PostgreSQL Insert → Amount Check

Branches:

Small Expense: Auto Approve → PostgreSQL Update

Large Expense: Manager Approval → Slack Notification

## Screenshots

Save screenshots with these names:

![Industrial Complete
Workflow](screenshots/professional_complete_workflow.png)

![Google Sheet
Trigger](screenshots/professional_google_sheet_trigger.png)

![Normalize Data Node](screenshots/professional_normalize_data_node.png)

![PostgreSQL
Insert](screenshots/professional_postgresql_insert_node.png)

![Amount Check](screenshots/professional_amount_check_node.png)

![Slack
Notification](screenshots/professional_slack_notification_node.png)

------------------------------------------------------------------------

# Workflow 2: Manager Approval Response API

Flow:

Webhook → Decision Check → PostgreSQL Update → Respond to Webhook

Screenshots:

![Approval Webhook](screenshots/manager_webhook_node.png)

![Decision Check](screenshots/manager_decision_check_node.png)

![Approve Update](screenshots/manager_approve_update_node.png)

![Reject Update](screenshots/manager_reject_update_node.png)

![Webhook Response](screenshots/respond_to_webhook_node.png)

------------------------------------------------------------------------

# Database

PostgreSQL table:

expenses

Fields:

-   id
-   employee_name
-   department
-   expense_type
-   amount
-   description
-   status
-   approval_type
-   approved_by
-   rejection_reason
-   created_at

------------------------------------------------------------------------

# Testing Results

Test cases:

1.  Small expense → Automatic Approval
2.  Large expense → Manager Approval
3.  Invalid expense → Rejection
4.  Manager Approve → Database Update
5.  Manager Reject → Database Update
