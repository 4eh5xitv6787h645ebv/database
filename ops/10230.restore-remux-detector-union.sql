-- @operation: export
-- @entity: custom_format
-- @name: Restore Remux Detector Union
-- @exportedAt: 2026-08-06T23:10:48.000Z
-- @opIds: 12595

-- --- BEGIN op 12595 ( restore Remux detector union )
-- Ops 9–11 merged three v1 Remux detectors into one custom format, but Arr
-- ANDs different condition implementation types. The merged Radarr graph
-- therefore required both the title token and its parser quality classifier,
-- while the optional Sonarr source sibling was ignored beside required Not DVD.
-- Restore both lost parser-native arms as app-scoped fallbacks. Negating the
-- shared Remux title in each fallback makes the branches mutually exclusive,
-- so every accepted Remux gets one -999999 score instead of v1's possible
-- double score. Not DVD remains a global gate, preserving DVD Remux eligibility.

INSERT INTO custom_formats (name, description)
SELECT 'Remux (Quality Match)', 'Matches non-DVD Radarr Remux quality classifications that lack a Remux title token.'
WHERE NOT EXISTS (
  SELECT 1 FROM custom_formats WHERE name = 'Remux (Quality Match)'
)
AND EXISTS (
  SELECT 1
  FROM custom_format_conditions c
  JOIN condition_quality_modifiers q
    ON q.custom_format_name = c.custom_format_name
   AND q.condition_name = c.name
  WHERE c.custom_format_name = 'Remux'
    AND c.name = 'Remux Quality Match'
    AND c.type = 'quality_modifier'
    AND c.arr_type = 'radarr'
    AND c.negate = 0
    AND c.required = 0
    AND q.quality_modifier = 'remux'
);

INSERT INTO custom_formats (name, description)
SELECT 'Remux (Source)', 'Matches non-DVD Sonarr Bluray Raw sources that lack a Remux title token.'
WHERE NOT EXISTS (
  SELECT 1 FROM custom_formats WHERE name = 'Remux (Source)'
)
AND EXISTS (
  SELECT 1
  FROM custom_format_conditions c
  JOIN condition_sources s
    ON s.custom_format_name = c.custom_format_name
   AND s.condition_name = c.name
  WHERE c.custom_format_name = 'Remux'
    AND c.name = 'Remux Source'
    AND c.type = 'source'
    AND c.arr_type = 'sonarr'
    AND c.negate = 0
    AND c.required = 0
    AND s.source = 'bluray_raw'
);

INSERT INTO custom_format_tags (custom_format_name, tag_name)
SELECT cf.name, t.name
FROM custom_formats cf, tags t
WHERE cf.name = 'Remux (Quality Match)'
  AND cf.description = 'Matches non-DVD Radarr Remux quality classifications that lack a Remux title token.'
  AND t.name = 'Storage'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_tags
    WHERE custom_format_name = cf.name AND tag_name = t.name
  );

INSERT INTO custom_format_tags (custom_format_name, tag_name)
SELECT cf.name, t.name
FROM custom_formats cf, tags t
WHERE cf.name = 'Remux (Source)'
  AND cf.description = 'Matches non-DVD Sonarr Bluray Raw sources that lack a Remux title token.'
  AND t.name = 'Storage'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_tags
    WHERE custom_format_name = cf.name AND tag_name = t.name
  );

INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT cf.name, 'Remux', 'quality_modifier', 'radarr', 0, 1
FROM custom_formats cf
WHERE cf.name = 'Remux (Quality Match)'
  AND cf.description = 'Matches non-DVD Radarr Remux quality classifications that lack a Remux title token.'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions WHERE custom_format_name = cf.name
  );

INSERT INTO condition_quality_modifiers
  (custom_format_name, condition_name, quality_modifier)
SELECT c.custom_format_name, c.name, 'remux'
FROM custom_format_conditions c
WHERE c.custom_format_name = 'Remux (Quality Match)'
  AND c.name = 'Remux'
  AND c.type = 'quality_modifier'
  AND c.arr_type = 'radarr'
  AND c.negate = 0
  AND c.required = 1
  AND NOT EXISTS (
    SELECT 1 FROM condition_quality_modifiers q
    WHERE q.custom_format_name = c.custom_format_name
      AND q.condition_name = c.name
  );

INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT cf.name, 'Not DVD', 'source', 'radarr', 1, 1
FROM custom_formats cf
WHERE cf.name = 'Remux (Quality Match)'
  AND cf.description = 'Matches non-DVD Radarr Remux quality classifications that lack a Remux title token.'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = cf.name AND name = 'Not DVD'
  );

INSERT INTO condition_sources (custom_format_name, condition_name, source)
SELECT c.custom_format_name, c.name, 'dvd'
FROM custom_format_conditions c
WHERE c.custom_format_name = 'Remux (Quality Match)'
  AND c.name = 'Not DVD'
  AND c.type = 'source'
  AND c.arr_type = 'radarr'
  AND c.negate = 1
  AND c.required = 1
  AND NOT EXISTS (
    SELECT 1 FROM condition_sources s
    WHERE s.custom_format_name = c.custom_format_name
      AND s.condition_name = c.name
  );

INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT cf.name, 'Not Remux Title', 'release_title', 'radarr', 1, 1
FROM custom_formats cf
WHERE cf.name = 'Remux (Quality Match)'
  AND cf.description = 'Matches non-DVD Radarr Remux quality classifications that lack a Remux title token.'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = cf.name AND name = 'Not Remux Title'
  );

INSERT INTO condition_patterns
  (custom_format_name, condition_name, regular_expression_name)
SELECT c.custom_format_name, c.name, re.name
FROM custom_format_conditions c, regular_expressions re
WHERE c.custom_format_name = 'Remux (Quality Match)'
  AND c.name = 'Not Remux Title'
  AND c.type = 'release_title'
  AND c.arr_type = 'radarr'
  AND c.negate = 1
  AND c.required = 1
  AND re.name = 'Remux'
  AND NOT EXISTS (
    SELECT 1 FROM condition_patterns p
    WHERE p.custom_format_name = c.custom_format_name
      AND p.condition_name = c.name
      AND p.regular_expression_name = re.name
  );

INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT cf.name, 'Remux', 'source', 'sonarr', 0, 1
FROM custom_formats cf
WHERE cf.name = 'Remux (Source)'
  AND cf.description = 'Matches non-DVD Sonarr Bluray Raw sources that lack a Remux title token.'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions WHERE custom_format_name = cf.name
  );

INSERT INTO condition_sources (custom_format_name, condition_name, source)
SELECT c.custom_format_name, c.name, 'bluray_raw'
FROM custom_format_conditions c
WHERE c.custom_format_name = 'Remux (Source)'
  AND c.name = 'Remux'
  AND c.type = 'source'
  AND c.arr_type = 'sonarr'
  AND c.negate = 0
  AND c.required = 1
  AND NOT EXISTS (
    SELECT 1 FROM condition_sources s
    WHERE s.custom_format_name = c.custom_format_name
      AND s.condition_name = c.name
  );

INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT cf.name, 'Not DVD', 'source', 'sonarr', 1, 1
FROM custom_formats cf
WHERE cf.name = 'Remux (Source)'
  AND cf.description = 'Matches non-DVD Sonarr Bluray Raw sources that lack a Remux title token.'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = cf.name AND name = 'Not DVD'
  );

INSERT INTO condition_sources (custom_format_name, condition_name, source)
SELECT c.custom_format_name, c.name, 'dvd'
FROM custom_format_conditions c
WHERE c.custom_format_name = 'Remux (Source)'
  AND c.name = 'Not DVD'
  AND c.type = 'source'
  AND c.arr_type = 'sonarr'
  AND c.negate = 1
  AND c.required = 1
  AND NOT EXISTS (
    SELECT 1 FROM condition_sources s
    WHERE s.custom_format_name = c.custom_format_name
      AND s.condition_name = c.name
  );

INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
SELECT cf.name, 'Not Remux Title', 'release_title', 'sonarr', 1, 1
FROM custom_formats cf
WHERE cf.name = 'Remux (Source)'
  AND cf.description = 'Matches non-DVD Sonarr Bluray Raw sources that lack a Remux title token.'
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = cf.name AND name = 'Not Remux Title'
  );

INSERT INTO condition_patterns
  (custom_format_name, condition_name, regular_expression_name)
SELECT c.custom_format_name, c.name, re.name
FROM custom_format_conditions c, regular_expressions re
WHERE c.custom_format_name = 'Remux (Source)'
  AND c.name = 'Not Remux Title'
  AND c.type = 'release_title'
  AND c.arr_type = 'sonarr'
  AND c.negate = 1
  AND c.required = 1
  AND re.name = 'Remux'
  AND NOT EXISTS (
    SELECT 1 FROM condition_patterns p
    WHERE p.custom_format_name = c.custom_format_name
      AND p.condition_name = c.name
      AND p.regular_expression_name = re.name
  );

INSERT INTO quality_profile_custom_formats
  (quality_profile_name, custom_format_name, arr_type, score)
SELECT base.quality_profile_name, 'Remux (Quality Match)', 'radarr', base.score
FROM quality_profile_custom_formats base
WHERE base.custom_format_name = 'Remux'
  AND base.arr_type = 'all'
  AND base.score = -999999
  AND (
    SELECT COUNT(*) FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Remux'
      AND arr_type = 'all'
      AND score = -999999
  ) = 9
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_quality_modifiers q
      ON q.custom_format_name = c.custom_format_name
     AND q.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Quality Match)'
      AND c.name = 'Remux'
      AND c.type = 'quality_modifier'
      AND c.arr_type = 'radarr'
      AND c.negate = 0
      AND c.required = 1
      AND q.quality_modifier = 'remux'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_sources s
      ON s.custom_format_name = c.custom_format_name
     AND s.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Quality Match)'
      AND c.name = 'Not DVD'
      AND c.type = 'source'
      AND c.arr_type = 'radarr'
      AND c.negate = 1
      AND c.required = 1
      AND s.source = 'dvd'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Quality Match)'
      AND c.name = 'Not Remux Title'
      AND c.type = 'release_title'
      AND c.arr_type = 'radarr'
      AND c.negate = 1
      AND c.required = 1
      AND p.regular_expression_name = 'Remux'
  )
  AND (
    SELECT COUNT(*) FROM custom_format_conditions
    WHERE custom_format_name = 'Remux (Quality Match)'
  ) = 3
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats target
    WHERE target.quality_profile_name = base.quality_profile_name
      AND target.custom_format_name = 'Remux (Quality Match)'
      AND target.arr_type = 'radarr'
  );

INSERT INTO quality_profile_custom_formats
  (quality_profile_name, custom_format_name, arr_type, score)
SELECT base.quality_profile_name, 'Remux (Source)', 'sonarr', base.score
FROM quality_profile_custom_formats base
WHERE base.custom_format_name = 'Remux'
  AND base.arr_type = 'all'
  AND base.score = -999999
  AND (
    SELECT COUNT(*) FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Remux'
      AND arr_type = 'all'
      AND score = -999999
  ) = 9
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_sources s
      ON s.custom_format_name = c.custom_format_name
     AND s.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Source)'
      AND c.name = 'Remux'
      AND c.type = 'source'
      AND c.arr_type = 'sonarr'
      AND c.negate = 0
      AND c.required = 1
      AND s.source = 'bluray_raw'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Source)'
      AND c.name = 'Not Remux Title'
      AND c.type = 'release_title'
      AND c.arr_type = 'sonarr'
      AND c.negate = 1
      AND c.required = 1
      AND p.regular_expression_name = 'Remux'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_sources s
      ON s.custom_format_name = c.custom_format_name
     AND s.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Source)'
      AND c.name = 'Not DVD'
      AND c.type = 'source'
      AND c.arr_type = 'sonarr'
      AND c.negate = 1
      AND c.required = 1
      AND s.source = 'dvd'
  )
  AND (
    SELECT COUNT(*) FROM custom_format_conditions
    WHERE custom_format_name = 'Remux (Source)'
  ) = 3
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats target
    WHERE target.quality_profile_name = base.quality_profile_name
      AND target.custom_format_name = 'Remux (Source)'
      AND target.arr_type = 'sonarr'
  );

DELETE FROM custom_format_conditions
WHERE custom_format_name = 'Remux'
  AND name = 'Remux Quality Match'
  AND type = 'quality_modifier'
  AND arr_type = 'radarr'
  AND negate = 0
  AND required = 0
  AND EXISTS (
    SELECT 1 FROM condition_quality_modifiers
    WHERE custom_format_name = 'Remux'
      AND condition_name = 'Remux Quality Match'
      AND quality_modifier = 'remux'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_quality_modifiers q
      ON q.custom_format_name = c.custom_format_name
     AND q.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Quality Match)'
      AND c.name = 'Remux'
      AND c.type = 'quality_modifier'
      AND c.arr_type = 'radarr'
      AND c.negate = 0
      AND c.required = 1
      AND q.quality_modifier = 'remux'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_sources s
      ON s.custom_format_name = c.custom_format_name
     AND s.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Quality Match)'
      AND c.name = 'Not DVD'
      AND c.type = 'source'
      AND c.arr_type = 'radarr'
      AND c.negate = 1
      AND c.required = 1
      AND s.source = 'dvd'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Quality Match)'
      AND c.name = 'Not Remux Title'
      AND c.type = 'release_title'
      AND c.arr_type = 'radarr'
      AND c.negate = 1
      AND c.required = 1
      AND p.regular_expression_name = 'Remux'
  )
  AND (
    SELECT COUNT(*) FROM custom_format_conditions
    WHERE custom_format_name = 'Remux (Quality Match)'
  ) = 3
  AND (
    SELECT COUNT(*) FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Remux'
      AND arr_type = 'all'
      AND score = -999999
  ) = 9
  AND (
    SELECT COUNT(*) FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Remux (Quality Match)'
      AND arr_type = 'radarr'
      AND score = -999999
  ) = 9;

DELETE FROM custom_format_conditions
WHERE custom_format_name = 'Remux'
  AND name = 'Remux Source'
  AND type = 'source'
  AND arr_type = 'sonarr'
  AND negate = 0
  AND required = 0
  AND EXISTS (
    SELECT 1 FROM condition_sources
    WHERE custom_format_name = 'Remux'
      AND condition_name = 'Remux Source'
      AND source = 'bluray_raw'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_sources s
      ON s.custom_format_name = c.custom_format_name
     AND s.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Source)'
      AND c.name = 'Remux'
      AND c.type = 'source'
      AND c.arr_type = 'sonarr'
      AND c.negate = 0
      AND c.required = 1
      AND s.source = 'bluray_raw'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_sources s
      ON s.custom_format_name = c.custom_format_name
     AND s.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Source)'
      AND c.name = 'Not DVD'
      AND c.type = 'source'
      AND c.arr_type = 'sonarr'
      AND c.negate = 1
      AND c.required = 1
      AND s.source = 'dvd'
  )
  AND EXISTS (
    SELECT 1
    FROM custom_format_conditions c
    JOIN condition_patterns p
      ON p.custom_format_name = c.custom_format_name
     AND p.condition_name = c.name
    WHERE c.custom_format_name = 'Remux (Source)'
      AND c.name = 'Not Remux Title'
      AND c.type = 'release_title'
      AND c.arr_type = 'sonarr'
      AND c.negate = 1
      AND c.required = 1
      AND p.regular_expression_name = 'Remux'
  )
  AND (
    SELECT COUNT(*) FROM custom_format_conditions
    WHERE custom_format_name = 'Remux (Source)'
  ) = 3
  AND (
    SELECT COUNT(*) FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Remux'
      AND arr_type = 'all'
      AND score = -999999
  ) = 9
  AND (
    SELECT COUNT(*) FROM quality_profile_custom_formats
    WHERE custom_format_name = 'Remux (Source)'
      AND arr_type = 'sonarr'
      AND score = -999999
  ) = 9;

UPDATE custom_format_conditions
SET required = 1
WHERE custom_format_name = 'Remux'
  AND name = 'Remux'
  AND type = 'release_title'
  AND arr_type = 'all'
  AND negate = 0
  AND required = 0
  AND EXISTS (
    SELECT 1 FROM condition_patterns
    WHERE custom_format_name = 'Remux'
      AND condition_name = 'Remux'
      AND regular_expression_name = 'Remux'
  )
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = 'Remux'
      AND name IN ('Remux Quality Match', 'Remux Source')
  );

UPDATE custom_formats
SET description = 'Matches non-DVD releases with a standalone Remux title token.'
WHERE name = 'Remux'
  AND description = 'Matches Remux as a codec, not a source. Either h265 or h264.'
  AND EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = 'Remux'
      AND name = 'Remux'
      AND type = 'release_title'
      AND arr_type = 'all'
      AND negate = 0
      AND required = 1
  );
-- --- END op 12595
