-- @operation: export
-- @entity: batch
-- @name: Right-Bound Legacy Atmos Prefix Branch
-- @exportedAt: 2026-08-07T09:12:00.000Z
-- @opIds: 12598

-- --- BEGIN op 12598 ( update regular_expression "Atmos" )
-- Op 226 right-bounded its NEW branches against Atmosphere-class collisions
-- but kept the legacy unbounded `\bATMOS` prefix branch, so word-boundary-
-- delimited titles (`Atmosphere.2023.`, `.Atmosphere.`) still classify as
-- Atmos and wrongly suppress Atmos (Missing). The legacy branch is a strict
-- subset of the bounded `(?<![^\W_])ATMOS(?:(?![^\W_])|\d)` branch for every
-- genuine marker shape (start-of-title, dotted, spaced, hyphenated, and
-- digit-suffixed forms), so dropping it removes only the longer-word
-- collisions. Underscore-delimited `_Atmosphere_` was already protected by
-- `\b` failing between word characters; this closes the remaining
-- dot/start-delimited class.
update "regular_expressions" set "pattern" = '(?<![^\W_])(?:ATMOS(?:(?![^\W_])|\d)|True[ .-]?HD(?:ATMOS(?:(?![^\W_])|\d)|[ ._-]?[57][ ._]1[ ._-]+ATOMS(?![^\W_])))|DDPA(\b|\d)', "description" = 'Matches Atmos and DDPA markers, including underscore-delimited Atmos, joined TrueHDAtmos, and the evidenced contextual TrueHD 5.1/7.1 Atoms spelling, with every branch right-bounded against longer-word collisions such as Atmosphere.' where "name" = 'Atmos' and "pattern" = '\bATMOS|(?<![^\W_])(?:ATMOS(?:(?![^\W_])|\d)|True[ .-]?HD(?:ATMOS(?:(?![^\W_])|\d)|[ ._-]?[57][ ._]1[ ._-]+ATOMS(?![^\W_])))|DDPA(\b|\d)';
-- --- END op 12598
