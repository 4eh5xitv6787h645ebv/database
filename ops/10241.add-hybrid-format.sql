-- @operation: export
-- @entity: batch
-- @name: Add Hybrid Format
-- @exportedAt: 2026-08-07T12:24:00.000Z
-- @opIds: 12607

-- --- BEGIN op 12607 ( create custom_format "Hybrid" )
-- Zero patterns contained "hybrid" despite hybrids being the flagship output
-- of the database's own top-tier groups (103 hybrid-remux titles in the
-- evidence corpus; issue #8). Small tiebreak bonus in the Quality and Remux
-- profiles. The -HYBRID release group is required-negated so group names never
-- masquerade as the edition marker (Canerhan/TRaSH guard shape).
INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('Hybrid', '(?<![^\W_])HYBRID(?:(?![^\W_])|\d)', 'Matches Hybrid release markers (best-of-multiple-sources masters) with underscore-tolerant boundaries.', NULL);

INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('HYBRID Group', '(?<=^|[\s.-])HYBRID\b', 'Matches the HYBRID release group so the Hybrid marker format can exclude it.', NULL);

INSERT INTO tags (name) VALUES ('Release Group') ON CONFLICT (name) DO NOTHING;
INSERT INTO regular_expression_tags (regular_expression_name, tag_name) VALUES ('HYBRID Group', 'Release Group');

INSERT INTO custom_formats (name, description)
VALUES ('Hybrid', 'Matches hybrid releases (video/audio remastered from multiple sources). Small tiebreak preference in Quality and Remux profiles.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Hybrid', 'Hybrid', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Hybrid', 'Hybrid', 'Hybrid');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Hybrid', 'Not HYBRID Group', 'release_group', 'all', 1, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Hybrid', 'Not HYBRID Group', 'HYBRID Group');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
VALUES
  ('1080p Quality', 'Hybrid', 'all', 100),
  ('1080p Quality HDR', 'Hybrid', 'all', 100),
  ('1080p Remux', 'Hybrid', 'all', 100),
  ('2160p Quality', 'Hybrid', 'all', 100),
  ('2160p Remux', 'Hybrid', 'all', 100);
-- --- END op 12607
