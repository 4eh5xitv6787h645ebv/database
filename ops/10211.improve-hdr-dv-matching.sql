-- @operation: export
-- @entity: batch
-- @name: Improve HDR/DV Matching
-- @exportedAt: 2026-08-06T13:25:06.000Z
-- @opIds: 12562

-- --- BEGIN op 12562 ( update regular_expression "Dolby Vision (Without Fallback)" )
-- Demonstrated false positive fixed: hyphenated Blu-ray spellings
-- ("2160p.Blu-ray.x265.DV", "COMPLETE.UHD.BLU-RAY.DV") evade the BLURAY substring
-- negation, hard-banning disc-sourced DV that by definition carries an HDR10 base
-- layer -> BLURAY becomes BLU[-]?RAY, matching "BluRay" or "Blu-Ray" but not
-- "Blu Ray" - the same choice the 'UHD Blu-ray' regex made in
-- "tweak(regex): improve Blu-ray parsing (#31)". The spelling is real-world
-- (Radarr parser fixtures: "Movie.Hunter.2018.720p.Blu-ray.Remux.AVC.FLAC.2.0-SiCFoI").
update "regular_expressions" set "pattern" = '(?<=^(?!.*(HDR|HULU|REMUX|BLU[-]?RAY)).*?)\b(DV|Dovi|Dolby[ .]?Vision)\b' where "name" = 'Dolby Vision (Without Fallback)' and "pattern" = '(?<=^(?!.*(HDR|HULU|REMUX|BLURAY)).*?)\b(DV|Dovi|Dolby[ .]?Vision)\b';
-- --- END op 12562
