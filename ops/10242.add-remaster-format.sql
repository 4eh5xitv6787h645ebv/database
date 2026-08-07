-- @operation: export
-- @entity: batch
-- @name: Add Remaster Format
-- @exportedAt: 2026-08-07T12:26:00.000Z
-- @opIds: 12608

-- --- BEGIN op 12608 ( create custom_format "Remaster" )
-- LEDGER iteration 1 ruled Remastered/Restored out of Special Edition ("Radarr
-- classes them separately") but the sibling format was never created, leaving
-- the phenomenon inexpressible (issue #9; 82 remaster titles in the evidence
-- corpus). Post-year anchor in house style keeps movie titles ("Remastering
-- History") unmatched. Small bonus in Quality and Remux profiles.
INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('Remastered', '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])Remaster(?:ed)?(?![^\W_])', 'Matches Remaster/Remastered markers after a separator-delimited year, with underscore-tolerant boundaries.', NULL);

INSERT INTO custom_formats (name, description)
VALUES ('Remaster', 'Matches remastered releases. Small preference in Quality and Remux profiles.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Remaster', 'Remastered', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Remaster', 'Remastered', 'Remastered');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
VALUES
  ('1080p Quality', 'Remaster', 'all', 25),
  ('1080p Remux', 'Remaster', 'all', 25),
  ('2160p Quality', 'Remaster', 'all', 25),
  ('2160p Remux', 'Remaster', 'all', 25);
-- --- END op 12608
