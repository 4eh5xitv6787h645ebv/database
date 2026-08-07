-- @operation: export
-- @entity: batch
-- @name: Exclude SBS Broadcaster Context From 3D
-- @exportedAt: 2026-08-07T09:10:00.000Z
-- @opIds: 12597

-- --- BEGIN op 12597 ( update regular_expression "3D" )
-- Op 223 excluded bare SBS only when immediately followed by WEB-DL/WEBRip,
-- the evidenced broadcaster class at the time. The same Korean-broadcaster
-- collision exists for the network's HDTV forms: bare SBS immediately
-- followed by HDTV, a resolution token (720p/1080i/...), an episode marker
-- (E653), or a six-digit broadcast date stamp is a channel tag, not a
-- Side-by-Side packing marker. Extend both lookaheads (yearless corroborated
-- branch and post-year branch) to the full broadcaster-context set. Genuine
-- stereoscopic names keep matching: any explicit 3D token still matches
-- directly, and H/Half/F/Full-prefixed packing forms (HSBS, Half-SBS, FSBS)
-- never enter the bare-SBS exclusion.
update "regular_expressions" set "pattern" = '^(?=.*(?:\b|_)(?:BluRay|BD)?3D(?:\b|_))(?=.*(?:\b|_)(?!SBS[ ._-]?(?:WEB[ ._-]?(?:DL|Rip)?|HDTV|\d{3,4}[pi]|E\d+|\d{6})\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?)(?:\b|_))|(?<=(?<![A-Za-z0-9])[12]\d{3})(?![A-Za-z0-9]).*(?:\b|_)(?:(?:BluRay|BD)?3D|(?!SBS[ ._-]?(?:WEB[ ._-]?(?:DL|Rip)?|HDTV|\d{3,4}[pi]|E\d+|\d{6})\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?))(?:\b|_)', "description" = 'Matches 3D stereoscopic format tags while avoiding title and broadcaster collisions.

**1. Post-year marker** - after a separator-delimited four-digit year, matches `3D` (optionally prefixed with `Bluray` or `BD`) or an Over-Under / Side-by-Side packing marker. Boundaries accept underscores as separators, including underscore-delimited years and tags.

**2. Yearless corroborated marker** - when no usable year precedes the tags, requires both an explicit `3D` marker and an explicit packing marker. This admits unambiguous names such as `Inception 3D BluRay 1080p Half SBS` without treating movie-title-only forms such as `Jaws.3D.1983` as stereoscopic.

The packing branch recognises bare, Half/H, and Full/F forms of Over-Under and Side-by-Side, including compact forms such as `HOU`, `HSBS`, `FOU`, and `FSBS`. Bare `SBS` immediately followed by broadcaster context - a WEB/WEB-DL/WEBRip token, `HDTV`, a resolution token, an `E`-numbered episode marker, or a six-digit broadcast date - is excluded because `SBS` is also a Korean broadcaster tag in real release names.' where "name" = '3D' and "pattern" = '^(?=.*(?:\b|_)(?:BluRay|BD)?3D(?:\b|_))(?=.*(?:\b|_)(?!SBS[ ._-]?WEB[ ._-]?(?:DL|Rip)\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?)(?:\b|_))|(?<=(?<![A-Za-z0-9])[12]\d{3})(?![A-Za-z0-9]).*(?:\b|_)(?:(?:BluRay|BD)?3D|(?!SBS[ ._-]?WEB[ ._-]?(?:DL|Rip)\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?))(?:\b|_)';
-- --- END op 12597
