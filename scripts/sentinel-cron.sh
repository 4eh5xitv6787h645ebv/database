#!/usr/bin/env bash
# Nightly sentinel run from a dedicated clone (dictionarry-sentinel.service).
set -euo pipefail
cd "$(dirname "$0")/.."
git pull --rebase --quiet origin fix/regex-audit
export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$DOTNET_ROOT:$PATH"
python3 scripts/sentinel.py
