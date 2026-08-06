-- @operation: export
-- @entity: quality_profile
-- @name: Restore Extras Ban to 1080p Compact
-- @exportedAt: 2026-08-06T23:36:53.000Z
-- @opIds: 12596

-- --- BEGIN op 12596 ( restore Extras ban to 1080p Compact )
-- The v1 Compact lineage carried both the Radarr Extras and Sonarr TV Extras
-- bans until commit c156dfad removed them during a broad, explicitly
-- testing-only source/tier refactor. No policy rationale accompanied that
-- removal, and all ten other shipped profiles retained both -999999 scores.
-- Ops 4 and 218 later merged and repaired the app-scoped detectors, faithfully
-- preserving Compact's stale omission. Restore only its two missing score rows.
WITH target_apps(arr_type) AS (
  VALUES ('radarr'), ('sonarr')
),
expected_peer_profiles(name) AS (
  VALUES
    ('1080p Balanced'),
    ('1080p Efficient'),
    ('1080p Quality'),
    ('1080p Quality HDR'),
    ('1080p Remux'),
    ('2160p Balanced'),
    ('2160p Efficient'),
    ('2160p Quality'),
    ('2160p Remux'),
    ('720p Quality')
)
INSERT INTO quality_profile_custom_formats
  (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, app.arr_type, -999999
FROM quality_profiles qp
JOIN custom_formats cf
  ON cf.name = 'Extras'
CROSS JOIN target_apps app
WHERE qp.name = '1080p Compact'
  AND qp.upgrades_allowed = 1
  AND qp.minimum_custom_format_score = 200000
  AND cf.description = 'Matches the ''Extras'' Regex Pattern'
  AND (
    SELECT COUNT(*)
    FROM custom_format_conditions
    WHERE custom_format_name = 'Extras'
  ) = 2
  AND (
    SELECT COUNT(*)
    FROM condition_patterns
    WHERE custom_format_name = 'Extras'
  ) = 2
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE c.custom_format_name = 'Extras'
      AND c.name = 'Movie Extras'
      AND c.type = 'release_title'
      AND c.arr_type = 'radarr'
      AND c.negate = 0
      AND c.required = 0
      AND p.regular_expression_name = 'Movie Extras'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE c.custom_format_name = 'Extras'
      AND c.name = 'TV Extras'
      AND c.type = 'release_title'
      AND c.arr_type = 'sonarr'
      AND c.negate = 0
      AND c.required = 0
      AND p.regular_expression_name = 'TV Extras'
  )
  AND (
    SELECT COUNT(*)
    FROM quality_profile_custom_formats scores
    WHERE scores.custom_format_name = 'Extras'
      AND scores.quality_profile_name <> '1080p Compact'
  ) = 20
  AND NOT EXISTS (
    SELECT 1
    FROM expected_peer_profiles peer
    CROSS JOIN target_apps expected_app
    WHERE NOT EXISTS (
      SELECT 1
      FROM quality_profile_custom_formats scores
      WHERE scores.quality_profile_name = peer.name
        AND scores.custom_format_name = 'Extras'
        AND scores.arr_type = expected_app.arr_type
        AND scores.score = -999999
    )
  )
  AND NOT EXISTS (
    SELECT 1
    FROM quality_profile_custom_formats target
    WHERE target.quality_profile_name = qp.name
      AND target.custom_format_name = cf.name
      AND (
        target.arr_type NOT IN ('radarr', 'sonarr')
        OR target.score <> -999999
      )
  )
  AND NOT EXISTS (
    SELECT 1
    FROM quality_profile_custom_formats target
    WHERE target.quality_profile_name = qp.name
      AND target.custom_format_name = cf.name
      AND target.arr_type = app.arr_type
  );
-- --- END op 12596
