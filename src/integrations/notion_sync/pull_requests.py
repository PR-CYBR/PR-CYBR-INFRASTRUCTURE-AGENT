"""Pull request synchronisation helpers."""
from __future__ import annotations

from typing import Any, Dict, Iterable, List, Optional

from .client import NotionSyncClient, NotionSyncConfig


def _collect_pull_requests(payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    pull_requests: List[Dict[str, Any]] = []
    pr = payload.get("pull_request")
    if isinstance(pr, dict):
        pull_requests.append(pr)
    pr_list = payload.get("pull_requests")
    if isinstance(pr_list, list):
        pull_requests.extend([item for item in pr_list if isinstance(item, dict)])
    return pull_requests


def _format_reviewers(pr: Dict[str, Any]) -> Iterable[str]:
    reviewers = pr.get("requested_reviewers")
    if not isinstance(reviewers, list):
        return []
    formatted = []
    for reviewer in reviewers:
        if isinstance(reviewer, dict):
            login = reviewer.get("login")
            if isinstance(login, str) and login:
                formatted.append(login)
        elif isinstance(reviewer, str) and reviewer:
            formatted.append(reviewer)
    return formatted


def sync(client: NotionSyncClient, payload: Dict[str, Any], config: NotionSyncConfig, log) -> None:
    """Synchronise GitHub pull requests with Notion."""

    repository = payload.get("repository", {})
    repo_name: Optional[str] = repository.get("full_name") if isinstance(repository, dict) else None

    for pull_request in _collect_pull_requests(payload):
        pr_id = pull_request.get("node_id") or pull_request.get("id") or pull_request.get("number")
        if pr_id is None:
            log(
                "warning",
                "Pull request payload missing identifier",
                event="pull_request.skipped",
                pull_request=pull_request,
            )
            continue

        properties: Dict[str, Any] = {}

        properties["GitHub URL"] = client.build_url(pull_request.get("html_url"))
        properties["State"] = client.build_select(str(pull_request.get("state"))) if pull_request.get("state") else None
        user = pull_request.get("user")
        author_login = user.get("login") if isinstance(user, dict) else None
        head = pull_request.get("head")
        base = pull_request.get("base")

        properties["Repository"] = client.build_rich_text(repo_name)
        properties["Author"] = client.build_rich_text(author_login)
        properties["Draft"] = client.build_select("Draft" if pull_request.get("draft") else "Ready")
        properties["Merged"] = client.build_select("Merged" if pull_request.get("merged") else "Unmerged")
        head_ref = head.get("ref") if isinstance(head, dict) else None
        base_ref = base.get("ref") if isinstance(base, dict) else None
        properties["Head Branch"] = client.build_rich_text(head_ref)
        properties["Base Branch"] = client.build_rich_text(base_ref)
        properties["Reviewers"] = client.build_multi_select(_format_reviewers(pull_request))
        properties["Last Updated"] = client.build_date(pull_request.get("updated_at"))
        properties["Merged At"] = client.build_date(pull_request.get("merged_at"))
        properties["Number"] = (
            client.build_number(float(pull_request.get("number")))
            if pull_request.get("number") is not None
            else None
        )

        try:
            page = client.upsert_page(
                database_id=config.database_id,
                id_property=config.id_property,
                id_property_type=config.id_property_type,
                id_value=str(pr_id),
                title_property=config.title_property,
                title=pull_request.get("title") or "Untitled Pull Request",
                properties=properties,
            )
        except Exception as exc:  # pragma: no cover - network failure or API exception
            log(
                "error",
                "Failed to sync pull request",
                event="pull_request.error",
                pull_request_number=pull_request.get("number"),
                error=str(exc),
            )
            continue

        log(
            "info",
            "Pull request synced to Notion",
            event="pull_request.synced",
            pull_request_number=pull_request.get("number"),
            notion_page_id=page.get("id"),
        )
