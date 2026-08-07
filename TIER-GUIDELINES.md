# Release-Group Tier Guidelines — 1080p Quality

**Scope:** the six `1080p Quality Tier N` custom formats and how the `1080p Quality`
profile consumes them. This documents the system *as it exists* on `fix/regex-audit`
(no tier changes are proposed here). It is the reference to follow when adding new
groups or releases later. Other resolutions (720p, 2160p, …) follow the same pattern
and can be appended to this doc as they are mapped.

---

## 1. What a "tier" physically is

A tier is a **custom format** (CF) whose conditions come in two layers:

**Gate conditions** (identical across all six tiers — a release must pass *all* of them):

| Condition | Type | Flags | Effect |
|---|---|---|---|
| `1080p` | resolution | required | Only 1080p releases |
| `Not Remux` | release_title | required + negate, pattern `\b((BD\|UHD)[-_. ]?)?Remux\b` | Remuxes are excluded (they have their own CFs) |
| `Bluray` | source | optional | Source must be Bluray… |
| `WEBRip` | source | optional, **radarr only** | …or WEBRip, but only on the movie side |

**Membership conditions** — one `release_group` condition per group, all optional
(`negate 0, required 0`). CF semantics: conditions of the same type are OR'd,
different types are AND'd. So the CF matches when:

```
1080p  AND  not-a-remux  AND  (Bluray OR radarr-WEBRip)  AND  (release group ∈ tier list)
```

Notes that follow from this:

- On **Sonarr**, WEBRips never earn a tier bonus (the WEBRip source condition is
  radarr-scoped — op `3.designate-webrips-to-radarr-side-only-for-1080p-quality-tier.sql`).
- A group can be side-scoped individually: `FraMeSToR` is `radarr`-only in Tier 5
  (op 99 removed it sonarr-side).
- Each membership condition points at one row in `regular_expressions`; every
  pattern uses the same boundary idiom: `(?<=^|[\s.-])NAME\b`.

## 2. How tiers plug into the profile's scoring

Effective scores in `1080p Quality` (Profilarr prefers an arr-specific score row over
an `all` row — `sync/qualityProfiles/transformer.ts`; the older `all` rows at
125000…120000 are dormant legacy):

| CF | Score (radarr & sonarr) |
|---|---|
| 1080p Quality Tier 1 | 185000 |
| 1080p Quality Tier 2 | 184000 |
| 1080p Quality Tier 3 | 183000 |
| 1080p Quality Tier 4 | 182000 |
| 1080p Quality Tier 5 | 181000 |
| 1080p Quality Tier 6 | 180000 |

The tier bonus sits on top of the source-ladder CFs (`1080p WEB-DL` 860000,
`1080p Bluray` / `1080p WEBRip` 700000). That layering *is* the design:

- **Tiered Bluray beats WEB-DL:** 700000 + ≥180000 = ≥880000 > 860000 (+ WEB-DL
  Tier bonuses, which max at 100).
- **Un-tiered Bluray loses to WEB-DL:** 700000 + 0 < 860000. A Bluray encode from a
  group not in any tier is *worse than a WEB-DL* under this profile's philosophy,
  because an unvetted encode may be starved/filtered while WEB-DL is untouched
  source video.
- **Tier order dominates within Blurays:** adjacent tiers differ by 1000, while the
  additive bonuses a Bluray can earn (audio: FLAC 800 … AAC 200; repacks ≤ 8) stay
  below 1000, so a Tier-3 release always outranks a Tier-4 release regardless of
  audio codec. (Edition bonuses of exactly 1000 can tie a release *into* the next
  tier's baseline but never leapfrog it.)
- **Vetoes trump everything:** −999999 CFs (x265/h265, HDR/DV, Remux, Upscale,
  `Release Group (Missing)`, banned groups, …) keep this profile x264/SDR/encode-only.
  A release with no parsable group can never score a tier, by construction.

## 3. The tier ladder (current membership)

The database stores membership, not rationale. The characterizations below are
inferred from Dictionarry's transparency-comparison methodology (encode quality
measured against the source, not popularity) and from the ops history in this repo.

### Tier 1 — 185000 · apex transparent encoders (7 groups)

`coffee, DON, REBORN, SA89, SoLaR, TeamSyndicate, ZoroSenpai`

The short list of groups whose 1080p x264 Bluray encodes are considered
indistinguishable from source. Effectively a closed set: no op in this repo's
history has ever added to it.

### Tier 2 — 184000 · elite (10 groups)

`c0kE, CtrlHD, D-Z0N3, EbP, Geek, HiFi, LoRD, TayTo, VietHD, ZQ`

Long-established encoders with near-transparent output; the classic "internals"
canon. Also closed in practice — no additions in ops history.

### Tier 3 — 183000 · excellent (9 groups)

`BV, CRiSC, decibeL, FoRM, HiDt, HiP, iFT, SbR, WMING`

Consistently excellent, marginally below Tier 2 in comparisons. No additions in
ops history.

### Tier 4 — 182000 · very good (9 groups)

`BMF, de[42], eXterminator, HDMaNiAcS, IDE, LolHD, NCmt, NTb, Skazhutin`

Strong groups with occasional visible compromises. One historical addition:
`eXterminator` (op 79) — the only op ever to place a group above Tier 5.

### Tier 5 — 181000 · trusted / **the default landing tier** (61 groups)

`0BSiDiAN, AJP69, ATELiER, BAT1, BSTD, Chotab, CJ, CRX, Dariush, E1, EA, E.N.D,
EDPH, ENDSkY, ESiR, EXCiSION, faBR, FraMeSToR (radarr-only), GALAXY, GS88, GZ,
hdalx, HQMUX, HR, iLoveHD, IMNEWHERE, KASHMiR, Kitsune, LAZY, LiNG, luvBB,
Natuyuki, NiBuRu, nmd, NyHD, ORiGEN, pcroland, Penumbra, playHD, Positive,
Prestige, PTer, RiCO, rightSIZE, RO, Rose3Thorn, rttr, SaNcTi, SiMPLE, Softboat,
SOP, SPHD, TBB, TDD, TnP, ViSUM, VLAD, W4NK3R, WiLF, xander, ZIMBO`

Vetted, reliably good encoders that haven't (yet) accumulated the comparison
record of Tiers 1–4. This is where new groups go: **14 of the 18 group-addition
ops in this repo target Tier 5** (GZ 86, iLoveHD 96, ViSUM 97, Softboat 100,
Rose3Thorn 101, Natuyuki 102, IMNEWHERE 103, pcroland 104, HR 105, Prestige 117,
ENDSkY 148, faBR 175, BAT1 186, 0BSiDiAN 204).

### Tier 6 — 180000 · acceptable fallback (29 groups)

`ASD87, BakedFEL, BRUTE, BTN, CART, CHD, EuReKA, GALVANiZE, HaB, HANDJOB, HDC,
iON, Ivandro, j3rico, KnG, LEGi0N, Lulz, MaG, MTeam, NiP, P0W4HD, PTP, PuTao,
ROCiNANTE, Slappy, ThD, WiKi, WiLDCAT`

High-volume or historical groups (scene, prolific P2P, tracker autotools like
`BTN`/`PTP`) whose encodes are decent but not comparison-vetted. The point of this
tier is coverage: *any* tier beats WEB-DL, so Tier 6 marks "safe to prefer over
WEB-DL, but upgrade to anything higher." Additions: CART 84, BakedFEL 85, ORBiT 87,
BTN 178.

## 4. Invariants (must stay true after any change)

1. **Gate conditions are identical across all six tiers.** Never edit one tier's
   gates alone.
2. **A group appears in at most one 1080p Quality tier** (per arr side).
3. **`(Efficient)` mirrors stay in lock-step.** `1080p Quality Tier N (Efficient)`
   (used by the 1080p/2160p Efficient profiles as radarr x264-Bluray fallbacks,
   ops 141/143) has byte-identical membership — verified empty diff. Every
   membership op must touch both CFs (see op 204's shape).
4. **Adjacent-tier score gap (1000) must stay larger than any achievable sum of
   additive non-tier bonuses on a Bluray release.**
5. **Regex convention:** name = canonical group spelling; pattern =
   `(?<=^|[\s.-])NAME\b` (escape regex metacharacters in NAME); tagged `Release
   Group` + `Bluray`.
6. **History is append-only:** changes ship as a new numbered `ops/N.slug.sql`
   batch export — never edit an existing op.

## 5. How to add a new group (procedure)

Follow the canonical shape of `ops/204.add-0bsidian-to-1080p-quality-tier-5.sql`:

1. **Vet the group.** Evidence should be encode-quality based: screenshot/SSIM
   comparisons against source, tracker reputation, encoder identity. Volume alone
   is not evidence of quality (that's what Tier 6 is for).
2. **Pick the tier:**
   - Default is **Tier 5**. Every first placement of a modern group in this repo's
     history landed there (or Tier 6).
   - **Tier 6** if the group is high-volume/auto-generated but acceptable
     (tracker internals, prolific scene groups).
   - **Tiers 1–4 are effectively closed.** Placing or promoting into them requires
     head-to-head comparisons against existing members of the target tier — one
     historical precedent exists (eXterminator → Tier 4, op 79).
   - Not sure between 5 and 6? Choose 6. Promotion later is one op; demotion after
     users grabbed inferior releases doesn't undo the downloads.
3. **Create the regex** in `regular_expressions` following invariant 5.
4. **Add the membership condition** (`type release_group, arr_type all, negate 0,
   required 0`) to `1080p Quality Tier N` **and** `1080p Quality Tier N (Efficient)`.
   Use a narrower `arr_type` only with a documented reason (FraMeSToR precedent).
5. **Cover other resolutions the group actually releases in** — e.g. ops 103/148
   added groups to the 720p Tier 5 at the same time. Don't add speculatively.
6. **Verify** with the audit harness: rebuild
   (`audit/harness/replay.sh ops out.db`), then check the group matches its tier CF
   and — critically — does not shadow-match any other CF (short names like `HR`,
   `RO`, `E1`, `EA` are one bad boundary away from false positives; test titles
   containing the token mid-word).
7. **Ship it** as `ops/<next-number>.add-<group>-to-1080p-quality-tier-<n>.sql`
   with the standard `@operation/@entity/@name` header.

## 6. Removing / re-scoping a group

Prefer **side-scoping or removal ops** over rewrites, mirroring op 99
(`remove-framestor-from-1080p-quality-tier-5-sonarr-side-only`): a DELETE (or
arr_type narrowing) in a new op, applied to both the base CF and its
`(Efficient)` mirror.

---

*Sources: SQLite DB rebuilt from `ops/` 0–231 on `fix/regex-audit` (schema 1.1.0);
condition and score tables queried directly; Profilarr score-resolution behavior
confirmed in `src/lib/server/sync/qualityProfiles/transformer.ts`.*
