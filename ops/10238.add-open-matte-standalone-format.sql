-- @operation: export
-- @entity: batch
-- @name: Add Open Matte Standalone Format
-- @exportedAt: 2026-08-07T11:09:00.000Z
-- @opIds: 12603

-- --- BEGIN op 12603 ( create custom_format "Open Matte" )
-- The Open Matte regex exists (audit-hardened in op 225) but is wired only as
-- a negation inside the edition formats, so Open Matte itself can be neither
-- preferred nor avoided (issue #11). Create the standalone format at score 0
-- radarr-side in every profile (SDR-highlight style): visible, neutral, and
-- ready for users to flip positive or negative.
INSERT INTO custom_formats (name, description)
VALUES ('Open Matte', 'Matches Open Matte releases (full-frame versions without theatrical letterboxing). Neutral highlight by default; score it up or down to taste.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Open Matte', 'Open Matte', 'release_title', 'all', 0, 1);
INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('Open Matte', 'Open Matte', 'Open Matte');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT name, 'Open Matte', 'radarr', 0 FROM quality_profiles;
-- --- END op 12603
