"""Issue synchronisation helpers."""
from __future__ import annotations

from typing import Any, Dict, Iterable, List, Optional

from .client import NotionSyncClient, NotionSyncConfig


def _collect_issues(payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    issues: List[Dict[str, Any]] = []
    issue = payload.get("issue")
    if isinstance(issue, dict):
        issues.append(issue)
    issue_list = payload.get("issues")
    if isinstance(issue_list, list):
        issues.extend([item for item in issue_list if isinstance(item, dict)])
    return issues


def _format_labels(issue: Dict[str, Any]) -> Iterable[str]:
    labels = issue.get("labels")
    if not isinstance(labels, list):
        return []
    formatted = []
    for label in labels:
        if isinstance(label, dict):
            name = label.get("name")
            if isinstance(name, str) and name:
                formatted.append(name)
        elif isinstance(label, str) and label:
            formatted.append(label)
    return formatted


def _format_assignees(issue: Dict[str, Any]) -> Iterable[str]:
    assignees = issue.get("assignees")
    if not isinstance(assignees, list):
        return []
    names = []
    for assignee in assignees:
        if isinstance(assignee, dict):
            login = assignee.get("login")
            if isinstance(login, str) and login:
                names.append(login)
        elif isinstance(assignee, str) and assignee:
            names.append(assignee)
    return names


def sync(client: NotionSyncClient, payload: Dict[str, Any], config: NotionSyncConfig, log) -> None:
    """Synchronise GitHub issues with a Notion database."""

    repository = payload.get("repository", {})
    repo_name: Optional[str] = repository.get("full_name") if isinstance(repository, dict) else None

    for issue in _collect_issues(payload):
        issue_id = issue.get("node_id") or issue.get("id") or issue.get("number")
        if issue_id is None:
            log(
                "warning",
                "Issue payload missing identifier",
                event="issue.skipped",
                issue=issue,
            )
            continue

        properties: Dict[str, Any] = {}

        properties["GitHub URL"] = client.build_url(issue.get("html_url"))
        properties["State"] = client.build_select(str(issue.get("state"))) if issue.get("state") else None
        properties["Repository"] = client.build_rich_text(repo_name)
        author = issue.get("user")
        author_login = author.get("login") if isinstance(author, dict) else None
        properties["Author"] = client.build_rich_text(author_login)
        properties["Labels"] = client.build_multi_select(_format_labels(issue))
        properties["Assignees"] = client.build_multi_select(_format_assignees(issue))
        properties["Last Updated"] = client.build_date(issue.get("updated_at"))
        properties["Number"] = client.build_number(float(issue.get("number"))) if issue.get("number") is not None else None

        try:
            page = client.upsert_page(
                database_id=config.database_id,
                id_property=config.id_property,
                id_property_type=config.id_property_type,
                id_value=str(issue_id),
                title_property=config.title_property,
                title=issue.get("title") or "Untitled Issue",
                properties=properties,
            )
        except Exception as exc:  # pragma: no cover - network failure or API exception
            log(
                "error",
                "Failed to sync issue",
                event="issue.error",
                issue_number=issue.get("number"),
                error=str(exc),
            )
            continue

        log(
            "info",
            "Issue synced to Notion",
            event="issue.synced",
            issue_number=issue.get("number"),
            notion_page_id=page.get("id"),
        )
