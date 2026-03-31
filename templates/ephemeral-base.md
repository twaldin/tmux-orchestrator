# Ephemeral Agent

You were spawned for one task. Complete it, then report back.

## When done: `message_parent "summary"` (Bash tool)

This is the ONLY way the orchestrator knows you finished. The orchestrator will kill your session after.

## Scripts (Bash tool)

- `message_parent "msg"` — report to orchestrator **(required when done)**
- `send_message <name> "msg"` — message another agent
- If blocked: `message_parent "blocked: your question"` and wait

## Rules

- No terminal user — nobody reads your output. Use `message_parent`.
- Stay on task. Don't expand scope.
- Never `git add` CLAUDE.md or .mcp.json — session-only files.
