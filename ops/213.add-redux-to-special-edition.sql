-- @operation: export
-- @entity: batch
-- @name: Add Redux to Special Edition
-- @exportedAt: 2026-08-06T15:55:00.000Z
-- @opIds: 12565

-- --- BEGIN op 12565 ( update regular_expression "Special Edition" )
-- "Redux" is a real, common non-theatrical-cut token in post-year edition position
-- (e.g. "Apocalypse.Now.1979.Redux.1080p.BluRay.DD.7.1.x264-playHD",
-- "Apocalypse.Now.1979.REDUX.2160p.UHD.BLURAY.REMUX.HDR.HEVC...-EXTREME") but is
-- missing from the Special Edition token list, so Redux releases neither get the
-- +1000 edition score nor trip the "Not Special Edition" negation in the
-- Theatrical / Better Theatricals formats. No release group named REDUX exists
-- (srrdb group search empty), so the post-year-anchored token adds no new false
-- positives.
update "regular_expressions" set "pattern" = '(?<=\b[12]\d{3}\b).*\b(Cut|Directors|DC|Extended|Redux|Special|Uncensored|Uncut|Unrated|Version|(?<!{)Edition)(\b|\d)' where "name" = 'Special Edition' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Cut|Directors|DC|Extended|Special|Uncensored|Uncut|Unrated|Version|(?<!{)Edition)(\b|\d)';
-- --- END op 12565
