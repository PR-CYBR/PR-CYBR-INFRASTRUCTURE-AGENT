"""Configuration hooks for the dashboard application.

This module exposes helper functions that allow operators and automated
systems to plug in custom workflow handlers and health check logic.
The defaults provide simple in-memory examples that can be replaced by
importing callables from elsewhere in the infrastructure code base.
"""
from __future__ import annotations

from dataclasses import dataclass
from importlib import import_module
import os
from typing import Callable, Dict, List


@dataclass
class Workflow:
    """Represents an executable workflow exposed by the dashboard UI."""

    name: str
    description: str
    handler: Callable[[], str]


@dataclass
class HealthCheck:
    """Represents a status check that can be visualized in the UI."""

    name: str
    description: str
    evaluator: Callable[[], Dict[str, str]]


def _load_overrides(settings_env: str) -> Dict[str, Callable]:
    """Attempt to load overrides from an import path declared in ``settings_env``.

    The environment variable should contain an import path that exposes
    ``WORKFLOWS`` and/or ``HEALTH_CHECKS`` iterables. This makes it easy for
    Codex to ship updated back-end logic without modifying the dashboard UI.
    """

    module_path = os.getenv(settings_env)
    if not module_path:
        return {}

    module = import_module(module_path)
    overrides: Dict[str, Callable] = {}
    for attribute in ("WORKFLOWS", "HEALTH_CHECKS"):
        if hasattr(module, attribute):
            overrides[attribute] = getattr(module, attribute)
    return overrides


def load_workflows() -> List[Workflow]:
    """Load workflow definitions, optionally overriding the defaults."""

    defaults = [
        Workflow(
            name="refresh-caches",
            description="Refreshes cached infrastructure metadata and secrets",
            handler=lambda: "Cache refresh started",
        ),
        Workflow(
            name="rotate-keys",
            description="Kick off key rotation across sensitive services",
            handler=lambda: "Key rotation requested",
        ),
    ]

    overrides = _load_overrides("DASHBOARD_EXTENSIONS")
    if workflows := overrides.get("WORKFLOWS"):
        return [
            Workflow(name=item.name, description=item.description, handler=item.handler)
            for item in workflows
        ]
    return defaults


def load_health_checks() -> List[HealthCheck]:
    """Load health check definitions, optionally overriding the defaults."""

    defaults = [
        HealthCheck(
            name="message-queue",
            description="Latency and backlog for the primary message queue",
            evaluator=lambda: {"status": "ok", "latency_ms": "45", "backlog": "12"},
        ),
        HealthCheck(
            name="scheduler",
            description="Heartbeat information from orchestration services",
            evaluator=lambda: {"status": "degraded", "last_seen": "2m ago"},
        ),
    ]

    overrides = _load_overrides("DASHBOARD_EXTENSIONS")
    if health_checks := overrides.get("HEALTH_CHECKS"):
        return [
            HealthCheck(
                name=item.name, description=item.description, evaluator=item.evaluator
            )
            for item in health_checks
        ]
    return defaults


__all__ = ["Workflow", "HealthCheck", "load_workflows", "load_health_checks"]
