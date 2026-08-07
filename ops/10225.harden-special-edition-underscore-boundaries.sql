-- @operation: export
-- @entity: batch
-- @name: Harden Edition Underscore Boundaries
-- @exportedAt: 2026-08-06T17:23:56.000Z
-- @opIds: 12582, 12583, 12584, 12585, 12586, 12587, 12588

-- --- BEGIN op 12582 ( update regular_expression "Special Edition" )
-- Underscores are word characters, so the old year and token boundaries miss
-- real names such as Avatar_2009_Collectors_Edition_With_Bonus and
-- The_Shining_1980_Directors_Cut_1080p. Treat underscores as separators while
-- preserving the post-year gate, the {edition- metadata guard, and digit suffixes.
update "regular_expressions" set "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(?:Cut|Directors|DC|Extended|Redux|Special|Uncensored|Uncut|Unrated|Version|(?<!{)Edition)(?:(?![^\W_])|\d)', "description" = 'Matches cut and edition markers after a separator-delimited four-digit year, including underscore-separated release names. Covers Cut, Directors, DC, Extended, Redux, Special, Uncensored, Uncut, Unrated, Version, and Edition while retaining the `{edition-...}` metadata guard and numeric suffix support.' where "name" = 'Special Edition' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Cut|Directors|DC|Extended|Redux|Special|Uncensored|Uncut|Unrated|Version|(?<!{)Edition)(\b|\d)';
-- --- END op 12582

-- --- BEGIN op 12583 ( update regular_expression "IMAX" )
-- Harden every required negation in the same concern. Otherwise widening only
-- the positive would let underscore compounds bypass Special Edition's guards.
update "regular_expressions" set "pattern" = '(?<![^\W_])((?<!NON.?)IMAX)(?![^\W_])', "description" = 'Matches IMAX as a separator-delimited token, including underscore-separated names, while excluding NON IMAX / NON-IMAX style negations.' where "name" = 'IMAX' and "pattern" = '\b((?<!NON.?)IMAX)\b';
-- --- END op 12583

-- --- BEGIN op 12584 ( update regular_expression "Open Matte" )
update "regular_expressions" set "pattern" = '(?<![^\W_])(Open[ ._-]?Matte)(?![^\W_])', "description" = 'Matches Open Matte as a separator-delimited marker, including compact and underscore-separated forms.' where "name" = 'Open Matte' and "pattern" = '\b(Open[ ._-]?Matte)\b';
-- --- END op 12584

-- --- BEGIN op 12585 ( update regular_expression "Theatrical Edition" )
update "regular_expressions" set "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Theatrical)(?:(?![^\W_])|\d)', "description" = 'Matches Theatrical markers after a separator-delimited four-digit year, including underscore-separated edition metadata, while retaining numeric suffix support.' where "name" = 'Theatrical Edition' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Theatrical)(\b|\d)';
-- --- END op 12585

-- --- BEGIN op 12586 ( update regular_expression "Extended Clip" )
update "regular_expressions" set "pattern" = '(?<![^\W_])(extended.?clip)(?![^\W_])', "description" = 'Matches Extended Clip as a separator-delimited marker, including underscore-separated forms.' where "name" = 'Extended Clip' and "pattern" = '\b(extended.?clip)\b';
-- --- END op 12586

-- --- BEGIN op 12587 ( update regular_expression "Sing Along" )
update "regular_expressions" set "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Sing[-_. ]Along)(?![^\W_])', "description" = 'Matches Sing Along markers after a separator-delimited four-digit year, including underscore-separated forms.' where "name" = 'Sing Along' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Sing[-_. ]Along)\b';
-- --- END op 12587

-- --- BEGIN op 12588 ( update regular_expression "Extended Edition" )
-- The scored Extended Edition format shares the same five required negations.
-- Its positive has the identical underscore boundary gap, demonstrated by
-- A.Grand.Ole.Opry.Christmas.2025._edition-Extended_.1080p.WEBRip...
update "regular_expressions" set "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Extended)(?:(?![^\W_])|\d)', "description" = 'Matches Extended markers after a separator-delimited four-digit year, including underscore-separated edition metadata, while retaining numeric suffix support.' where "name" = 'Extended Edition' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Extended)(\b|\d)';
-- --- END op 12588
