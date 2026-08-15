# Global Context Evaluation

`global-context-scenarios.json` is the acceptance fixture for simplifying
always-loaded OpenCode context and routing behavior.

## Baseline Procedure

Before changing a context layer, run every scenario with the same repository
state and non-destructive permissions. Record:

- whether every expectation passes;
- selected skill, agent, and tool family where observable;
- unsafe or unexpected actions;
- response duration and token usage when the runtime exposes them.

Run the same scenarios after the candidate change. A candidate cannot proceed
when it regresses a safety, path, conditional-policy, or routing expectation.

## Static Checks

Run these before recording an A/B result:

```sh
python3 config/opencode/scripts/audit-skills.py
python3 -m json.tool config/opencode/config.json >/dev/null
ansible-playbook --syntax-check --list-tasks ansible/dotfiles.yml
ansible-playbook --check --diff ansible/dotfiles.yml --tags links
```

The skill audit validates skill names, frontmatter, duplicate names, and local
markdown references. It reports directories without `SKILL.md` as warnings so
workspace fixtures and ignored external shadows remain visible without being
mistaken for runtime skills.

Measure the current static context surface with:

```sh
wc -c -l -w \
  config/opencode/AGENTS.md \
  AGENTS.md \
  config/opencode/agent/*.md \
  config/ai/global-policy.md \
  config/ai/playbooks/workflow.md
```

## Runtime Scope

Static checks do not infer live MCP availability or effective permission order.
Use `opencode debug config`, `opencode debug agent <name>`, and focused runtime
smoke tests to verify tool namespaces and mutation boundaries.
