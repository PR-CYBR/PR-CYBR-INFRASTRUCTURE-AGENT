# Infrastructure Rollout Checklist

This checklist supports safe promotion of infrastructure changes through the PR-CYBR branching model and associated Terraform Cloud workspaces.

## 1. Validate in the Test Workspace
- [ ] Select the Terraform Cloud workspace dedicated to staging/test.
- [ ] Apply the change set using the `--dry-run` or plan-only mode where available.
- [ ] Capture plan output and confirm no destructive changes are introduced without approval.
- [ ] Run integration smoke tests or synthetic monitors attached to the workspace endpoints.

## 2. Feature Branch Verification
- [ ] Ensure the change is committed to a feature branch derived from `codex`, `agents`, or `dev` per the branching policy.
- [ ] Link the branch to the corresponding GitHub issue, pull request, or project item so automation can update status.
- [ ] Execute `pytest` and relevant linters to confirm handlers and scripts pass CI locally before opening a PR.
- [ ] Request peer review from the infrastructure maintainers group and address feedback.

## 3. Monitoring and Post-Deployment Plan
- [ ] Define metrics or dashboards that should be observed during rollout (e.g., Notion sync success rates, GitHub webhook health).
- [ ] Configure alerts in the existing observability stack to notify the infrastructure Slack channel on anomalies.
- [ ] Schedule a follow-up review to evaluate impact and capture lessons learned for future rollouts.
- [ ] Update Notion or internal runbooks with the outcome and any remediation tasks.
