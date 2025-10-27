############################################################
# PR-CYBR Agent Terraform Entry Point
#
# This configuration intentionally remains lightweight so it
# can be executed locally (plan / validate) without requiring
# direct network calls to Terraform Cloud or GitHub. The real
# workspace in Terraform Cloud injects values for every
# variable defined in agent-variables.tf.
############################################################

terraform {
  required_version = ">= 1.5.0"
}

locals {
  agent_identity = {
    agent_id       = var.AGENT_ID
    notion_page_id = var.NOTION_PAGE_ID
    global_domain  = var.GLOBAL_DOMAIN
  }

  github_credentials = {
    dockerhub_username = var.DOCKERHUB_USERNAME
    dockerhub_token    = var.DOCKERHUB_TOKEN
    pr_cybr_user       = var.PR_CYBR_DOCKER_USER
    pr_cybr_pass       = var.PR_CYBR_DOCKER_PASS
    actions_token      = var.AGENT_ACTIONS
  }

  notion_resources = {
    token                       = var.NOTION_TOKEN
    discussions_arc_db_id       = var.NOTION_DISCUSSIONS_ARC_DB_ID
    issues_backlog_db_id        = var.NOTION_ISSUES_BACKLOG_DB_ID
    knowledge_file_db_id        = var.NOTION_KNOWLEDGE_FILE_DB_ID
    project_board_backlog_db_id = var.NOTION_PROJECT_BOARD_BACKLOG_DB_ID
    pr_backlog_db_id            = var.NOTION_PR_BACKLOG_DB_ID
    task_backlog_db_id          = var.NOTION_TASK_BACKLOG_DB_ID
  }

  terraform_cloud = {
    token = var.TFC_TOKEN
  }
}

output "agent_identity" {
  description = "Non-sensitive identifiers for this agent."
  value       = local.agent_identity
}

output "github_credentials" {
  description = "Sensitive authentication tokens for GitHub and Docker registries."
  value       = local.github_credentials
  sensitive   = true
}

output "notion_resources" {
  description = "Notion resource identifiers and shared tokens."
  value       = local.notion_resources
  sensitive   = true
}

output "terraform_cloud" {
  description = "Terraform Cloud credentials required by automation workflows."
  value       = local.terraform_cloud
  sensitive   = true
}
