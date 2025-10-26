#!/usr/bin/env python3
"""Synchronise GitHub webhook payloads with Notion databases."""
from __future__ import annotations

import json
import logging
import os
import sys
from pathlib import Path
from typing import Any, Callable, Dict, Iterable, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
SRC_PATH = ROOT / "src"
if str(SRC_PATH) not in sys.path:
    sys.path.insert(0, str(SRC_PATH))

from integrations.notion_sync import NotionSyncClient, NotionSyncConfig, discussions, issues, projects, pull_requests


HandlerFunction = Callable[[NotionSyncClient, Dict[str, Any], NotionSyncConfig, Callable[..., None]], None]

LOGGER = logging.getLogger("notion_sync")


def setup_logging() -> None:
    logging.basicConfig(level=logging.INFO, format="%(message)s")


def emit(level: str, message: str, /, **fields: Any) -> None:
    level_name = level.upper()
    logging_level = getattr(logging, level_name, logging.INFO)
    entry = {"level": level_name.lower(), "message": message, **fields}
    LOGGER.log(logging_level, json.dumps(entry, sort_keys=True))


EVENT_NAME_HANDLER_MAP: Dict[str, Tuple[str, HandlerFunction]] = {
    "issues": ("issues", issues.sync),
    "issue_comment": ("issues", issues.sync),
    "pull_request": ("pull_requests", pull_requests.sync),
    "pull_request_target": ("pull_requests", pull_requests.sync),
    "pull_request_review": ("pull_requests", pull_requests.sync),
    "discussion": ("discussions", discussions.sync),
    "discussion_comment": ("discussions", discussions.sync),
    "projects_v2_item": ("projects", projects.sync),
    "project": ("projects", projects.sync),
    "project_card": ("projects", projects.sync),
    "project_column": ("projects", projects.sync),
}

PAYLOAD_KEY_HANDLER_MAP: Dict[str, Tuple[str, HandlerFunction]] = {
    "issue": ("issues", issues.sync),
    "issues": ("issues", issues.sync),
    "pull_request": ("pull_requests", pull_requests.sync),
    "pull_requests": ("pull_requests", pull_requests.sync),
    "discussion": ("discussions", discussions.sync),
    "discussions": ("discussions", discussions.sync),
    "project": ("projects", projects.sync),
    "projects": ("projects", projects.sync),
    "project_card": ("projects", projects.sync),
    "project_cards": ("projects", projects.sync),
}


def load_config_from_env() -> Dict[str, NotionSyncConfig]:
    config: Dict[str, NotionSyncConfig] = {}
    mappings = {
        "issues": {
            "database": "NOTION_ISSUES_DATABASE_ID",
            "id_property": "NOTION_ISSUES_ID_PROPERTY",
            "id_property_type": "NOTION_ISSUES_ID_PROPERTY_TYPE",
            "title_property": "NOTION_ISSUES_TITLE_PROPERTY",
        },
        "pull_requests": {
            "database": "NOTION_PULL_REQUESTS_DATABASE_ID",
            "id_property": "NOTION_PULL_REQUESTS_ID_PROPERTY",
            "id_property_type": "NOTION_PULL_REQUESTS_ID_PROPERTY_TYPE",
            "title_property": "NOTION_PULL_REQUESTS_TITLE_PROPERTY",
        },
        "projects": {
            "database": "NOTION_PROJECTS_DATABASE_ID",
            "id_property": "NOTION_PROJECTS_ID_PROPERTY",
            "id_property_type": "NOTION_PROJECTS_ID_PROPERTY_TYPE",
            "title_property": "NOTION_PROJECTS_TITLE_PROPERTY",
        },
        "discussions": {
            "database": "NOTION_DISCUSSIONS_DATABASE_ID",
            "id_property": "NOTION_DISCUSSIONS_ID_PROPERTY",
            "id_property_type": "NOTION_DISCUSSIONS_ID_PROPERTY_TYPE",
            "title_property": "NOTION_DISCUSSIONS_TITLE_PROPERTY",
        },
    }

    for key, env in mappings.items():
        database_id = os.getenv(env["database"])
        if not database_id:
            continue
        id_property = os.getenv(env["id_property"], "GitHub ID")
        id_property_type = os.getenv(env["id_property_type"], "rich_text")
        title_property = os.getenv(env["title_property"], "Name")
        config[key] = NotionSyncConfig(
            database_id=database_id,
            id_property=id_property,
            id_property_type=id_property_type,
            title_property=title_property,
        )
    return config


def determine_handlers(
    *,
    event_name: Optional[str],
    payload: Dict[str, Any],
) -> Iterable[Tuple[str, HandlerFunction]]:
    seen: set[str] = set()
    if event_name:
        handler_info = EVENT_NAME_HANDLER_MAP.get(event_name)
        if handler_info:
            seen.add(handler_info[0])
            yield handler_info
    for key, handler_info in PAYLOAD_KEY_HANDLER_MAP.items():
        if handler_info[0] in seen:
            continue
        if key in payload:
            seen.add(handler_info[0])
            yield handler_info


def load_event_payload(event_path: str) -> Dict[str, Any]:
    with open(event_path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def main() -> int:
    setup_logging()

    event_path = os.getenv("GITHUB_EVENT_PATH")
    if not event_path:
        emit("error", "GITHUB_EVENT_PATH is not set", event="startup.missing_event_path")
        return 1

    try:
        payload = load_event_payload(event_path)
    except FileNotFoundError:
        emit("error", "GitHub event payload not found", event="startup.missing_event_file", path=event_path)
        return 1
    except json.JSONDecodeError as exc:
        emit(
            "error",
            "Unable to parse GitHub event payload",
            event="startup.invalid_event_file",
            path=event_path,
            error=str(exc),
        )
        return 1

    notion_token = os.getenv("NOTION_API_TOKEN") or os.getenv("NOTION_INTEGRATION_TOKEN")
    if not notion_token:
        emit("error", "Missing Notion API token", event="startup.missing_token")
        return 1

    try:
        max_retries = int(os.getenv("NOTION_API_MAX_RETRIES", "3"))
    except ValueError:
        max_retries = 3
    try:
        retry_backoff = float(os.getenv("NOTION_API_RETRY_BACKOFF", "1.5"))
    except ValueError:
        retry_backoff = 1.5

    try:
        client = NotionSyncClient(
            api_token=notion_token,
            max_retries=max_retries,
            retry_backoff_seconds=retry_backoff,
        )
    except Exception as exc:
        emit("error", "Unable to initialise Notion client", event="startup.client_error", error=str(exc))
        return 1

    config = load_config_from_env()
    if not config:
        emit("warning", "No Notion database configuration found", event="startup.no_config")
        return 0

    event_name = os.getenv("GITHUB_EVENT_NAME")
    emit("info", "Starting Notion synchronisation", event="sync.start", event_name=event_name)

    handled_any = False
    for config_key, handler in determine_handlers(event_name=event_name, payload=payload):
        handler_config = config.get(config_key)
        if not handler_config:
            emit(
                "warning",
                "Skipping handler due to missing database configuration",
                event="sync.handler_skipped",
                handler=config_key,
            )
            continue
        handled_any = True
        try:
            handler(client, payload, handler_config, emit)
        except Exception as exc:  # pragma: no cover - defensive guard
            emit(
                "error",
                "Handler raised an unexpected exception",
                event="sync.handler_error",
                handler=config_key,
                error=str(exc),
            )

    if not handled_any:
        emit("warning", "No handlers matched the event payload", event="sync.no_handlers")
    else:
        emit("info", "Notion synchronisation completed", event="sync.complete")

    return 0


if __name__ == "__main__":
    sys.exit(main())
