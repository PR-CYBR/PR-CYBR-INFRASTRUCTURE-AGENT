###############################################
# PR-CYBR-INFRASTRUCTURE-AGENT
# Main Terraform Configuration
###############################################

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # Backend configuration for Terraform Cloud
  # Organization and workspace are configured via CLI or environment variables
  cloud {
    organization = "PR-CYBR"
    
    workspaces {
      name = "PR-CYBR-INFRASTRUCTURE-AGENT"
    }
  }
}

# Local values
locals {
  agent_version = "0.1.0"
  agent_name    = "PR-CYBR-INFRASTRUCTURE-AGENT"
}

# Placeholder resource to ensure terraform plan/apply works
# This will be replaced with actual infrastructure resources
resource "null_resource" "agent_placeholder" {
  triggers = {
    agent_version = local.agent_version
  }

  provisioner "local-exec" {
    command = "echo 'PR-CYBR Infrastructure Agent initialized'"
  }
}

# Output agent information
output "agent_name" {
  value       = local.agent_name
  description = "Name of the PR-CYBR Infrastructure Agent"
}

output "agent_version" {
  value       = local.agent_version
  description = "Version of the PR-CYBR Infrastructure Agent"
}
