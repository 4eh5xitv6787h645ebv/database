-- @operation: export
-- @entity: batch
-- @name: Add Criterion Format
-- @exportedAt: 2026-08-07T13:05:00.000Z
-- @opIds: 12610

-- --- BEGIN op 12610 ( create custom_format "Criterion" )
-- Boutique disc labels matched nothing unless the title happened to contain
-- "Edition" (issue #10; 112 Criterion titles in the evidence corpus). Disc
-- editions only: the source conditions (bluray OR dvd) exclude Criterion
-- CHANNEL WEB releases, which stay the CRiT streaming tag's business. The
-- parsed release group "Criterion" is required-negated so a group name can
-- never earn the label bonus (Canerhan/TRaSH guard shape). Masters of Cinema
-- and Vinegar Syndrome are deferred: zero evidence titles.
INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('Criterion', '(?<![^\W_])Criterion(?![^\W_])', 'Matches Criterion (Collection) disc-label markers with underscore-tolerant boundaries.', NULL);

INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('Criterion Group', '(?<=^|[\s.-])Criterion\b', 'Matches a release group literally named Criterion so the label format can exclude it.', NULL);

INSERT INTO tags (name) VALUES ('Release Group') ON CONFLICT (name) DO NOTHING;
INSERT INTO regular_expression_tags (regular_expression_name, tag_name) VALUES ('Criterion Group', 'Release Group');

INSERT INTO custom_formats (name, description)
VALUES ('Criterion', 'Matches Criterion Collection disc releases (Bluray/DVD source). Small preference in Quality and Remux profiles.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Criterion', 'Criterion', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Criterion', 'Criterion', 'Criterion');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Criterion', 'Bluray', 'source', 'all', 0, 0);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('Criterion', 'Bluray', 'bluray');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Criterion', 'DVD', 'source', 'all', 0, 0);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('Criterion', 'DVD', 'dvd');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Criterion', 'Not Criterion Group', 'release_group', 'all', 1, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Criterion', 'Not Criterion Group', 'Criterion Group');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
VALUES
  ('1080p Quality', 'Criterion', 'radarr', 50),
  ('1080p Remux', 'Criterion', 'radarr', 50),
  ('2160p Quality', 'Criterion', 'radarr', 50),
  ('2160p Remux', 'Criterion', 'radarr', 50);
-- --- END op 12610
