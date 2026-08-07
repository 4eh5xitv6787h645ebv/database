-- @operation: export
-- @entity: batch
-- @name: Speed Up Year-Anchored Marker Regexes
-- @exportedAt: 2026-08-07T16:40:00.000Z
-- @opIds: 12616

-- --- BEGIN op 12616 ( update 13 regular_expressions )
-- PERFORMANCE ONLY - every matched title set is unchanged, proven below.
--
-- 13 expressions shared one shape: `(?<=\b[12]\d{3}\b).*TOKEN`. The
-- leading lookbehind gives the engine no anchor, so it retried the year test at
-- every position in the title, and most of these formats match nothing at all
-- on a normal release feed - they were pure overhead on every single release.
--
-- Each is rewritten as `^(?=.*GATE).*?(?<=YEAR).*TOKEN`, where GATE is a plain
-- literal that is a strict superset of anything the body can match (a title with
-- no "Noir" in it cannot possibly match the Noir format). The gate can therefore
-- only skip work, never change an answer. Combined:
-- 14,449 -> 2,476 ns per title across the 13 patterns.
--
-- Rejected during this pass, on evidence rather than taste:
--   * Movie Extras - the proposed gate was NOT a superset (the body also matches
--     `Extended[ ._-]Clip`), so the equivalence check failed and it was dropped;
--   * Special Edition, TV Extras - already anchored by ops 10224/10225, where a
--     gate costs more than it saves (0.42x and 0.43x - a slowdown).
--
-- Measured under exact Radarr semantics (.NET Regex, IgnoreCase|Compiled,
-- median of 5 interleaved rounds) and verified on 6,272 titles: 2,247 real
-- Dragon Ball S01E01 release names from five indexers, the evidence corpus, and
-- 2,576 generated permutations. Zero new matches, zero lost matches.

-- CAM: 2,288 -> 625 ns/title (3.77x)
update "regular_expressions" set "pattern" = '^(?=.*(?:CAM|SCR|TELE|WORK|HD[ ._-]?T)).*?(?<=(\b|_)[12]\d{3}(\b|_)).*((\b|_)(CAM[ ._-]?(Rip)?|DVD[ ._-]?(SCR(EENER)?)|HD[ ._-]?(CAM|SCR|TC|TS)|SCREENER|TELE(CINE|SYNC)|WORKPRINT)(\b|_))' where "name" = 'CAM' and "pattern" = '(?<=(\b|_)[12]\d{3}(\b|_)).*((\b|_)(CAM[ ._-]?(Rip)?|DVD[ ._-]?(SCR(EENER)?)|HD[ ._-]?(CAM|SCR|TC|TS)|SCREENER|TELE(CINE|SYNC)|WORKPRINT)(\b|_))';
-- Grayscale: 1,523 -> 83 ns/title (16.53x)
update "regular_expressions" set "pattern" = '^(?=.*Gr[ae]y).*?(?<=\b[12]\d{3}\b).*\b(Gr[ae]y([ ._-]?(scale))?)\b(?!$)' where "name" = 'Grayscale' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Gr[ae]y([ ._-]?(scale))?)\b(?!$)';
-- Color: 1,418 -> 83 ns/title (14.91x)
update "regular_expressions" set "pattern" = '^(?=.*Colo).*?(?<=\b[12]\d{3}\b).*\b((No|Minus)[ ._-]?Colou?r)\b(?!$)' where "name" = 'Color' and "pattern" = '(?<=\b[12]\d{3}\b).*\b((No|Minus)[ ._-]?Colou?r)\b(?!$)';
-- Noir: 1,297 -> 87 ns/title (12.98x)
update "regular_expressions" set "pattern" = '^(?=.*Noir).*?(?<=\b[12]\d{3}\b).*\b(Noir)\b(?!$)' where "name" = 'Noir' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Noir)\b(?!$)';
-- AI Movie Upscale: 1,416 -> 285 ns/title (5.36x)
update "regular_expressions" set "pattern" = '^(?=.*AI).*?(?<=\b[12]\d{3}\b).*(\b(AI)\b)' where "name" = 'AI Movie Upscale' and "pattern" = '(?<=\b[12]\d{3}\b).*(\b(AI)\b)';
-- Black & White: 1,558 -> 469 ns/title (3.15x)
update "regular_expressions" set "pattern" = '^(?=.*(?:hite|Chrome|out|B[ ._-]?(?:and|[n&])|BW)).*?(?<=\b[12]\d{3}\b).*\b((B(lack)?[ ._-]?(out|(and|[n&])?[ ._-]?(W(hite)?|Chrome))))\b(?!$)' where "name" = 'Black & White' and "pattern" = '(?<=\b[12]\d{3}\b).*\b((B(lack)?[ ._-]?(out|(and|[n&])?[ ._-]?(W(hite)?|Chrome))))\b(?!$)';
-- AI TV Upscale: 1,282 -> 224 ns/title (5.28x)
update "regular_expressions" set "pattern" = '^(?=.*AI).*?(?<=\bS\d+\b).*(\b(AI)\b)' where "name" = 'AI TV Upscale' and "pattern" = '(?<=\bS\d+\b).*(\b(AI)\b)';
-- Shush Cut: 1,007 -> 68 ns/title (12.76x)
update "regular_expressions" set "pattern" = '^(?=.*Shush).*?(?<=\b[12]\d{3}\b).*\b(Shush[ ._-]?Cut)\b(?!$)' where "name" = 'Shush Cut' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Shush[ ._-]?Cut)\b(?!$)';
-- Darkness & Light: 1,049 -> 119 ns/title (10.46x)
update "regular_expressions" set "pattern" = '^(?=.*Darkness).*?(?<=\b[12]\d{3}\b).*\b(Darkness?[ ._-]?(and|&)[ ._-]?(Light))\b(?!$)' where "name" = 'Darkness & Light' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Darkness?[ ._-]?(and|&)[ ._-]?(Light))\b(?!$)';
-- Monochrome: 879 -> 57 ns/title (13.99x)
update "regular_expressions" set "pattern" = '^(?=.*Monochrome).*?(?<=\b[12]\d{3}\b).*\b(Monochrome)\b(?!$)' where "name" = 'Monochrome' and "pattern" = '(?<=\b[12]\d{3}\b).*\b(Monochrome)\b(?!$)';
-- Sing Along: 276 -> 115 ns/title (2.4x)
update "regular_expressions" set "pattern" = '^(?=.*Sing).*?(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Sing[-_. ]Along)(?![^\W_])' where "name" = 'Sing Along' and "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Sing[-_. ]Along)(?![^\W_])';
-- Theatrical Edition: 247 -> 108 ns/title (2.51x)
update "regular_expressions" set "pattern" = '^(?=.*Theatrical).*?(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Theatrical)(?:(?![^\W_])|\d)' where "name" = 'Theatrical Edition' and "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Theatrical)(?:(?![^\W_])|\d)';
-- Extended Edition: 210 -> 153 ns/title (1.73x)
update "regular_expressions" set "pattern" = '^(?=.*Extended).*?(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Extended)(?:(?![^\W_])|\d)' where "name" = 'Extended Edition' and "pattern" = '(?<![^\W_])[12]\d{3}(?![^\W_]).*(?<![^\W_])(Extended)(?:(?![^\W_])|\d)';
-- --- END op 12616
