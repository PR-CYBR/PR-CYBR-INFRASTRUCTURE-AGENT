# Reference template only. Real values are sourced from Terraform Cloud workspace variables.
# Each assignment maps the friendly variable name used by downstream modules to the
# authoritative Terraform variable defined in agent-variables.tf.

agent_id                           = var.AGENT_ID
notion_page_id                     = var.NOTION_PAGE_ID
pr_cybr_docker_user                = var.PR_CYBR_DOCKER_USER
pr_cybr_docker_pass                = var.PR_CYBR_DOCKER_PASS
dockerhub_username                 = var.DOCKERHUB_USERNAME
dockerhub_token                    = var.DOCKERHUB_TOKEN
global_domain                      = var.GLOBAL_DOMAIN
agent_actions_token                = var.AGENT_ACTIONS
notion_token                       = var.NOTION_TOKEN
notion_discussions_arc_db_id       = var.NOTION_DISCUSSIONS_ARC_DB_ID
notion_issues_backlog_db_id        = var.NOTION_ISSUES_BACKLOG_DB_ID
notion_knowledge_file_db_id        = var.NOTION_KNOWLEDGE_FILE_DB_ID
notion_project_board_backlog_db_id = var.NOTION_PROJECT_BOARD_BACKLOG_DB_ID
notion_pr_backlog_db_id            = var.NOTION_PR_BACKLOG_DB_ID
notion_task_backlog_db_id          = var.NOTION_TASK_BACKLOG_DB_ID
tfc_token                          = var.TFC_TOKEN
