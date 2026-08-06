# Custom-format audit-and-fix loop ledger

started_at: 2026-08-06T22:11:09Z
status: active
consecutive_dry: 0
iteration: 2

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
- **Score fallback precedence**: an `arr_type=all` score is intentionally shadowed by an app-specific score for the same profile/format/app. Profilarr selects both and the app-specific row overrides the fallback; the 72 fully shadowed triples in the quality-tier families are cleanup debt, not double scoring.
- **App filtering**: Profilarr filters non-target conditions plus Radarr-only quality modifiers and Sonarr-only release types before evaluation. No scored format has zero conditions for either effective target app.

## Open hypotheses

- **720p Quality Tier 4 / Tier 5 shared `EA` member**: both formats carry the same optional-positive `EA` release-group regex and otherwise identical effective app constraints. They overlap in all 22 profile/app slots at +142000 and +141000, so an eligible EA release appears to stack +283000. Trace v1 policy and obtain parser-backed release controls before changing membership.
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

## Iteration log

- **Iteration 1 (2026-08-07)**: area = whole-database structural inventory, score reachability, v1/v2 translation, and parser-test coverage. Result: **1 live bug fixed (op 228)**. `720p HDTV Tier 3` required 1080p, making its full graph identical to `1080p HDTV Tier 3`; both formats overlap in all 11 profiles for both apps, so 1080p HANDJOB HDTV could stack +60000 while the intended 720p release missed +20000. Op 228 exact-guards both the condition name and backing resolution to 720p. Fresh replay of 229 ops plus the tweak is FK-clean with integrity `ok`; all 44 score rows are unchanged; 588/588 native regex checks and 210/210 Profilarr parser-backed tests pass. Profilarr validation database 2 synced through commit `100164e` in job 17 (229 base ops + one tweak). The report and `docs/index.html` were updated byte-identically (SHA-256 `7db189f4798fffaf29da7a9a0c3b8a682be82ca4840c1b9216f5178b0dd09aa7`) and pushed in `0266103`. The bug exists in both v1 and v2; the fork's live v1 branches were inspected read-only and not modified. `consecutive_dry` remains 0; iteration advances to 2.
- Iteration 2 in progress: duplicated release-group tier membership, starting with the live `EA` overlap between 720p Quality Tier 4 and Tier 5.
