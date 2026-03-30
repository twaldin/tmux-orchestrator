---
name: orchestrate
description: "Manage a team of Claude Code agents in tmux windows. Spawn agents in worktrees, communicate two-way, monitor health, kill when done. Use when the user needs parallel work, isolated code changes, or long-running agents."
user-invocable: true
---

# tmux Orchestrator: Managing Agent Teams

You are now operating as an orchestrator. You manage a team of Claude Code agents running in named tmux windows. Each agent is isolated, has its own context, and communicates back to you when done.

**Core principle:** The tmux window list is the agent registry. If a window exists, the agent is alive. No daemons, no APIs, no polling.

---

## When to Spawn Agents

Spawn when:
- **Parallel tasks** — multiple independent things that don't need to coordinate in real-time
- **Isolated code changes** — a fix or feature that benefits from its own worktree (no interference with your working tree)
- **Long-running work** — tasks that would consume your context window (analysis, research, multi-file refactors)
- **Adversarial review** — a separate agent with a different perspective (evaluator, security reviewer)
- **Specialization** — tasks that need a different tool set (web research, database work, infrastructure)

Don't spawn when:
- A simple question or single-file change you can do in 60 seconds
- Tasks that are tightly coupled and need constant back-and-forth
- You're already at >80% context (finish current work first)

---

## Spawning Agents

```bash
spawn_teammate <name> <dir> [options]
```

**Options:**
| Flag | Values | Default | Purpose |
|------|--------|---------|---------|
| `--model` | `opus`, `sonnet`, `haiku` | `sonnet` | Model tier |
| `--lifecycle` | `ephemeral`, `persistent` | `ephemeral` | Whether agent exits when done |
| `--task "..."` | string | — | First message sent to agent |
| `--worktree` | flag | off | Create isolated git worktree |
| `--type coder` | flag | off | Add PR workflow and git rules to agent |

**Examples:**

Spawn a researcher:
```bash
spawn_teammate researcher ~/project \
  --model sonnet \
  --task "Research Rust async runtimes. Focus on tokio vs async-std. Return findings via message_parent."
```

Spawn a coder in an isolated worktree:
```bash
spawn_teammate coder-auth ~/project \
  --model sonnet \
  --lifecycle ephemeral \
  --type coder \
  --worktree \
  --task "Implement JWT refresh token rotation. See SPEC.md for requirements."
```

Fix a specific GitHub issue (convenience script):
```bash
spawn_coder 42 --dir ~/project --model sonnet
```

---

## CLAUDE.md Injection

When you spawn an **ephemeral** agent, the script automatically prepends context to the target directory's CLAUDE.md:
- **All ephemerals:** completion protocol (how to use `message_parent` and `/exit`)
- **`--type coder`:** full coder template — PR workflow, git rules, script inventory

The original CLAUDE.md is backed up as `CLAUDE.md.pre-coder-backup`. It's restored when you call `kill_teammate`.

The agent also gets `$TMUX_ORCHESTRATOR_HOME/scripts/` on its PATH automatically.

---

## Two-Way Communication

**You → Agent:**
```bash
send_message <name> "your task or question"
```
The message is prefixed with `[ORCHESTRATOR]: ` to prevent prompt injection.

**Agent → You:**
Agents call `message_parent "done, PR #5 — 24 tests"` from their session.
This injects a message into your tmux pane as `[AGENTNAME]: done, PR #5...`.

You don't need to poll or watch. Messages arrive as new prompts in your window.

---

## Completion Protocol

All ephemeral agents must:
1. `message_parent "summary of what you did"`
2. `/exit` to terminate

When an agent messages you that it's done, call `kill_teammate <name>` to restore CLAUDE.md and close the window.

---

## Monitoring

List all active agents:
```bash
list_teammates
```
Shows window name, whether it's active, current command, and working directory.

Watch for stuck permission prompts (auto-approve):
```bash
watch_agents --auto-approve
```
Run this if an agent seems unresponsive. The Stop hook runs this automatically after each of your responses.

---

## Lifecycle Management

| Situation | Action |
|-----------|--------|
| Agent done and messaged you | `kill_teammate <name>` |
| Agent stuck >10 minutes | `watch_agents` first, then `kill_teammate` |
| Agent context >80% | Send: `send_message <name> "compact yourself — write state.md, run compact_self"` |
| Agent silent for 5+ min | `tmux attach -t <session>:<name>` to inspect, then decide |
| Need to re-task agent | `send_message <name> "new task here"` |

Kill an agent:
```bash
kill_teammate <name>
```
This restores the CLAUDE.md backup and closes the tmux window.

---

## Agent Types Reference

**Ephemeral (default):** Spawned for one task, exits when done. Gets completion protocol injection.

**Persistent (`--lifecycle persistent`):** Long-running, does NOT get injection (it has its own permanent CLAUDE.md). Self-compacts when context fills. Use `/tmux-orchestrator:persistent` to set one up.

**Coder (`--type coder`):** Ephemeral + PR workflow + git rules. Works in a worktree. Creates a PR and exits.

**Researcher:** Ephemeral, uses WebSearch/WebFetch, returns structured findings. See `agents/researcher/agent.md`.

---

## Parallel Work Pattern

For truly parallel work where tasks are independent:

```bash
# Spawn three coders on different issues
spawn_coder 101 --dir ~/project
spawn_coder 102 --dir ~/project
spawn_coder 103 --dir ~/project

# Check status
list_teammates

# Each coder will message_parent when done
# Kill them as they complete
```

Each coder gets its own worktree (branch `agent/coder-<N>`), so they don't interfere.

---

## What's on Agent PATH

Agents spawned by `spawn_teammate` have these scripts available:

| Script | Use |
|--------|-----|
| `message_parent "msg"` | Report back to orchestrator |
| `send_message <name> "msg"` | Message a sibling agent |
| `compact_self [file] [prompt]` | Self-compact (persistent agents) |
| `watch_agents` | Check for stuck permission prompts |

---

## Quick Reference

```bash
# Spawn
spawn_teammate <name> <dir> [--model M] [--lifecycle L] [--task T] [--worktree] [--type coder]
spawn_coder <issue#> [--dir D] [--model M]

# Communicate
send_message <name> "message"     # you → agent
# Agent → you: message_parent (injected to your pane automatically)

# Monitor
list_teammates                    # list all windows
watch_agents --auto-approve       # unstick permission prompts

# Lifecycle
kill_teammate <name>              # clean shutdown
```
