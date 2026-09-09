"""Independent CSV arithmetic/graph audit; no MATLAB detector imports.

Usage: python3 tests/analysis/verify_surge_branch_replay.py OUTPUT_ROOT
Does not independently reconstruct image candidates or biological identities.
"""
import csv
import gzip
import hashlib
import json
import math
import sys
from collections import Counter, defaultdict
from pathlib import Path


def read(path):
    stream = path.open(newline="") if path.exists() else gzip.open(str(path) + ".gz", "rt", newline="")
    with stream:
        return list(csv.DictReader(stream))


def number(row, field):
    return float(row[field])


def flag(row, field):
    assert row[field].lower() in ("0", "1", "false", "true")
    return row[field].lower() in ("1", "true")


def main(root):
    root = Path(root)
    completion = json.loads((root / "completion.json").read_text())
    summaries = read(root / "policy-summary.csv")
    edge_total = run_total = 0
    for summary in summaries:
        folder = root / summary["Session"] / summary["Case"]
        params = json.loads((folder / "provenance.json").read_text())["Parameters"]
        policy = summary["Policy"]
        runs = read(folder / (policy + "-runs.csv"))
        run_by_id = {int(row["CandidateRunID"]): row for row in runs}
        edges = read(folder / (policy + "-edges.csv"))
        baseline = read(folder / "isolated_shape-edges.csv")
        assert len(edges) == len(baseline)
        incoming, outgoing = defaultdict(list), defaultdict(list)
        linked_counts = Counter()
        ambiguous = set()
        linked_nodes_previous, linked_nodes_next = set(), set()
        for row in edges:
            a, b = int(row["PreviousRunID"]), int(row["NextRunID"])
            f, g = int(row["FromFrame"]), int(row["ToFrame"])
            assert g == f + 1
            assert int(run_by_id[a]["NativeStartFrame"]) <= f <= int(run_by_id[a]["NativeEndFrame"])
            assert int(run_by_id[b]["NativeStartFrame"]) <= g <= int(run_by_id[b]["NativeEndFrame"])
            outgoing[(f, a)].append(row)
            incoming[(g, b)].append(row)
        for row in edges:
            a, b = int(row["PreviousRunID"]), int(row["NextRunID"])
            f, g = int(row["FromFrame"]), int(row["ToFrame"])
            n, na, nb = (number(row, field) for field in ("SharedPixels", "PreviousPixels", "NextPixels"))
            assert 0 < n <= min(na, nb)
            mutual, containment, ratio = n / max(na, nb), n / min(na, nb), max(na, nb) / min(na, nb)
            for field, expected in (("MutualCoverage", mutual), ("SmallerRegionCoverage", containment), ("AreaRatio", ratio)):
                assert math.isclose(number(row, field), expected, rel_tol=1e-12, abs_tol=1e-12)
            np, nn = len(outgoing[(f, a)]), len(incoming[(g, b)])
            assert number(row, "PreviousPartners") == np and number(row, "NextPartners") == nn
            isolated, contact = np == nn == 1, np > 1 or nn > 1
            primary = mutual >= params["surgeTrackingOverlapFraction"]
            geometry = containment >= params["surgeTrackingContainmentFraction"] and ratio <= params["surgeTrackingMaxAreaRatio"]
            expected = primary or (isolated and geometry)
            if policy == "majority_shape":
                expected |= geometry and mutual > .5
            elif policy == "split_only":
                expected |= geometry and mutual > .5 and nn == 1
            elif policy == "segment_contacts":
                expected &= isolated
            assert flag(row, "PrimaryEligible") == primary
            assert flag(row, "Contact") == contact
            assert flag(row, "Linked") == expected == (a == b)
            if contact:
                ambiguous.update((a, b))
            if expected:
                assert (f, a) not in linked_nodes_previous and (g, b) not in linked_nodes_next
                linked_nodes_previous.add((f, a))
                linked_nodes_next.add((g, b))
                linked_counts[a] += 1
        for groups, area_field in ((outgoing, "PreviousPixels"), (incoming, "NextPixels")):
            for rows in groups.values():
                areas = {number(row, area_field) for row in rows}
                assert len(areas) == 1
                assert sum(number(row, "SharedPixels") for row in rows) <= areas.pop()
        for run in runs:
            identity = int(run["CandidateRunID"])
            duration = int(run["NativeEndFrame"]) - int(run["NativeStartFrame"]) + 1
            assert duration == int(run["DurationFrames"]) == linked_counts[identity] + 1
            assert flag(run, "KeptAsEvent") == (duration >= math.ceil(params["ThresholMinddur_Surges"]))
            assert flag(run, "AmbiguousTracking") == (identity in ambiguous)
        assert [int(r["CandidateRunID"]) for r in runs] == list(range(1, len(runs) + 1))
        assert int(summary["CandidateRuns"]) == len(runs)
        assert int(summary["RetainedRuns"]) == sum(flag(r, "KeptAsEvent") for r in runs)
        assert int(summary["AmbiguousRetainedRuns"]) == sum(flag(r, "KeptAsEvent") and flag(r, "AmbiguousTracking") for r in runs)
        assert int(summary["ContactEdges"]) == sum(flag(r, "Contact") for r in edges)
        assert int(summary["LinkedContactEdges"]) == sum(flag(r, "Contact") and flag(r, "Linked") for r in edges)
        assert int(summary["AddedLinks"]) == sum(flag(r, "Linked") and not flag(b, "Linked") for r, b in zip(edges, baseline))
        assert int(summary["RemovedLinks"]) == sum(not flag(r, "Linked") and flag(b, "Linked") for r, b in zip(edges, baseline))
        for row, old in zip(edges, baseline):
            assert all(row[field] == old[field] for field in (
                "FromFrame", "ToFrame", "SharedPixels", "PreviousPixels", "NextPixels"))
        edge_total += len(edges)
        run_total += len(runs)
    assert len(summaries) == completion["CompleteMovieReplays"] * completion["Policies"]
    result = dict(PolicyComparisons=len(summaries), CandidateRunRows=run_total,
                  OverlapEdgeRows=edge_total, LinkRulesVerified=True,
                  DurationAndQualificationVerified=True, AllContactFlagsVerified=True,
                  EndpointPixelAccountingVerified=True,
                  VerifierSHA256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  Scope="CSV graph arithmetic. Candidate reconstruction and pixel conservation are checked by MATLAB; physiological identity and support-score accuracy are not established here.")
    (root / "graph-verification.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main(sys.argv[1])
