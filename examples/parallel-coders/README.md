# Example: Parallel Coders

Spawn three coders to fix different GitHub issues simultaneously.

```bash
# Use /tmux-orchestrator:orchestrate first to enter orchestration mode

# Spawn three coders in parallel
spawn_coder 101 --dir ~/my-project
spawn_coder 102 --dir ~/my-project
spawn_coder 103 --dir ~/my-project

# Check status
list_teammates
# NAME                 ACTIVE   COMMAND          DIR
# coder-101            no       node             /tmp/tmux-orchestrator-wt-coder-101
# coder-102            no       node             /tmp/tmux-orchestrator-wt-coder-102
# coder-103            no       node             /tmp/tmux-orchestrator-wt-coder-103

# Unstick any that hit permission prompts
watch_agents --auto-approve

# As each agent finishes, it messages you: [CODER-101]: Done. PR #5 — 12 tests.
# Then kill it:
kill_teammate coder-101
```

## How it works

Each `spawn_coder` call:
1. Creates a git worktree (`/tmp/tmux-orchestrator-wt-coder-<N>`) on a new branch `agent/coder-<N>`
2. Prepends the coder CLAUDE.md template to the project's CLAUDE.md
3. Adds `CLAUDE.md` and `.mcp.json` to `.gitignore` in the worktree to prevent accidental commits
4. Launches `claude --dangerously-skip-permissions` in a new tmux window
5. Sends the issue context as the first message

## What agents get

- `message_parent` on their PATH (messages you when done)
- The issue title and body as their task
- `/gsd:fast` or `/gsd:plan-phase` workflow guidance
- Full coder rules (PR creation, git discipline, no scope expansion)

## After all coders finish

Each leaves a PR open. Review them, merge, and clean up worktrees:
```bash
git worktree prune
```
