-- @operation: export
-- @entity: batch
-- @name: Fix Extras CF Condition Wiring
-- @exportedAt: 2026-08-06T19:20:00.000Z
-- @opIds: 12571, 12572

-- --- BEGIN op 12571 ( update custom_format "Extras" )
-- Same wiring bug as DUBBED (op 217), but LIVE: Extras is scored -999999 across
-- 20 profile entries, yet both conditions were required=1 - a title needed a year
-- (Movie Extras anchor) AND an S\d+ marker (TV Extras anchor) simultaneously.
-- Real movie extras ("American.Reunion.2012.EXTRAS.1080p.BluRay.H264-RMXTRAS",
-- "Avatar.Fire.and.Ash.2025.EXTRAS.1080p.BluRay.H264-RiSEHD") carry no season
-- marker; real TV extras packs ("Boardwalk.Empire.S01.EXTRAS.1080p.AV1.10bit-MeGusta")
-- carry no year - both classes were escaping the ban. Only both-marker titles
-- ("11.22.63.2016.Season.1.S01.+.Extras...QxR") could ever fire. Both conditions
-- become optional (Radarr ORs optionals), restoring the intended either-form ban.
update "custom_format_conditions" set "required" = 0 where "custom_format_name" = 'Extras' and "name" = 'Movie Extras' and "negate" = 0 and "required" = 1;
-- --- END op 12571

-- --- BEGIN op 12572 ( update custom_format "Extras" )
update "custom_format_conditions" set "required" = 0 where "custom_format_name" = 'Extras' and "name" = 'TV Extras' and "negate" = 0 and "required" = 1;
-- --- END op 12572
