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
      AND score <= -999999
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
        AND scores.score <= -999999
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
      AND score <= -999999
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

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Late Remux groups retain their intended tier links',
  (
    SELECT COUNT(*) = 2
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE (
        (
          c.custom_format_name = 'Remux Tier 2'
          AND c.name = 'CONSORTiUM'
          AND p.regular_expression_name = 'CONSORTiUM'
        )
        OR (
          c.custom_format_name = 'Remux Tier 3'
          AND c.name = 'SilentRogue'
          AND p.regular_expression_name = 'SilentRogue'
        )
      )
      AND c.type = 'release_group'
      AND c.arr_type = 'all'
      AND c.negate = 0
      AND c.required = 0
  )
  AND NOT EXISTS (
    SELECT 1
    FROM (
      SELECT
        'Remux Tier 2' AS custom_format_name,
        'CONSORTiUM' AS regular_expression_name,
        80 AS score
      UNION ALL
      SELECT 'Remux Tier 3', 'SilentRogue', 60
    ) expected
    WHERE NOT EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = expected.custom_format_name
        AND c.name = expected.regular_expression_name
        AND c.type = 'release_group'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 0
        AND p.regular_expression_name = expected.regular_expression_name
        AND (
          SELECT COUNT(*)
          FROM condition_patterns exact_backing
          WHERE exact_backing.custom_format_name = c.custom_format_name
            AND exact_backing.condition_name = c.name
        ) = 1
    )
    OR (
      SELECT COUNT(*)
      FROM quality_profile_custom_formats score
      WHERE score.custom_format_name = expected.custom_format_name
        AND score.quality_profile_name IN ('1080p Remux', '2160p Remux')
        AND score.arr_type = 'all'
        AND score.score = expected.score
    ) <> 2
  )
);

-- Jojont54-inspired structural audits (fork sweep 2026-08-07): tier formats
-- must never be reachable through optional conditions alone, and policy
-- decisions encoded as scores must not drift silently.

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Every scored tier format keeps at least one required gate',
  NOT EXISTS (
    SELECT 1
    FROM quality_profile_custom_formats s
    JOIN custom_formats cf ON cf.name = s.custom_format_name
    WHERE cf.name LIKE '% Tier %'
      AND s.score > 0
      AND NOT EXISTS (
        SELECT 1 FROM custom_format_conditions c
        WHERE c.custom_format_name = cf.name
          AND c.required = 1
      )
  )
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Multi-group tier OR-lists stay optional and non-negated',
  -- Single-group tiers (e.g. 1080p Bluray HEVC Tier 1 = HONE required) may
  -- require their one group; tiers with 2+ group conditions must keep them
  -- all optional/non-negated or members silently stop OR-ing.
  NOT EXISTS (
    SELECT 1 FROM custom_format_conditions c
    WHERE c.custom_format_name LIKE '% Tier %'
      AND c.type = 'release_group'
      AND (c.required = 1 OR c.negate = 1)
      AND (
        SELECT COUNT(*) FROM custom_format_conditions g
        WHERE g.custom_format_name = c.custom_format_name
          AND g.type = 'release_group'
      ) >= 2
  )
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'EVO (No WEB) keeps its full negation graph',
  (
    SELECT COUNT(*) = 4 FROM custom_format_conditions
    WHERE custom_format_name = 'EVO (No WEB)' AND required = 1
  )
  AND (
    SELECT COUNT(*) = 3 FROM custom_format_conditions
    WHERE custom_format_name = 'EVO (No WEB)' AND negate = 1
  )
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Obfuscated stays informational: score 0 in every profile',
  NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Obfuscated' AND score <> 0
  )
  AND (
    SELECT COUNT(*) FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Obfuscated'
  ) = (SELECT COUNT(*) FROM quality_profiles)
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  '5.1/7.1 Surround exclusivity wiring intact',
  EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = '5.1 Surround'
      AND name = 'Not 7.1 Surround' AND negate = 1 AND required = 1
  )
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'Ban magnitude dominates every naive positive stack (issue #20)',
  -- Upper bound per profile+arr: max quality-ladder CF + max tier CF + sum of
  -- all other positives. Overcounts real co-occurrence, so bound < |ban| is
  -- sufficient proof. Op 10232 recorded a real 1,840,606 stack, which beat the
  -- old -999999 magnitude; bans are now -99999999 and this guards the margin.
  NOT EXISTS (
    WITH scored AS (
      SELECT quality_profile_name AS profile,
             CASE WHEN arr_type = 'all' THEN 'radarr' ELSE arr_type END AS arr,
             custom_format_name AS cf, score
      FROM quality_profile_custom_formats WHERE score > 0
      UNION ALL
      SELECT quality_profile_name, 'sonarr', custom_format_name, score
      FROM quality_profile_custom_formats WHERE score > 0 AND arr_type = 'all'
    ),
    classed AS (
      SELECT profile, arr, score,
        CASE
          WHEN cf LIKE '% Tier %' THEN 'tier'
          WHEN cf LIKE '%WEB-DL' OR cf LIKE '%Bluray' OR cf LIKE '%WEBRip'
            OR cf LIKE '%HDTV' OR cf IN ('DVD', 'DVD Remux', 'SDTV') THEN 'ladder'
          ELSE 'other'
        END AS klass
      FROM scored
    ),
    bounds AS (
      SELECT profile, arr,
        MAX(CASE WHEN klass = 'ladder' THEN score ELSE 0 END)
        + MAX(CASE WHEN klass = 'tier' THEN score ELSE 0 END)
        + SUM(CASE WHEN klass = 'other' THEN score ELSE 0 END) AS bound
      FROM classed GROUP BY profile, arr
    ),
    bans AS (
      SELECT quality_profile_name AS profile, MIN(score) AS worst_ban
      FROM quality_profile_custom_formats WHERE score < 0
      GROUP BY quality_profile_name
    )
    SELECT 1 FROM bounds b JOIN bans n ON n.profile = b.profile
    WHERE b.bound >= ABS(n.worst_ban)
  )
);

INSERT INTO audit_assertions (label, ok)
VALUES (
  'No legacy-magnitude ban rows remain',
  -- Exactly the old ban value: mid-range negatives like the deliberate
  -- x265 (Bluray) -820000 counterweight are legitimate and stay allowed.
  NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats
    WHERE score = -999999
  )
);

SELECT label || ': ok'
FROM audit_assertions
ORDER BY label;
