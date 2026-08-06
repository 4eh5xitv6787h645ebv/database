-- @operation: export
-- @entity: custom_format
-- @name: Fix 720p HDTV Tier 3 Resolution
-- @exportedAt: 2026-08-06T22:19:39.000Z
-- @opIds: 12593

-- --- BEGIN op 12593 ( update custom_format "720p HDTV Tier 3" )
-- The format was translated with a required 1080p resolution condition, making
-- its complete graph identical to 1080p HDTV Tier 3. Both formats are scored in
-- all 11 shipped profiles for Radarr and Sonarr, so qualifying 1080p HANDJOB
-- releases could receive both tier scores while 720p releases missed this tier.
-- Correct both the condition's display name and its one-to-one backing value.
UPDATE condition_resolutions
SET resolution = '720p'
WHERE custom_format_name = '720p HDTV Tier 3'
  AND condition_name = '1080p'
  AND resolution = '1080p'
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions
    WHERE custom_format_name = '720p HDTV Tier 3'
      AND name = '1080p'
      AND type = 'resolution'
      AND arr_type = 'all'
      AND negate = 0
      AND required = 1
  );

UPDATE custom_format_conditions
SET name = '720p'
WHERE custom_format_name = '720p HDTV Tier 3'
  AND name = '1080p'
  AND type = 'resolution'
  AND arr_type = 'all'
  AND negate = 0
  AND required = 1
  AND EXISTS (
    SELECT 1
    FROM condition_resolutions
    WHERE custom_format_name = '720p HDTV Tier 3'
      AND condition_name = '1080p'
      AND resolution = '720p'
  );
-- --- END op 12593
