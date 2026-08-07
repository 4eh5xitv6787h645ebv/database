-- @operation: export
-- @entity: batch
-- @name: Add DS4K Format
-- @exportedAt: 2026-08-07T12:28:00.000Z
-- @opIds: 12609

-- --- BEGIN op 12609 ( create custom_format "DS4K" )
-- DS4K (1080p downscaled from the 2160p master) is a widespread tracker
-- convention with no pattern in the database (issue #12; live evidence:
-- Crime.101.2026.1080p.DS4K.WEB-DL.x265.10bit.HDR.E-AC-3.5.1-Kris). Most DS4K
-- output is x265, so the bonus lands where x265 is allowed: the 1080p
-- Efficient and Balanced profiles (plus 1080p Quality for the rare x264 case).
-- Kept small: the token says the master was 4K, not that the encoder is good.
INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('DS4K', '(?<![^\W_])DS4K(?![^\W_])', 'Matches DS4K markers (1080p encode downscaled from a 2160p master) with underscore-tolerant boundaries.', NULL);

INSERT INTO custom_formats (name, description)
VALUES ('DS4K', 'Matches releases downscaled from a 4K master. Small preference in 1080p profiles.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('DS4K', 'DS4K', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('DS4K', 'DS4K', 'DS4K');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
VALUES
  ('1080p Quality', 'DS4K', 'all', 25),
  ('1080p Efficient', 'DS4K', 'all', 25),
  ('1080p Balanced', 'DS4K', 'all', 25);
-- --- END op 12609
