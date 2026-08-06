# Optional local media test assets

The user's workstation has an additional read-only test corpus at:

`/home/jake/media-tests-video-files/`

It contained 12,444 tracked paths when first inspected on 2026-08-07. The
directory includes real media containers, generated Jellyfin/Canopy fixtures,
physical-media stubs, manifests, and ffprobe/MediaInfo/mkvmerge reports.

## How it can help this audit

- Exercise parser and container behavior against actual media files.
- Check codec, stream, subtitle, language, 3D-layout, edition, extras, and
  physical-media edge cases.
- Supply synthetic negative controls for release-title regex changes.
- Reproduce a suspected parser interaction before adding a permanent small
  fixture to `audit/harness/corpus.json`.

For targeted discovery, use a task-specific variable so the optional location
is easy to override:

```bash
MEDIA_TEST_FIXTURES=/home/jake/media-tests-video-files
rg --files "$MEDIA_TEST_FIXTURES" | rg -i 'dual|jpn|eng|edition|3d|extras'
```

## Evidence and portability boundaries

- Most human-readable names in this directory are purpose-built test fixtures,
  not indexer release names. They can prove parser behavior or guard against a
  false positive, but they do not by themselves prove a real-world regex bug.
- Continue to require an independently sourced real release name (for example,
  Prowlarr metadata, SRRDB, an upstream parser fixture, or another public index)
  before landing a production regex expansion.
- The directory exists only on the user's machine. Required tests must not
  depend on it; optional integrations should skip cleanly when it is absent.
- Do not commit, copy, download, or redistribute the media corpus. Only commit
  minimal derived expectations or non-sensitive metadata needed by the audit.

