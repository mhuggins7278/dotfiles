---
description: Stage and commit any pending changes
---

# Commit Command

You are an AI agent that helps create well-formatted git commits with conventional commit messages.

## Instructions

1. **Analyze git status**:
   - Run `git status --porcelain` to check for changes
   - If no files are staged, run `git add .` to stage all modified files
   - If files are already staged, proceed with only those files
2. **Analyze the changes**:
   - Run `git diff --cached` to see what will be committed
   - Analyze the diff to determine the primary change type (feat, fix, docs, etc.)
   - Identify the main scope and purpose of the changes
3. **Generate commit message**:
   - Create message following format: `<type>[optional scope]: <description>`
   - Keep description concise, clear, and in imperative mood
   - Show the proposed message to user for confirmation
4. **Execute the commit**:
   - Run `git commit -m "<generated message>"`
   - Display the commit hash and confirm success
   - Provide brief summary of what was committed

## Commit Message Guidelines

When generating commit messages, follow these rules:

- **Atomic commits**: Each commit should contain related changes that serve a single purpose
- **Imperative mood**: Write as commands (e.g., "add feature" not "added feature")
- **Concise first line**: Keep under 72 characters
- **Conventional format**: Use `<type>: <description>` where type is one of:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation changes
  - `style`: Code style changes (formatting, etc.)
  - `refactor`: Code changes that neither fix bugs nor add features
  - `perf`: Performance improvements
  - `test`: Adding or fixing tests
  - `chore`: Changes to the build process, tools, etc.
- **Present tense, imperative mood**: Write commit messages as commands (e.g., "add feature" not "added feature")
- **Concise first line**: Keep the first line under 72 characters

## Examples

### Commit message with description and breaking change footer

feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files

### Commit message with ! to draw attention to breaking change

feat!: send an email to the customer when a product is shipped

### Commit message with scope and ! to draw attention to breaking change

feat(api)!: send an email to the customer when a product is shipped

### Commit message with both ! and BREAKING CHANGE footer

chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.

### Commit message with no body

docs: correct spelling of CHANGELOG

### Commit message with scope

feat(lang): add Polish language

## Agent Behavior Notes

- **Error handling**: If validation fails, give user option to proceed or fix issues first
- **Auto-staging**: If no files are staged, automatically stage all changes with `git add .`
- **File priority**: If files are already staged, only commit those specific files
- **Never push the commit**: I will manually push up the changes when I'm ready.
- **Message quality**: Ensure commit messages are clear, concise, and follow conventional format
- **Success feedback**: After successful commit, show commit hash and brief summary
