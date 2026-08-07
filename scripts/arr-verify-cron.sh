#!/usr/bin/env bash
# Daily arr-level verification (dictionarry-arr-verify.service).
# Syncs the disposable verification arrs from Profilarr, then asserts that every
# fork op still does what its report card claims — in a REAL Radarr/Sonarr, not
# just at the regex layer. Files a GitHub issue if an expectation breaks.
set -euo pipefail
cd "$(dirname "$0")/.."
git pull --rebase --quiet origin fix/regex-audit

PROFILARR="${DV_PROFILARR_URL:-http://127.0.0.1:6869}"
for id in 101 102 103 104; do
  curl -s -X POST "$PROFILARR/arr/$id/sync?/syncQualityProfiles" \
    -H "Origin: $PROFILARR" -H "Content-Type: application/x-www-form-urlencoded" \
    --data "" -o /dev/null || true
done
# give the sync jobs time to drain before asserting
for _ in $(seq 1 40); do
  sleep 10
  pending=$(curl -s "$PROFILARR/api/v1/status" -o /dev/null -w "%{http_code}" || echo 000)
  [ "$pending" = "200" ] || continue
  break
done
sleep 30

if ! out=$(python3 scripts/arr_verify.py 2>&1); then
  echo "$out"
  title="Arr-level verification failed $(date -u +%F)"
  if ! gh issue list --repo 4eh5xitv6787h645ebv/jakes-profilarr-database \
        --state open --search "in:title \"$title\"" --json title \
        | grep -q "$title"; then
    gh issue create --repo 4eh5xitv6787h645ebv/jakes-profilarr-database \
      --title "$title" --label sentinel --label audit \
      --body "A fork op no longer behaves as its report card claims, verified against real arrs.

\`\`\`
$out
\`\`\`

Regex-level tests can pass while this fails — the arr normalizes titles before custom formats run. Investigate before shipping anything else."
  fi
  exit 1
fi
echo "$out"
