# Custom-format audit-and-fix loop ledger

started_at: 2026-08-06T22:11:09Z
status: active
consecutive_dry: 0
iteration: 1

Repo: fork `4eh5xitv6787h645ebv/jakes-profilarr-database`, branch `fix/regex-audit`.
Safety: the fork's live v1 `stable` and `custom` branches are read-only for this loop. Never write to any upstream repository.
Scope: custom-format condition wiring, required/optional/negated semantics, Radarr/Sonarr scoping, score reachability, parser behavior, tests, and v1/v2 translation drift. Regex text is in scope only when needed to evaluate a custom-format graph; settled regex hypotheses in `LEDGER.md` remain closed.
Harness: `audit/harness/`, with the schema clone at `~/work/dictionarry-fix-loop/schema`.
Optional local controls: `/home/jake/media-tests-video-files/`, documented in `audit/LOCAL-TEST-ASSETS.md`; repository tests must not depend on this local-only path.
Stop rule inherited from the completed regex loop: stop after five consecutive dry iterations or 40 hours from `started_at`, whichever comes first.
Publication rule: every landed migration gets a newest-first card in `audit/regex-fixes.html`, and `docs/index.html` must be updated in the same commit and remain byte-identical. The user's Claude artifact is deferred by request.
Commit rule: every migration, harness change, corpus/test addition, report update, and ledger update is committed and pushed separately to the safe fork immediately.

## Baseline

- Fresh replay: 228 base operations (ops 0–227) plus `tweaks/hdr-dv-truth-corpus.sql`; foreign keys clean and `PRAGMA integrity_check = ok`.
- Current graph: 257 custom formats, 1,646 conditions, 1,216 condition-pattern links, 2,227 profile-score rows, 206 parser tests, 11 quality profiles, and 533 regex definitions.
- Condition types: 818 release-group, 398 release-title, 258 source, 155 resolution, seven indexer-flag, four release-type, four language, and two quality-modifier rows.
- Condition flags: 987 optional-positive, 416 required-positive, 243 required-negated, and zero optional-negated rows.

## Inherited settled custom-format verdicts — do not repeat without new graph evidence

- **DUBBED wiring**: fixed by op 217; its mutually exclusive Radarr/Sonarr title conditions are optional and OR correctly. The format remains deliberately unscored.
- **Extras wiring**: fixed by op 218; its mutually exclusive app-scoped title conditions are optional and OR correctly. It is live at −999999 in ten profiles per app.
- **QxR/TAoE/HONE-style title-positive plus group-negated fallbacks** are deliberate complements to parsed-group tiers, not inverted conditions. Dashless member suffixes remain a parser/tier-policy issue.
- **Dolby Vision (Without Fallback), HDR/SDR, Atmos (Missing), DTS, DTS-HD MA, Special/Extended Edition, Full Disc, and German DL** graphs are covered by the completed regex loop's compound gates; reopen only if this audit finds a new structural or scoring path.
- **HDR10 (Missing) on Sonarr** is explicitly documented as incompatible with its required source design and is unscored; do not silently turn it into a new policy.
- The prior full title-regex conjunction sweep found no other mutually exclusive required title pair after ops 217–218. This loop will still audit different axes: source/resolution compatibility, app scoping, score reachability, stale/deleted wiring, and parser-test coverage.

## Open hypotheses

- Bootstrap inventory in progress; rank only findings with a concrete runtime or score path.

## Searched sources and queries

- Inherit the exhausted source/query pairs in `LEDGER.md`; do not repeat them.

## Iteration log

- Iteration 1 in progress: whole-database structural inventory and score-reachability triage.
