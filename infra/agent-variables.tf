#############################################
# PR-CYBR Unified Agent Variable Definitions
# This schema mirrors the Terraform Cloud
# workspace variables configured for all
# PR-CYBR automation agents. Real values are
# injected by Terraform Cloud; never commit
# secrets or clear-text credentials.
#############################################

variable "AGENT_ID" {
  type        = string
  description = "Unique identifier for this PR-CYBR agent (e.g., A-04)."
}

variable "PR_CYBR_DOCKER_USER" {
  type        = string
  description = "Shared Docker Hub username for PR-CYBR service images."
}

variable "PR_CYBR_DOCKER_PASS" {
  type        = string
  sensitive   = true
  description = "Shared Docker Hub access token for PR-CYBR service images."
}

variable "DOCKERHUB_USERNAME" {
  type        = string
  description = "Legacy Docker Hub username used for image publishing."
}

variable "DOCKERHUB_TOKEN" {
  type        = string
  sensitive   = true
  description = "Legacy Docker Hub token used for image publishing."
}

variable "GLOBAL_DOMAIN" {
  type        = string
  description = "Primary DNS domain for PR-CYBR hosted services."
}

variable "AGENT_ACTIONS" {
  type        = string
  sensitive   = true
  description = "GitHub Actions token scoped for this agent's automation workflows."
}

variable "NOTION_TOKEN" {
  type        = string
  sensitive   = true
  description = "Shared Notion integration token for PR-CYBR automation."
}

variable "NOTION_DISCUSSIONS_ARC_DB_ID" {
  type        = string
  description = "Database ID for the Discussions ARC board in Notion."
}

variable "NOTION_ISSUES_BACKLOG_DB_ID" {
  type        = string
  description = "Database ID for the Issues backlog board in Notion."
}

variable "NOTION_KNOWLEDGE_FILE_DB_ID" {
  type        = string
  description = "Database ID for the Knowledge File library in Notion."
}

variable "NOTION_PROJECT_BOARD_BACKLOG_DB_ID" {
  type        = string
  description = "Database ID for the Project Board backlog in Notion."
}

variable "NOTION_PR_BACKLOG_DB_ID" {
  type        = string
  description = "Database ID for the Pull Request backlog in Notion."
}

variable "NOTION_TASK_BACKLOG_DB_ID" {
  type        = string
  description = "Database ID for the Task backlog in Notion."
}

variable "NOTION_PAGE_ID" {
  type        = string
  description = "Notion page ID dedicated to this PR-CYBR agent."
}

variable "TFC_TOKEN" {
  type        = string
  sensitive   = true
  description = "Terraform Cloud user/API token for workspace automation."
}
