# Example: Monitor Bot

A persistent agent that watches a system and alerts on anomalies.

## Setup

```bash
mkdir -p ~/agents/monitor
```

Write `~/agents/monitor/CLAUDE.md`:
```markdown
# System Monitor

I am a persistent monitoring agent. I check system health every 10 minutes
and alert the orchestrator if anything is wrong.

## Startup Sequence
1. Read state.md
2. Recreate crons from crons.md
3. Begin monitoring loop

## What I Monitor
- Server response times (ping key endpoints)
- Disk usage (alert if >85%)
- Active agent count (alert if unexpected agents appear)

## Alerting
message_parent "ALERT: [description] — [values]"

## Self-Compaction
When context >60%: write state.md, run compact_self
```

Write `~/agents/monitor/crons.md`:
```markdown
# Crons

| Name | Schedule | Action |
|------|----------|--------|
| health-check | every 10 minutes | Check servers, disk, agents. Log results. Compact if needed. |
```

## Spawn it

```bash
spawn_teammate monitor ~/agents/monitor \
  --lifecycle persistent \
  --model haiku \
  --task "Read CLAUDE.md and begin your monitoring loop."
```

## What happens

The monitor agent:
1. Reads its CLAUDE.md and crons.md on boot
2. Creates a heartbeat cron (every 10 min)
3. At each heartbeat: checks health, logs to state.md, messages parent if anomalies
4. Self-compacts when context >60%, resumes from state.md

## Killing it

```bash
kill_teammate monitor
```

No CLAUDE.md backup is needed (persistent agents own their CLAUDE.md).
