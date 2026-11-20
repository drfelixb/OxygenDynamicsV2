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


# Independent specification of runSurgeBranchReplay's frozen experiment.
# Check identities, not just totals supplied by the output being verified.
POLICIES = ("isolated_shape", "majority_shape", "split_only", "segment_contacts")
MOVIE_CASES = (
    ("M401-01-baseline-awake", "smooth_pairs"),
    ("M400-01-baseline-awake", "moving_clean"),
    ("FB2312-baseline-awake", "growing_clean"),
    ("FB2312-baseline-awake", "shrinking_clean"),
    ("FB2411", "growing_clean"),
    ("FB2411", "shrinking_clean"),
)


def require(condition, message):
    """Validation must remain active with -O and PYTHONOPTIMIZE."""
    if not condition:
        raise ValueError(message)


def validate_comparisons(summaries, completion):
    keys = [(r["Session"], r["Case"], r["Policy"]) for r in summaries]
    require(len(keys) == len(set(keys)), "Duplicate recording/case/policy comparison")
    expected = {(session, case, policy) for session, case in MOVIE_CASES for policy in POLICIES}
    missing, unexpected = expected - set(keys), set(keys) - expected
    require(not missing and not unexpected,
            f"Incomplete comparison matrix: missing={sorted(missing)}, unexpected={sorted(unexpected)}")
    for field, expected_count in (
        ("CompleteMovieReplays", len(MOVIE_CASES)),
        ("SourceRecordings", len({session for session, _ in MOVIE_CASES})),
        ("Policies", len(POLICIES)),
    ):
        require(completion[field] == expected_count,
                f"Completion {field} must be {expected_count}, got {completion[field]}")


def read(path):
    stream = path.open(newline="") if path.exists() else gzip.open(str(path) + ".gz", "rt", newline="")
    with stream:
        return list(csv.DictReader(stream))


def number(row, field):
    return float(row[field])


def flag(row, field):
    require(row[field].lower() in ("0", "1", "false", "true"),
            'Invalid boolean flag')
    return row[field].lower() in ("1", "true")


def main(root):
    root = Path(root)
    completion = json.loads((root / "completion.json").read_text())
    summaries = read(root / "policy-summary.csv")
    validate_comparisons(summaries, completion)
    edge_total = run_total = 0
    for summary in summaries:
        folder = root / summary["Session"] / summary["Case"]
        params = json.loads((folder / "provenance.json").read_text())["Parameters"]
        policy = summary["Policy"]
        runs = read(folder / (policy + "-runs.csv"))
        run_by_id = {int(row["CandidateRunID"]): row for row in runs}
        edges = read(folder / (policy + "-edges.csv"))
        baseline = read(folder / "isolated_shape-edges.csv")
        require(len(edges) == len(baseline),
                'Overlap edge count differs from baseline')
        incoming, outgoing = defaultdict(list), defaultdict(list)
        linked_counts = Counter()
        ambiguous = set()
        linked_nodes_previous, linked_nodes_next = set(), set()
        for row in edges:
            a, b = int(row["PreviousRunID"]), int(row["NextRunID"])
            f, g = int(row["FromFrame"]), int(row["ToFrame"])
            require(g == f + 1,
                    'Overlap edge spans nonadjacent frames')
            require(int(run_by_id[a]["NativeStartFrame"]) <= f <= int(run_by_id[a]["NativeEndFrame"]),
                    'Previous endpoint is outside its run')
            require(int(run_by_id[b]["NativeStartFrame"]) <= g <= int(run_by_id[b]["NativeEndFrame"]),
                    'Next endpoint is outside its run')
            outgoing[(f, a)].append(row)
            incoming[(g, b)].append(row)
        for row in edges:
            a, b = int(row["PreviousRunID"]), int(row["NextRunID"])
            f, g = int(row["FromFrame"]), int(row["ToFrame"])
            n, na, nb = (number(row, field) for field in ("SharedPixels", "PreviousPixels", "NextPixels"))
            require(0 < n <= min(na, nb),
                    'Shared pixel count is outside endpoint areas')
            mutual, containment, ratio = n / max(na, nb), n / min(na, nb), max(na, nb) / min(na, nb)
            for field, expected in (("MutualCoverage", mutual), ("SmallerRegionCoverage", containment), ("AreaRatio", ratio)):
                require(math.isclose(number(row, field), expected, rel_tol=1e-12, abs_tol=1e-12),
                        'Overlap geometry mismatch')
            np, nn = len(outgoing[(f, a)]), len(incoming[(g, b)])
            require(number(row, "PreviousPartners") == np and number(row, "NextPartners") == nn,
                    'Partner count mismatch')
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
            require(flag(row, "PrimaryEligible") == primary,
                    'Primary eligibility mismatch')
            require(flag(row, "Contact") == contact,
                    'Contact flag mismatch')
            require(flag(row, "Linked") == expected == (a == b),
                    'Link decision or run identity mismatch')
            if contact:
                ambiguous.update((a, b))
            if expected:
                require((f, a) not in linked_nodes_previous and (g, b) not in linked_nodes_next,
                        'Multiple links share an endpoint')
                linked_nodes_previous.add((f, a))
                linked_nodes_next.add((g, b))
                linked_counts[a] += 1
        for groups, area_field in ((outgoing, "PreviousPixels"), (incoming, "NextPixels")):
            for rows in groups.values():
                areas = {number(row, area_field) for row in rows}
                require(len(areas) == 1,
                        'Inconsistent endpoint area')
                require(sum(number(row, "SharedPixels") for row in rows) <= areas.pop(),
                        'Shared pixels exceed endpoint area')
        for run in runs:
            identity = int(run["CandidateRunID"])
            duration = int(run["NativeEndFrame"]) - int(run["NativeStartFrame"]) + 1
            require(duration == int(run["DurationFrames"]) == linked_counts[identity] + 1,
                    'Run duration mismatch')
            require(flag(run, "KeptAsEvent") == (duration >= math.ceil(params["ThresholMinddur_Surges"])),
                    'Duration qualification mismatch')
            require(flag(run, "AmbiguousTracking") == (identity in ambiguous),
                    'Run ambiguity mismatch')
        require([int(r["CandidateRunID"]) for r in runs] == list(range(1, len(runs) + 1)),
                'Candidate run IDs are not unique and consecutive')
        require(int(summary["CandidateRuns"]) == len(runs),
                'Candidate run total mismatch')
        require(int(summary["RetainedRuns"]) == sum(flag(r, "KeptAsEvent") for r in runs),
                'Retained run total mismatch')
        require(int(summary["AmbiguousRetainedRuns"]) == sum(flag(r, "KeptAsEvent") and flag(r, "AmbiguousTracking") for r in runs),
                'Ambiguous retained run total mismatch')
        require(int(summary["ContactEdges"]) == sum(flag(r, "Contact") for r in edges),
                'Contact edge total mismatch')
        require(int(summary["LinkedContactEdges"]) == sum(flag(r, "Contact") and flag(r, "Linked") for r in edges),
                'Linked contact total mismatch')
        require(int(summary["AddedLinks"]) == sum(flag(r, "Linked") and not flag(b, "Linked") for r, b in zip(edges, baseline)),
                'Added link total mismatch')
        require(int(summary["RemovedLinks"]) == sum(not flag(r, "Linked") and flag(b, "Linked") for r, b in zip(edges, baseline)),
                'Removed link total mismatch')
        for row, old in zip(edges, baseline):
            require(all(row[field] == old[field] for field in (
                "FromFrame", "ToFrame", "SharedPixels", "PreviousPixels", "NextPixels")),
                    'Overlap geometry differs from baseline')
        edge_total += len(edges)
        run_total += len(runs)
    result = dict(PolicyComparisons=len(summaries), CandidateRunRows=run_total,
                  ComparisonMatrixVerified=True,
                  OverlapEdgeRows=edge_total, LinkRulesVerified=True,
                  DurationAndQualificationVerified=True, AllContactFlagsVerified=True,
                  EndpointPixelAccountingVerified=True,
                  VerifierSHA256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  Scope="CSV graph arithmetic. Candidate reconstruction and pixel conservation are checked by MATLAB; physiological identity and support-score accuracy are not established here.")
    (root / "graph-verification.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main(sys.argv[1])
