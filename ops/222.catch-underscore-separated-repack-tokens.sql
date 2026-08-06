-- @operation: export
-- @entity: batch
-- @name: Catch Underscore Separated Repack Tokens
-- @exportedAt: 2026-08-07T04:45:00.000Z
-- @opIds: 12576, 12577, 12578

-- --- BEGIN op 12576 ( update regular_expression "Repack1" )
-- Same underscore class as the CAM fix (op 216): \b cannot fire between "_" and a
-- token letter, so underscore-separated repacks miss the repack scoring. Real
-- title (Prowlarr, multiple indexers): "28_Years_Later_2025_1080p_HDCAM_REPACK_x264-SyncUP".
-- Controls verified: "Properly" and dotted/plain REPACK/PROPER unchanged.
update "regular_expressions" set "pattern" = '(\b|_)(re(pack|rip)|proper)(\b|_)' where "name" = 'Repack1' and "pattern" = '\b(re(pack|rip)|proper)\b';
-- --- END op 12576

-- --- BEGIN op 12577 ( update regular_expression "Repack2" )
update "regular_expressions" set "pattern" = '(\b|_)(real[\s.]?(re(pack|rip)|proper)|(re(pack|rip)|proper)2)(\b|_)' where "name" = 'Repack2' and "pattern" = '\b(real[\s.]?(re(pack|rip)|proper)|(re(pack|rip)|proper)2)\b';
-- --- END op 12577

-- --- BEGIN op 12578 ( update regular_expression "Repack3" )
update "regular_expressions" set "pattern" = '(\b|_)(real[\s.]?real[\s.]?(re(pack|rip)|proper)|(re(pack|rip)|proper)3)(\b|_)' where "name" = 'Repack3' and "pattern" = '\b(real[\s.]?real[\s.]?(re(pack|rip)|proper)|(re(pack|rip)|proper)3)\b';
-- --- END op 12578
