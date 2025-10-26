"""High-level automation routines for GitHub events.

This module provides light-weight coordination helpers that translate
webhook payloads for issues, pull requests, discussions, and project items
into high-level automation behaviours.  The handlers are intentionally
stateless so that they can be reused both in production code and inside test
suites.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Mapping, Protocol, Sequence, runtime_checkable


@runtime_checkable
class GitHubClientProtocol(Protocol):
    """Protocol describing the minimal surface used by the handlers."""

    def add_issue_comment(self, repo: str, issue_number: int, body: str) -> None:
        ...

    def add_issue_labels(self, repo: str, issue_number: int, labels: Sequence[str]) -> None:
        ...

    def add_pull_request_comment(self, repo: str, pr_number: int, body: str) -> None:
        ...

    def add_pull_request_labels(self, repo: str, pr_number: int, labels: Sequence[str]) -> None:
        ...

    def request_reviewers(self, repo: str, pr_number: int, reviewers: Sequence[str]) -> None:
        ...

    def add_discussion_comment(self, repo: str, discussion_number: int, body: str) -> None:
        ...

    def update_project_item_status(self, project_id: int, item_id: int, status: str) -> None:
        ...


@dataclass(slots=True)
class GitHubEventHandler:
    """Coordinates automation flows for GitHub webhook payloads."""

    client: GitHubClientProtocol
    triage_label: str = "needs-triage"
    review_label: str = "needs-review"
    community_label: str = "community"
    backlog_status: str = "Backlog"
    default_reviewers: Sequence[str] | None = None

    def handle_issue(self, payload: Mapping[str, Any]) -> Dict[str, Any]:
        """Process an issue payload by triaging, labelling, and thanking authors."""

        repository = _pluck(payload, "repository", "full_name")
        issue_number = int(_pluck(payload, "issue", "number"))
        action = str(payload.get("action", "")).lower()

        summary: Dict[str, Any] = {"actions": []}

        if action == "opened":
            commenter = _pluck(payload, "issue", "user", "login", default="contributor")
            message = (
                f"Thanks for opening this issue, @{commenter}! The infrastructure team will "
                "triage it shortly."
            )
            self.client.add_issue_comment(repository, issue_number, message)
            self.client.add_issue_labels(repository, issue_number, [self.triage_label])
            summary["actions"].extend(["commented", "labelled"])
        elif action == "reopened":
            message = (
                "Welcome back! We'll take another look at this issue to see what changed."
            )
            self.client.add_issue_comment(repository, issue_number, message)
            summary["actions"].append("commented")
        elif action == "closed" and _pluck(payload, "issue", "state", default="") == "closed":
            message = (
                "This issue is now closed. If you need further help, feel free to create a new "
                "issue so we can track it separately."
            )
            self.client.add_issue_comment(repository, issue_number, message)
            summary["actions"].append("commented")

        return summary

    def handle_pull_request(self, payload: Mapping[str, Any]) -> Dict[str, Any]:
        """Process pull request payloads by welcoming authors and coordinating reviews."""

        repository = _pluck(payload, "repository", "full_name")
        pr_number = int(_pluck(payload, "pull_request", "number"))
        action = str(payload.get("action", "")).lower()
        pull_request = payload.get("pull_request", {})

        summary: Dict[str, Any] = {"actions": []}

        if action == "opened" and not bool(pull_request.get("draft", False)):
            author = _pluck(payload, "pull_request", "user", "login", default="contributor")
            welcome = (
                f"Thanks for the pull request, @{author}! A reviewer will take a look soon."
            )
            self.client.add_pull_request_comment(repository, pr_number, welcome)
            self.client.add_pull_request_labels(repository, pr_number, [self.review_label])
            summary["actions"].extend(["commented", "labelled"])

            reviewers = list(self.default_reviewers or [])
            if reviewers:
                self.client.request_reviewers(repository, pr_number, reviewers)
                summary["actions"].append("requested_reviewers")
        elif action == "closed" and bool(pull_request.get("merged", False)):
            message = "This pull request has been merged. Thank you for the contribution!"
            self.client.add_pull_request_comment(repository, pr_number, message)
            summary["actions"].append("commented")

        return summary

    def handle_discussion(self, payload: Mapping[str, Any]) -> Dict[str, Any]:
        """Process new discussions by guiding contributors to the right resources."""

        repository = _pluck(payload, "repository", "full_name")
        discussion_number = int(_pluck(payload, "discussion", "number"))
        action = str(payload.get("action", "")).lower()
        category = _pluck(payload, "discussion", "category", "slug", default="general")

        summary: Dict[str, Any] = {"actions": []}

        if action == "created":
            if category == "ideas":
                message = (
                    "Thanks for sharing your idea! Please include goals, risk, and rollout "
                    "considerations so the team can evaluate it effectively."
                )
            else:
                message = (
                    "Welcome to the discussion board! Share as much context as possible so "
                    "the community can jump in."
                )

            self.client.add_discussion_comment(repository, discussion_number, message)
            summary["actions"].append("commented")

        return summary

    def handle_project(self, payload: Mapping[str, Any]) -> Dict[str, Any]:
        """Normalize new project items by assigning a consistent default status."""

        project_id = int(_pluck(payload, "project", "id"))
        project_title = _pluck(payload, "project", "title", default="project")
        item_id = int(_pluck(payload, "item", "id"))
        action = str(payload.get("action", "")).lower()

        summary: Dict[str, Any] = {"actions": [], "project": project_title}

        if action == "created":
            self.client.update_project_item_status(project_id, item_id, self.backlog_status)
            summary["actions"].append("moved_to_backlog")
        elif action == "status_changed":
            new_status = _pluck(payload, "item", "status", default=self.backlog_status)
            self.client.update_project_item_status(project_id, item_id, new_status)
            summary["actions"].append("updated_status")

        return summary


def _pluck(mapping: Mapping[str, Any], *keys: str, default: Any | None = None) -> Any:
    """Retrieve nested dictionary values using a series of keys."""

    current: Any = mapping
    for key in keys:
        if isinstance(current, Mapping) and key in current:
            current = current[key]
        else:
            return default
    return current
