#!/usr/bin/env python3
"""Arr-level verification: assert every fork op actually changes REAL arr behaviour.

Why this exists
---------------
RegexMatrix/FlipMatrix prove what a pattern does in isolation. They do NOT prove
what Radarr/Sonarr do, because the arr normalizes the release title before custom
formats are evaluated. Real example (2026-08-07): Radarr rewrites `Blu-ray` to
`Bluray`, so a regex-level "false positive" in Dolby Vision (Without Fallback)
could never happen in practice — an upstream bug report based on regex evidence
alone had to be retracted. Anything claimed about behaviour must be proven here.

What it does
------------
1. expectations — runs audit/harness/arr-expectations.json through the FORK arrs
   (parse endpoint) and asserts must_match / must_not_match. Failure = the op
   does not do what its card claims.
2. differential — runs the same titles through the UPSTREAM arrs and reports the
   custom-format delta, so an op that changes nothing versus upstream is visible
   (that is the signature of a fix that only existed at regex level).

Config via env (see ~/.config/dictionarry-automation/env):
  DV_RADARR_FORK_URL/KEY, DV_SONARR_FORK_URL/KEY,
  DV_RADARR_UPSTREAM_URL/KEY, DV_SONARR_UPSTREAM_URL/KEY
Exit 1 if any expectation fails.
"""
import json
import os
import pathlib
import sys
import urllib.parse
import urllib.request

REPO = pathlib.Path(__file__).resolve().parent.parent
EXPECTATIONS = REPO / "audit/harness/arr-expectations.json"


def arr(kind: str, side: str):
    u = os.environ.get(f"DV_{kind.upper()}_{side.upper()}_URL")
    k = os.environ.get(f"DV_{kind.upper()}_{side.upper()}_KEY")
    return (u.rstrip("/"), k) if u and k else (None, None)


def parse(base: str, key: str, title: str) -> set:
    url = f"{base}/api/v3/parse?title={urllib.parse.quote(title)}"
    req = urllib.request.Request(url, headers={"X-Api-Key": key})
    with urllib.request.urlopen(req, timeout=60) as r:
        return {c["name"] for c in json.load(r).get("customFormats", [])}


def main() -> int:
    cases = json.loads(EXPECTATIONS.read_text())["cases"]
    failures, diffs, skipped = [], [], 0

    for case in cases:
        kind = "sonarr" if case.get("type") == "series" else "radarr"
        base, key = arr(kind, "fork")
        if not base:
            skipped += 1
            continue
        got = parse(base, key, case["title"])

        for cf in case.get("must_match", []):
            if cf not in got:
                failures.append((case, f"expected {cf!r}, arr reported {sorted(got)}"))
        for cf in case.get("must_not_match", []):
            if cf in got:
                failures.append((case, f"{cf!r} matched but must not"))

        ubase, ukey = arr(kind, "upstream")
        if ubase:
            up = parse(ubase, ukey, case["title"])
            if got != up:
                diffs.append((case["op"], case["title"], sorted(got - up), sorted(up - got)))
            else:
                diffs.append((case["op"], case["title"], [], []))

    ops_with_effect = {d[0] for d in diffs if d[2] or d[3]}
    ops_without = {d[0] for d in diffs} - ops_with_effect

    print(f"arr-level expectations: {len(cases)} cases, {len(failures)} failed"
          + (f", {skipped} skipped (no instance configured)" if skipped else ""))
    for case, why in failures:
        print(f"  FAIL op {case['op']}: {case['title']}\n        {why}")

    if diffs:
        print(f"\ndifferential vs upstream: {len(ops_with_effect)} ops show a real "
              f"behaviour change, {len(ops_without)} show none")
        for op, title, gained, lost in diffs:
            if gained or lost:
                bits = []
                if gained:
                    bits.append("+" + ", +".join(gained))
                if lost:
                    bits.append("-" + ", -".join(lost))
                print(f"  op {op}: {title[:70]}\n        {' | '.join(bits)}")
        if ops_without:
            print("  NOTE — no upstream delta for ops: " + ", ".join(sorted(ops_without)))
            print("         (either upstream already behaves the same, or the fix only "
                  "exists at regex level — investigate before claiming it upstream)")

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
