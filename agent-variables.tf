#############################################
# PR-CYBR Agent Variables (Generic Baseline)
# This file declares variables expected by
# Terraform Cloud across all PR-CYBR Agents.
# Real values are securely managed in TFC.
#############################################

# --- Docker / Registry ---
variable "DOCKERHUB_TOKEN" {
  type        = string
  sensitive   = true
  description = "Docker Hub access token"
}

variable "DOCKERHUB_USERNAME" {
  type        = string
  description = "Docker Hub username"
}

# --- GitHub / Terraform Cloud ---
variable "GITHUB_TOKEN" {
  type        = string
  sensitive   = true
  description = "GitHub personal access token for repository automation"
}

variable "TFC_TOKEN" {
  type        = string
  sensitive   = true
  description = "Terraform Cloud user or team token"
}

# --- Docker Publishing (GitHub Secrets) ---
variable "PR_CYBR_DOCKER_USER" {
  type        = string
  description = "GitHub secret providing Docker Hub username"
}

variable "PR_CYBR_DOCKER_PASS" {
  type        = string
  sensitive   = true
  description = "GitHub secret providing Docker Hub password"
}

# --- Global Infrastructure URIs ---
variable "GLOBAL_DOMAIN" {
  type        = string
  description = "Root DNS domain for PR-CYBR services"
}

variable "GLOBAL_ELASTIC_URI" {
  type        = string
  description = "Elasticsearch endpoint"
}

variable "GLOBAL_GRAFANA_URI" {
  type        = string
  description = "Grafana endpoint"
}

variable "GLOBAL_KIBANA_URI" {
  type        = string
  description = "Kibana endpoint"
}

variable "GLOBAL_PROMETHEUS_URI" {
  type        = string
  description = "Prometheus endpoint"
}

# --- Networking / Security ---
variable "GLOBAL_TAILSCALE_AUTHKEY" {
  type        = string
  sensitive   = true
  description = "Auth key for Tailscale VPN/DNS"
}

variable "GLOBAL_TRAEFIK_ACME_EMAIL" {
  type        = string
  description = "Email used by Traefik for Let's Encrypt"
}

variable "GLOBAL_TRAEFIK_ENTRYPOINTS" {
  type        = string
  description = "Default entrypoints for Traefik"
}

variable "GLOBAL_ZEROTIER_NETWORK_ID" {
  type        = string
  sensitive   = true
  description = "ZeroTier overlay network ID"
}

# --- Agent Tokens ---
variable "AGENT_ACTIONS" {
  type        = string
  sensitive   = true
  description = "Token for CI/CD pipelines (builds, tests, deploys)"
}

variable "AGENT_COLLAB" {
  type        = string
  sensitive   = true
  description = "Token for governance, discussions, issues, project boards"
}

# --- Knowledge Management (Notion) ---
variable "NOTION_TOKEN" {
  type        = string
  sensitive   = true
  description = "Notion integration token for workspace automation"
}

variable "NOTION_PAGE_ID" {
  type        = string
  description = "Root Notion page identifier"
}

variable "NOTION_DISCUSSIONS_ARC_DB_ID" {
  type        = string
  description = "Notion database ID for discussions archive"
}

variable "NOTION_ISSUES_BACKLOG_DB_ID" {
  type        = string
  description = "Notion database ID for issues backlog"
}

variable "NOTION_KNOWLEDGE_FILE_DB_ID" {
  type        = string
  description = "Notion database ID for knowledge files"
}

variable "NOTION_PR_BACKLOG_DB_ID" {
  type        = string
  description = "Notion database ID for pull request backlog"
}

variable "NOTION_PROJECT_BOARD_BACKLOG_DB_ID" {
  type        = string
  description = "Notion database ID for project board backlog"
}

variable "NOTION_TASK_BACKLOG_DB_ID" {
  type        = string
  description = "Notion database ID for task backlog"
}
