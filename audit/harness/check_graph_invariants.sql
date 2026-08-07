-- Database-level invariants that title/parser cases cannot express.
-- Usage: sqlite3 replayed.db < audit/harness/check_graph_invariants.sql
.bail on

CREATE TEMP TABLE audit_assertions (
  label TEXT PRIMARY KEY,
  ok INTEGER NOT NULL CHECK (ok = 1)
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Extras keeps one optional title detector per app',
  (
    SELECT COUNT(*) = 2
    FROM custom_format_conditions
    WHERE custom_format_name = 'Extras'
  )
  AND (
    SELECT COUNT(*) = 2
    FROM condition_patterns
    WHERE custom_format_name = 'Extras'
  )
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
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Extras is a hard ban in every profile and app',
  (SELECT COUNT(*) = 11 FROM quality_profiles)
  AND (
    SELECT COUNT(*) = 22
    FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Extras'
      AND arr_type IN ('radarr', 'sonarr')
      AND score = -999999
  )
  AND (
    SELECT COUNT(*) = 22
    FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Extras'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM quality_profiles profile
    CROSS JOIN (
      SELECT 'radarr' AS arr_type
      UNION ALL
      SELECT 'sonarr'
    ) app
    WHERE NOT EXISTS (
      SELECT 1
      FROM quality_profile_custom_formats scores
      WHERE scores.quality_profile_name = profile.name
        AND scores.custom_format_name = 'Extras'
        AND scores.arr_type = app.arr_type
        AND scores.score = -999999
    )
  )
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  '1080p Compact has both restored Extras bans',
  (
    SELECT COUNT(*) = 2
    FROM quality_profile_custom_formats
    WHERE quality_profile_name = '1080p Compact'
      AND custom_format_name = 'Extras'
      AND arr_type IN ('radarr', 'sonarr')
      AND score = -999999
  )
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Compact Radarr QxR tiers exclude the HONE title fallback',
  (
    SELECT COUNT(*) = 2
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE c.custom_format_name IN (
        '1080p Compact Movie Bluray Tier 4',
        '1080p Compact Movie WEB Tier 1'
      )
      AND c.name = 'Not HONE'
      AND c.type = 'release_title'
      AND c.arr_type = 'all'
      AND c.negate = 1
      AND c.required = 1
      AND p.regular_expression_name = 'HONE'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM (
      SELECT '1080p Compact Movie Bluray Tier 4' AS custom_format_name
      UNION ALL
      SELECT '1080p Compact Movie WEB Tier 1'
    ) expected
    WHERE NOT EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = expected.custom_format_name
        AND c.name = 'Not HONE'
        AND c.type = 'release_title'
        AND c.arr_type = 'all'
        AND c.negate = 1
        AND c.required = 1
        AND p.regular_expression_name = 'HONE'
    )
  )
);

SELECT label || ': ok'
FROM audit_assertions
ORDER BY label;
