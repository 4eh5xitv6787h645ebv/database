-- @operation: export
-- @entity: batch
-- @name: Fix DUBBED CF Condition Wiring
-- @exportedAt: 2026-08-06T18:40:00.000Z
-- @opIds: 12569, 12570

-- --- BEGIN op 12569 ( update custom_format "DUBBED" )
-- Both conditions were required=1, so a release had to match BOTH the movie form
-- (year-anchored "Movie DUBBED") AND the series form (SxxExx-anchored "TV DUBBED")
-- at once - impossible for any normal title. Real movie-dubbed
-- ("Arac.Attack.Angriff.der.achtbeinigen.Monster.2002.GERMAN.DUBBED.DL.1080P.BLURAY.X264-WATCHABLE")
-- matches only the first; real TV-dubbed
-- ("2.Broke.Girls.S01E22.And.The.Big.Buttercream.Breakthrough.GERMAN.DL.DUBBED.1080p.BluRay.x264-TVP")
-- only the second. Radarr/Sonarr semantics: required conditions are ANDed while
-- optional conditions are OR-ed, so both become optional. The format is not yet
-- scored in any profile (op 196 staged it for future use), so this only makes it
-- usable, changing no current scoring.
update "custom_format_conditions" set "required" = 0 where "custom_format_name" = 'DUBBED' and "name" = 'Movie DUBBED' and "negate" = 0 and "required" = 1;
-- --- END op 12569

-- --- BEGIN op 12570 ( update custom_format "DUBBED" )
update "custom_format_conditions" set "required" = 0 where "custom_format_name" = 'DUBBED' and "name" = 'TV DUBBED' and "negate" = 0 and "required" = 1;
-- --- END op 12570
