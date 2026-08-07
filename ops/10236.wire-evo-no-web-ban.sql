-- @operation: export
-- @entity: batch
-- @name: Wire EVO (No WEB) Ban
-- @exportedAt: 2026-08-07T11:05:00.000Z
-- @opIds: 12601

-- --- BEGIN op 12601 ( create custom_format "EVO (No WEB)" and ban it )
-- The EVO group regex has existed since v1 with zero condition links (orphaned;
-- LEDGER iteration 18 class). EVO's non-WEB output is the classic fake-early-
-- Bluray / retagged-cam class that beats the CAM ban by using HDRip/BluRay
-- naming, while their genuine WEB-DLs are ordinary and stay acceptable
-- (TRaSH now bans EVO outright; we keep the WEB carve-out per issue #3).
-- Graph: parsed group EVO (required) AND source is not web_dl/webrip
-- (negated required source conditions) AND title carries no WEB-DL token
-- (negated required, reusing the existing WEB-DL regex for dotted spellings).
-- Banned -999999 radarr-side in the same 11 profiles that ban CAM
-- (EVO TV output is negligible; sonarr left unscored).
INSERT INTO custom_formats (name, description)
VALUES ('EVO (No WEB)', 'Matches EVO releases that are not WEB sourced: parsed group EVO with no WEB-DL/WEBRip source and no WEB-DL title token. EVO non-WEB releases are frequently fake Blurays or retagged cams; their WEB-DLs are left untouched.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('EVO (No WEB)', 'EVO', 'release_group', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('EVO (No WEB)', 'EVO', 'EVO');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('EVO (No WEB)', 'Not WEB-DL Source', 'source', 'all', 1, 1);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('EVO (No WEB)', 'Not WEB-DL Source', 'web_dl');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('EVO (No WEB)', 'Not WEBRip Source', 'source', 'all', 1, 1);
INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('EVO (No WEB)', 'Not WEBRip Source', 'webrip');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('EVO (No WEB)', 'Not WEB-DL Title', 'release_title', 'all', 1, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('EVO (No WEB)', 'Not WEB-DL Title', 'WEB-DL');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT quality_profile_name, 'EVO (No WEB)', 'radarr', -999999
FROM quality_profile_custom_formats
WHERE custom_format_name = 'CAM' AND arr_type = 'radarr';
-- --- END op 12601
