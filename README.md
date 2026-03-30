# tmux-orchestrator

> Other tools give you an agent framework. This gives you tmux windows.

A Claude Code plugin for managing multi-agent teams in tmux. Spawn Claude Code agents in isolated windows with their own context, git worktrees, and task injection. Two-way communication via tmux send-keys. No daemons, no APIs, no polling — the window list is the registry.

## What You Get

- **Two skills:** `/tmux-orchestrator:orchestrate` (reactive management) and `/tmux-orchestrator:persistent` (always-on orchestrator)
- **Eight scripts:** spawn, kill, message, list, watch, compact — all bash, all tmux
- **Agent templates:** ephemeral, coder, persistent, researcher
- **CLAUDE.md injection:** coders get task context and completion protocols baked in
- **Worktree isolation:** each coder gets its own branch — no merge conflicts during parallel work
- **Auto-approval:** `watch_agents` unblocks stuck permission prompts across all agent panes

## Installation

### From GitHub (now)

```bash
# In your Claude Code settings.json
{
  "enabledPlugins": {
    "tmux-orchestrator": {
      "source": "github:twaldin/tmux-orchestrator"
    }
  }
}
```

### Local development

```json
{
  "enabledPlugins": {
    "tmux-orchestrator@local": {
      "source": "local:/path/to/tmux-orchestrator"
    }
  }
}
```

### Standalone (without plugin system)

Add to your shell profile:
```bash
export TMUX_ORCHESTRATOR_HOME="$HOME/tmux-orchestrator"
export PATH="$TMUX_ORCHESTRATOR_HOME/scripts:$PATH"
```

## Requirements

- tmux
- Claude Code CLI (`claude`)
- bash
- `git` and `gh` (for `spawn_coder`)

## Quick Start

1. Start a tmux session
2. Launch Claude Code
3. Run `/tmux-orchestrator:orchestrate`

You're now an orchestrator. Spawn your first agent:

```bash
spawn_teammate researcher ~/my-project \
  --task "Research the top 3 Rust async runtimes. Return findings via message_parent."
```

When it's done, it messages you: `[RESEARCHER]: Done. Findings in research-rust-async.md.`

Then: `kill_teammate researcher`

## Scripts

All scripts live in `scripts/` and are added to spawned agents' PATH automatically.

| Script | Usage |
|--------|-------|
| `spawn_teammate` | Spawn agent in named tmux window |
| `kill_teammate` | Kill agent, restore CLAUDE.md, close window |
| `send_message` | Send message to agent (orchestrator → agent) |
| `message_parent` | Send message to orchestrator (agent → orchestrator) |
| `list_teammates` | List all agent windows with status |
| `watch_agents` | Auto-approve stuck permission prompts |
| `compact_self` | Agent self-compaction: write state, /clear, resume |
| `spawn_coder` | Convenience: worktree + GitHub issue context |

### spawn_teammate

```
spawn_teammate <name> <dir> [--model M] [--lifecycle L] [--task T] [--worktree] [--type coder]
```

- `--model opus|sonnet|haiku` — model tier (default: sonnet)
- `--lifecycle ephemeral|persistent` — whether agent exits when done (default: ephemeral)
- `--task "..."` — first message sent to agent
- `--worktree` — create git worktree for file isolation
- `--type coder` — add PR workflow + git rules to injection

### spawn_coder

```
spawn_coder <issue_number> [--dir <project_dir>] [--model M]
```

Fetches GitHub issue, creates worktree, spawns coder with full context.

## Skills

### /tmux-orchestrator:orchestrate

The core product. Teaches you:
- When to spawn agents vs when to just do the work yourself
- How to use all the scripts
- Two-way communication patterns
- Lifecycle management (kill, compact, re-task)
- Parallel work patterns

### /tmux-orchestrator:persistent

Advanced. Teaches you how to run as an always-on orchestrator:
- Directory setup (state.md, tasks.md, crons.md)
- Self-compaction when context fills
- Heartbeat crons
- Task queue and proactive work loop
- Spawning persistent sub-agents

## Agent Types

### Ephemeral

Default. Spawned for one task, exits when done. Gets completion protocol injection (message_parent + /exit).

```bash
spawn_teammate analyst ~/data \
  --task "Analyze sales-q1.csv. Write findings to analysis.md. message_parent when done."
```

### Coder (`--type coder`)

Ephemeral + PR workflow + git rules. Designed for worktree-isolated code changes.

```bash
spawn_teammate fix-auth ~/project --type coder --worktree \
  --task "Fix the JWT expiry bug in auth/token.ts. Tests in auth/token.test.ts."
```

### Persistent (`--lifecycle persistent`)

Long-running. Has its own permanent directory with state.md and crons.md. Self-compacts independently.

```bash
spawn_teammate monitor ~/agents/monitor --lifecycle persistent \
  --task "Read CLAUDE.md and begin your monitoring loop."
```

### Researcher

Ephemeral. WebSearch + WebFetch + structured report. See `agents/researcher/agent.md`.

```bash
spawn_teammate researcher ~/scratch \
  --task "Research competing products in the CI/CD space. Focus on developer experience."
```

## CLAUDE.md Injection

When you spawn an ephemeral agent, the spawner prepends context to the target directory's CLAUDE.md:

- **All ephemerals:** completion protocol (message_parent + /exit instructions)
- **`--type coder`:** full coder template (PR workflow, git rules, script inventory)

Original CLAUDE.md is backed up as `CLAUDE.md.pre-coder-backup`. Restored when you `kill_teammate`.

## How Communication Works

```
Orchestrator                          Agent
     │                                  │
     │  spawn_teammate researcher       │
     │ ─────────────────────────────→   │  (tmux window created)
     │                                  │
     │  send_message researcher "task"  │
     │ ─────────────────────────────→   │  (tmux send-keys)
     │                                  │
     │                                  │  (agent works...)
     │                                  │
     │  [RESEARCHER]: Done. report.md   │
     │ ←─────────────────────────────   │  (message_parent → tmux send-keys)
     │                                  │
     │  kill_teammate researcher        │
     │ ─────────────────────────────→   │  (window closed, CLAUDE.md restored)
```

No HTTP. No queues. No polling. Messages are injected directly into tmux panes.

## Examples

See `examples/` for complete walkthroughs:

- `parallel-coders/` — three coders fixing different bugs simultaneously
- `monitor-bot/` — persistent system monitor with heartbeat crons
- `evaluator/` — adversarial PR reviewer using opus
- `stock-monitor/` — market hours agent with self-compaction
- `seo-auditor/` — ephemeral research agent

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `TMUX_ORCHESTRATOR_HOME` | Auto-detected | Path to plugin root |
| `TMUX_ORCHESTRATOR_SESSION` | Current tmux session | Session to spawn agents in |
| `AGENT_NAME` | (set by spawn_teammate) | Agent's name (injected) |
| `ORCHESTRATOR_SESSION` | (set by spawn_teammate) | Session to message back to |
| `ORCHESTRATOR_WINDOW` | (set by spawn_teammate) | Window to message back to |

## What's Not Included

- **Discord routing** — ships separately as `claudecord` plugin. Depends on this plugin.
- **HTTP API / daemon** — not needed. Bash + tmux is sufficient.
- **Agent registry file** — the tmux window list is the registry.
- **Domain-specific agents** (trader, etc.) — see `examples/` for patterns.

## License

MIT — see LICENSE.
