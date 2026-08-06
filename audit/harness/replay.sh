#!/usr/bin/env bash
# Replay ops/*.sql in numeric order into a fresh SQLite DB.
# Usage: replay.sh <ops-dir> <output-db> [extra-migration.sql ...]
set -euo pipefail
OPS_DIR="$1"; DB="$2"; shift 2
rm -f "$DB"
HERE="$(cd "$(dirname "$0")" && pwd)"
# Schema layer: Dictionarry-Hub/schema @ 1.1.0 (the dependency pinned in database/pcd.json),
# replayed exactly like profilarr's cache builder — with PRAGMA foreign_keys = ON so
# ON DELETE CASCADE fires (profilarr src/lib/server/pcd/database/cache.ts).
run_sql() {
  { echo "PRAGMA foreign_keys = ON;"; cat "$1"; } | sqlite3 "$DB" || { echo "FAILED at $1" >&2; exit 1; }
}
SCHEMA_DIR="${SCHEMA_DIR:-$HERE/../../../schema}"
for f in $(ls "$SCHEMA_DIR/ops" | grep -E '^[0-9]+\.' | sort -t. -k1,1n); do
  run_sql "$SCHEMA_DIR/ops/$f"
done
for f in $(ls "$OPS_DIR" | grep -E '^[0-9]+\.' | sort -t. -k1,1n); do
  run_sql "$OPS_DIR/$f"
done
for extra in "$@"; do
  run_sql "$extra"
done
echo "Replayed $(ls "$OPS_DIR" | grep -cE '^[0-9]+\.') ops (+$# extra) into $DB"
