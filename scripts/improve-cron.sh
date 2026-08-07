#!/usr/bin/env bash
# Weekly unattended improvement session (dictionarry-improve.service).
# Fresh disposable clone -> headless claude -> cleanup.
#
# Permission model: NOT --dangerously-skip-permissions. The session gets an
# explicit tool allowlist covering only what the documented workflow needs
# (repo edits, git/gh, the harness toolchain). Anything else — WebFetch,
# arbitrary network tools, secret paths — is denied by the harness. This is a
# mitigation, not a jail: Bash(python3 …)/Bash(dotnet …) can still run
# arbitrary repo code, so the real boundary is that the clone is disposable
# and the merge gate is CI on the PR. For a hard boundary, move this into a
# rootless container with network limited to github.com + Prowlarr.
set -euo pipefail
STATE="$HOME/.local/state/dictionarry-automation"
mkdir -p "$STATE"
WORK="$(mktemp -d /tmp/dictionarry-improve-XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
git clone -q --branch fix/regex-audit \
  https://github.com/4eh5xitv6787h645ebv/jakes-profilarr-database "$WORK/repo"
git clone -q --depth 1 --branch 1.1.0 \
  https://github.com/Dictionarry-Hub/schema "$WORK/schema"
export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$HOME/.local/bin:$DOTNET_ROOT:$PATH"
export SCHEMA_DIR="$WORK/schema"
cd "$WORK/repo"
LOG="$STATE/improve-$(date -u +%Y%m%dT%H%M%SZ).log"
claude -p "$(cat automation/improve-prompt.md)" \
  --permission-mode acceptEdits \
  --allowedTools "Read(./**),Read(~/.config/dictionarry-automation/env),Edit(./**),Write(./**),Glob,Grep,TodoWrite,Bash(git *),Bash(gh issue *),Bash(gh pr *),Bash(gh api repos/4eh5xitv6787h645ebv/*),Bash(gh api repos/Dictionarry-Hub/*),Bash(dotnet *),Bash(python3 *),Bash(sqlite3 *),Bash(bash audit/harness/*),Bash(sha256sum *),Bash(cp audit/*),Bash(ls *),Bash(curl -s http://127.0.0.1:9696/*)" \
  >"$LOG" 2>&1 || { echo "improvement session failed; see $LOG" >&2; exit 1; }
tail -5 "$LOG"
