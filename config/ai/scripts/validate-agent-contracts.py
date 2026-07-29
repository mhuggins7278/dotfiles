#!/usr/bin/env python3
"""Validate that each shared agent contract has an OpenCode adapter."""

from __future__ import annotations

import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
CONTRACT_PATH = ROOT / "config/ai/agent-contracts.json"
REQUIRED_ADAPTERS = {"opencode"}
VALID_MUTATION_LEVELS = {
    "read-only",
    "interactive",
    "implementation",
    "approval-required",
}


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_contract() -> dict[str, object]:
    try:
        contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"{CONTRACT_PATH.relative_to(ROOT)} is not valid JSON: {error}")

    if not isinstance(contract, dict):
        fail(f"{CONTRACT_PATH.relative_to(ROOT)} root must be a JSON object")

    return contract


def require_relative_file(path_text: object, label: str) -> Path:
    if not isinstance(path_text, str) or not path_text:
        fail(f"{label} must be a non-empty path")

    path = Path(path_text)
    if path.is_absolute() or ".." in path.parts:
        fail(f"{label} must be a repository-relative path: {path_text}")

    resolved = ROOT / path
    if not resolved.is_file():
        fail(f"{label} does not exist: {path_text}")

    return resolved


def validate_agent(agent: object, seen_ids: set[str]) -> None:
    if not isinstance(agent, dict):
        fail("each agent contract must be an object")

    agent_id = agent.get("id")
    if not isinstance(agent_id, str) or not agent_id:
        fail("each agent contract needs a non-empty id")
    if agent_id in seen_ids:
        fail(f"duplicate agent contract id: {agent_id}")
    seen_ids.add(agent_id)

    playbook_text = agent.get("playbook")
    playbook = require_relative_file(playbook_text, f"{agent_id}.playbook")

    capabilities = agent.get("required_capabilities")
    if not isinstance(capabilities, list) or not capabilities:
        fail(f"{agent_id}.required_capabilities must be a non-empty list")
    if not all(
        isinstance(capability, str) and capability for capability in capabilities
    ):
        fail(f"{agent_id}.required_capabilities must contain only non-empty strings")

    mutation = agent.get("mutation")
    if mutation not in VALID_MUTATION_LEVELS:
        fail(
            f"{agent_id}.mutation must be one of "
            f"{', '.join(sorted(VALID_MUTATION_LEVELS))}"
        )

    adapters = agent.get("adapters")
    if not isinstance(adapters, dict) or set(adapters) != REQUIRED_ADAPTERS:
        fail(f"{agent_id}.adapters must contain exactly: opencode")

    playbook_reference = str(playbook_text)
    for tool, adapter in adapters.items():
        if not isinstance(adapter, dict):
            fail(f"{agent_id}.{tool} adapter must be an object")

        name = adapter.get("name")
        if not isinstance(name, str) or not name:
            fail(f"{agent_id}.{tool}.name must be a non-empty string")

        adapter_path = require_relative_file(
            adapter.get("path"), f"{agent_id}.{tool}.path"
        )
        adapter_text = adapter_path.read_text(encoding="utf-8")
        if playbook_reference not in adapter_text:
            fail(
                f"{agent_id}.{tool} does not reference its canonical playbook "
                f"{playbook_reference}"
            )

    print(f"validated {agent_id}")


def main() -> None:
    contract = read_contract()
    if contract.get("version") != 1:
        fail("agent contract version must be 1")

    agents = contract.get("agents")
    if not isinstance(agents, list) or not agents:
        fail("agent contracts must contain a non-empty agents list")

    seen_ids: set[str] = set()
    for agent in agents:
        validate_agent(agent, seen_ids)

    print(f"validated {len(seen_ids)} agent contracts")


if __name__ == "__main__":
    main()
