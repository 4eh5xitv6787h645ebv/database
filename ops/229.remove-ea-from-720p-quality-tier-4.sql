-- @operation: export
-- @entity: custom_format
-- @name: Remove EA From 720p Quality Tier 4
-- @exportedAt: 2026-08-06T22:35:57.000Z
-- @opIds: 12594

-- --- BEGIN op 12594 ( update custom_format "720p Quality Tier 4" )
-- v1 commit a0a23ed explicitly moved EA to the 1080p/720p Quality Tier 5
-- families, but removed only its Tier 6 memberships and left this older Tier 4
-- copy behind. Tier 4 and Tier 5 otherwise have identical eligibility gates and
-- overlap in every shipped profile/app, so a qualifying EA release receives
-- both +142000 and +141000. Remove only the stale Tier 4 member; Tier 5 remains
-- the authoritative destination selected by that history.
DELETE FROM custom_format_conditions
WHERE custom_format_name = '720p Quality Tier 4'
  AND name = 'EA'
  AND type = 'release_group'
  AND arr_type = 'all'
  AND negate = 0
  AND required = 0
  AND EXISTS (
    SELECT 1
    FROM condition_patterns
    WHERE custom_format_name = '720p Quality Tier 4'
      AND condition_name = 'EA'
      AND regular_expression_name = 'EA'
  )
  AND (
    SELECT COUNT(*)
    FROM condition_patterns
    WHERE custom_format_name = '720p Quality Tier 4'
      AND condition_name = 'EA'
  ) = 1;
-- --- END op 12594
