-- @operation: export
-- @entity: batch
-- @name: Normalize Atmos Channel Separators
-- @exportedAt: 2026-08-06T17:59:46.000Z
-- @opIds: 12589, 12590, 12591

-- --- BEGIN op 12589 ( update regular_expression "7.1 Surround" )
-- Real release names normalize 7.1 to "7 1" and "7_1", while the consuming
-- Atmos (Missing) graph also needs end-of-title markers to work. Lookarounds
-- preserve the old dotted matches without consuming their surrounding text.
update "regular_expressions" set "pattern" = '(?<!\d)7[ ._]1(?!\d)', "description" = 'Matches 7.1 channel markers with dot, space, or underscore separators, including at string boundaries, while rejecting markers embedded in larger numbers.' where "name" = '7.1 Surround' and "pattern" = '\D7\.1\D';
-- --- END op 12589

-- --- BEGIN op 12590 ( update regular_expression "Atmos" )
-- Widening 7.1 alone is unsafe: underscore-delimited Atmos, joined
-- TrueHDAtmos, and the evidenced TrueHD 7.1 "Atoms" typo would otherwise be
-- classified as Atmos (Missing). New branches are right-bounded so they do
-- not introduce _Atmosphere or TrueHDAtmospheric prefix collisions.
update "regular_expressions" set "pattern" = '\bATMOS|(?<![^\W_])(?:ATMOS(?:(?![^\W_])|\d)|True[ .-]?HD(?:ATMOS(?:(?![^\W_])|\d)|[ ._-]?[57][ ._]1[ ._-]+ATOMS(?![^\W_])))|DDPA(\b|\d)', "description" = 'Matches Atmos and DDPA markers, including underscore-delimited Atmos, joined TrueHDAtmos, and the evidenced contextual TrueHD 5.1/7.1 Atoms spelling while guarding the new branches against longer-word collisions.' where "name" = 'Atmos' and "pattern" = '\bATMOS|DDPA(\b|\d)';
-- --- END op 12590

-- --- BEGIN op 12591 ( update regular_expression "BTN Atmos" )
-- Keep the legacy dotted branch byte-for-byte, then add a separator-aware
-- branch so normalized TrueHDA7 1 / TrueHDA7_1 shapes cannot become false
-- Atmos (Missing) matches when 7.1 Surround is widened.
update "regular_expressions" set "pattern" = '\bTrue[ .-]?HDA[ .-]?[57]\.1|(?<![^\W_])True[ .-]?HDA[ ._-]?[57][ ._]1(?!\d)', "description" = 'Matches BroadcastTheNet TrueHDA 5.1/7.1 naming plus separator-normalized space and underscore channel forms, including underscore-delimited release names.' where "name" = 'BTN Atmos' and "pattern" = '\bTrue[ .-]?HDA[ .-]?[57]\.1';
-- --- END op 12591
