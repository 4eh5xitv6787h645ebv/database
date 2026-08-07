-- @operation: export
-- @entity: batch
-- @name: Add ALL4 and DSCP Service Tags
-- @exportedAt: 2026-08-07T13:09:00.000Z
-- @opIds: 12612

-- --- BEGIN op 12612 ( create service tag formats "ALL4" and "DSCP" )
-- Channel 4 (ALL4) and Discovery+ (DSCP) WEB-DLs are live in the evidence
-- corpus but matched no service tag (issue #17). Zero-score visibility rows in
-- every profile, matching the existing niche-service convention (iP/NOW/CRAV).
-- DSCP is kept strict — the TRaSH dcp/disc spelling variants collide with
-- ordinary words. ITVX/MY5/STV/U-NEXT stay deferred: zero evidence titles.
INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('ALL4', '(?<![^\W_])ALL4(?![^\W_])', 'Matches Channel 4 (ALL4) service tags with underscore-tolerant boundaries.', NULL);

INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('DSCP', '(?<![^\W_])DSCP(?![^\W_])', 'Matches Discovery+ (DSCP) service tags with underscore-tolerant boundaries.', NULL);

INSERT INTO custom_formats (name, description)
VALUES ('ALL4', 'Matches Channel 4 (ALL4) WEB releases.');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('ALL4', 'ALL4', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('ALL4', 'ALL4', 'ALL4');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('ALL4', 'WEB-DL', 'source', 'all', 0, 0);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('ALL4', 'WEB-DL', 'web_dl');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('ALL4', 'WEBRip', 'source', 'all', 0, 0);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('ALL4', 'WEBRip', 'webrip');

INSERT INTO custom_formats (name, description)
VALUES ('DSCP', 'Matches Discovery+ (DSCP) WEB releases.');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('DSCP', 'DSCP', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('DSCP', 'DSCP', 'DSCP');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('DSCP', 'WEB-DL', 'source', 'all', 0, 0);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('DSCP', 'WEB-DL', 'web_dl');
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('DSCP', 'WEBRip', 'source', 'all', 0, 0);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('DSCP', 'WEBRip', 'webrip');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT name, 'ALL4', 'all', 0 FROM quality_profiles;
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT name, 'DSCP', 'all', 0 FROM quality_profiles;
-- --- END op 12612
