-- @operation: export
-- @entity: batch
-- @name: Improve Remux and German DL Matching
-- @exportedAt: 2026-08-06T14:55:00.000Z
-- @opIds: 12563, 12564

-- --- BEGIN op 12563 ( update regular_expression "Remux" )
-- \b(Remux)\b never matches the joined spellings BDRemux / BDREMUX / UHDremux
-- (common Russian/Spanish tracker naming; Radarr's own QualityParser accepts
-- (BD|UHD)[-_. ]?Remux). The regex is the "Not Remux" gate in every Quality Tier
-- format and the positive trigger of the Remux / Banned Remux formats (49 formats
-- total), so joined-spelling remuxes slip through all of them - including a
-- demonstrated -999999 Full Disc false positive on
-- "Interstellar.2014.1080p.BDRemux.AVC.DTS-HD.MA.5.1-HDCLUB" (the unanchored AVC
-- branch of Full Disc fires and the broken Remux gate no longer rescues it).
update "regular_expressions" set "pattern" = '\b((BD|UHD)[-_. ]?)?Remux\b' where "name" = 'Remux' and "pattern" = '\b(Remux)\b';
-- --- END op 12563

-- --- BEGIN op 12564 ( update regular_expression "German DL" )
-- The (?<!WEB-) guard that keeps the DL of WEB-DL from being read as Dual
-- Language only covers the hyphen spelling. Real titles also spell it WEB.DL and
-- WEB DL, so e.g. "The.German.Doctor.2013.1080p.WEB.DL.DD5.1.H264-GROUP" (an
-- English release whose movie title contains "German") is banned with -999999 in
-- 11 profiles. Same bug class as the Dolby Vision (Without Fallback) BLURAY fix:
-- a single hardcoded spelling inside an exclusion. Guard becomes the separator
-- class WEB[-_. ] used throughout the database.
update "regular_expressions" set "pattern" = '(?=.*\bGERMAN\b)(?=.*\b(?<!WEB[-_. ])[DM]L\b).*' where "name" = 'German DL' and "pattern" = '(?=.*\bGERMAN\b)(?=.*\b(?<!WEB-)[DM]L\b).*';
-- --- END op 12564
