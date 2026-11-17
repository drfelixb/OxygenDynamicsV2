# Surge amplitude footprint and baseline: paired-source audit

**Decision: validate event-local onset and baseline placement before adopting a
persistent-core amplitude.** Smaller supports capture more of the imposed signal,
but can also increase the imposed rising phase in the baseline and alter the
contribution from underlying source fluctuations. A larger amplitude, or one
closer to the imposed 20% change, is not by itself evidence of a better estimate.
The normal full-event amplitude definition is unchanged.

## Scope

Read-only audit of the eight previously constructed growing/shrinking movies
from **four source recordings** in Dandiset 000891, version `0.240215.0831`:

| Source | Movies | Image height × width × frames | µm/pixel | Retained surges, growing / shrinking |
| --- | --- | --- | --- | --- |
| ID400 awake baseline | Growing and shrinking | 512 × 512 × 600 | 4.75 | 51 / 51 |
| ID401 awake baseline | Growing and shrinking | 512 × 512 × 600 | 4.75 | 12 / 12 |
| FB2312 awake baseline | Growing and shrinking | 512 × 512 × 1,200 | 2.35 | 40 / 39 |
| FB2411 fluorescence control | Growing and shrinking | 394 × 221 × 301 | 6.75 | 12 / 11 |

All use 1 Hz sampling. The fluorescence control is interpreted separately.
Per-case provenance contains the exact archive asset and selected image series,
calibration, source/challenge TIFF hashes, and frozen sink/surge MAT hashes.
The [original construction report](../surge-shape-evidence-20260909/README.md)
describes these movies. This audit does not create new recordings, rerun detection,
run master/statistics, upgrade historical output contracts, or establish biological
accuracy. It preserves the original full-event measurement as its comparison.

The 228 retained surge events each receive three fixed spatial supports: full
event union, pixels present in at least 50% of native frames, and pixels present
in at least 75%. Eight additional rows describe recipe-derived common-core
oracles, giving **692 rows**, not 692 independent events. No persistent core was
empty in this set; empty-support behavior is covered by controlled tests.

All three event supports share the original full-event clean-baseline frame list.
The **130 available and 98 unavailable** amplitudes therefore stay available or
unavailable across all three supports. The [protocol](../../SURGE_AMPLITUDE_SUPPORT.md)
defines the exact formulas, units, missingness and counterfactual limitations.

## Spatial capture and rising-phase contamination

Five cases had a previously selected native spacetime-overlap match to the
imposed surge. Selection was reproduced from the masks and was not changed to
favor a core. FB2312 shrinking and both FB2411 cases had no matched event; they
remain in the full audit and case summary rather than disappearing from the set.

In the table, each triplet is **full footprint / 50% core / 75% core**. Applied
increment is the peak positive imposed change relative to the unmodified source
at the same frame on that support. Baseline uplift is the known imposed change
in the twenty-frame native prewindow relative to its unmodified source mean.
These use different reference definitions and must not be subtracted directly.

| Preselected case | Applied increment captured (%) | Imposed baseline uplift (%) |
| --- | --- | --- |
| ID400 growing | 2.87 / 7.76 / 9.80 | 1.14 / 3.10 / 3.92 |
| ID400 shrinking | 3.73 / 10.39 / 13.09 | 2.50 / 6.83 / 7.55 |
| ID401 growing | 4.52 / 10.40 / 12.82 | 0.19 / 0.42 / 0.53 |
| ID401 shrinking | 5.64 / 10.72 / 13.03 | 0.31 / 0.60 / 0.70 |
| FB2312 growing | 5.47 / 13.09 / 18.52 | 3.52 / 8.50 / 12.43 |

The common-core oracles recover approximately **19.987–20.004%** imposed change,
including integer-image rounding. These use the known construction, not an
estimated event support. Their tissue-eligible fractions are approximately 82%
for ID400, 88% for ID401, 76% for FB2312 and **0% for FB2411**. Consequently, the
FB2411 lack of a matched event in these particular disk challenges must not be
interpreted as biological false-negative detection. A dedicated positive-recovery
panel needs locations screened for tissue eligibility before imposing signals.

## Effects on baseline-referenced amplitude

For each support, the counterfactual replaces the constructed prebaseline mean
with the **unmodified source mean at those same frames**. It preserves underlying
source dynamics. The baseline effect below is observed minus counterfactual
amplitude, expressed in **percentage points**, including the denominator change.

| Preselected case | Strict amplitude, full → 75% core (%) | Baseline effect, full → 75% core (percentage points) |
| --- | --- | --- |
| ID400 growing | Unavailable → unavailable | −1.19 → −4.25 |
| ID400 shrinking | Unavailable → unavailable | −2.59 → −8.21 |
| ID401 growing | 11.19 → 19.14 | −0.21 → −0.63 |
| ID401 shrinking | 9.87 → 17.26 | −0.35 → −0.82 |
| FB2312 growing | 10.39 → 14.95 | −3.89 → −14.29 |

ID400 has only 19/20 and 18/20 clean baseline samples, respectively. Its baseline
effects are explicitly **unscreened diagnostics**, not rescued measurements.
All three other preselected cases pass the existing twenty-sample baseline
checks, yet their native prewindows include imposed positive increments for
11, 8 and 20 frames, respectively. `valid` therefore does not mean that the
imposed event had not already started rising.

For FB2312's 75% core, the baseline is raised by 12.43%. Its counterfactual peak
is 29.24%, whereas its observed baseline-referenced peak is 14.95%:

```text
(0.29238 - 0.12431) / (1 + 0.12431) ≈ 0.14949
```

The 29.24% counterfactual is **not** an isolated 20% surge estimate: approximately
9.08 percentage points come from underlying source change at that same peak and
20.16 points from the imposed increment relative to the source baseline.
In ID401 growing, the 75% core's apparent 19.14% similarly combines source and
imposed components. Its proximity to 20% is not sufficient validation.

The [15 preselected support rows](preselected-comparison.csv) retain all exact
components and the 50% results. The [complete table](support-results.csv) includes
all events, no-signal overlaps, unavailable measurements and oracle rows. Source
fluctuations may be physiological or acquisition-related; they are not classified
as noise by this audit. Counterfactual source traces are unavailable for real
spontaneous events, so these values cannot be used as a production correction.

## Numerical verification

- **123 MATLAB tests passed**, including nine new known-answer tests for the
  amplitude algebra, different peak frames, missing baselines, opposite-sign
  baseline contamination, occupancy thresholds and empty cores.
- Repository checks inspected **389 MATLAB files**, with 74 Code Analyzer
  advisory messages. The included hypoxia-amyloid synthetic checks passed.
- **26 Python tests passed**, including seven new counterfactual checks; the
  seven new checks also passed under `-O`.
- Independent verification under `-O` reconstructed all occupancy/oracle
  supports and shared baseline exclusions, and rebuilt **537,371 support-frame
  samples** from complete source/challenge TIFFs. Each sample contains source,
  constructed, positive-increment and negative-increment means.
- All **228 original event amplitudes/statuses** and all **692 support rows**
  passed their numerical checks. There were zero original measurement mismatches.
  This verifies saved-mask calculations, not independent segmentation or
  biological detection accuracy.

See [completion scope](completion.json), [independent verification](independent-verification.json),
[original measurement audit](original-amplitude-audit.csv), [case summary](case-summary.csv),
[MATLAB tests](matlab-tests.csv), [repository checks](repository-checks.json),
[Python tests](python-tests.txt), [optimized tests](python-optimized-tests.txt),
and the [frozen MATLAB source manifest](code-manifest.csv).
Compact CSV evidence uses LF endings; per-case tables are compressed as `.csv.gz`.
`artifact-manifest.csv` hashes the evidence. Native masks and paired trace caches
remain outside Git at `../reference-validation/surge-amplitude-support-20260909`.

## Next implementation

Develop a bounded, event-local onset and prebaseline procedure and test it first
on eligible-tissue imposed signals and unchanged recordings. Compare its estimated
onset with the known imposed start, measure resulting baseline bias, and count
unjustified early shifts in controls. Do not choose the lowest preceding value
to maximize amplitude; preserve uncertain onset and unavailable-reference states.
Keep the current full-event spatial support fixed during that initial comparison,
then repeat it with candidate cores to assess the interaction. Only promote a new
measurement definition after those results are reviewed.
