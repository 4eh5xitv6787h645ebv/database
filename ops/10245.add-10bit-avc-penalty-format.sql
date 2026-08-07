-- @operation: export
-- @entity: batch
-- @name: Add 10-bit AVC Penalty Format
-- @exportedAt: 2026-08-07T13:07:00.000Z
-- @opIds: 12611

-- --- BEGIN op 12611 ( create custom_format "10-bit AVC" )
-- Hi10P (10-bit AVC, the anime encode profile) has no hardware decoder
-- anywhere, so it always forces a software transcode, yet scored like
-- ordinary x264 (issue #13; real victims: Big.Hero.6 Hi10p-NTb, The Hobbit
-- Hi10P-DON). The AVC conjunction is mandatory: bare 10bit would hit fine
-- HEVC releases, so x264 is required and x265 is required-negated. Penalty
-- (not ban) in the hardware-oriented 1080p Compact and Efficient profiles.
INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('10-bit Marker', '(?<![^\W_])(?:Hi10P?|10[ ._-]?bit)(?![^\W_])', 'Matches 10-bit / Hi10P bit-depth markers with underscore-tolerant boundaries.', NULL);

INSERT INTO custom_formats (name, description)
VALUES ('10-bit AVC', 'Matches 10-bit AVC (Hi10P) encodes, which no hardware decoder supports. Penalized in hardware-oriented profiles.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('10-bit AVC', '10-bit Marker', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('10-bit AVC', '10-bit Marker', '10-bit Marker');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('10-bit AVC', 'x264', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('10-bit AVC', 'x264', 'x264');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('10-bit AVC', 'Not x265', 'release_title', 'all', 1, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('10-bit AVC', 'Not x265', 'x265');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
VALUES
  ('1080p Compact', '10-bit AVC', 'all', -10000),
  ('1080p Efficient', '10-bit AVC', 'all', -10000);
-- --- END op 12611
