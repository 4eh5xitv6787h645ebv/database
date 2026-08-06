-- @operation: export
-- @entity: batch
-- @name: Tolerate Separators in Apple TV Plus
-- @exportedAt: 2026-08-07T04:20:00.000Z
-- @opIds: 12575

-- --- BEGIN op 12575 ( update regular_expression "Apple TV+" )
-- The spelled-out form was the literal "Apple TV\+" (space only), and the group's
-- trailing \s*\b cannot close after "+." anyway - so real dotted naming missed:
-- "Drops.of.God.S01E01.A.Father.2160p.Apple.TV+.WEB-DL.DDP.5.1.Atmos.DV.H.265-BlackTV"
-- and the plus-less "...2160p.Apple.TV.WEB-DL..." variants (Prowlarr, BlackTV).
-- The spelled form now takes a separator class and requires a following WEB
-- token (same guard style as Max/iTunes/Movies Anywhere), which keeps titles
-- like "Apple.TV.Repair.Man.2020.1080p.BluRay" unmatched (verified). Same class
-- as the Paramount+ fix in op 215.
update "regular_expressions" set "pattern" = '\b(ATVP|ATV|APTV)\s*\b|\bApple[ ._-]?TV\+?(?=[ ._-]?WEB[ ._-]?(DL|RIP)?\b)' where "name" = 'Apple TV+' and "pattern" = '\b(ATVP|ATV|APTV|Apple TV\+)\s*\b';
-- --- END op 12575
