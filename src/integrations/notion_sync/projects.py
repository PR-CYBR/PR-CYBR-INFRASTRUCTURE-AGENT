"""Project synchronisation helpers."""
from __future__ import annotations

from typing import Any, Dict, List, Optional, Tuple

from .client import NotionSyncClient, NotionSyncConfig


def _collect_projects(payload: Dict[str, Any]) -> List[Tuple[str, Dict[str, Any]]]:
    items: List[Tuple[str, Dict[str, Any]]] = []
    project = payload.get("project")
    if isinstance(project, dict):
        items.append(("project", project))
    projects = payload.get("projects")
    if isinstance(projects, list):
        items.extend([("project", item) for item in projects if isinstance(item, dict)])
    project_card = payload.get("project_card")
    if isinstance(project_card, dict):
        items.append(("project_card", project_card))
    project_cards = payload.get("project_cards")
    if isinstance(project_cards, list):
        items.extend([("project_card", item) for item in project_cards if isinstance(item, dict)])
    return items


def _project_properties(
    client: NotionSyncClient,
    project: Dict[str, Any],
    repo_name: Optional[str],
) -> Dict[str, Any]:
    creator = project.get("creator")
    creator_login = creator.get("login") if isinstance(creator, dict) else None
    properties: Dict[str, Any] = {}
    properties["GitHub URL"] = client.build_url(project.get("html_url"))
    properties["State"] = client.build_select(project.get("state"))
    properties["Body"] = client.build_rich_text(project.get("body"))
    properties["Creator"] = client.build_rich_text(creator_login)
    properties["Repository"] = client.build_rich_text(repo_name)
    properties["Last Updated"] = client.build_date(project.get("updated_at"))
    project_number = project.get("number")
    properties["Project Number"] = (
        client.build_number(float(project_number)) if project_number is not None else None
    )
    properties["Type"] = client.build_select("Project")
    return properties


def _project_card_properties(client: NotionSyncClient, card: Dict[str, Any]) -> Dict[str, Any]:
    creator = card.get("creator")
    creator_login = creator.get("login") if isinstance(creator, dict) else None
    column = card.get("column_id")
    project_id = card.get("project_id")
    properties: Dict[str, Any] = {}
    properties["Note"] = client.build_rich_text(card.get("note"))
    properties["Creator"] = client.build_rich_text(creator_login)
    properties["Column ID"] = client.build_number(float(column)) if column is not None else None
    properties["Project ID"] = client.build_number(float(project_id)) if project_id is not None else None
    properties["GitHub URL"] = client.build_url(card.get("url") or card.get("content_url"))
    properties["Type"] = client.build_select("Project Card")
    properties["Last Updated"] = client.build_date(card.get("updated_at"))
    return properties


def sync(client: NotionSyncClient, payload: Dict[str, Any], config: NotionSyncConfig, log) -> None:
    """Synchronise GitHub projects and project cards."""

    repository = payload.get("repository", {})
    repo_name: Optional[str] = repository.get("full_name") if isinstance(repository, dict) else None

    for item_type, project in _collect_projects(payload):
        project_id = project.get("node_id") or project.get("id")
        if project_id is None:
            log(
                "warning",
                "Project payload missing identifier",
                event="project.skipped",
                project=project,
            )
            continue

        if item_type == "project":
            properties = _project_properties(client, project, repo_name)
            title = project.get("name") or "Untitled Project"
        else:
            properties = _project_card_properties(client, project)
            title = project.get("note") or project.get("content_url") or "Project Card"

        try:
            page = client.upsert_page(
                database_id=config.database_id,
                id_property=config.id_property,
                id_property_type=config.id_property_type,
                id_value=str(project_id),
                title_property=config.title_property,
                title=title,
                properties=properties,
            )
        except Exception as exc:  # pragma: no cover - network failure or API exception
            log(
                "error",
                "Failed to sync project item",
                event="project.error",
                project_id=project_id,
                error=str(exc),
            )
            continue

        log(
            "info",
            "Project item synced to Notion",
            event="project.synced",
            project_id=project_id,
            notion_page_id=page.get("id"),
        )
