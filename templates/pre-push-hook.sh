#!/bin/bash
# pre-push hook — blocks .mcp.json and CLAUDE.md from being pushed
#
# Installed by spawn_teammate for coder agents.
# These files are injected by the spawner and must not be committed to the remote.

BLOCKED_FILES=".mcp.json CLAUDE.md"

while read local_ref local_sha remote_ref remote_sha; do
  if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
    RANGE="$local_sha"
  else
    RANGE="$remote_sha..$local_sha"
  fi

  for file in $BLOCKED_FILES; do
    if git log --diff-filter=A --name-only --pretty=format: "$RANGE" 2>/dev/null | grep -qx "$file"; then
      echo "ERROR: $file was injected by spawn_teammate and must not be pushed."
      echo "       Stage only the files you changed, not .mcp.json or CLAUDE.md."
      exit 1
    fi
  done
done
