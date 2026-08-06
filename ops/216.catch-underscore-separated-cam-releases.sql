-- @operation: export
-- @entity: batch
-- @name: Catch Underscore Separated CAM Releases
-- @exportedAt: 2026-08-06T18:05:00.000Z
-- @opIds: 12568

-- --- BEGIN op 12568 ( update regular_expression "CAM" )
-- Underscore-separated cam releases escape the CAM ban entirely: underscores are
-- word characters, so neither the year anchor (?<=\b[12]\d{3}\b) nor the \b token
-- boundaries can fire on "_2025_" / "_HDCAM_". Real title (Prowlarr, multiple
-- indexers): "28_Years_Later_2025_1080p_HDCAM_REPACK_x264-SyncUP". Radarr's CF
-- matching sees the raw underscores (SimpleReleaseTitle strips only <>?*| -
-- Parser.cs SimpleReleaseTitleRegex), so this is live. \b becomes (\b|_) at the
-- year anchor and token edges; letter/digit adjacency is still rejected, so
-- group names like -CAMELOT and words like Camp stay unmatched (verified).
update "regular_expressions" set "pattern" = '(?<=(\b|_)[12]\d{3}(\b|_)).*((\b|_)(CAM[ ._-]?(Rip)?|DVD[ ._-]?(SCR(EENER)?)|HD[ ._-]?(CAM|SCR|TC|TS)|SCREENER|TELE(CINE|SYNC)|WORKPRINT)(\b|_))' where "name" = 'CAM' and "pattern" = '(?<=\b[12]\d{3}\b).*(\b(CAM[ ._-]?(Rip)?|DVD[ ._-]?(SCR(EENER)?)|HD[ ._-]?(CAM|SCR|TC|TS)|SCREENER|TELE(CINE|SYNC)|WORKPRINT)\b)';
-- --- END op 12568
