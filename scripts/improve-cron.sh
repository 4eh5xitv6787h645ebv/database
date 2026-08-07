#!/usr/bin/env bash
# Weekly unattended improvement session (dictionarry-improve.service).
# Fresh disposable clone -> headless claude with the improvement prompt -> cleanup.
set -euo pipefail
STATE="$HOME/.local/state/dictionarry-automation"
mkdir -p "$STATE"
WORK="$(mktemp -d /tmp/dictionarry-improve-XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
git clone -q --branch fix/regex-audit \
  https://github.com/4eh5xitv6787h645ebv/jakes-profilarr-database "$WORK/repo"
export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$HOME/.local/bin:$DOTNET_ROOT:$PATH"
cd "$WORK/repo"
LOG="$STATE/improve-$(date -u +%Y%m%dT%H%M%SZ).log"
claude -p "$(cat automation/improve-prompt.md)" \
  --dangerously-skip-permissions \
  >"$LOG" 2>&1 || { echo "improvement session failed; see $LOG" >&2; exit 1; }
tail -5 "$LOG"
