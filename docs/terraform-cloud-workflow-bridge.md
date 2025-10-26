# Terraform Cloud Workflow Bridge (Template A-04)

This repository uses the Terraform Cloud–GitHub workflow bridge to keep sensitive values in Terraform Cloud while GitHub Actions only uploads configuration and triggers runs.

## Workflow Overview

- **Speculative Plans**: Pull requests targeting the `impl` or `dev` branches run the `speculative-plan` job in [`.github/workflows/terraform-cloud-workflow-bridge.yml`](../.github/workflows/terraform-cloud-workflow-bridge.yml). The job uploads the Terraform configuration, creates a speculative plan-only run, and posts the summary back to the pull request.
- **Apply Runs**: Pushes to `dev` (and manual workflow dispatches) upload the same configuration and create an apply run. If Terraform Cloud marks the run as confirmable, the workflow auto-applies it.
- **Secrets Management**: Provider credentials and other sensitive inputs belong in Terraform Cloud workspace variables. GitHub only stores the API token that allows it to request runs.

## Required Configuration

Set the following repository secret and variables under **Settings → Secrets and variables → Actions**:

| Name | Type | Purpose |
|------|------|---------|
| `TF_API_TOKEN` | Secret | Terraform Cloud API token with permissions to manage runs. |
| `TF_CLOUD_ORGANIZATION` | Variable | Terraform Cloud organization slug. |
| `TF_WORKSPACE` | Variable | Workspace that should receive apply runs. |
| `TF_SPECULATIVE_WORKSPACE` | Variable (optional) | Workspace dedicated to pull request plans; defaults to `TF_WORKSPACE` when omitted. |
| `TF_CONFIG_DIRECTORY` | Variable (optional) | Relative path to Terraform configuration. Defaults to `terraform/`. |

## Terraform Configuration Layout

Place Terraform source files under [`terraform/`](../terraform/README.md) or the directory referenced by `TF_CONFIG_DIRECTORY`. The workflow uploads everything within that directory on every run, so keep it limited to Terraform configuration.

## Trigger Matrix

| Event | Branch Target | Job | Result |
|-------|---------------|-----|--------|
| `pull_request` | `impl`, `dev` | `speculative-plan` | Creates a speculative plan and comments on the PR. |
| `push` | `dev` | `apply-run` | Uploads configuration and triggers an apply run. |
| `workflow_dispatch` | Any | `apply-run` | Manually trigger an apply run using the currently configured branch contents. |

## Operational Notes

- The workflow enforces that required variables are present before attempting to call Terraform Cloud, providing fast feedback if the repository configuration is incomplete.
- Runs are serialized through the `concurrency` setting so multiple pushes do not create conflicting Terraform Cloud runs.
- Review the plan comment on each pull request to confirm Terraform Cloud’s output before approving merges into `dev`.
