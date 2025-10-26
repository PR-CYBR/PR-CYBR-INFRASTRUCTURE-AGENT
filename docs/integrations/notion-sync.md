# Notion Content Synchronization

## Current State

The integration currently supports exporting structured data from GitHub into Notion workspaces so that field teams can curate SOPs, tasking, and operational metadata alongside live infrastructure state. GitHub remains the system of record, while Notion surfaces a user-friendly, collaborative view for day-to-day execution. Synchronization today is a one-way push into Notion that is triggered manually as part of release workflows.

---

## Planned Enhancements

The next iteration of the integration focuses on enabling two-way synchronization so operational edits authored inside Notion can flow back into version-controlled Markdown and configuration assets in GitHub. This capability is essential for capturing institutional knowledge developed during live operations without breaking our GitOps practices.

### Future Notion → GitHub Synchronization Flow

1. **Trigger Strategy**  
   - **Scheduled Harvesting:** A scheduled job (GitHub Actions workflow or Terraform-scheduled container task) will poll Notion on a fixed cadence (e.g., every 15 minutes) using the `search` and `databases.query` endpoints. The job will request pages updated since the last successful run, leveraging stored sync cursors.  
   - **Webhook Receiver:** In parallel, a lightweight webhook receiver (serverless function or containerized FastAPI service) will subscribe to Notion's `page.updated` events. Each event queues a delta for processing, ensuring near-real-time propagation when available while the scheduled job provides redundancy if a webhook delivery is missed.

2. **Delta Handling Pipeline**  
   - The processor normalizes incoming Notion page payloads into the existing schema (front matter, Markdown content blocks, and metadata).  
   - A change detector compares the Notion revision timestamp and content hash against the last committed Git revision recorded for that page.  
   - Only deltas with a newer Notion revision proceed to GitHub reconciliation, minimizing unnecessary commits.

3. **Conflict Resolution**  
   - **Parallel Edits:** When both GitHub and Notion have diverged since the last sync, the pipeline flags the record and opens a pull request containing both versions plus a generated diff comment summarizing conflicts.  
   - **Authoritative Source Selection:** Operations leadership can configure per-database policies (Notion-wins, GitHub-wins, or manual review). For manual review, the PR requests reviewers from the owning team to resolve conflicts before merge.  
   - **Audit Trail:** All updates include commit metadata linking back to the Notion page ID, editor, and revision timestamp so that resolution decisions remain traceable.

### Supporting Infrastructure and Secrets

- **Webhook Receiver Service**  
  - Deployed via Terraform with an HTTPS endpoint, backed by either AWS Lambda + API Gateway or an Azure Function App.  
  - Requires a `NOTION_WEBHOOK_SECRET` for validating signatures and an `ENCRYPTION_KEY` (managed in Terraform Cloud workspace variables) for at-rest storage of pending deltas.

- **Scheduler Configuration**  
  - GitHub Actions workflow authenticated with `NOTION_INTEGRATION_TOKEN` (Least-privilege bot) and `GITHUB_TOKEN` with content write scope.  
  - Stores the last successful sync cursor in an encrypted GitHub Actions secret (`NOTION_SYNC_CURSOR_STATE`) or in Terraform-managed secret storage (e.g., AWS SSM parameter) referenced by the workflow.

- **Queue & Persistence Layer**  
  - Optional message queue (SQS/Service Bus) buffers webhook events for idempotent processing. Credentials (`QUEUE_ACCESS_KEY`, `QUEUE_SECRET_KEY`) are injected from Terraform Cloud environment variables.  
  - Metadata state is persisted in a managed database or key-value store (DynamoDB/Cosmos DB) keyed by the internal content ID.

### ID Mapping for Reverse Updates

To reliably apply Notion edits back into GitHub, every synchronized document maintains a durable ID mapping record:

- **Composite Identifier:** Each Notion page stores the corresponding GitHub path and commit SHA in custom properties. Conversely, GitHub front matter includes the Notion page ID and last Notion revision.
- **Mapping Registry:** The integration writes a mapping entry `{notion_page_id → github_file_path}` into the shared persistence layer during the initial sync.  
- **Reverse Lookup Usage:** When a webhook delivers a Notion update, the processor looks up the GitHub file path using the Notion page ID. If the mapping is missing (e.g., new page), the processor triggers provisioning logic to generate a target path and open a draft PR for human classification.
- **Consistency Checks:** During each sync cycle, the job cross-validates that the IDs stored in Notion and GitHub match the registry. Any drift is surfaced as an alert in the CI/CD pipeline and prevents automated merges until resolved.

These mappings, secrets, and infrastructure components ensure that reverse synchronization is authenticated, traceable, and resilient, while aligning with PR-CYBR's Terraform-managed environment variable strategy and advanced branching workflows modeled after the spec-bootstrap repository.
