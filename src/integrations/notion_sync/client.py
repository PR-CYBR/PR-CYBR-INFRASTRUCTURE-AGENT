"""Wrapper utilities around the Notion SDK with retry support."""
from __future__ import annotations

import logging
import time
from dataclasses import dataclass
from typing import Any, Dict, Optional

try:  # pragma: no cover - notion_client is optional during testing
    from notion_client import Client
    from notion_client.errors import APIResponseError
except ImportError:  # pragma: no cover - allows unit tests without notion-client
    Client = None  # type: ignore

    class APIResponseError(Exception):
        """Fallback error used when the notion_client package is unavailable."""

from requests.exceptions import RequestException

LOGGER = logging.getLogger(__name__)


@dataclass
class NotionSyncConfig:
    """Configuration for a Notion database sync target."""

    database_id: str
    id_property: str = "GitHub ID"
    id_property_type: str = "rich_text"
    title_property: str = "Name"


class NotionSyncClient:
    """Convenience wrapper that adds retries and helper property builders."""

    def __init__(
        self,
        *,
        api_token: str,
        max_retries: int = 3,
        retry_backoff_seconds: float = 1.5,
        notion_client_kwargs: Optional[Dict[str, Any]] = None,
    ) -> None:
        if Client is None:
            raise RuntimeError(
                "The notion_client package is required to use NotionSyncClient. "
                "Install it by adding 'notion-client' to your requirements."
            )

        self._client = Client(auth=api_token, **(notion_client_kwargs or {}))
        self._max_retries = max(1, max_retries)
        self._retry_backoff_seconds = retry_backoff_seconds

    @property
    def client(self) -> Client:
        """Expose the underlying Notion client."""

        return self._client

    # ------------------------------------------------------------------
    # Property helper factories
    # ------------------------------------------------------------------
    @staticmethod
    def build_rich_text(value: Optional[str]) -> Optional[Dict[str, Any]]:
        if not value:
            return None
        return {"rich_text": [{"text": {"content": value}}]}

    @staticmethod
    def build_title(value: Optional[str]) -> Optional[Dict[str, Any]]:
        if not value:
            return None
        return {"title": [{"text": {"content": value}}]}

    @staticmethod
    def build_url(value: Optional[str]) -> Optional[Dict[str, Any]]:
        if not value:
            return None
        return {"url": value}

    @staticmethod
    def build_select(value: Optional[str]) -> Optional[Dict[str, Any]]:
        if not value:
            return None
        return {"select": {"name": value}}

    @staticmethod
    def build_multi_select(values: Optional[Any]) -> Optional[Dict[str, Any]]:
        if not values:
            return None
        options = [
            {"name": str(option)}
            for option in values
            if isinstance(option, str) and option
        ]
        if not options:
            return None
        return {"multi_select": options}

    @staticmethod
    def build_date(value: Optional[str]) -> Optional[Dict[str, Any]]:
        if not value:
            return None
        return {"date": {"start": value}}

    @staticmethod
    def build_number(value: Optional[float]) -> Optional[Dict[str, Any]]:
        if value is None:
            return None
        return {"number": value}

    # ------------------------------------------------------------------
    def _with_retries(self, func, *args, **kwargs):
        last_error: Optional[Exception] = None
        for attempt in range(1, self._max_retries + 1):
            try:
                return func(*args, **kwargs)
            except (APIResponseError, RequestException) as exc:  # pragma: no cover - network failure
                last_error = exc
                wait_time = self._retry_backoff_seconds * attempt
                LOGGER.warning(
                    "Notion API call failed, retrying",
                    extra={
                        "attempt": attempt,
                        "max_retries": self._max_retries,
                        "error": str(exc),
                        "wait_time": wait_time,
                    },
                )
                time.sleep(wait_time)
        if last_error is not None:
            raise last_error
        raise RuntimeError("Notion API call failed without raising an exception")

    def _build_id_property(self, *, property_type: str, value: Any) -> Dict[str, Any]:
        if property_type == "number":
            number = float(value) if value is not None else None
            return self.build_number(number) or {"number": None}
        if property_type == "title":
            return self.build_title(str(value)) or {"title": []}
        if property_type == "url":
            return self.build_url(str(value)) or {"url": None}
        if property_type == "select":
            return self.build_select(str(value)) or {"select": None}
        # Default to rich_text
        return self.build_rich_text(str(value)) or {"rich_text": []}

    def _find_page_by_id(
        self,
        *,
        database_id: str,
        id_property: str,
        id_property_type: str,
        id_value: Any,
    ) -> Optional[Dict[str, Any]]:
        if id_value is None:
            return None
        if id_property_type == "number":
            notion_filter = {
                "property": id_property,
                "number": {"equals": float(id_value)},
            }
        elif id_property_type == "select":
            notion_filter = {
                "property": id_property,
                "select": {"equals": str(id_value)},
            }
        elif id_property_type == "title":
            notion_filter = {
                "property": id_property,
                "title": {"equals": str(id_value)},
            }
        elif id_property_type == "url":
            notion_filter = {
                "property": id_property,
                "url": {"equals": str(id_value)},
            }
        else:
            notion_filter = {
                "property": id_property,
                "rich_text": {"equals": str(id_value)},
            }

        response = self._with_retries(
            self._client.databases.query,
            database_id=database_id,
            filter=notion_filter,
            page_size=1,
        )
        results = response.get("results", []) if isinstance(response, dict) else []
        return results[0] if results else None

    def upsert_page(
        self,
        *,
        database_id: str,
        id_property: str,
        id_property_type: str,
        id_value: Any,
        title_property: str,
        title: str,
        properties: Dict[str, Dict[str, Any]],
    ) -> Dict[str, Any]:
        properties = {
            key: value
            for key, value in properties.items()
            if value is not None
        }

        properties[id_property] = self._build_id_property(
            property_type=id_property_type,
            value=id_value,
        )

        title_property_value = self.build_title(title)
        if title_property_value:
            properties[title_property] = title_property_value

        existing_page = self._find_page_by_id(
            database_id=database_id,
            id_property=id_property,
            id_property_type=id_property_type,
            id_value=id_value,
        )
        if existing_page:
            page_id = existing_page["id"]
            return self._with_retries(
                self._client.pages.update,
                page_id=page_id,
                properties=properties,
            )

        return self._with_retries(
            self._client.pages.create,
            parent={"database_id": database_id},
            properties=properties,
        )
