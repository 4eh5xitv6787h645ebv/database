-- @operation: export
-- @entity: regular_expression
-- @name: Bound DTS Hi Shorthand
-- @exportedAt: 2026-08-06T18:21:01.000Z
-- @opIds: 12592

-- --- BEGIN op 12592 ( update regular_expression "DTS-HD HRA ES" )
-- Real Hi10P and Hi444PP video-profile markers can immediately follow an
-- ordinary DTS token. Bound only the legacy "Hi" shorthand before letters or
-- digits, while retaining underscore as a repository-standard separator and
-- preserving the existing DTS-ES and HR/HRA branches byte-for-byte in effect.
update "regular_expressions" set "pattern" = 'dts[-. ]?(es|(hd[. ]?)?(hra?|hi(?![^\W_])))', "description" = 'Matches DTS-ES and DTS-HD HR/HRA/Hi markers while preventing joined Hi10P, Hi444PP, and longer Hi-prefixed video or word tokens from negating ordinary DTS.' where "name" = 'DTS-HD HRA ES' and "pattern" = 'dts[-. ]?(es|(hd[. ]?)?(hr|hi))';
-- --- END op 12592
