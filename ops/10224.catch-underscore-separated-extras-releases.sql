-- @operation: export
-- @entity: batch
-- @name: Catch Underscore-Separated Extras Releases
-- @exportedAt: 2026-08-06T16:53:57.000Z
-- @opIds: 12580, 12581

-- --- BEGIN op 12580 ( update regular_expression "Movie Extras" )
-- Underscores are word characters, so the existing word boundaries miss both
-- the year and marker in real names such as
-- Avatar_2009_Collectors_Edition_With_Bonus. Treat underscores as separators
-- while preserving the post-year gate that protects movie-title collisions.
update "regular_expressions" set "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(?:Extras?|Bonus|Extended[ ._-]Clip|Special Feature[s]?)(?![^\W_])', "description" = 'Matches movie extras markers after a separator-delimited four-digit year, including underscore-separated names. Covers Extra/Extras, Bonus, Extended Clip, and Special Feature(s).' where "name" = 'Movie Extras' and "pattern" = '(?<=\b[12]\d{3}\b).*(\b|\.)\b(Extras?|Bonus|Extended[ ._-]Clip|Special Feature[s]?)\b';
-- --- END op 12580

-- --- BEGIN op 12581 ( update regular_expression "TV Extras" )
-- Apply the same boundary rule to season-pack naming such as
-- Mr._Robot_S01_Extras_720p while retaining the post-season marker gate.
update "regular_expressions" set "pattern" = '(?<![^\W_])S\d+(?![^\W_]).*(?<![^\W_])(?:Extras|Bonus|Extended[ ._-]Clip)(?![^\W_])', "description" = 'Matches TV extras markers after a separator-delimited season token, including underscore-separated names. Covers Extras, Bonus, and Extended Clip.' where "name" = 'TV Extras' and "pattern" = '(?<=\bS\d+\b).*\b(Extras|Bonus|Extended[ ._-]Clip)\b';
-- --- END op 12581
