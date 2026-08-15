-- @operation: export
-- @entity: batch
-- @name: Reconcile Apple TV Split With Separator Fix
-- @exportedAt: 2026-08-16T00:00:00.000Z
-- @opIds: 12920, 12921

-- Context: upstream ops 214/215 (adopted verbatim by this PR) split the single
-- "Apple TV+" regex into two services — "Apple TV+" keeps ATVP/APTV plus the
-- spelled-out literal, and a NEW "Apple TV" regex takes the bare ATV token.
-- Upstream op 12805 rewrites "Apple TV+" starting from the SAME base pattern
-- that fork op 10221 (op 12575) exact-guards on, so on this fork op 10221 now
-- replays as a silent no-op and its separator fix would be lost: upstream's
-- spelled-out branch is the space-only literal "Apple TV\+" whose trailing
-- \s*\b cannot close after "+." — real dotted naming like
-- "Drops.of.God.S01E01.A.Father.2160p.Apple.TV+.WEB-DL.DDP.5.1.Atmos.DV.H.265-BlackTV"
-- (Prowlarr, op 10221 evidence) matches nothing again.
--
-- This op re-applies op 10221's separator class on top of the upstream split,
-- routed per upstream's new token semantics:
--   * "Apple TV+"  keeps ATVP/APTV and gains the separator-tolerant spelled
--     form WITH a mandatory literal "+" and the WEB guard (Max/iTunes style).
--   * "Apple TV"   keeps bare ATV (op 215's fixed \b form) and gains the
--     spelled-out PLUS-LESS form with the same WEB guard; (?!\+) keeps the two
--     spelled branches mutually exclusive.
-- Intended flips vs the pre-adoption fork state: plus-less spelled titles
-- ("...2160p.Apple.TV.WEB-DL...") and bare-ATV titles move from Apple TV+ to
-- Apple TV, mirroring upstream's ATVP/ATV split; dotted "Apple.TV+" titles
-- stay on Apple TV+ (they would match NOTHING under upstream's patterns).
-- Controls: "Apple.TV.Repair.Man.2020.1080p.BluRay.x264-GRP" (no WEB token
-- after TV) stays unmatched by both; ATVP keeps failing the Apple TV \b(ATV)\b
-- branch (no boundary between V and P).

-- --- BEGIN op 12920 ( update regular_expression "Apple TV+" )
update "regular_expressions" set "pattern" = '\b(ATVP|APTV)\s*\b|\bApple[ ._-]?TV\+(?=[ ._-]?WEB[ ._-]?(DL|RIP)?\b)' where "name" = 'Apple TV+' and "pattern" = '\b(ATVP|APTV|Apple TV\+)\s*\b';
-- --- END op 12920

-- --- BEGIN op 12921 ( update regular_expression "Apple TV" )
update "regular_expressions" set "pattern" = '\b(ATV)\b|\bApple[ ._-]?TV(?!\+)(?=[ ._-]?WEB[ ._-]?(DL|RIP)?\b)' where "name" = 'Apple TV' and "pattern" = '\b(ATV)\b';
-- --- END op 12921
