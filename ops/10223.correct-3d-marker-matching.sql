-- @operation: export
-- @entity: batch
-- @name: Correct 3D Marker Matching
-- @exportedAt: 2026-08-06T16:34:34.000Z
-- @opIds: 12579

-- --- BEGIN op 12579 ( update regular_expression "3D" )
-- Three real SBS-network WEB-DLs were hard-banned as 3D because the packing
-- branch accepted bare SBS. Real stereoscopic names also exposed two false-
-- negative boundary classes: underscore-separated tags/year and a yearless
-- title carrying both explicit 3D and Half-SBS markers. Keep movie-title-only
-- 3D before the year excluded, require corroborating packing for the yearless
-- path, and exclude only bare SBS immediately followed by WEB-DL/WEBRip.
update "regular_expressions" set "pattern" = '^(?=.*(?:\b|_)(?:BluRay|BD)?3D(?:\b|_))(?=.*(?:\b|_)(?!SBS[ ._-]?WEB[ ._-]?(?:DL|Rip)\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?)(?:\b|_))|(?<=(?<![A-Za-z0-9])[12]\d{3})(?![A-Za-z0-9]).*(?:\b|_)(?:(?:BluRay|BD)?3D|(?!SBS[ ._-]?WEB[ ._-]?(?:DL|Rip)\b)(?:(?:H(?:alf)?|F(?:ull)?).?)?(?:O(?:ver)?.?U(?:nder)?|S(?:ide)?[\W_]?B(?:y)?.?S(?:ide)?))(?:\b|_)', "description" = 'Matches 3D stereoscopic format tags while avoiding title and broadcaster collisions.

**1. Post-year marker** - after a separator-delimited four-digit year, matches `3D` (optionally prefixed with `Bluray` or `BD`) or an Over-Under / Side-by-Side packing marker. Boundaries accept underscores as separators, including underscore-delimited years and tags.

**2. Yearless corroborated marker** - when no usable year precedes the tags, requires both an explicit `3D` marker and an explicit packing marker. This admits unambiguous names such as `Inception 3D BluRay 1080p Half SBS` without treating movie-title-only forms such as `Jaws.3D.1983` as stereoscopic.

The packing branch recognises bare, Half/H, and Full/F forms of Over-Under and Side-by-Side, including compact forms such as `HOU`, `HSBS`, `FOU`, and `FSBS`. Bare `SBS` immediately followed by a WEB-DL or WEBRip token is excluded because `SBS` is also a broadcaster tag in real release names.' where "name" = '3D' and "pattern" = '(?<=\b[12]\d{3}\b).*\b((Bluray|BD)?3D|((H(alf)?|F(ull)?).?)?(O(ver)?.?U(nder)?|S(ide)?[\W_]?B(y)?.?S(ide)?))\b';
-- --- END op 12579
