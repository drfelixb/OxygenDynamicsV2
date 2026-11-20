# Fixed baseline and timing challenge

12 September 2026. **R2-BASELINE-TIMING-014 completed: retain current calculation
rules, restrict interpretation, defer scientific baseline/timing policy.** This
is synthetic development evidence for BOI measurement, with both signs retained.
It does not close R2 physiological validation, R3 variability evaluation, R4
animal inference or independent R5 researcher release.

The [prespecified decision](../../planning/boi-baseline-timing-20260912.json)
fixes 17 amplitude recipes for each sign and 10 sink timing recipes. The original
pre-execution plan and executed runner are preserved locally. No detector,
recording/cohort analysis, parameter search, baseline shortening or exclusion was
performed. Production functions and the draft measurement dictionary are unchanged.

## What was learned

All **34 amplitude cases** agreed with hand-derived current-rule expectations
and the existing independent raw-footprint auditor. All **10 timing cases**
matched their fixed boundary/status expectations. The **23 existing regression
tests** passed. The MATLAB challenge and tests took **12.48 seconds**, excluding
MATLAB startup, plotting and evidence hashing; peak memory was not measured.

A finite amplitude is a change relative to the chosen preceding baseline over a
fixed spatial footprint. Even a numerically correct value can differ from an
imposed local component:

| Synthetic condition | Sink measured peak | Surge measured peak | Imposed reference |
|---|---:|---:|---|
| Constant background, clean pulse | 20% | 20% | 20% |
| Unmarked same-sign precursor in baseline | 16.67% | 15.38% | 20% |
| Unmarked opposite-sign precursor in baseline | 23.08% | 25.00% | 20% |
| Background rises 0.2 raw units/frame | 16.90% | 21.62% | 20% relative to the declared 100-unit reference |
| Background falls 30 units at event start | 50% | **−10%** | 20% additive component |
| Activity alternates between two pixels | 10% | 10% | 10% over the fixed union; 20% at the active pixel |

The imposed component is known by construction, not inferred from a biological
recording. Its reference is explicitly **100 raw units**. Under drift or a global
step, it is a different estimand from a pre-event-normalized observed trace.
These differences must not be described as coding error or evidence of a
particular physiological cause in HP. The negative synthetic surge is retained.

There are **22 finite and 12 unavailable selected-event amplitudes**. For each
sign, one overlapping same-sign run, one opposite-sign overlap, a recording-start
case and one missing baseline sample yield insufficient clean context; a missing
event sample and a zero baseline yield the other unavailable status. Disjoint
opposite-sign support leaves availability intact. The same-site recurrence case
selects EventID 2 and preserves that identity. No missing value becomes zero, and
no earlier or post-event baseline replaces the unavailable measurement.

The extended-interval fixture keeps five native samples but supplies fifteen
measurement samples with weak tails: peak remains 20%, while the signed integral
changes from ±1 to ±1.5 fraction·seconds. This explicitly supplied interval tests
the finalizer's support contract for both signs; it **does not introduce or imply
an implemented surge timing-refinement rule**.

Timing tests show that a successful threshold crossing, a missing search sample,
a recording edge, an extension limit and a neighboring-event partition have
distinct outcomes. A positive sample inside the native interval keeps timing
unresolved even when both outer edges cross the return threshold. Partial edge
refinement remains visible. These are threshold/support statements, not proofs
of physiological onset or recovery.

![Fixed amplitude and timing challenge](challenge-overview.png)

## Scope and validation

The tiny supplied masks and one-frame/zero-signal cases deliberately bypass
normal detector admission. They test quantification, not sensitivity, false
positives or realistic event size. Deterministic weak/strong, brief/sustained,
recurrent, cross-sign and moving-support examples expose distinct mechanisms;
they do not represent animal variability, acquisition strata, irregular
biological waveforms, motion, noise distributions or the full cohort.

Sampling is exactly 1 Hz in these recipes, with `(frame − 1)/fs` sample times and
inclusive duration. HP's externally triggered 1 Hz remains authoritative;
incorrect embedded recording clocks and camera exposure are separate provenance.
No source recording was used to generate this challenge. Hash verification reads
preserved files only to check integrity.

[Verification report](verification-report.json) records independent Python replay
of all 3,400 amplitude trace rows, all 34 peak/baseline/integral/support results,
and comparison of 10 timing results with the frozen expectations. This is an
independent calculation path, **not an independent human review**. The existing
MATLAB footprint audit independently reconstructs masks and baseline screening.
Numerical tolerance is `1e-10 * max(1, abs(expected))`; no scientific acceptance
threshold was selected. All 460 MATLAB files in the execution manifest match.

The evidence checker initially selected only the newest manifest location label,
leaving older manifests with zero selections. Review caught this; a second
attempt then exposed distinct historical roots. Both scripts/logs and the initial
incomplete report are retained. The completed checker resolves the recorded
roots and requires nonempty selections: **380 prior local artifacts are
unchanged**. MATLAB measurements needed no correction or rerun.

## Reproduction and evidence

Run `setupOxygenDynamicsPath`, add `tests/analysis` to the MATLAB path, then call
[`runBOIBaselineTimingChallenge`](../../../tests/analysis/runBOIBaselineTimingChallenge.m)
with a **new output directory** and the frozen JSON plan. Existing output folders
are rejected. The default 20-second baselines, 0.015 sink return tolerance and
20-second maximum extension are asserted before execution. Unknown recipe IDs
fail. Results are saved before assertion so any disagreement remains inspectable.

Compact evidence is included here: [amplitude results](amplitude-results.csv),
[timing results](timing-results.csv), [amplitude traces](amplitude-traces.csv),
[timing traces](timing-traces.csv), [independent footprint audit](independent-footprint-audit.csv)
and [regression results](regression-tests.csv). Full fixtures, effective MATLAB
settings, code manifest, original plan, executed runner, logs, independent replay
and SVG figure are in workspace
`reference-validation/boi-baseline-timing-20260912/`. The
[artifact record](artifact-record.json) binds both evidence locations.

## Decision and stopping point

Retain current formulas, supports and every result. Restrict claims from
amplitude-complete subsets, drift-affected amplitudes, spatially averaged peaks
and trace-derived recovery. The earlier
[saved-support diagnostic](../boi-measurement-support-20260912/README.md) remains
recording-specific evidence of unavailable-amplitude coverage, not cohort truth.

This bounded challenge stops here. Baseline/missingness policy, physiological
onset/recovery, tissue validity, comparison priority and outcome admission remain
scientific decisions. No candidate method is adopted, no outcome is demoted to
make a test pass, and no further tuning/evaluation is authorized by these results.
The next scientific step is to specify the intended reference and permissible
claims for the chosen comparison before testing a replacement measurement rule.
