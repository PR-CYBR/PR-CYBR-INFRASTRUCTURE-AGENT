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

# Placeholder resource to ensure terraform plan/apply works
# This will be replaced with actual infrastructure resources
resource "null_resource" "agent_placeholder" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'PR-CYBR Infrastructure Agent placeholder resource'"
  }
}

# Output agent information
output "agent_name" {
  value       = "PR-CYBR-INFRASTRUCTURE-AGENT"
  description = "Name of the PR-CYBR Infrastructure Agent"
}

output "agent_version" {
  value       = "0.1.0"
  description = "Version of the PR-CYBR Infrastructure Agent"
}
