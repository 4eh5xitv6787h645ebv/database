-- @operation: export
-- @entity: batch
-- @name: Match Spelled Out Dolby Digital
-- @exportedAt: 2026-08-06T20:55:00.000Z
-- @opIds: 12574

-- --- BEGIN op 12574 ( update regular_expression "Dolby Digital" )
-- Plain spelled-out "Dolby.Digital.5.1" matched neither DD nor DD+ (only the
-- abbreviation was known, while the DV cousin regex has supported spelled-out
-- Dolby[ .]?Vision all along). Real class (Prowlarr, usenet obfuscated reposts):
-- "Criminal.Minds.S01E03.720p.WEB-DL.Dolby.Digital.5.1.h264-Obfuscated".
-- The added branch is Plus-guarded so spelled-out Dolby Digital Plus stays
-- exclusively with the DD+ regex (op 214); the DD format's negated DD+ condition
-- double-protects. Completes the OPEN "Dolby Digital family" ledger item.
update "regular_expressions" set "pattern" = '\bDD[^a-z+]|(?<!e-?)\b(ac-?3)\b|\bDolby[ ._-]?Digital\b(?![ ._-]?(P(lus)?\b|\+))' where "name" = 'Dolby Digital' and "pattern" = '\bDD[^a-z+]|(?<!e-?)\b(ac-?3)\b';
-- --- END op 12574
