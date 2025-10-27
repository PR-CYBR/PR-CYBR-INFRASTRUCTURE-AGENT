#############################################
# PR-CYBR Agent Variables (A-04 Baseline)
# All real values are managed via Terraform
# Cloud workspace variables for A-04.
#############################################

# --- Docker Hub ---
variable "DOCKERHUB_USERNAME" {
  type        = string
  description = "Docker Hub username used for publishing images"
}

variable "PR_CYBR_DOCKER_PASS" {
  type        = string
  sensitive   = true
  description = "Docker Hub password for the PR-CYBR organisation"
}

# --- Global Infrastructure ---
variable "GLOBAL_DOMAIN" {
  type        = string
  description = "Root DNS domain for PR-CYBR services"
}

variable "GLOBAL_ELASTIC_URI" {
  type        = string
  description = "Shared Elasticsearch endpoint"
}

# --- Networking / Connectivity ---
variable "GLOBAL_TAILSCALE_AUTHKEY" {
  type        = string
  sensitive   = true
  description = "Tailscale auth key for secure overlay networking"
}

variable "GLOBAL_ZEROTIER_NETWORK_ID" {
  type        = string
  sensitive   = true
  description = "ZeroTier overlay network identifier"
}

# --- Agent Integrations ---
variable "AGENT_ACTIONS" {
  type        = string
  sensitive   = true
  description = "Token for agent automation via GitHub Actions"
}

variable "NOTION_TOKEN" {
  type        = string
  sensitive   = true
  description = "Notion integration token for knowledge sync"
}

variable "NOTION_PAGE_ID" {
  type        = string
  description = "Root Notion page identifier for A-04"
}
