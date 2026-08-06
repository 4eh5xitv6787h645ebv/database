# Custom-format audit-and-fix loop ledger

started_at: 2026-08-06T22:11:09Z
status: active
consecutive_dry: 0
iteration: 3

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

## Settled custom-format verdicts — do not repeat without new graph evidence

- **DUBBED wiring**: fixed by op 217; its mutually exclusive Radarr/Sonarr title conditions are optional and OR correctly. The format remains deliberately unscored.
- **Extras wiring**: fixed by op 218; its mutually exclusive app-scoped title conditions are optional and OR correctly. It is live at −999999 in ten profiles per app.
- **QxR/TAoE/HONE-style title-positive plus group-negated fallbacks** are deliberate complements to parsed-group tiers, not inverted conditions. Dashless member suffixes remain a parser/tier-policy issue.
- **Dolby Vision (Without Fallback), HDR/SDR, Atmos (Missing), DTS, DTS-HD MA, Special/Extended Edition, Full Disc, and German DL** graphs are covered by the completed regex loop's compound gates; reopen only if this audit finds a new structural or scoring path.
- **HDR10 (Missing) on Sonarr** is explicitly documented as incompatible with its required source design and is unscored; do not silently turn it into a new policy.
- The prior full title-regex conjunction sweep found no other mutually exclusive required title pair after ops 217–218. This loop will still audit different axes: source/resolution compatibility, app scoping, score reachability, stale/deleted wiring, and parser-test coverage.
- **Score fallback precedence**: an `arr_type=all` score is intentionally shadowed by an app-specific score for the same profile/format/app. Profilarr selects both and the app-specific row overrides the fallback; the 72 fully shadowed triples in the quality-tier families are cleanup debt, not double scoring.
- **App filtering**: Profilarr filters non-target conditions plus Radarr-only quality modifiers and Sonarr-only release types before evaluation. No scored format has zero conditions for either effective target app.
- **EA tier membership**: fixed by op 229. The authoritative v1 move commit `a0a23ed` places EA in `720p Quality Tier 5`; its older Tier 4 membership was stale residue. Keep EA only in Tier 5 unless new policy evidence supersedes that history.

## Open hypotheses

- **Remux v2 merge regression**: v1 independently scored title, Radarr quality-match, and Sonarr source formats. Ops 9–11 collapsed them into one graph, but Arr ANDs condition implementation groups; current Radarr is title AND not-DVD AND remux modifier, while Sonarr is title AND not-DVD and its optional `bluray_raw` sibling is ignored. A one-bit `required` change repairs only the dead sibling, not the lost cross-type union; remediation needs a full scoring/format design and app-backed controls.
- **Golden Popcorn app scope (latent)**: all three unscored definitions scope required `ptp_golden` flags to `all` although Profilarr and their descriptions mark the flag Radarr-only. Fix before any built-in Sonarr score path is added; currently no shipped score changes.
- **Extras coverage**: the live −999999 format covers ten profiles per app but omits `1080p Compact`; no explicit history rationale found. Treat as a policy question until release/profile evidence proves omission accidental.
- Description-only debt is tracked separately from runtime bugs: SDR says “Ban” despite deliberate score-zero highlighting; Remux claims an h264/h265 test it does not have; TrueHD (Missing), HDR10 (Missing), Banned WEBRip, Audio Description, and 2160p Quality Tier 6 also have stale or incomplete descriptions.

## Searched sources and queries

- Inherit the exhausted source/query pairs in `LEDGER.md`; do not repeat them.
- Profilarr score transformer and condition evaluator: app-specific score precedence, target-app filtering, and required/optional type-group behavior.
- Fresh whole-graph SQL scans: backing cardinality/type, exact and semantic duplicate signatures, mutually exclusive required values, app expansion, effective scores, scoreless formats, test coverage, and sequential graph history across ops 0–227.
- v1 final YAML on the fork's read-only `stable`/`custom` branches: `720p HDTV Tier 3` carries the same erroneous 1080p condition; the initial v2 translation preserved it exactly.
- Fresh metadata-only Prowlarr query `HANDJOB HDTV`: one real victim, `ESPN.E60.WWE.Behind.The.Curtain.720p.HDTV.x264-HANDJOB`. No content was downloaded.
- Profilarr parser `/parse` and `/match/batch`: the real title parses as television, 720p, release group HANDJOB, with both title/group regexes matching; the constructed 1080p twin parses identically except for resolution.
- EA history across v1 commits `99eb353`, `cf370415`, and `a0a23ed` plus merged PR 93: EA began in 720p Tier 4, was later added to Tier 6, then was explicitly moved to 1080p/720p Tier 5 without removing the old 720p Tier 4 row. The same PR's `fb05d23` move removes its source-tier member, and the neighboring 1080p family ends with EA only in Tier 5. Initial v2 op 0 copied the stale overlap; no later operation changed it.
- Independent TRaSH Guides history carries EA in exactly one HD Bluray tier. Current whole-graph replay likewise found EA to be the only duplicated release group across the base `* Quality Tier N` families.
- Fresh metadata-only Prowlarr controls: movie `Legiony.2019.720p.BluRay.DD5.1.x264-EA` and series `My.Hero.Academia.S03E24.720p.BluRay.AAC.2.0.x264-EA`; both parse as Bluray, 720p, release group EA. The bundled `1883.S01.720p.BluRay.DD5.1.x264-NTb` control parses into Tier 4 only. No content was downloaded. The optional local 12,464-file media corpus and local Arr history contained no exact EA release-group control.

## Iteration log

- **Iteration 1 (2026-08-07)**: area = whole-database structural inventory, score reachability, v1/v2 translation, and parser-test coverage. Result: **1 live bug fixed (op 228)**. `720p HDTV Tier 3` required 1080p, making its full graph identical to `1080p HDTV Tier 3`; both formats overlap in all 11 profiles for both apps, so 1080p HANDJOB HDTV could stack +60000 while the intended 720p release missed +20000. Op 228 exact-guards both the condition name and backing resolution to 720p. Fresh replay of 229 ops plus the tweak is FK-clean with integrity `ok`; all 44 score rows are unchanged; 588/588 native regex checks and 210/210 Profilarr parser-backed tests pass. Profilarr validation database 2 synced through commit `100164e` in job 17 (229 base ops + one tweak). The report and `docs/index.html` were updated byte-identically (SHA-256 `7db189f4798fffaf29da7a9a0c3b8a682be82ca4840c1b9216f5178b0dd09aa7`) and pushed in `0266103`. The bug exists in both v1 and v2; the fork's live v1 branches were inspected read-only and not modified. `consecutive_dry` remains 0; iteration advances to 2.
- **Iteration 2 (2026-08-07)**: area = duplicated release-group tier membership and the complete EA score/app graph. Result: **1 live bug fixed (op 229)**. `720p Quality Tier 4` retained stale EA membership after authoritative commit `a0a23ed` moved EA to Tier 5. The two formats otherwise have identical effective gates and are live at +142000 and +141000 in all 11 profiles for both apps, so eligible Bluray EA releases stacked +283000 in every one of 22 profile/app slots. Op 229 exact-guards and removes only the stale Tier 4 EA condition; its repeat is a no-op, the Tier 5 condition remains exactly once, all score rows are unchanged, foreign keys are clean, and integrity is `ok`. Fresh replay covers 230 base ops plus the tweak; 588/588 native regex checks and 216/216 Profilarr parser-backed tests pass. Direct entity evaluation proves real EA movie and series titles match Tier 5 only, while the real NTb control remains Tier 4 only. Migration `97b4375`, test commits `07d333a` and `bae6ab7`, and Profilarr sync job 19 were pushed to the safe fork. The report and `docs/index.html` were updated byte-identically (SHA-256 `870d0435cdff6adc65751e2e6057def022de58ead9ac70947778e99bd0ad6742`) and pushed in `716f84e`. The bug exists in both v1 and v2; all comparison branches were read-only. `consecutive_dry` remains 0; iteration advances to 3.
- Iteration 3 in progress: v1-to-v2 Remux format merge and its app-specific title/source/quality-modifier score reachability.
