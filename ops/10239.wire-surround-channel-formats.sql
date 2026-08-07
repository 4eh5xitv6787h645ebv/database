-- @operation: export
-- @entity: batch
-- @name: Wire Surround Channel Formats
-- @exportedAt: 2026-08-07T11:11:00.000Z
-- @opIds: 12604, 12605

-- --- BEGIN op 12604 ( update regular_expression "5.1 Surround" )
-- LEDGER iteration 19 proved the separator/end-boundary form recovers 210
-- bundled titles with zero losses but ruled the regex could only ship
-- "atomically with wiring" — this op is that wiring, so the pattern update
-- lands with its first consumer. Mirrors the op-226 7.1 form exactly.
UPDATE "regular_expressions" SET "pattern" = '(?<!\d)5[ ._]1(?!\d)', "description" = 'Matches 5.1 channel markers with dot, space, or underscore separators, including at string boundaries, while rejecting markers embedded in larger numbers.' WHERE "name" = '5.1 Surround' AND "pattern" = '\D5\.1\D';
-- --- END op 12604

-- --- BEGIN op 12605 ( create custom_formats "5.1 Surround" and "7.1 Surround" )
-- First consumers of the channel-count regexes (issue #15): small tiebreak
-- bonuses in the Balanced profiles only (their audio taste is pragmatic;
-- Quality/Remux already rank via lossless-codec formats). 7.1 outranks 5.1;
-- the 5.1 format required-negates 7.1 so exactly one fires per release.
-- Bonuses (50/100) sit far below the 1000-point tier gap and cannot reorder
-- tiers or sources.
INSERT INTO custom_formats (name, description)
VALUES ('5.1 Surround', 'Matches 5.1 channel audio markers in the release title.');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('5.1 Surround', '5.1 Surround', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('5.1 Surround', '5.1 Surround', '5.1 Surround');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('5.1 Surround', 'Not 7.1 Surround', 'release_title', 'all', 1, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('5.1 Surround', 'Not 7.1 Surround', '7.1 Surround');

INSERT INTO custom_formats (name, description)
VALUES ('7.1 Surround', 'Matches 7.1 channel audio markers in the release title.');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('7.1 Surround', '7.1 Surround', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('7.1 Surround', '7.1 Surround', '7.1 Surround');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
VALUES
  ('1080p Balanced', '5.1 Surround', 'all', 50),
  ('1080p Balanced', '7.1 Surround', 'all', 100),
  ('2160p Balanced', '5.1 Surround', 'all', 50),
  ('2160p Balanced', '7.1 Surround', 'all', 100);
-- --- END op 12605
