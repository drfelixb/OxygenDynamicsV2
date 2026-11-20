"""Exercise the verifier CLI, including broken exports and optimized Python."""
import csv
import gzip
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from verify_surge_branch_replay import MOVIE_CASES, POLICIES


VERIFIER = Path(__file__).with_name("verify_surge_branch_replay.py")
MODES = ("normal", "-O", "PYTHONOPTIMIZE")


def write_csv(path, rows):
    with path.open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


class BranchVerifierTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="oxygen-verifier-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.completion = dict(CompleteMovieReplays=6, SourceRecordings=4, Policies=4)
        self.run = dict(CandidateRunID=1, NativeStartFrame=1, NativeEndFrame=2,
                        DurationFrames=2, AmbiguousTracking=0, KeptAsEvent=1)
        self.edge = dict(FromFrame=1, ToFrame=2, PreviousRunID=1, NextRunID=1,
                         SharedPixels=100, PreviousPixels=100, NextPixels=100,
                         MutualCoverage=1, SmallerRegionCoverage=1, AreaRatio=1,
                         PreviousPartners=1, NextPartners=1, PrimaryEligible=1,
                         Linked=1, Contact=0)
        self.summaries = []
        for session, case in MOVIE_CASES:
            folder = self.root / session / case
            folder.mkdir(parents=True)
            params = dict(surgeTrackingOverlapFraction=.6, surgeTrackingContainmentFraction=.8,
                          surgeTrackingMaxAreaRatio=2, ThresholMinddur_Surges=2)
            (folder / "provenance.json").write_text(json.dumps(dict(Parameters=params)))
            for policy in POLICIES:
                write_csv(folder / (policy + "-runs.csv"), [self.run])
                write_csv(folder / (policy + "-edges.csv"), [self.edge])
                self.summaries.append(dict(Session=session, Case=case, Policy=policy,
                                          CandidateRuns=1, RetainedRuns=1, AmbiguousRetainedRuns=0,
                                          ContactEdges=0, LinkedContactEdges=0, AddedLinks=0, RemovedLinks=0))
        self.write_metadata()

    def write_metadata(self):
        write_csv(self.root / "policy-summary.csv", self.summaries)
        (self.root / "completion.json").write_text(json.dumps(self.completion))

    def run_cli(self, mode):
        env = os.environ.copy()
        env.pop("PYTHONOPTIMIZE", None)
        if mode == "PYTHONOPTIMIZE":
            env["PYTHONOPTIMIZE"] = "1"
        options = ["-O"] if mode == "-O" else []
        return subprocess.run([sys.executable, "-B", *options, str(VERIFIER), str(self.root)],
                              env=env, capture_output=True, text=True, timeout=30)

    def reject_in_all_modes(self, diagnostic):
        for mode in MODES:
            with self.subTest(mode=mode):
                result = self.run_cli(mode)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(diagnostic, result.stderr)
                self.assertNotIn('"LinkRulesVerified": true', result.stdout)
                self.assertFalse((self.root / "graph-verification.json").exists())

    def test_valid_exports_pass_in_all_modes(self):
        self.summaries.reverse()  # Input order is not part of the contract.
        self.write_metadata()
        for mode in MODES:
            with self.subTest(mode=mode):
                result = self.run_cli(mode)
                self.assertEqual(result.returncode, 0, result.stderr)
                report = json.loads(result.stdout)
                self.assertTrue(report["ComparisonMatrixVerified"])
                self.assertTrue(report["DurationAndQualificationVerified"])
                self.assertEqual(report["PolicyComparisons"], 24)
                self.assertEqual(report["CandidateRunRows"], 24)
                self.assertEqual(report["OverlapEdgeRows"], 24)

    def test_invalid_duration_rejected_in_all_modes(self):
        self.run["DurationFrames"] = 999999
        folder = self.root.joinpath(*MOVIE_CASES[0])
        write_csv(folder / "majority_shape-runs.csv", [self.run])
        self.reject_in_all_modes("Run duration mismatch")

    def test_invalid_boolean_rejected_in_all_modes(self):
        self.edge["Linked"] = "not-a-boolean"
        folder = self.root.joinpath(*MOVIE_CASES[0])
        write_csv(folder / "majority_shape-edges.csv", [self.edge])
        self.reject_in_all_modes("Invalid boolean flag")

    def test_duplicate_rows_cannot_replace_comparison_matrix(self):
        self.summaries = [self.summaries[0]] * 24
        self.write_metadata()
        self.reject_in_all_modes("Duplicate recording/case/policy comparison")

    def test_missing_policy_rejected_even_when_totals_are_reduced(self):
        self.summaries = [r for r in self.summaries if r["Policy"] != "split_only"]
        self.completion["Policies"] = 3
        self.write_metadata()
        self.reject_in_all_modes("Incomplete comparison matrix")

    def test_missing_movie_rejected_even_when_totals_are_reduced(self):
        self.summaries = self.summaries[4:]
        self.completion["CompleteMovieReplays"] = 5
        self.write_metadata()
        self.reject_in_all_modes("Incomplete comparison matrix")

    def test_unknown_policy_cannot_replace_expected_policy(self):
        for row in self.summaries:
            if row["Policy"] == "split_only":
                row["Policy"] = "unknown_policy"
        self.write_metadata()
        self.reject_in_all_modes("Incomplete comparison matrix")

    def test_unknown_movie_cannot_replace_expected_movie(self):
        for row in self.summaries[:4]:
            row["Session"] = "unexpected_recording"
        self.write_metadata()
        self.reject_in_all_modes("Incomplete comparison matrix")

    def test_wrong_completion_source_count_rejected(self):
        self.completion["SourceRecordings"] = 5
        self.write_metadata()
        self.reject_in_all_modes("Completion SourceRecordings must be 4")

    def test_compressed_exports_remain_supported(self):
        for path in self.root.glob("*/*/*.csv"):
            with gzip.open(str(path) + ".gz", "wb") as stream:
                stream.write(path.read_bytes())
            path.unlink()
        result = self.run_cli("normal")
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
