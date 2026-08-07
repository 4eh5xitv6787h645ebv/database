-- @operation: export
-- @entity: batch
-- @name: Tolerate Separators in Paramount Plus
-- @exportedAt: 2026-08-06T17:20:00.000Z
-- @opIds: 12567

-- --- BEGIN op 12567 ( update regular_expression "Paramount+" )
-- "Paramount Plus" was space-only while real dotted-scene titles use
-- "Paramount.Plus" (e.g. "Infinite.2021.2160p.WEB-DL.Paramount.Plus.Dolby.Vision.
-- HEVC.E-AC-3.5.1-MZABI", hdencode). Sibling service regexes (Disney+, HBO Max,
-- Crave, Peacock TV) already use separator classes; this brings Paramount+ in
-- line. [ ._-]? is a superset of the old literal space, so no existing match is
-- lost.
update "regular_expressions" set "pattern" = '\b(PMTP|Paramount[ ._-]?Plus)\b' where "name" = 'Paramount+' and "pattern" = '\b(PMTP|Paramount Plus)\b';
-- --- END op 12567
