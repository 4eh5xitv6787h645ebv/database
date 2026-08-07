#!/usr/bin/env python3
"""Pull fresh release titles into evidence/titles.txt (metadata only, no grabs).

Sources:
  - Prowlarr search API: a rotating slice of FAMILY_TERMS (day-of-year keyed) so
    every CF family gets fresh evidence over time without hammering indexers.
  - Radarr/Sonarr history APIs (grabbed/imported release names), when configured.

Config: environment file (systemd EnvironmentFile) with
  PROWLARR_URL, PROWLARR_API_KEY, and optionally
  RADARR_URL, RADARR_API_KEY, SONARR_URL, SONARR_API_KEY, EVIDENCE_MAX_ADD.

New unique titles are appended (sorted whole-file rewrite) and committed by the
calling service unit. Exit 0 with "no new titles" is normal.
"""
import datetime
import json
import os
import pathlib
import sys
import urllib.parse
import urllib.request

REPO = pathlib.Path(__file__).resolve().parent.parent
TITLES = REPO / "evidence" / "titles.txt"

# One family per line; the daily rotation walks this list.
FAMILY_TERMS = [
    "1080p bluray x264", "2160p remux", "1080p remux", "bdremux",
    "atmos truehd", "dts-hd ma", "dolby vision hdr10", "hdr10plus",
    "1080p webrip", "2160p web-dl", "repack proper", "extended cut bluray",
    "directors cut 1080p", "imax 2160p", "open matte", "3d half-sbs",
    "german dl 1080p", "hdcam telesync", "complete bluray", "dvd9 pal",
    "special edition remastered", "criterion 1080p", "hybrid remux",
    "e-ac-3 web-dl", "sing along edition", "extras bonus bluray",
    # Targeted hunts for evidence-gated backlog items (#2 #4 #5 #6 #16 #18 #19)
    "korsub hdrip", "hc webrip hardcoded", "german md dubbed", "german ld line dubbed",
    "colorized bluray", "fanedit despecialized", "hidive web-dl", "b-global web-dl",
    "itvx web-dl", "u-next web-dl",
]


def http_json(url: str, headers: dict) -> object:
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def prowlarr_titles(base: str, key: str, terms: list) -> set:
    out = set()
    for term in terms:
        q = urllib.parse.quote(term)
        try:
            rows = http_json(f"{base}/api/v1/search?query={q}&type=search&limit=200",
                             {"X-Api-Key": key})
        except Exception as e:  # one dead indexer must not kill the run
            print(f"prowlarr search {term!r} failed: {e}", file=sys.stderr)
            continue
        out.update(r["title"].strip() for r in rows if r.get("title"))
    return out


def arr_history_titles(base: str, key: str) -> set:
    out = set()
    try:
        rows = http_json(f"{base}/api/v3/history?pageSize=500&sortKey=date&sortDirection=descending",
                         {"X-Api-Key": key})
        for rec in rows.get("records", []):
            t = rec.get("sourceTitle", "").strip()
            if t and "/" not in t:  # skip disk paths, keep release names
                out.add(t)
    except Exception as e:
        print(f"history pull from {base} failed: {e}", file=sys.stderr)
    return out


def main() -> int:
    purl, pkey = os.environ.get("PROWLARR_URL"), os.environ.get("PROWLARR_API_KEY")
    if not (purl and pkey):
        print("PROWLARR_URL/PROWLARR_API_KEY not set", file=sys.stderr)
        return 2

    day = datetime.date.today().toordinal()
    slice_size = 4
    start = (day * slice_size) % len(FAMILY_TERMS)
    terms = [FAMILY_TERMS[(start + i) % len(FAMILY_TERMS)] for i in range(slice_size)]
    print(f"terms today: {terms}")

    fresh = prowlarr_titles(purl.rstrip("/"), pkey, terms)
    for prefix in ("RADARR", "SONARR"):
        u, k = os.environ.get(f"{prefix}_URL"), os.environ.get(f"{prefix}_API_KEY")
        if u and k:
            fresh |= arr_history_titles(u.rstrip("/"), k)

    existing = set(l.strip() for l in TITLES.read_text().splitlines() if l.strip())
    new = sorted(t for t in fresh - existing if 10 <= len(t) <= 300 and "\t" not in t)
    cap = int(os.environ.get("EVIDENCE_MAX_ADD", "500"))
    if len(new) > cap:
        print(f"capping {len(new)} new titles to {cap}")
        new = new[:cap]
    if not new:
        print("no new titles")
        return 0

    TITLES.write_text("\n".join(sorted(existing | set(new))) + "\n")
    print(f"added {len(new)} titles ({len(existing) + len(new)} total)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
