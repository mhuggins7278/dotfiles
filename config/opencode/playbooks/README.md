# OpenCode Playbooks

Playbooks are step-by-step guides for recurring operations. Rather than having the AI reverse-engineer how to do something from existing code every time, a playbook provides an explicit path to follow.

## When to write a playbook
- "How to add a new CLI command"
- "How to implement a new API endpoint in repo X"
- "How to handle database migrations"

## Structure
A good playbook should:
1. State its goal and target repository clearly.
2. Outline the exact mechanical steps required.
3. List the validation/testing commands to prove it worked.

When OpenCode agents run into repeated friction on standard tasks, the `/retro` skill will suggest extracting the successful workflow into a playbook here.
