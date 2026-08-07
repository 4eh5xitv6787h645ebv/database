#!/usr/bin/env python3
"""Nightly drift sentinel: finds work the database doesn't know it needs.

Checks, each filing a deduplicated GitHub issue on the fork:
  1. unknown-group  — trailing release-group tokens seen on >=3 distinct
     1080p/Bluray-context evidence titles that no release_group regex matches
     (tier-addition candidates per the tier guidelines).
  2. obfuscated     — evidence titles carrying known usenet obfuscation/retag
     tags (candidates for an Obfuscated/Retags CF).
  3. upstream-drift — new commits on Dictionarry-Hub/database main that this
     fork has not reviewed (ops to replay/adapt).

Requirements: gh CLI (authenticated), dotnet (DOTNET_ROOT honored), sqlite3,
a schema clone (SCHEMA_DIR env or ~/work/dictionarry-automation-schema).
State: ~/.local/state/dictionarry-automation/.
Run from the repo root (sentinel-cron.sh does this).
"""
import collections
import json
import os
import pathlib
import re
import subprocess
import sys
import tempfile

REPO = pathlib.Path.cwd()
STATE = pathlib.Path.home() / ".local/state/dictionarry-automation"
GH_REPO = "4eh5xitv6787h645ebv/jakes-profilarr-database"
UPSTREAM = "Dictionarry-Hub/database"
SCHEMA_DIR = os.environ.get("SCHEMA_DIR",
                            str(pathlib.Path.home() / "work/dictionarry-automation-schema"))

OBFUSCATION_TAGS = [
    "Obfuscated", "AsRequested", "AsRq", "NZBGeek", "postbot", "xpost",
    "BUYMORE", "Scrambled", "WhiteRev", "CAPTCHA", "Rakuv", "4Planet",
    "AlternativeToRequested", "GEROV", "Z0iDS3N", "Chamele0n", "4P", "4Planet",
]


def sh(*args: str, **kw) -> str:
    return subprocess.run(args, check=True, capture_output=True, text=True, **kw).stdout


def build_db(path: str) -> None:
    subprocess.run(["bash", "audit/harness/replay.sh", "ops", path],
                   check=True, env={**os.environ, "SCHEMA_DIR": SCHEMA_DIR},
                   capture_output=True, text=True)


def group_patterns(db: str) -> dict:
    import sqlite3
    con = sqlite3.connect(db)
    rows = con.execute("""
        SELECT DISTINCT re.name, re.pattern
        FROM regular_expressions re
        JOIN condition_patterns cp ON cp.regular_expression_name = re.name
        JOIN custom_format_conditions c
          ON c.custom_format_name = cp.custom_format_name AND c.name = cp.condition_name
        WHERE c.type = 'release_group'""").fetchall()
    return dict(rows)


def net_matches(patterns: dict, titles: list) -> dict:
    """title -> set(pattern names that match), via FlipMatrix under .NET semantics."""
    inp = {"pairs": {n: {"before": "(?!x)x", "after": p} for n, p in patterns.items()},
           "titles": titles}
    out = sh("dotnet", "run", "--project", "audit/harness/FlipMatrix",
             "--verbosity", "quiet", input=json.dumps(inp))
    hits = collections.defaultdict(set)
    for line in out.splitlines():
        name, direction, title = line.split("\t", 2)
        if direction == "NEW-MATCH":
            hits[title].add(name)
    return hits


def trailing_group(title: str) -> str | None:
    t = re.sub(r"\.(mkv|mp4|avi|ts|m2ts|wmv)$", "", title, flags=re.I)
    t = re.sub(r"\[[^\]]*\]$", "", t).strip(" .-")
    m = re.search(r"-([A-Za-z0-9@]{2,20})$", t)
    return m.group(1) if m else None


def existing_issue(title: str) -> bool:
    out = sh("gh", "issue", "list", "--repo", GH_REPO, "--state", "all",
             "--search", f'in:title "{title}"', "--json", "title")
    return any(i["title"] == title for i in json.loads(out))


def file_issue(title: str, body: str, labels: list) -> None:
    if existing_issue(title):
        print(f"issue exists, skipping: {title}")
        return
    sh("gh", "issue", "create", "--repo", GH_REPO, "--title", title,
       "--body", body, *sum((["--label", l] for l in labels), []))
    print(f"filed: {title}")


def main() -> int:
    STATE.mkdir(parents=True, exist_ok=True)
    titles = [l.strip() for l in (REPO / "evidence/titles.txt").open() if l.strip()]

    with tempfile.NamedTemporaryFile(suffix=".db") as tf:
        build_db(tf.name)
        patterns = group_patterns(tf.name)
        print(f"{len(patterns)} group patterns, {len(titles)} evidence titles")
        known = net_matches(patterns, titles)

    # 1. unknown recurring groups in 1080p/Bluray context
    ctx = re.compile(r"1080p|blu.?ray|bdrip", re.I)
    counts = collections.defaultdict(set)
    for t in titles:
        if not ctx.search(t) or known.get(t):
            continue
        g = trailing_group(t)
        if g and g.lower() not in {"group", "grp", "sample", "repack"}:
            counts[g].add(t)
    for g, ts in sorted(counts.items(), key=lambda kv: -len(kv[1])):
        if len(ts) < 3:
            continue
        ex = "\n".join(f"- `{t}`" for t in sorted(ts)[:10])
        file_issue(
            f"Sentinel: unknown recurring group {g}",
            f"{len(ts)} distinct 1080p/Bluray-context evidence titles from `-{g}` "
            f"match no release_group regex. Tier-addition candidate — vet per the "
            f"tier guidelines (default Tier 5/6, evidence first).\n\nExamples:\n{ex}",
            ["sentinel", "tier-candidate"])

    # 2. obfuscation tags
    ob = re.compile(r"-(?:" + "|".join(map(re.escape, OBFUSCATION_TAGS)) + r")\d*\b", re.I)
    hits = sorted(t for t in titles if ob.search(t))
    if len(hits) >= 3:
        ex = "\n".join(f"- `{t}`" for t in hits[:15])
        file_issue(
            "Sentinel: obfuscated/retagged releases in evidence",
            f"{len(hits)} evidence titles carry known usenet obfuscation/retag "
            f"group tags and bypass every group-tier CF. Candidate: Obfuscated/"
            f"Retags penalty CF (see cf backlog).\n\nExamples:\n{ex}",
            ["sentinel", "cf-candidate"])

    # 3. upstream drift
    sha = json.loads(sh("gh", "api", f"repos/{UPSTREAM}/commits?per_page=1"))[0]["sha"]
    seen_f = STATE / "upstream-sha"
    seen = seen_f.read_text().strip() if seen_f.exists() else ""
    if sha != seen:
        if seen:
            file_issue(
                f"Sentinel: upstream {UPSTREAM} moved to {sha[:10]}",
                f"Upstream advanced from `{seen[:10] or '(unknown)'}` to `{sha[:10]}`. "
                f"Review new upstream ops for replay/adaptation onto this fork.\n\n"
                f"https://github.com/{UPSTREAM}/compare/{seen}...{sha}",
                ["sentinel", "upstream"])
        seen_f.write_text(sha)
        print(f"upstream sha recorded: {sha[:10]}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
