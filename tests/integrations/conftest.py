import json
import sys
from pathlib import Path
from typing import Any, Callable, Dict
from unittest.mock import create_autospec

import pytest

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from agent_logic.github_handlers import GitHubClientProtocol


@pytest.fixture
def load_payload() -> Callable[[str], Dict[str, Any]]:
    fixtures_dir = Path(__file__).parent / "fixtures"

    def _loader(name: str) -> Dict[str, Any]:
        path = fixtures_dir / f"{name}.json"
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)

    return _loader


@pytest.fixture
def github_client_mock() -> GitHubClientProtocol:
    return create_autospec(GitHubClientProtocol, spec_set=True, instance=True)
