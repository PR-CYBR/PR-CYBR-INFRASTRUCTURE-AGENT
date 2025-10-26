#!/usr/bin/env python3
"""Synchronise local planning data with a Notion database.

The script intentionally keeps its behaviour simple so that it can be used both
in automation and locally by engineers.  A `--dry-run` flag is provided to make
it safe to iterate without pushing updates to the remote workspace.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Mapping, Sequence

import requests

NOTION_API_BASE = "https://api.notion.com/v1"
NOTION_VERSION = "2022-06-28"


@dataclass
class NotionClient:
    """Very small wrapper around the Notion REST API."""

    token: str
    database_id: str
    dry_run: bool = False
    session: requests.Session = field(default_factory=requests.Session)

    def headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json",
            "Notion-Version": NOTION_VERSION,
        }

    def upsert_task(self, task: Mapping[str, Any]) -> Dict[str, Any]:
        """Create or update a task record in Notion."""

        payload = self._build_payload(task)

        if self.dry_run:
            logging.info("[dry-run] Would synchronise task with payload: %s", json.dumps(payload))
            return {"dry_run": True, "payload": payload}

        response = self.session.post(
            f"{NOTION_API_BASE}/pages",
            headers=self.headers(),
            json=payload,
            timeout=30,
        )
        response.raise_for_status()
        logging.info("Synchronised task '%s'", payload["properties"]["Name"]["title"][0]["plain_text"])
        return response.json()

    def _build_payload(self, task: Mapping[str, Any]) -> Dict[str, Any]:
        title = str(task.get("title")) or "Infrastructure Task"
        status = str(task.get("status", "Planned"))
        tags = [str(tag) for tag in task.get("tags", [])]

        payload: Dict[str, Any] = {
            "parent": {"database_id": self.database_id},
            "properties": {
                "Name": {
                    "title": [
                        {
                            "text": {"content": title},
                            "plain_text": title,
                        }
                    ]
                },
                "Status": {
                    "select": {"name": status},
                },
            },
        }

        if tags:
            payload["properties"]["Tags"] = {"multi_select": [{"name": tag} for tag in tags]}

        notes = task.get("notes")
        if notes:
            payload.setdefault("children", []).append(
                {
                    "object": "block",
                    "type": "paragraph",
                    "paragraph": {
                        "rich_text": [
                            {
                                "type": "text",
                                "text": {"content": str(notes)},
                            }
                        ]
                    },
                }
            )

        return payload


def load_tasks(path: Path | None) -> List[Dict[str, Any]]:
    if path is None:
        return []

    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if isinstance(data, list):
        return [dict(task) for task in data]

    raise ValueError("Input file must contain a JSON array of task objects")


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Synchronise data into Notion")
    parser.add_argument(
        "--input",
        type=Path,
        help="Path to a JSON file containing an array of tasks to sync",
    )
    parser.add_argument(
        "--database-id",
        default=os.environ.get("NOTION_DATABASE_ID"),
        help="Target Notion database identifier (defaults to NOTION_DATABASE_ID env variable)",
    )
    parser.add_argument(
        "--token",
        default=os.environ.get("NOTION_TOKEN"),
        help="Notion integration token (defaults to NOTION_TOKEN env variable)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run without sending mutations to the Notion API",
    )
    parser.add_argument(
        "--log-level",
        default=os.environ.get("NOTION_SYNC_LOG_LEVEL", "INFO"),
        help="Override logging level (default: INFO)",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)

    logging.basicConfig(level=args.log_level.upper(), format="%(levelname)s %(message)s")

    token = args.token
    database_id = args.database_id

    if (not token or not database_id) and not args.dry_run:
        logging.error(
            "Notion credentials are required unless running in dry-run mode. Set NOTION_TOKEN "
            "and NOTION_DATABASE_ID or pass them via CLI options."
        )
        return 1

    tasks = load_tasks(args.input)
    client = NotionClient(token=token or "dry-run", database_id=database_id or "dry-run", dry_run=args.dry_run)

    if not tasks:
        logging.info("No tasks found in input. Nothing to synchronise.")
        return 0

    for task in tasks:
        client.upsert_task(task)

    logging.info("Processed %d task(s)", len(tasks))
    return 0


if __name__ == "__main__":
    sys.exit(main())
