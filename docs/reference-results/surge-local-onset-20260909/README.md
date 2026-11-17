# Bounded raw-trace surge onset: not promoted

The first experimental onset rule does **not** support replacing the production
baseline. It resolves none of the five previously selected imposed surges.
Production detection, timing, masks, amplitudes and statistics remain unchanged.
The code is confined to `tests/analysis`; no pipeline identity changes.

## Scope and frozen rule

This is a cached measurement experiment on 228 retained surge events from eight
constructed movies based on four DANDI source recordings: ID400, ID401, FB2312
and the separate FB2411 fluorescence control. Each full native event footprint
is evaluated on its constructed trace and paired original-source trace: **456
trace evaluations, not 456 events or recordings**. No movie detection, full master
or statistics run was repeated. The prior amplitude audit independently rebuilt
these cached traces from pixels; see its
[evidence](../surge-amplitude-support-20260909/README.md).

The [protocol](../../SURGE_LOCAL_ONSET.md) was written before the comparison.
A broken straight line searches for an increase in raw-signal slope at most
40 seconds before native onset. Every candidate uses the same context, beginning
60 seconds before native onset and ending at most four seconds after it.
The proposed reference is the 20 seconds immediately preceding the estimated
onset. Spatial support and native peak search remain fixed. Known neighboring
detections, absent/nonfinite context, weak or falling changes, search-edge
solutions and broad profiles leave onset unresolved. No fitted minimum is used
as a baseline. The score is descriptive, not a significance test.

## Results

The constructed and paired-source status counts were identical:

| Outcome | Constructed event rows | Paired source rows |
|---|---:|---:|
| Earlier detected activity intersects the required fitting support | 136 | 136 |
| Full preceding context unavailable at recording start | 28 | 28 |
| Insufficient improvement over a straight line | 45 | 45 |
| Fitted change is not a rising change | 11 | 11 |
| Resolved operational onset | 8 | 8 |
| Total | 228 | 228 |

Thus 164/228 event rows cannot enter the fitting comparison under this context
rule. The current baseline is available for 130 rows and unavailable for 98.
Of those 130 currently available rows, 58 encounter earlier detected activity
in the longer fitting context and eight lack the full preceding context.
Requiring this prototype without fallback would leave only eight provisional
amplitudes. That loss of availability is a property of this rule, not evidence
that the other detections are false.

The five matches were selected previously by native spacetime overlap, before
this onset experiment:

| Source / constructed case | Native start | Known imposed first sample | Result |
|---|---:|---:|---|
| ID400 growing | 127 | 101 | Earlier detected activity in fitting support |
| ID400 shrinking | 127 | 101 | Earlier detected activity in fitting support |
| ID401 growing | 113 | 101 | Insufficient fit improvement; score −6.14 |
| ID401 shrinking | 110 | 101 | Insufficient fit improvement; score −6.41 |
| FB2312 growing | 133 | 101 | Earlier detected activity in fitting support |

The threshold for improvement was 10. The two ID401 score profiles span the
entire 40-second search. Their best candidate locations are diagnostics and
are **not** accepted onset estimates. FB2312 shrinking and both FB2411 cases
have no intersecting retained surge match; they remain explicitly present in
the [eight-case ledger](case-summary.csv). The FB2411 recipe's common support
was outside eligible tissue, so those absences are not onset failures.

The eight resolved movie/event rows refer to existing fluctuations in ID400
and FB2312, repeated across the growing/shrinking movies. Their raw traces are
identical to the source throughout the fitting and native peak intervals.
The estimated onsets move the reference 10–39 seconds earlier and increase
the provisional amplitudes, but there is no imposed signal in their proposed
baselines. This is not evidence of successful injection-onset recovery. The
source can contain genuine physiology; these rows cannot be labeled biological
false positives or used to estimate specificity.

No matched case obtains a proposed onset or baseline. Consequently this run
provides **no matched-event timing error or baseline-bias reduction estimate**.
Unresolved values remain NaN; a best fit or native start is not substituted.

## Interpretation and next experiment

There are two separate obstacles. Requiring all 60 preceding seconds to be free
of detected overlap rejects much of the available data, including cases whose
last 20 seconds pass the existing baseline rule. Where fitting is possible,
the imposed rise on the current large full-event support may not produce a
clear broken-line change against the source fluctuations. These results do not
establish that no better onset estimate is possible. They do reject promoting
this particular rule on the available evidence.

Next use a prespecified trace-level panel with known rises of different sizes
and durations added to the archived backgrounds. Hold support fixed and compare
this rule with a fit restricted to the available contiguous clean context.
Measure onset error, unresolved fraction, residual imposed signal in the
baseline, and background-driven shifts using paired controls. This determines
what the raw trace supports before paying for more full-movie detection runs.
It is a conditional timing test, not detector validation. Fresh positive movie
locations must be screened for tissue eligibility before construction.

## Validation and reproducibility

- **135 MATLAB focused tests passed**, including 12 new onset tests for known
  ramps, linear/falling signals, neighbor exclusions, recording/search bounds,
  missing samples, gain changes, nonpositive references, retained drift and
  fractional sampling rates.
- **34 Python tests passed**, including eight new checks; all also passed with
  `python -O`. A broad-profile fixture remains unresolved, and deliberate
  numerical mismatches still raise errors when assertions are optimized away.
- Independent NumPy least-squares fits agree with all 456 MATLAB evaluations.
  Exclusions are rebuilt from cached pixel masks, and native/proposed baseline
  arithmetic, imposed contributions, missingness and all case/match joins agree.
- Repository checks inspect 392 MATLAB files and pass the hypoxia-amyloid
  synthetic tests. The analyzer reports 74 advisory messages, unchanged from
  the preceding audit. No new full-master integration run is claimed here.
- MATLAB source and the 24 cached input files remained unchanged during the
  experiment. [Code](code-manifest.csv), [input](input-manifest.csv) and
  [artifact](artifact-manifest.csv) hashes accompany the results. Python/protocol
  source hashes are in [validation-code-manifest.csv](validation-code-manifest.csv).

Primary tables: [all fits](onset-results.csv),
[selected matches](preselected-results.csv), [status totals](status-summary.csv),
[case ledger](case-summary.csv), and
[independent verification](independent-verification.json).

From the repository root, with the previous amplitude caches available:

```matlab
setupOxygenDynamicsPath; addpath('tests/analysis');
results = runtests('tests/analysis'); assertSuccess(results);
runSurgeLocalOnsetValidation( ...
    '../reference-validation/surge-amplitude-support-20260909', ...
    '../reference-validation/surge-local-onset-new-run');
```

Then run `tests/analysis/verify_surge_local_onset.py` with that cache directory
and new output directory as its two arguments, using Python with NumPy, Pillow
and h5py installed. Raw TIFFs and MAT caches are not committed to GitHub.
