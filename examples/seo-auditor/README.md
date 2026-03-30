# Example: SEO Auditor

Spawn a researcher to audit your site's SEO and return a structured report.

```bash
spawn_teammate seo-auditor ~/my-project/docs \
  --model sonnet \
  --task "Audit https://mysite.com for SEO issues.

Check:
- Title tags and meta descriptions (all pages)
- Heading structure (H1/H2 hierarchy)
- Internal linking gaps
- Page load speed indicators (image sizes, script counts)
- Missing alt text
- Sitemap completeness

Write a prioritized report to seo-audit.md.
message_parent with top 3 findings when done."
```

## What the agent does

1. Fetches key pages with WebFetch
2. Checks each SEO factor
3. Prioritizes issues by impact
4. Writes `seo-audit.md` with specific fixes
5. Messages the orchestrator with a summary

## After it completes

```bash
# Agent messages: [SEO-AUDITOR]: Done. 8 issues found. Top 3: ...
kill_teammate seo-auditor
cat ~/my-project/docs/seo-audit.md
```

## Variations

- Pass a list of competitor URLs for comparative analysis
- Schedule as a weekly persistent agent that diffs against last week
- Chain it: spawn a coder after to fix the top 3 issues
