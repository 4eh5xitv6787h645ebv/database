-- @operation: export
-- @entity: batch
-- @name: Link CONSORTiUM and SilentRogue to Remux Tiers
-- @exportedAt: 2026-08-07T01:08:00.000Z
-- @opIds: 12600

-- --- BEGIN op 12600 ( restore omitted Remux tier memberships )
-- Ops 154 and 155 are explicitly named "Add CONSORTiUM to Remux Tier 2"
-- and "Add SilentRogue to Remux Tier 3", but their exports contain only the
-- regex creation/correction steps. Neither export links its regex to the named
-- custom format, leaving both release groups unable to receive the intended
-- +80/+60 Remux tier preference. Restore only those two omitted optional
-- release-group conditions. Scores and regex text remain unchanged.

WITH targets (
  custom_format_name,
  regular_expression_name,
  expected_pattern,
  expected_score
) AS (
  VALUES
    ('Remux Tier 2', 'CONSORTiUM', '(?<=^|[\s.-])CONSORTiUM\b', 80),
    ('Remux Tier 3', 'SilentRogue', '(?<=^|[\s.-])SilentRogue\b', 60)
),
expected_profiles(name) AS (
  VALUES ('1080p Remux'), ('2160p Remux')
),
eligible AS (
  SELECT target.*
  FROM targets target
  JOIN custom_formats cf
    ON cf.name = target.custom_format_name
  JOIN regular_expressions re
    ON re.name = target.regular_expression_name
   AND re.pattern = target.expected_pattern
  WHERE cf.include_in_rename = 0
    AND cf.description = 'Matches release groups who fall under ' || target.custom_format_name
    AND re.description IS NULL
    AND re.regex101_id IS NULL
    AND (
      SELECT COUNT(*)
      FROM regular_expression_tags ret
      WHERE ret.regular_expression_name = target.regular_expression_name
    ) = 2
    AND EXISTS (
      SELECT 1
      FROM regular_expression_tags ret
      WHERE ret.regular_expression_name = target.regular_expression_name
        AND ret.tag_name = 'Release Group'
    )
    AND EXISTS (
      SELECT 1
      FROM regular_expression_tags ret
      WHERE ret.regular_expression_name = target.regular_expression_name
        AND ret.tag_name = 'Remux'
    )
    AND NOT EXISTS (
      SELECT 1
      FROM condition_patterns p
      WHERE p.regular_expression_name = target.regular_expression_name
    )
    AND (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
    ) = 9
    AND (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
        AND c.type = 'release_group'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 0
    ) = 7
    AND (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = target.custom_format_name
        AND c.type = 'release_group'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 0
        AND p.regular_expression_name = c.name
    ) = 7
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_patterns p
        ON p.custom_format_name = c.custom_format_name
       AND p.condition_name = c.name
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = 'Remux'
        AND c.type = 'release_title'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 1
        AND p.regular_expression_name = 'Remux'
    )
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      JOIN condition_sources s
        ON s.custom_format_name = c.custom_format_name
       AND s.condition_name = c.name
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = 'Not DVD'
        AND c.type = 'source'
        AND c.arr_type = 'all'
        AND c.negate = 1
        AND c.required = 1
        AND s.source = 'dvd'
    )
    AND NOT EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = target.regular_expression_name
    )
    AND (
      SELECT COUNT(*)
      FROM quality_profile_custom_formats score
      WHERE score.custom_format_name = target.custom_format_name
    ) = 2
    AND NOT EXISTS (
      SELECT 1
      FROM expected_profiles profile
      WHERE NOT EXISTS (
        SELECT 1
        FROM quality_profile_custom_formats score
        WHERE score.quality_profile_name = profile.name
          AND score.custom_format_name = target.custom_format_name
          AND score.arr_type = 'all'
          AND score.score = target.expected_score
      )
    )
)
INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT
  custom_format_name,
  regular_expression_name,
  'release_group',
  'all',
  0,
  0
FROM eligible
WHERE (SELECT COUNT(*) FROM eligible) = 2;

WITH targets (
  custom_format_name,
  regular_expression_name,
  expected_pattern,
  expected_score
) AS (
  VALUES
    ('Remux Tier 2', 'CONSORTiUM', '(?<=^|[\s.-])CONSORTiUM\b', 80),
    ('Remux Tier 3', 'SilentRogue', '(?<=^|[\s.-])SilentRogue\b', 60)
),
expected_profiles(name) AS (
  VALUES ('1080p Remux'), ('2160p Remux')
),
configured AS (
  SELECT target.*
  FROM targets target
  JOIN regular_expressions re
    ON re.name = target.regular_expression_name
   AND re.pattern = target.expected_pattern
  WHERE (
      SELECT COUNT(*)
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
    ) = 10
    AND EXISTS (
      SELECT 1
      FROM custom_format_conditions c
      WHERE c.custom_format_name = target.custom_format_name
        AND c.name = target.regular_expression_name
        AND c.type = 'release_group'
        AND c.arr_type = 'all'
        AND c.negate = 0
        AND c.required = 0
    )
    AND NOT EXISTS (
      SELECT 1
      FROM condition_patterns p
      WHERE p.custom_format_name = target.custom_format_name
        AND p.condition_name = target.regular_expression_name
    )
    AND NOT EXISTS (
      SELECT 1
      FROM condition_patterns p
      WHERE p.regular_expression_name = target.regular_expression_name
    )
    AND (
      SELECT COUNT(*)
      FROM quality_profile_custom_formats score
      WHERE score.custom_format_name = target.custom_format_name
    ) = 2
    AND NOT EXISTS (
      SELECT 1
      FROM expected_profiles profile
      WHERE NOT EXISTS (
        SELECT 1
        FROM quality_profile_custom_formats score
        WHERE score.quality_profile_name = profile.name
          AND score.custom_format_name = target.custom_format_name
          AND score.arr_type = 'all'
          AND score.score = target.expected_score
      )
    )
)
INSERT INTO condition_patterns
  (custom_format_name, condition_name, regular_expression_name)
SELECT
  custom_format_name,
  regular_expression_name,
  regular_expression_name
FROM configured
WHERE (SELECT COUNT(*) FROM configured) = 2;
-- --- END op 12600
