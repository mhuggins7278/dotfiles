# Global Context Evaluation

`global-context-scenarios.json` is the acceptance fixture for simplifying
always-loaded OpenCode and Claude Code context. It complements the existing
skill trigger and review fixtures; it does not replace them.

## Baseline Procedure

Before changing a context layer, run every scenario with both tools using the
same repository state and non-destructive permissions. Record:

- whether every expectation passes;
- selected skill, agent, and tool family where observable;
- unsafe or unexpected actions;
- response duration and token usage when the runtime exposes them.

Run the same scenarios after the candidate change. A candidate cannot proceed
when it regresses a safety, path, conditional-policy, or routing expectation.

## Static Checks

Run these before recording an A/B result:

```sh
python3 config/ai/scripts/validate-agent-contracts.py
python3 -m json.tool config/opencode/config.json >/dev/null
python3 -m json.tool config/claude/settings.json >/dev/null
ansible-playbook --syntax-check --list-tasks ansible/dotfiles.yml
ansible-playbook --check --diff ansible/dotfiles.yml --tags links
```

Measure the current static context surface with:

```sh
wc -c -l -w \
  config/opencode/AGENTS.md \
  config/claude/CLAUDE.md \
  AGENTS.md \
  CLAUDE.md \
  config/opencode/agent/*.md \
  config/claude/agents/*.md \
  config/ai/playbooks/*.md
```

## Contract Scope

`../agent-contracts.json` declares the expected OpenCode and Claude adapters,
their canonical core playbook, required abstract capabilities, and mutation
level. The validator confirms that both adapters and their referenced playbook
exist before later phases reduce adapter bodies or migrate permissions.

The contract deliberately does not infer live MCP availability. Runtime smoke
tests remain responsible for verifying actual tool namespaces, per-agent
permission precedence, and MCP connection behavior.
