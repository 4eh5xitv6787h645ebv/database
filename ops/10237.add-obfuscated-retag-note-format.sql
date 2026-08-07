-- @operation: export
-- @entity: batch
-- @name: Add Obfuscated/Retag Note Format
-- @exportedAt: 2026-08-07T11:07:00.000Z
-- @opIds: 12602

-- --- BEGIN op 12602 ( create informational custom_format "Obfuscated" )
-- Usenet obfuscation/retag tags replace the real release group, so every
-- group-tier CF misses these releases (11 live examples in evidence/titles.txt
-- as of 2026-08-07; sentinel issue #7). Per maintainer decision the format is
-- INFORMATIONAL ONLY for now: scored 0 in every profile so it is visible in
-- the arrs and in Profilarr without affecting any grab or upgrade decision.
-- Tag list follows the TRaSH obfuscated/retags clusters (issue #7 references).
INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('Obfuscated Tags', '-(?:Obfuscated|As[-_. ]?Requested|AsRq|AlternativeToRequested|NZBGeek|postbot|xpost|BUYMORE|Scrambled|WhiteRev|CAPTCHA|Rakuv\w*|4Planet|4P|GEROV|Z0iDS3N|Chamele0n)\b', 'Matches usenet obfuscation suffix tags that replace or trail the real release group.', NULL);

INSERT INTO regular_expressions (name, pattern, description, regex101_id)
VALUES ('Retag Tags', '\[\s*(?:eztvx?(?:[ ._-]?(?:io|re|to))?|rarbg|rartv|TGx)\s*\]', 'Matches bracketed re-tag site suffixes appended to stolen releases.', NULL);

INSERT INTO tags (name) VALUES ('Release Group') ON CONFLICT (name) DO NOTHING;
INSERT INTO regular_expression_tags (regular_expression_name, tag_name) VALUES ('Obfuscated Tags', 'Release Group');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name) VALUES ('Retag Tags', 'Release Group');

INSERT INTO custom_formats (name, description)
VALUES ('Obfuscated', 'Matches usenet obfuscated or re-tagged releases (tag replaces the real release group, so group tiers cannot score them). Informational: scored 0 everywhere for now.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Obfuscated', 'Obfuscated Tags', 'release_title', 'all', 0, 0);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Obfuscated', 'Obfuscated Tags', 'Obfuscated Tags');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Obfuscated', 'Retag Tags', 'release_title', 'all', 0, 0);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Obfuscated', 'Retag Tags', 'Retag Tags');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT name, 'Obfuscated', 'all', 0 FROM quality_profiles;
-- --- END op 12602
