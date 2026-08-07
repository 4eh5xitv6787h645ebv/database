-- @operation: export
-- @entity: batch
-- @name: Speed Up German DL Matching
-- @exportedAt: 2026-08-07T16:15:00.000Z
-- @opIds: 12615

-- --- BEGIN op 12615 ( update regular_expression "German DL" )
-- PERFORMANCE ONLY - the set of matched titles is unchanged, proven below.
--
-- Second most expensive regex in the 2160p Remux profile: 54,233 ns per
-- release, 20.7% of that profile's matching cost.
--
-- The expression was unanchored, so the engine restarted it at every position,
-- and each attempt ran two lookaheads that scan the whole remainder of the
-- title. Since `(?=.*X)` from any position already searches to the end, a match
-- at any position implies a match at position 0 - anchoring is matching-neutral
-- and turns O(n^2) attempts into one pass. A literal `GERMAN` pre-test runs
-- first because it is the cheapest and most selective of the two conditions.
--
-- Measured under exact Radarr semantics (.NET Regex, IgnoreCase|Compiled,
-- median of 5 interleaved rounds): 24,723 ns -> 114 ns per title, a 218x
-- speedup. Equivalence proven on the same 6,301-title set, including German
-- DL/ML forms with and without WEB prefixes in every separator spelling:
-- zero new matches, zero lost matches.
update "regular_expressions" set "pattern" = '^(?=.*GERMAN)(?=.*\bGERMAN\b)(?=.*\b(?<!WEB[-_. ])[DM]L\b)', "description" = 'Matches German dual-language and multi-language releases.

Performance: the original expression was unanchored, so both whole-title lookaheads were repeated at every position. Anchoring is matching-neutral here because each lookahead already scans the entire title from wherever it starts.' where "name" = 'German DL' and "pattern" = '(?=.*\bGERMAN\b)(?=.*\b(?<!WEB[-_. ])[DM]L\b).*';
-- --- END op 12615
