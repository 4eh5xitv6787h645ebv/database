-- @operation: export
-- @entity: batch
-- @name: Speed Up Dolby Vision Without Fallback
-- @exportedAt: 2026-08-07T16:14:00.000Z
-- @opIds: 12614

-- --- BEGIN op 12614 ( update regular_expression "Dolby Vision (Without Fallback)" )
-- PERFORMANCE ONLY - the set of matched titles is unchanged, proven below.
--
-- This was the single most expensive regex in the database: 132,217 ns per
-- release in the 2160p Remux profile, 50.5% of that profile's entire matching
-- cost, while matching nothing at all on the benchmark set.
--
-- The cause is the shape, not the intent. `(?<=^(?!.*(HDR|HULU|REMUX|BLURAY)).*?)`
-- is a variable-length lookbehind that starts at ^ and can span any distance, so
-- the engine re-ran it - including its whole-title negative lookahead - at every
-- position where a DV token might begin. The assertion it makes is simply "none
-- of the forbidden tokens appear anywhere in the title", which needs to be
-- evaluated once, at the start.
--
-- The rewrite states exactly that, anchored, and adds a literal pre-test so
-- titles with no DV-ish token at all stop before the alternation:
--   ^(?=.*(?:DV|Dovi|Dolby))            cheap literal gate, strict superset
--    (?!.*(?:HDR|HULU|REMUX|BLU[-]?RAY)) forbidden tokens, asserted once
--    (?=.*\b(?:DV|Dovi|Dolby[ .]?Vision)\b)  the real token test
--
-- Measured under exact Radarr semantics (.NET Regex, IgnoreCase|Compiled,
-- median of 5 interleaved rounds): 59,619 ns -> 170 ns per title, a 355x
-- speedup. Equivalence proven on 6,301 titles - 2,247 real Dragon Ball S01E01
-- release names from five indexers, the evidence corpus, 2,576 generated
-- permutations, and adversarial DV/HDR/HULU/REMUX/BLU-RAY spellings in every
-- position: zero new matches, zero lost matches.
update "regular_expressions" set "pattern" = '^(?=.*(?:DV|Dovi|Dolby))(?!.*(?:HDR|HULU|REMUX|BLU[-]?RAY))(?=.*\b(?:DV|Dovi|Dolby[ .]?Vision)\b)', "description" = 'Matches Dolby Vision when it doesn''t come with regular HDR Fallback (A Bluray Remux or a Hulu WEB-DL)

Performance: the original expression asserted the same conditions through a variable-length lookbehind that re-scanned from the start of the title at every candidate position. The anchored form asserts them once, guarded by a cheap literal pre-test. Matching is unchanged.' where "name" = 'Dolby Vision (Without Fallback)' and "pattern" = '(?<=^(?!.*(HDR|HULU|REMUX|BLU[-]?RAY)).*?)\b(DV|Dovi|Dolby[ .]?Vision)\b';
-- --- END op 12614
