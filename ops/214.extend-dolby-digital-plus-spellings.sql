-- @operation: export
-- @entity: batch
-- @name: Extend Dolby Digital Plus Spellings
-- @exportedAt: 2026-08-06T16:45:00.000Z
-- @opIds: 12566

-- --- BEGIN op 12566 ( update regular_expression "Dolby Digital +" )
-- Two real spelling families matched neither DD nor DD+:
--   1. Canonical hyphenated "E-AC-3" (Dolby's own spelling): the old e[-_. ]?ac3
--      allowed a separator after E but not between AC and 3. Real titles:
--      "Hamilton.2020.2160p.WEB-DL.DSNP.Dolby.Vision.HEVC.E-AC-3.5.1-LEWIS",
--      "The.Browns.S01.1080p.WEB-DL.E-AC-3.H.264-BTN" (hdencode).
--   2. Spelled-out "Dolby.Digital.Plus" (NF WEBRip naming): real titles
--      "Agent.Elvis.S01E01...1080p.NF.WEBRip.Dolby.Digital.Plus.with.Dolby.Atmos.5.1.H.265-iVy",
--      "Black.Widow.2021.Web-Dl.1080p.HEVC.10bit.HDR.Dolby.Digital.Plus.with.Dolby.Atmos.6ch-CAPTCHA".
-- The DD regex's (?<!e-?) guard already suppresses its ac-?3 branch on E-AC-3, so
-- these titles land exclusively in DD+ as intended. Plain spelled-out
-- "Dolby Digital" (without Plus) remains unhandled pending a real title (LEDGER).
update "regular_expressions" set "pattern" = '\bDD[P+]|\b(e[-_. ]?ac[-_. ]?3)\b|\bDolby[ ._-]?Digital[ ._-]?(P(lus)?\b|\+)' where "name" = 'Dolby Digital +' and "pattern" = '\bDD[P+]|\b(e[-_. ]?ac3)\b';
-- --- END op 12566
