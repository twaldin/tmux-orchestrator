# Example: Adversarial PR Evaluator

Spawn an evaluator agent to critique a PR from a fresh, skeptical perspective.

```bash
spawn_teammate evaluator ~/my-project \
  --model opus \
  --task "Review PR #47. Be adversarial — assume the author made mistakes.
Check: logic errors, missing edge cases, security issues, test coverage gaps, performance regressions.
Write findings to eval-pr-47.md. message_parent with your verdict when done."
```

## What makes this useful

A second agent reviewing with no context of "what was intended" catches different bugs than the author. Using `--model opus` gets more thorough analysis.

The agent:
- Has no knowledge of the PR author's intentions
- Reads the diff cold
- Tries to find counter-examples and failure modes
- Reports findings objectively

## After it completes

```bash
# Agent messages: [EVALUATOR]: Done. eval-pr-47.md written. 3 issues found.
kill_teammate evaluator
cat ~/my-project/eval-pr-47.md
```
