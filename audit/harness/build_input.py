#!/usr/bin/env python3
"""Assemble the RegexMatrix input JSON from a replayed PCD SQLite DB + corpus.json.

Python is used ONLY to assemble JSON; all regex evaluation happens in .NET
(harness/RegexMatrix), matching Radarr/Sonarr semantics exactly.
"""
import json, sqlite3, sys

db_path, corpus_path = sys.argv[1], sys.argv[2]
db = sqlite3.connect(db_path)

REGEX_NAMES = [
    "Dolby Vision", "Dolby Vision (Without Fallback)", "Basic HDR Formats",
    "HDR", "HDR10+", "SDR", "x265", "Movies Anywhere", "Remux", "UHD Bluray",
    "iTunes", "Dolby Digital", "Dolby Digital +", "German DL", "Full Disc", "x264", "Special Edition", "Paramount+", "CAM", "Movie DUBBED", "TV DUBBED", "Movie Extras", "TV Extras",
]
GROUP_REGEXES = ["BiTOR", "DepraveD", "Flights", "SM737", "SumVision", "4KDVS"]

patterns = {}
for name in REGEX_NAMES:
    row = db.execute("SELECT pattern FROM regular_expressions WHERE name=?", (name,)).fetchone()
    if row is None:
        sys.exit(f"regex '{name}' not found in {db_path}")
    patterns[name] = row[0]
for name in GROUP_REGEXES:
    row = db.execute("SELECT pattern FROM regular_expressions WHERE name=?", (name,)).fetchone()
    if row is None:
        sys.exit(f"regex '{name}' not found in {db_path}")
    patterns[f"grp:{name}"] = row[0]

# Composites mirror custom_format_conditions for the release_title conditions of
# each CF (source/resolution conditions are context noted per-case in corpus.json).
composites = [
    {"name": "CF:Dolby Vision (Without Fallback)",
     "all": ["Dolby Vision (Without Fallback)"], "none": ["HDR", "HDR10+"]},
    {"name": "CF:HDR", "all": ["HDR"], "none": ["HDR10+"]},
    {"name": "CF:SDR(title-part)", "all": [], "none": ["Basic HDR Formats", "Movies Anywhere"]},
    {"name": "CF:HDR10 (Missing)(title-part)", "all": [], "none": ["HDR", "HDR10+", "SDR"]},
    {"name": "CF:HDR (Missing)(title-part)",
     "all": ["Dolby Vision", "x265"], "none": ["HDR", "HDR10+", "SDR"]},
    {"name": "CF:Full Disc(title-part)",
     "all": ["Full Disc"], "none": ["Remux", "x264", "x265"]},
    {"name": "CF:DUBBED", "any": ["Movie DUBBED", "TV DUBBED"]},
    {"name": "CF:Extras", "any": ["Movie Extras", "TV Extras"]},
]

corpus = json.load(open(corpus_path))
json.dump({"patterns": patterns, "composites": composites, "cases": corpus["cases"]},
          sys.stdout, indent=1)
