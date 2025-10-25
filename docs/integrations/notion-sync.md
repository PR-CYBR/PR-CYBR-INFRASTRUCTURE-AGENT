# Notion Sync Integration

## Overview

The Notion Sync integration keeps PR-CYBR infrastructure records aligned with the source-of-truth Notion workspace. The automation reads structured pages from a designated database, converts the content into infrastructure change requests, and writes operational status updates back to Notion.

## Required Secrets

| Variable | Location | Description |
| --- | --- | --- |
| `NOTION_API_KEY` | Terraform Cloud (Environment) | Notion internal integration token with read/write access to the workspace. |
| `NOTION_DATABASE_ID` | Terraform Cloud (Environment) | Identifier of the database that stores infrastructure tasks to be synchronized. |
| `NOTION_SYNC_WEBHOOK_SECRET` | Terraform Cloud (Environment) | Shared secret used to validate webhook requests sent from the PR-CYBR automation platform. |
| `NOTION_SYNC_SCHEDULE` | Terraform Cloud (Terraform) | CRON expression (UTC) defining how frequently the sync job runs. |

> **Note:** All secrets must be stored as Terraform Cloud variables so they remain outside of the public repository.

## Configure Terraform Cloud Workspace Variables

1. Sign in to Terraform Cloud and open the workspace linked to `PR-CYBR-INFRASTRUCTURE-AGENT`.
2. Navigate to the **Variables** tab and ensure the **Environment Variables** section is selected.
3. Add the following entries:
   - `NOTION_API_KEY` – mark as **Sensitive** and paste the Notion integration token.
   - `NOTION_DATABASE_ID` – mark as **Sensitive** and paste the database UUID without dashes.
   - `NOTION_SYNC_WEBHOOK_SECRET` – mark as **Sensitive** and paste the webhook signing secret shared with the automation platform.
4. Switch to the **Terraform Variables** section and add `NOTION_SYNC_SCHEDULE` with the desired CRON expression (for example, `0 * * * *` for hourly).
5. Click **Save Variable** after each entry to persist the configuration.
6. Re-run the Terraform workspace or allow the next scheduled apply so the new variables become available to the Notion Sync automation.

## Verifying the Integration

- Trigger a manual Terraform run to confirm the variables are picked up without errors.
- Review the automation logs to ensure the Notion database entries are read and status updates are written successfully.
- Validate that webhook callbacks signed with `NOTION_SYNC_WEBHOOK_SECRET` are accepted and any unsigned requests are rejected.
