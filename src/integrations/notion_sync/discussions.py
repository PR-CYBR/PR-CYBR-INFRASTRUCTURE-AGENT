"""Discussion synchronisation helpers."""
from __future__ import annotations

from typing import Any, Dict, List, Optional

from .client import NotionSyncClient, NotionSyncConfig


def _collect_discussions(payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    discussions: List[Dict[str, Any]] = []
    discussion = payload.get("discussion")
    if isinstance(discussion, dict):
        discussions.append(discussion)
    discussion_list = payload.get("discussions")
    if isinstance(discussion_list, list):
        discussions.extend([item for item in discussion_list if isinstance(item, dict)])
    return discussions


def sync(client: NotionSyncClient, payload: Dict[str, Any], config: NotionSyncConfig, log) -> None:
    """Synchronise GitHub discussions with Notion."""

    repository = payload.get("repository", {})
    repo_name: Optional[str] = repository.get("full_name") if isinstance(repository, dict) else None

    for discussion in _collect_discussions(payload):
        discussion_id = discussion.get("node_id") or discussion.get("id") or discussion.get("number")
        if discussion_id is None:
            log(
                "warning",
                "Discussion payload missing identifier",
                event="discussion.skipped",
                discussion=discussion,
            )
            continue

        author = discussion.get("user") or discussion.get("author")
        author_login = author.get("login") if isinstance(author, dict) else None
        category = discussion.get("category")
        category_name = category.get("name") if isinstance(category, dict) else None

        properties: Dict[str, Any] = {}
        properties["GitHub URL"] = client.build_url(discussion.get("html_url"))
        properties["Repository"] = client.build_rich_text(repo_name)
        properties["Author"] = client.build_rich_text(author_login)
        properties["Category"] = client.build_select(category_name)
        properties["Answer URL"] = client.build_url(discussion.get("answer_html_url"))
        properties["Answered"] = client.build_select("Answered" if discussion.get("answer_html_url") else "Unanswered")
        properties["Locked"] = client.build_select("Locked" if discussion.get("locked") else "Open")
        properties["State"] = client.build_select(discussion.get("state"))
        properties["Last Updated"] = client.build_date(discussion.get("updated_at"))
        properties["Number"] = (
            client.build_number(float(discussion.get("number")))
            if discussion.get("number") is not None
            else None
        )

        try:
            page = client.upsert_page(
                database_id=config.database_id,
                id_property=config.id_property,
                id_property_type=config.id_property_type,
                id_value=str(discussion_id),
                title_property=config.title_property,
                title=discussion.get("title") or "Untitled Discussion",
                properties=properties,
            )
        except Exception as exc:  # pragma: no cover - network failure or API exception
            log(
                "error",
                "Failed to sync discussion",
                event="discussion.error",
                discussion_number=discussion.get("number"),
                error=str(exc),
            )
            continue

        log(
            "info",
            "Discussion synced to Notion",
            event="discussion.synced",
            discussion_number=discussion.get("number"),
            notion_page_id=page.get("id"),
        )
