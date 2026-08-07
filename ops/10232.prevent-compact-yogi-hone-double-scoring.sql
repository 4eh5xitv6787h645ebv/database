-- @operation: export
-- @entity: batch
-- @name: Prevent Compact Yogi HONE Double Scoring
-- @exportedAt: 2026-08-07T00:20:00.000Z
-- @opIds: 12597

-- --- BEGIN op 12597 ( prevent Compact Yogi/HONE double scoring )
-- The QxR release-group regex includes YOGI. HONE's title fallback is intended
-- for releases whose parsed group is not HONE. A real "x265-Yogi HONE" release
-- therefore matched both the Compact QxR tier and the HONE fallback, stacking
-- +940000 and +900000. Op 98 already added this exact required-negated HONE
-- guard to the corresponding Efficient QxR tiers under the explicit policy
-- "Prevent Yogi Double Matching". Add it only to the two Compact/Radarr movie
-- tiers that share an effective HONE fallback score. Compact/Sonarr TV tiers
-- deliberately remain unchanged because that profile/app has no HONE fallback.

WITH targets (
  custom_format_name,
  expected_condition_count,
  expected_group_count,
  tier_score,
  fallback_name,
  fallback_condition_count,
  fallback_score,
  source_kind
) AS (
  VALUES
    ('1080p Compact Movie Bluray Tier 4', 7, 4, 940000, 'HONE Bluray', 5, 900000, 'bluray'),
    ('1080p Compact Movie WEB Tier 1', 6, 2, 883000, 'HONE WEB', 6, 920000, 'web')
),
eligible AS (
  SELECT target.*
  FROM targets target
  JOIN custom_formats tier
    ON tier.name = target.custom_format_name
  JOIN custom_formats fallback
    ON fallback.name = target.fallback_name
  WHERE (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
    ) = target.expected_condition_count
    AND (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
        AND c.type = 'release_group'
    ) = target.expected_group_count
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = 'QxR'
        AND c.type = 'release_group'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 0
        AND p.regular_expression_name = 'QxR'
    )
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = 'x265'
        AND c.type = 'release_title'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 1
        AND p.regular_expression_name = 'x265 (Efficient)'
    )
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_resolutions r
        ON r.custom_format_name = c.custom_format_name
       AND r.condition_name = c.name
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = '1080p'
        AND c.type = 'resolution'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 1
        AND r.resolution = '1080p'
    )
    AND (
      (
        target.source_kind = 'bluray'
        AND (
          SELECT COUNT(*)
          FROM custom_format_conditions c
          WHERE c.custom_format_name = target.custom_format_name
            AND c.type = 'source'
        ) = 1
        AND EXISTS (
          SELECT 1
          FROM custom_format_conditions c
          JOIN condition_sources s
            ON s.custom_format_name = c.custom_format_name
           AND s.condition_name = c.name
          WHERE c.custom_format_name = target.custom_format_name
            AND c.name = 'Bluray'
            AND c.type = 'source'
            AND c.arr_type = 'all'
            AND c.negate = 0
            AND c.required = 1
            AND s.source = 'bluray'
        )
      )
      OR
      (
        target.source_kind = 'web'
        AND (
          SELECT COUNT(*)
          FROM custom_format_conditions c
          WHERE c.custom_format_name = target.custom_format_name
            AND c.type = 'source'
        ) = 2
        AND (
          SELECT COUNT(*)
          FROM custom_format_conditions c
          JOIN condition_sources s
            ON s.custom_format_name = c.custom_format_name
           AND s.condition_name = c.name
          WHERE c.custom_format_name = target.custom_format_name
            AND c.type = 'source'
            AND c.arr_type = 'all'
            AND c.negate = 0
            AND c.required = 0
            AND s.source IN ('web_dl', 'webrip')
        ) = 2
      )
    )
    AND (
      SELECT COUNT(*)
      FROM quality_profile_custom_formats score
      WHERE score.custom_format_name = target.custom_format_name
    ) = 1
    AND EXISTS (
      SELECT 1
      FROM quality_profile_custom_formats score
      WHERE score.quality_profile_name = '1080p Compact'
        AND score.custom_format_name = target.custom_format_name
        AND score.arr_type = 'radarr'
        AND score.score = target.tier_score
    )
    AND (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.fallback_name
    ) = target.fallback_condition_count
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = target.fallback_name
        AND c.name = 'HONE'
        AND c.type = 'release_title'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 1
        AND p.regular_expression_name = 'HONE'
    )
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = target.fallback_name
        AND c.name = 'Release Group'
        AND c.type = 'release_group'
        AND c.arr_type = 'all'
        AND c.negate = 1
        AND c.required = 1
        AND p.regular_expression_name = 'HONE'
    )
    AND EXISTS (
      SELECT 1
      FROM quality_profile_custom_formats score
      WHERE score.quality_profile_name = '1080p Compact'
        AND score.custom_format_name = target.fallback_name
        AND score.arr_type = 'radarr'
        AND score.score = target.fallback_score
    )
    AND EXISTS (
      SELECT 1
      FROM regular_expressions re
      WHERE re.name = 'HONE'
        AND re.pattern = '(?<=^|[\s.-])HONE\b'
    )
    AND NOT EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = 'Not HONE'
    )
)
INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT custom_format_name, 'Not HONE', 'release_title', 'all', 1, 1
FROM eligible
WHERE (SELECT COUNT(*) FROM eligible) = 2;

WITH targets (custom_format_name, expected_condition_count) AS (
  VALUES
    ('1080p Compact Movie Bluray Tier 4', 8),
    ('1080p Compact Movie WEB Tier 1', 7)
),
configured AS (
  SELECT target.custom_format_name
  FROM targets target
  WHERE (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
    ) = target.expected_condition_count
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = 'Not HONE'
        AND c.type = 'release_title'
        AND c.arr_type = 'all'
        AND c.negate = 1
        AND c.required = 1
    )
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = 'QxR'
        AND c.type = 'release_group'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 0
        AND p.regular_expression_name = 'QxR'
    )
)
INSERT INTO condition_patterns
  (custom_format_name, condition_name, regular_expression_name)
SELECT configured.custom_format_name, 'Not HONE', re.name
FROM configured
JOIN regular_expressions re
  ON re.name = 'HONE'
 AND re.pattern = '(?<=^|[\s.-])HONE\b'
WHERE (SELECT COUNT(*) FROM configured) = 2
  AND NOT EXISTS (
    SELECT 1
    FROM condition_patterns p
    WHERE p.custom_format_name = configured.custom_format_name
      AND p.condition_name = 'Not HONE'
  );
-- --- END op 12597
