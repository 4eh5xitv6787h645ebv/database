-- @operation: export
-- @entity: batch
-- @name: Raise Ban Magnitude Above Stackable Positives
-- @exportedAt: 2026-08-07T12:20:00.000Z
-- @opIds: 12606

-- --- BEGIN op 12606 ( rescore every -999999 ban to -99999999 )
-- Issue #20 (fork sweep finding, corroborated locally): -999999 is NOT safely
-- above every reachable positive stack. Computed upper bounds (max quality-
-- ladder CF + max tier CF + all other positives) reach 1.07M in 1080p Quality
-- and 11.15M in 2160p Efficient, and op 10232 documented a REAL release that
-- stacked to 1,840,606 before its fix — a banned release with that score
-- profile would have gone net-positive. Raise every ban row two orders of
-- magnitude; graph invariants now assert the margin holds as scores evolve
-- (naive bound per profile < |worst ban|) and that no legacy-magnitude row
-- remains. 421 rows; no other score semantics change.
UPDATE quality_profile_custom_formats SET score = -99999999 WHERE score = -999999;
-- --- END op 12606
