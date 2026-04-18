# OpenCode vs Claude Code Configuration Systems: Detailed Research Findings

**Research Date:** April 14, 2026  
**Sources:** 
- OpenCode: https://opencode.ai/docs
- Claude Code: https://docs.anthropic.com/en/docs/claude-code

---

## Executive Summary

OpenCode and Claude Code are two distinct AI coding agents with **similar but separate configuration systems**. While they share some conceptual overlap (agents, skills, instruction files), they have different architectures, file formats, and loading mechanisms. There is **limited direct compatibility** between the two systems, though both support markdown-based instruction files.

---

## 1. OpenCode Configuration System

### 1.1 Core Configuration Files

#### Main Config File: `opencode.json` / `opencode.jsonc`
- **Format:** JSON or JSON with Comments (JSONC)
- **Schema:** https://opencode.ai/config.json
- **Locations (by precedence):**
  1. Remote config (`.well-known/opencode` endpoint) - organizational defaults
  2. Global config (`~/.config/opencode/opencode.json`) - user preferences
  3. Custom config (`$OPENCODE_CONFIG` env var) - custom overrides
  4. Project config (`./opencode.json` in project root) - project-specific
  5. `.opencode` directories - agents, commands, plugins, skills
  6. Inline config (`$OPENCODE_CONFIG_CONTENT` env var) - runtime overrides
  7. Managed config (`/Library/Application Support/opencode/` on macOS, `/etc/opencode/` on Linux, `%ProgramData%\opencode` on Windows)
  8. macOS managed preferences (`.mobileconfig` via MDM) - highest priority

**Key Feature:** Configuration files are **merged together**, not replaced. Later configs override earlier ones only for conflicting keys.

#### TUI-Specific Config: `tui.json` / `tui.jsonc`
- **Format:** JSON or JSONC
- **Schema:** https://opencode.ai/tui.json
- **Locations:** `~/.config/opencode/tui.json` (global) or `tui.json` (project)
- **Contains:** UI settings, themes, keybinds, scroll speed, mouse settings

#### Project Initialization: `AGENTS.md`
- **Created by:** `/init` command
- **Purpose:** Project-specific instructions and coding patterns
- **Location:** Project root
- **Should be committed to Git**

### 1.2 Agents Configuration

#### Agent Definition Methods

**Method 1: JSON in `opencode.json`**
```json
{
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for best practices",
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-5",
      "prompt": "{file:./prompts/review.txt}",
      "tools": {
        "write": false,
        "edit": false
      }
    }
  }
}
```

**Method 2: Markdown files in `.opencode/agents/` or `~/.config/opencode/agents/`**
```markdown
---
description: Reviews code for quality and best practices
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
---

You are in code review mode. Focus on:
- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations
```

#### Agent Types
- **Primary agents:** Main assistants you interact with directly (e.g., Build, Plan)
- **Subagents:** Specialized assistants invoked by primary agents or via `@mention` (e.g., General, Explore)

#### Agent Configuration Options
- `description` (required) - When to use the agent
- `mode` - `primary`, `subagent`, or `all`
- `model` - Override default model
- `prompt` - Custom system prompt (can reference files with `{file:path}`)
- `temperature` - Randomness (0.0-1.0)
- `top_p` - Response diversity
- `steps` / `maxSteps` - Max agentic iterations
- `permission` - Tool access control (ask/allow/deny)
- `tools` (deprecated) - Tool availability
- `color` - Visual appearance
- `hidden` - Hide from UI
- `disable` - Disable agent
- `task_permissions` - Control which subagents can be invoked

### 1.3 Skills Configuration

#### Skill File Structure
- **Location:** `.opencode/skills/<name>/SKILL.md` (project) or `~/.config/opencode/skills/<name>/SKILL.md` (global)
- **Also searches:** `.claude/skills/` and `.agents/skills/` for compatibility
- **Format:** Markdown with YAML frontmatter

#### Skill Frontmatter Fields
```yaml
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---
```

**Required fields:**
- `name` - 1-64 chars, lowercase alphanumeric with hyphens, must match directory name
- `description` - 1-1024 chars, specific enough for agent to choose

**Optional fields:**
- `license`
- `compatibility`
- `metadata` - string-to-string map

#### Skill Discovery
- Walks up from current working directory to git worktree root
- Loads from `.opencode/skills/*/SKILL.md`
- Also loads from `.claude/skills/*/SKILL.md` and `.agents/skills/*/SKILL.md`
- Global: `~/.config/opencode/skills/*/SKILL.md`, `~/.claude/skills/*/SKILL.md`, `~/.agents/skills/*/SKILL.md`

#### Skill Permissions
```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

### 1.4 Instructions and Rules

#### Instructions Configuration
```json
{
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md"
  ]
}
```

- **Format:** Array of paths and glob patterns
- **Purpose:** Load instruction files into model context
- **Supports:** File references with `{file:path}` syntax

### 1.5 Other Configuration Options

#### Tools Configuration
```json
{
  "tools": {
    "write": false,
    "bash": false
  }
}
```

#### Models Configuration
```json
{
  "provider": {},
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

#### Commands Configuration
```json
{
  "command": {
    "test": {
      "template": "Run the full test suite...",
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-haiku-4-5"
    }
  }
}
```

#### MCP Servers
```json
{
  "mcp": {}
}
```

#### Plugins
```json
{
  "plugin": ["opencode-helicone-session", "@my-org/custom-plugin"]
}
```

#### Permissions
```json
{
  "permission": {
    "edit": "ask",
    "bash": "ask"
  }
}
```

#### Formatters
```json
{
  "formatter": {
    "prettier": {
      "disabled": true
    },
    "custom-prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts"]
    }
  }
}
```

---

## 2. Claude Code Configuration System

### 2.1 Core Configuration Files

#### Main Instruction File: `CLAUDE.md`
- **Format:** Markdown
- **Locations (by precedence):**
  1. Managed policy (`/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS, `/etc/claude-code/CLAUDE.md` on Linux, `C:\Program Files\ClaudeCode\CLAUDE.md` on Windows)
  2. Project instructions (`./CLAUDE.md` or `./.claude/CLAUDE.md`)
  3. User instructions (`~/.claude/CLAUDE.md`)
  4. Local instructions (`./CLAUDE.local.md` - personal, add to `.gitignore`)

**Key Feature:** Files are **concatenated**, not overridden. `CLAUDE.local.md` appends after `CLAUDE.md` at each level.

#### Project Rules: `.claude/rules/`
- **Format:** Markdown files with optional YAML frontmatter
- **Location:** `.claude/rules/` (project) or `~/.claude/rules/` (user)
- **Purpose:** Organize instructions by topic or file path
- **Supports:** Symlinks for sharing across projects

#### Rule Frontmatter (Optional)
```yaml
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
---

# API Development Rules
- All API endpoints must include input validation
```

#### Settings Files: `.claude/settings.json` and `.claude/settings.local.json`
- **Format:** JSON
- **Locations:** Project-level or user-level
- **Purpose:** Configure Claude Code behavior (not instructions)

#### Auto Memory: `MEMORY.md`
- **Location:** `~/.claude/projects/<project>/memory/MEMORY.md`
- **Purpose:** Claude's auto-generated learnings
- **Loaded:** First 200 lines or 25KB at session start
- **Scope:** Per git repository (shared across worktrees)

### 2.2 Subagents Configuration

#### Subagent Definition Methods

**Method 1: Markdown files in `.claude/agents/` or `~/.claude/agents/`**
```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
permissionMode: default
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

**Method 2: CLI flag with JSON**
```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

**Method 3: Interactive `/agents` command**
- Opens tabbed interface for managing subagents
- Guided setup or Claude generation

#### Subagent Frontmatter Fields
- `name` (required) - Unique identifier
- `description` (required) - When Claude should delegate
- `tools` - Allowlist of available tools
- `disallowedTools` - Denylist of tools
- `model` - Model to use (sonnet, opus, haiku, inherit, or full ID)
- `permissionMode` - default, acceptEdits, auto, dontAsk, bypassPermissions, plan
- `maxTurns` - Max agentic iterations
- `skills` - Skills to preload
- `mcpServers` - MCP servers available
- `hooks` - Lifecycle hooks
- `memory` - Persistent memory scope (user, project, local)
- `background` - Run as background task
- `effort` - Effort level (low, medium, high, max)
- `isolation` - worktree for isolated copy
- `color` - Display color
- `initialPrompt` - Auto-submitted first turn

#### Built-in Subagents
- **Explore** - Fast, read-only codebase exploration (Haiku model)
- **Plan** - Research agent for plan mode (read-only)
- **general-purpose** - Complex multi-step tasks (all tools)
- **statusline-setup** - Configure status line
- **Claude Code Guide** - Answer questions about features

### 2.3 Skills Configuration

#### Skill File Structure
- **Location:** `.claude/skills/<skill-name>/SKILL.md` (project), `~/.claude/skills/<skill-name>/SKILL.md` (user), or plugin
- **Format:** Markdown with YAML frontmatter
- **Invocation:** `/skill-name` or automatic when relevant

#### Skill Frontmatter Fields
```yaml
---
name: my-skill
description: What this skill does
disable-model-invocation: true
user-invocable: true
allowed-tools: Read Grep
model: sonnet
effort: high
context: fork
agent: Explore
paths:
  - "src/**/*.ts"
  - "tests/**/*.test.ts"
shell: bash
---
```

**Key fields:**
- `name` (required) - Lowercase letters, numbers, hyphens (max 64 chars)
- `description` (recommended) - When to use (1-1536 chars)
- `when_to_use` - Additional trigger context
- `argument-hint` - Expected arguments hint
- `disable-model-invocation` - Only user can invoke
- `user-invocable` - Only Claude can invoke
- `allowed-tools` - Pre-approved tools
- `model` - Override session model
- `effort` - Override effort level
- `context` - Set to `fork` for isolated subagent
- `agent` - Which subagent type (Explore, Plan, etc.)
- `paths` - Glob patterns for conditional loading
- `shell` - bash or powershell
- `hooks` - Lifecycle hooks

#### Skill Content Features
- **String substitution:** `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`
- **Dynamic context injection:** `` !`command` `` runs shell commands before skill content
- **Supporting files:** Reference templates, examples, scripts in skill directory
- **Preloaded skills:** Inject full skill content into subagent context

#### Skill Discovery
- Project: `.claude/skills/<name>/SKILL.md`
- User: `~/.claude/skills/<name>/SKILL.md`
- Plugin: `<plugin>/skills/<name>/SKILL.md`
- Additional directories: `.claude/skills/` within `--add-dir` paths
- **Priority:** Enterprise > Personal > Project > Plugin

#### Skill Permissions
```json
{
  "permissions": {
    "deny": ["Skill(deploy *)", "Skill(send-slack-message)"]
  }
}
```

### 2.4 Hooks Configuration

#### Hook Events
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `SubagentStart` - When subagent begins
- `SubagentStop` - When subagent completes
- `InstructionsLoaded` - When instructions load

#### Hook Configuration in Settings
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/validate-command.sh"
          }
        ]
      }
    ]
  }
}
```

### 2.5 Other Configuration Options

#### Managed Settings
- **Location:** `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux), `C:\Program Files\ClaudeCode\` (Windows)
- **Purpose:** Organization-wide enforcement
- **Cannot be overridden** by user or project settings

#### Environment Variables
- `CLAUDE_CODE_NEW_INIT=1` - Interactive multi-phase `/init` flow
- `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` - Disable auto memory
- `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` - Load CLAUDE.md from additional directories
- `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` - Use PowerShell for shell commands
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` - Disable background task functionality
- `CLAUDE_CODE_SUBAGENT_MODEL` - Override subagent model
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` - Trigger compaction at lower percentage

---

## 3. Detailed Comparison

### 3.1 Configuration File Locations

| Aspect | OpenCode | Claude Code |
|--------|----------|-------------|
| **Global config** | `~/.config/opencode/opencode.json` | `~/.claude/CLAUDE.md` |
| **Project config** | `./opencode.json` | `./CLAUDE.md` or `./.claude/CLAUDE.md` |
| **Local/personal** | N/A (use global) | `./CLAUDE.local.md` |
| **Managed/org** | `/Library/Application Support/opencode/` | `/Library/Application Support/ClaudeCode/` |
| **Rules/instructions** | `.opencode/` subdirs | `.claude/rules/` |
| **Agents** | `.opencode/agents/` or `opencode.json` | `.claude/agents/` |
| **Skills** | `.opencode/skills/` | `.claude/skills/` |
| **Memory** | N/A | `~/.claude/projects/<project>/memory/` |

### 3.2 Instruction Files

| Aspect | OpenCode | Claude Code |
|--------|----------|-------------|
| **Main file** | `AGENTS.md` (project) | `CLAUDE.md` (project/user/org) |
| **Format** | Markdown | Markdown |
| **Scope** | Project-level only | Project/user/org with hierarchy |
| **Merging** | N/A | Files concatenated, not replaced |
| **Rules/topics** | Via `instructions` config | `.claude/rules/` directory |
| **Path-specific** | Via `instructions` glob patterns | Via `paths` frontmatter in rules |
| **Imports** | Via `{file:path}` in config | Via `@path/to/file` in markdown |

### 3.3 Agents/Subagents

| Aspect | OpenCode | Claude Code |
|--------|----------|-------------|
| **Primary agents** | Build, Plan | Main conversation thread |
| **Subagents** | General, Explore | Explore, Plan, general-purpose |
| **Definition** | JSON or markdown | Markdown or CLI JSON |
| **Invocation** | Tab key or `@mention` | `@mention` or `--agent` flag |
| **Tool control** | `tools` or `permission` | `tools` or `disallowedTools` |
| **Model override** | `model` field | `model` field |
| **Permissions** | `permission` object | `permissionMode` field |
| **Memory** | N/A | `memory` field (user/project/local) |
| **Isolation** | N/A | `isolation: worktree` |

### 3.4 Skills/Commands

| Aspect | OpenCode | Claude Code |
|--------|----------|-------------|
| **File format** | Markdown with frontmatter | Markdown with frontmatter |
| **Invocation** | Automatic or via skill tool | `/skill-name` or automatic |
| **Frontmatter** | name, description, license, metadata | name, description, disable-model-invocation, etc. |
| **Supporting files** | N/A | Directory with templates, examples, scripts |
| **Dynamic context** | N/A | `` !`command` `` injection |
| **Preloading** | N/A | `skills` field in subagent |
| **Path-specific** | N/A | `paths` frontmatter |
| **Permissions** | `permission.skill` | `permissions.deny` with `Skill(name)` |
| **Arguments** | N/A | `$ARGUMENTS`, `$N`, `${CLAUDE_SESSION_ID}` |

### 3.5 Configuration Merging

| Aspect | OpenCode | Claude Code |
|--------|----------|-------------|
| **Merge strategy** | Configs merged, later overrides earlier | Files concatenated, later appends |
| **Precedence** | 8 levels (remote → managed) | 4 levels (managed → local) |
| **Conflict resolution** | Later config wins for same key | Later file appends (no override) |
| **Exclusion** | `disabled_providers`, `enabled_providers` | `claudeMdExcludes` |

---

## 4. Overlap and Compatibility

### 4.1 Shared Concepts
1. **Markdown instruction files** - Both use markdown for instructions
2. **Agent/subagent system** - Both have specialized agents
3. **Skills/commands** - Both have reusable workflows
4. **Tool permissions** - Both control tool access
5. **Model selection** - Both allow model override
6. **YAML frontmatter** - Both use YAML for metadata

### 4.2 Compatibility Attempts

#### OpenCode searches for Claude-compatible paths:
- `.claude/skills/*/SKILL.md`
- `.agents/skills/*/SKILL.md`
- `~/.claude/skills/*/SKILL.md`
- `~/.agents/skills/*/SKILL.md`

#### Claude Code reads `AGENTS.md`:
- Can import `AGENTS.md` into `CLAUDE.md` with `@AGENTS.md` syntax
- Allows both tools to read same instructions without duplication

### 4.3 Key Differences

| Aspect | OpenCode | Claude Code |
|--------|----------|-------------|
| **Config format** | JSON/JSONC | Markdown + JSON settings |
| **Instruction scope** | Project-only | Project/user/org hierarchy |
| **Agent types** | Primary + Subagents | Main thread + Subagents |
| **Memory system** | N/A | Auto memory + CLAUDE.md |
| **Hooks** | N/A | PreToolUse, PostToolUse, etc. |
| **Isolation** | N/A | Git worktree isolation |
| **Background tasks** | N/A | Background subagent execution |
| **Managed settings** | MDM support | File-based + MDM |

---

## 5. File Discovery and Loading

### 5.1 OpenCode Discovery

**Config files:**
1. Walk up from current directory to git root
2. Load from `.opencode/` subdirectories
3. Load from `~/.config/opencode/`
4. Load from managed locations

**Agents:**
- `.opencode/agents/` (project)
- `~/.config/opencode/agents/` (global)
- Defined in `opencode.json`

**Skills:**
- `.opencode/skills/*/SKILL.md` (project)
- `~/.config/opencode/skills/*/SKILL.md` (global)
- Also searches `.claude/skills/` and `.agents/skills/`

### 5.2 Claude Code Discovery

**CLAUDE.md files:**
1. Walk up from current directory
2. Load `CLAUDE.md` and `CLAUDE.local.md` at each level
3. Load from `~/.claude/CLAUDE.md`
4. Load from managed location
5. Concatenate all discovered files

**Rules:**
- `.claude/rules/` (project)
- `~/.claude/rules/` (user)
- Loaded on-demand when matching files are edited

**Subagents:**
- `.claude/agents/` (project)
- `~/.claude/agents/` (user)
- Managed location
- CLI `--agents` flag

**Skills:**
- `.claude/skills/` (project)
- `~/.claude/skills/` (user)
- Plugin directories
- Live change detection during session

---

## 6. Practical Integration Scenarios

### 6.1 Using Both Tools in Same Project

**Recommended structure:**
```
project/
├── CLAUDE.md                    # Claude Code instructions
├── AGENTS.md                    # OpenCode instructions (can import CLAUDE.md)
├── .claude/
│   ├── rules/                   # Claude Code rules
│   ├── agents/                  # Claude Code subagents
│   └── skills/
│       └── my-skill/SKILL.md    # Claude Code skills
├── .opencode/
│   ├── agents/                  # OpenCode agents
│   └── skills/
│       └── my-skill/SKILL.md    # OpenCode skills
└── opencode.json                # OpenCode config
```

**Sharing instructions:**
```markdown
# AGENTS.md (OpenCode)
@CLAUDE.md

## OpenCode-specific instructions
- Use the Build agent for implementation
- Use the Plan agent for analysis
```

```markdown
# CLAUDE.md (Claude Code)
# Project instructions for Claude Code

## Build and test
- Run `npm test` before committing
- Use TypeScript for all new code
```

### 6.2 Skill Compatibility

**Create skills in both locations:**
```
.claude/skills/
└── code-review/
    └── SKILL.md

.opencode/skills/
└── code-review/
    └── SKILL.md
```

Both tools can then invoke `/code-review` independently.

### 6.3 Agent Configuration

**OpenCode agents in `opencode.json`:**
```json
{
  "agent": {
    "reviewer": {
      "description": "Code review specialist",
      "mode": "subagent",
      "tools": {"read": true, "write": false}
    }
  }
}
```

**Claude Code subagent in `.claude/agents/reviewer.md`:**
```markdown
---
name: reviewer
description: Code review specialist
tools: Read, Grep, Glob
---
You are a code reviewer...
```

---

## 7. Key Takeaways

### 7.1 Configuration Philosophy

**OpenCode:**
- Centralized JSON configuration
- Hierarchical merging (later overrides earlier)
- Project-level `AGENTS.md` for instructions
- Agents defined in config or markdown

**Claude Code:**
- Distributed markdown instructions
- Hierarchical concatenation (later appends)
- Multi-level CLAUDE.md (org → user → project)
- Subagents defined in markdown
- Persistent auto memory across sessions

### 7.2 When to Use Each

**Use OpenCode for:**
- Centralized agent configuration
- Complex tool permission rules
- Formatter and LSP configuration
- MCP server management
- Plugin ecosystem

**Use Claude Code for:**
- Persistent cross-session memory
- Path-specific rules
- Subagent isolation and background tasks
- Hooks for automation
- Managed organization-wide policies

### 7.3 Compatibility Recommendations

1. **Separate instructions:** Keep `AGENTS.md` and `CLAUDE.md` distinct
2. **Shared skills:** Duplicate skill definitions in both `.opencode/skills/` and `.claude/skills/`
3. **Import pattern:** Use `@AGENTS.md` in `CLAUDE.md` to avoid duplication
4. **Naming conventions:** Use consistent skill/agent names across both systems
5. **Documentation:** Document which tool each instruction is for

### 7.4 Migration Path

**From OpenCode to Claude Code:**
1. Convert `opencode.json` agents to `.claude/agents/` markdown
2. Convert `AGENTS.md` to `CLAUDE.md`
3. Move skills from `.opencode/skills/` to `.claude/skills/`
4. Add `.claude/rules/` for topic-specific instructions

**From Claude Code to OpenCode:**
1. Convert `.claude/agents/` to `opencode.json` agent definitions
2. Convert `CLAUDE.md` to `AGENTS.md`
3. Move skills from `.claude/skills/` to `.opencode/skills/`
4. Add `instructions` config for rule files

---

## 8. Configuration File Examples

### 8.1 OpenCode Full Example

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  
  // Model configuration
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5",
  
  // Agents
  "agent": {
    "build": {
      "description": "Build and implement features",
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-5",
      "prompt": "{file:./prompts/build.txt}",
      "temperature": 0.3
    },
    "plan": {
      "description": "Plan and analyze without making changes",
      "mode": "primary",
      "model": "anthropic/claude-haiku-4-5",
      "permission": {
        "edit": "deny",
        "bash": "deny"
      }
    },
    "reviewer": {
      "description": "Code review specialist",
      "mode": "subagent",
      "tools": {
        "read": true,
        "grep": true,
        "write": false,
        "edit": false
      }
    }
  },
  
  // Default agent
  "default_agent": "build",
  
  // Commands
  "command": {
    "test": {
      "template": "Run tests and fix failures",
      "description": "Run test suite",
      "agent": "build"
    }
  },
  
  // Instructions
  "instructions": [
    "CONTRIBUTING.md",
    ".opencode/rules/*.md"
  ],
  
  // Tools
  "tools": {
    "write": true,
    "bash": true
  },
  
  // Permissions
  "permission": {
    "edit": "ask",
    "bash": "ask"
  },
  
  // MCP servers
  "mcp": {},
  
  // Formatters
  "formatter": {
    "prettier": {
      "disabled": false
    }
  },
  
  // Plugins
  "plugin": ["opencode-helicone-session"],
  
  // Autoupdate
  "autoupdate": true
}
```

### 8.2 Claude Code Full Example

```markdown
# CLAUDE.md

## Project Overview
This is a TypeScript/React project using Next.js and Tailwind CSS.

## Build and Test Commands
- Build: `npm run build`
- Test: `npm test`
- Dev: `npm run dev`
- Lint: `npm run lint`

## Code Style
- Use 2-space indentation
- Use TypeScript for all new code
- Use functional components with hooks
- Use Tailwind CSS for styling

## Architecture
- API routes in `pages/api/`
- Components in `components/`
- Utilities in `lib/`
- Styles in `styles/`

## Common Workflows
- @docs/git-workflow.md
- @docs/testing-guide.md

## Claude Code Specific
Use plan mode for changes under `src/billing/`.
```

```markdown
# .claude/rules/api-design.md

---
paths:
  - "pages/api/**/*.ts"
---

# API Development Rules

- All endpoints must validate input
- Use consistent error response format
- Include OpenAPI documentation
- Add proper TypeScript types
```

```markdown
# .claude/agents/code-reviewer.md

---
name: code-reviewer
description: Expert code review specialist
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer. When invoked:

1. Run `git diff` to see recent changes
2. Focus on modified files
3. Review for:
   - Code clarity and readability
   - Security vulnerabilities
   - Performance issues
   - Test coverage
   - Best practices

Provide feedback organized by priority.
```

```markdown
# .claude/skills/deploy/SKILL.md

---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
allowed-tools: Bash(npm *) Bash(git *)
---

Deploy to production:

1. Run tests: `npm test`
2. Build: `npm run build`
3. Deploy: `npm run deploy`
4. Verify: Check deployment status
```

---

## 9. Conclusion

OpenCode and Claude Code are **complementary but separate systems** with different philosophies:

- **OpenCode** emphasizes centralized JSON configuration with hierarchical merging
- **Claude Code** emphasizes distributed markdown instructions with hierarchical concatenation

**Limited direct compatibility exists**, but both can coexist in the same project by:
1. Maintaining separate instruction files (`AGENTS.md` vs `CLAUDE.md`)
2. Duplicating skills in both locations
3. Using import syntax to avoid duplication
4. Following consistent naming conventions

For teams using both tools, the recommended approach is to maintain **separate but parallel configurations**, with shared high-level instructions imported where possible.
