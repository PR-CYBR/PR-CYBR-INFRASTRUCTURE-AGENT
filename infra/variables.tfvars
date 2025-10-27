# -----------------------------------------------------------------------------
# Local development defaults for the A-04 workspace.
# Real values are injected via Terraform Cloud. Update these placeholders only
# when running plans locally with non-production credentials.
# -----------------------------------------------------------------------------

DOCKERHUB_USERNAME         = "local-dev"
PR_CYBR_DOCKER_PASS        = "change-me"
GLOBAL_DOMAIN              = "pr-cybr.local"
GLOBAL_ELASTIC_URI         = "https://elastic.pr-cybr.local"
GLOBAL_TAILSCALE_AUTHKEY   = "tskey-local"
GLOBAL_ZEROTIER_NETWORK_ID = "0000000000000000"
AGENT_ACTIONS              = "local-actions-token"
NOTION_TOKEN               = "local-notion-token"
NOTION_PAGE_ID             = "00000000-0000-0000-0000-000000000000"
