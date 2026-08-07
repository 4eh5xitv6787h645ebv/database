#!/usr/bin/env bash
# Daily evidence pull: sync branch, fetch new release titles, commit+push if changed.
# Run from a dedicated clone by dictionarry-evidence.service (EnvironmentFile
# provides the API keys).
set -euo pipefail
cd "$(dirname "$0")/.."
git pull --rebase --quiet origin fix/regex-audit
python3 scripts/evidence_pull.py
if ! git diff --quiet evidence/titles.txt; then
  git add evidence/titles.txt
  git commit -q -m "Evidence: daily title pull $(date -u +%F)"
  git push -q origin fix/regex-audit
  echo "pushed evidence update"
else
  echo "evidence unchanged"
fi
