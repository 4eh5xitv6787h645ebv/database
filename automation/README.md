# Automation — how this database improves itself

Set up 2026-08-07. Five moving parts; each is independently disableable.

## 1. CI regression gate (`.github/workflows/gate.yml`)
Every push/PR touching `ops/`, `tweaks/`, `audit/harness/`, or `evidence/`:
replays schema (pinned `1.1.0`) + all ops into SQLite, runs the labeled corpus
through `audit/harness/RegexMatrix` (exact Radarr/Sonarr .NET semantics — every
check must pass), and asserts `check_graph_invariants.sql`. On PRs a second job
rebuilds the **base** branch DB, diffs every regex, runs changed patterns over
`evidence/titles.txt` with `audit/harness/FlipMatrix`, and comments the full
flip list on the PR. A flip that isn't an intended fix is a false positive —
don't merge it.

## 2. Evidence feed (daily 05:00, `dictionarry-evidence.timer`)
`scripts/evidence_pull.py` pulls fresh release titles (metadata only) from
Prowlarr (rotating CF-family search terms) and Radarr/Sonarr grab history into
`evidence/titles.txt`, then commits and pushes. Config (API keys):
`~/.config/dictionarry-automation/env`. Cap: 500 new titles/day.

## 3. Drift sentinel (nightly 05:45, `dictionarry-sentinel.timer`)
`scripts/sentinel.py` rebuilds the DB and files deduplicated GitHub issues for:
unknown release groups recurring in 1080p/Bluray evidence (`tier-candidate`),
obfuscated/retagged releases (`cf-candidate`), and new commits on watched repos
(`upstream`): `Dictionarry-Hub/database` (replay/adapt) and
`Dumpstarr/Database` (ideas only — TRaSH-hybrid policies, never import ops).
State: `~/.local/state/dictionarry-automation/`.

## 4. Weekly improvement session (Sun 07:00, `dictionarry-improve.timer`)
`scripts/improve-cron.sh` clones a disposable copy and runs headless Claude
with `automation/improve-prompt.md`: pick ONE open backlog issue
(`cf-candidate`/`tier-candidate`/`sentinel`, `cheap-win` first), gather
evidence, implement op + corpus tests + report card under LEDGER.md rules, PR
to `fix/regex-audit` with `gh pr merge --auto --squash`. CI is the merge gate.
A no-op session (evidence insufficient → issue comment) is a valid outcome.
Logs: `~/.local/state/dictionarry-automation/improve-*.log`.

## 5. Consumption
The audit Profilarr instance (:6869) links this fork as database 2 with
auto-pull (60 min), so merged changes reach a live Profilarr automatically.
GitHub Pages serves `docs/` from this branch (report must stay byte-identical
to `audit/regex-fixes.html`).

## Operations
- Timers: `systemctl --user list-timers | grep dictionarry`; disable with
  `systemctl --user disable --now dictionarry-<name>.timer`.
- Timers only run while the user session exists; run `loginctl enable-linger`
  once to keep them running when logged out.
- The backlog: issues labeled `cf-candidate` (18 seeded from the 2026-08-07
  gap analysis; 3 marked `cheap-win`), plus whatever the sentinel files.
- Humans and automation share one rulebook: LEDGER.md.
