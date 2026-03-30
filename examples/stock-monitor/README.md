# Example: Stock Monitor

A persistent agent that runs during market hours and tracks positions.

## Setup

```bash
mkdir -p ~/agents/stock-monitor
```

Write `~/agents/stock-monitor/CLAUDE.md`:
```markdown
# Stock Monitor

I am a persistent agent that tracks market data during trading hours (9:30-16:00 ET weekdays).

## Startup Sequence
1. Read state.md — restore portfolio state
2. Recreate crons from crons.md
3. Begin monitoring loop

## Responsibilities
- Fetch prices for watchlist at each heartbeat
- Alert orchestrator if price moves >5% in either direction
- Log all data to state.md

## Alerting
message_parent "ALERT: [TICKER] moved [%] to $[price]"

## Self-Compaction
When context >60%: write state.md (include all current prices), run compact_self
```

## Spawn during market hours

```bash
spawn_teammate stock-monitor ~/agents/stock-monitor \
  --lifecycle persistent \
  --model haiku \
  --task "Read CLAUDE.md. Market opens in 5 minutes. Begin monitoring."
```

## Notes

- Use `haiku` — this is high-frequency, low-complexity work
- The agent self-compacts independently, surviving through the trading day
- Kill at market close or when you're done: `kill_teammate stock-monitor`
