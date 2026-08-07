-- @operation: export
-- @entity: batch
-- @name: Speed Up 3D Marker Matching
-- @exportedAt: 2026-08-07T15:40:00.000Z
-- @opIds: 12613

-- --- BEGIN op 12613 ( update regular_expression "3D" )
-- PERFORMANCE ONLY - the set of matched titles is unchanged, proven below.
--
-- The shipped pattern cost ~2,559 ns per title on the 1,451-title evidence
-- corpus, the most expensive regex in the database, because:
--   1. branch A paid for the full 3D-token alternation (with its \b|_ boundary
--      pairs) on every title, even though almost no title contains "3D" at all;
--   2. branch B opened with a lookbehind, giving the engine no anchor, so it
--      retried the year test at every one of ~60 start positions per title.
--
-- Two matching-neutral guards fix both:
--   1. `(?=.*3D)` in front of branch A - a plain literal scan .NET vectorises,
--      and a strict superset of anything branch A can match (every branch-A
--      match contains the literal "3D").
--   2. branch B is anchored and hops directly between year candidates via
--      `(?:[^12]*[12])*?\d{3}(?<=YEAR)`, preceded by its own superset gate
--      `(?=.*(?:3D|OU|O.U|Over|S.?B|Side))` - every body it can match contains
--      "3D", or an O..U / S..B packing skeleton.
--
-- Measured under exact Radarr semantics (.NET Regex, IgnoreCase|Compiled,
-- median of 15 interleaved rounds): 2,559 ns -> 487 ns per title, a 4.81x
-- speedup. Equivalence proven on 4,025 titles - the full evidence corpus plus
-- 2,576 generated permutations covering every Half/Full x Over-Under/
-- Side-by-Side spelling, every SBS broadcaster context, and year-shaped
-- decoys such as `12345.Movie.2023.3D` that defeat naive first-year-only
-- rewrites: zero new matches, zero lost matches.
update "regular_expressions" set "pattern" = '^(?:(?=.*3D)(?=.*(?:\b|_)(?:BluRay|BD)?3D(?:\b|_))(?=.*(?:\b|_)(?!SBS[ ._-]?(?:WEB[ ._-]?(?:DL|Rip)?|HDTV|\d{3,4}[pi]|E\d+|\d{6})\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?)(?:\b|_))|(?=.*(?:3D|OU|O.U|Over|S.?B|Side))(?:[^12]*[12])*?\d{3}(?<=(?<![A-Za-z0-9])[12]\d{3}(?![A-Za-z0-9])).*(?:\b|_)(?:(?:BluRay|BD)?3D|(?!SBS[ ._-]?(?:WEB[ ._-]?(?:DL|Rip)?|HDTV|\d{3,4}[pi]|E\d+|\d{6})\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?))(?:\b|_))', "description" = 'Matches 3D stereoscopic format tags while avoiding title and broadcaster collisions.

**1. Post-year marker** - after a separator-delimited four-digit year, matches `3D` (optionally prefixed with `Bluray` or `BD`) or an Over-Under / Side-by-Side packing marker. Boundaries accept underscores as separators, including underscore-delimited years and tags.

**2. Yearless corroborated marker** - when no usable year precedes the tags, requires both an explicit `3D` marker and an explicit packing marker. This admits unambiguous names such as `Inception 3D BluRay 1080p Half SBS` without treating movie-title-only forms such as `Jaws.3D.1983` as stereoscopic.

The packing branch recognises bare, Half/H, and Full/F forms of Over-Under and Side-by-Side, including compact forms such as `HOU`, `HSBS`, `FOU`, and `FSBS`. Bare `SBS` immediately followed by broadcaster context - a WEB/WEB-DL/WEBRip token, `HDTV`, a resolution token, an `E`-numbered episode marker, or a six-digit broadcast date - is excluded because `SBS` is also a Korean broadcaster tag in real release names.

Both branches are prefixed with cheap literal pre-tests and the post-year branch hops between year candidates instead of retrying a lookbehind at every position. These are matching-neutral performance guards: the set of matched titles is unchanged.' where "name" = '3D' and "pattern" = '^(?=.*(?:\b|_)(?:BluRay|BD)?3D(?:\b|_))(?=.*(?:\b|_)(?!SBS[ ._-]?(?:WEB[ ._-]?(?:DL|Rip)?|HDTV|\d{3,4}[pi]|E\d+|\d{6})\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?)(?:\b|_))|(?<=(?<![A-Za-z0-9])[12]\d{3})(?![A-Za-z0-9]).*(?:\b|_)(?:(?:BluRay|BD)?3D|(?!SBS[ ._-]?(?:WEB[ ._-]?(?:DL|Rip)?|HDTV|\d{3,4}[pi]|E\d+|\d{6})\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?))(?:\b|_)';
-- --- END op 12613
