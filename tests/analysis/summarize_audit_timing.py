"""Summarize within-site timing overlap from a completed signal audit (stdlib only)."""
import argparse
import csv
from collections import defaultdict
from pathlib import Path


def summarize(root):
    with (root / "all-event-signal-audit.csv").open() as source:
        by_session = defaultdict(list)
        for row in csv.DictReader(source):
            by_session[row["Session"]].append(row)
    results = []
    for session, rows in sorted(by_session.items()):
        sites = defaultdict(list)
        for index, row in enumerate(rows):
            if row["EventType"] == "sink":
                sites[row["SiteID"]].append((index, row))
        overlapping, identical, pairs = set(), set(), 0
        for group in sites.values():
            for offset, (index, first) in enumerate(group):
                for other_index, second in group[offset + 1:]:
                    start = max(int(first["StartFrame"]), int(second["StartFrame"]))
                    end = min(int(first["EndFrame"]), int(second["EndFrame"]))
                    if start <= end:
                        overlapping.update((index, other_index))
                        pairs += 1
                        if (first["StartFrame"], first["EndFrame"]) == (
                            second["StartFrame"], second["EndFrame"]
                        ):
                            identical.update((index, other_index))
        results.append(dict(
            Session=session, SinkEvents=sum(map(len, sites.values())),
            EventsWithSameSiteWindowOverlap=len(overlapping), OverlappingPairs=pairs,
            EventsWithIdenticalSameSiteWindow=len(identical),
        ))
    if not results:
        raise ValueError("No recording rows in audit input")
    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("audit_root", type=Path)
    args = parser.parse_args()
    summary = summarize(args.audit_root)
    with (args.audit_root / "same-site-timing-overlap.csv").open("w", newline="") as target:
        writer = csv.DictWriter(target, fieldnames=summary[0])
        writer.writeheader()
        writer.writerows(summary)
