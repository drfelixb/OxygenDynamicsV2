# Burden availability and export proposal

15 October 2026. Felix requested investigation of missing contributions, the
supplied script's handling and usable exports that retain normalization while
showing missing data. This is a saved-data review and a separate candidate
export, not adoption of a scientific-output change. No implementation milestone
is active. Owner: root Codex, without delegation.

**Scientific interpretation updated after Felix's objection:** the partial sum
is an internal availability diagnostic, not a recommended biological burden
endpoint or a substitute for the intended recording burden. The proposal to add
it as a routine GUI/export result is withdrawn. Saved evidence and the preview
are retained as historical diagnostic material. No calculation or export rule
has been adopted or changed.

The exclusion mechanism depends on event overlap and the immediate baseline
window. It therefore can select against closely recurring events rather than
merely remove a random fraction of otherwise equivalent observations. The
measured subset does not establish the cumulative burden across events, and
event-count coverage does not identify the fraction of burden retained. Existing
area/time normalization cannot correct this selection. Whether the exclusion
represents appropriate baseline protection, a measurement-contract mismatch or
an implementation defect still needs to be resolved; no answer is assumed here.
The scientific issue is the reference used to measure recurrent and
recording-start events. Blindly restoring shorter/post-event baselines or
discarding unavailable events would not resolve that issue. The intended
amplitude × area × duration sum and its normalization remain the target.

## Bounded evidence and result

The review uses only the existing 17-recording combined workbook and the 17
saved event-amplitude audit CSVs. No movie read, MATLAB start, detector run,
amplitude recalculation, statistics execution or scientific-rule change occurs.
All 5,407 sink event identities, saved amplitudes/statuses, baseline sample
counts and event bounds match their saved audit rows. Every saved event product,
normalization and recording denominator was checked. Area and duration are
available for every event.

| Contribution status | Events |
| --- | ---: |
| Measurable nonnegative sink contribution | 2,767 |
| Insufficient clean pre-event baseline | 2,572 |
| Finite amplitude in the wrong direction for a sink | 68 |
| Total detected sink events | 5,407 |

The baseline failures have disjoint saved-audit flags: 2,452 overlap only,
99 recording-start truncation only, and 21 both. None has nonfinite baseline
samples. Every supplied recording uses a required 20-frame baseline at 1 Hz.
The current finalizer requires the complete immediate window and removes any
frame where either detected event sign overlaps the fixed event footprint.
Even one such exclusion can therefore make the amplitude unavailable.

Overall event coverage is 51.1744%, with individual-recording coverage
39.6887–64.0657%. This is a count fraction, not tissue-time coverage or an
estimated fraction of total physiological burden. Overlap-related missingness
can preferentially exclude recurrent events. No missing-at-random assumption or
coverage-based inflation is justified by this review.

## Supplied versus current source

The pre-development source at `8cf3f03` contains the intended event composite
and area/time normalization. Its `helpers/createHypoxicBurdenMetrics.m` uses
`sum(Contributions,'omitnan')` and reports `NumEvents` as the number of finite
contributions. Thus missing events need not make the total missing, and the
reported count alone can conceal how many detections were excluded.

The old `helpers/quantifyOxygenSinkEvent.m` uses a site raw trace, accepts
truncated pre-event windows, omits nonfinite samples when averaging, and uses
post-event frames when the native event starts at frame 1. It does not perform
the current cross-sign, spatial-overlap exclusion. The old burden helper also
uses a median-based sign convention rather than the current explicit sign
provenance and per-event wrong-direction exclusion. Reinstating the whole old
path would therefore change more than aggregation.

The current `helpers/aggregateOxygenRecordingBurden.m` propagates missing
contributions through a strict sum. All 17 complete normalized totals are
unavailable. Area/time normalization remains unchanged:

`sum(drop_percent * event_area_um2 * duration_sec) * 1e6 / recording_area_um2 * 60 / recording_duration_sec`

The candidate applies only the old omit-missing aggregation idea to current
saved nonnegative contributions. It does not reproduce an old-pipeline result,
restore post-event baselines or infer amplitudes for missing events. The
rank-amplitude and amplitude-free variants remain separate and unchanged.

## Concrete candidate export

The separate `BOI_burden_export_preview.xlsx` contains a recording summary and
all 5,407 event ingredients with contribution reasons and saved baseline flags.
It retains full recording tissue area and full recording duration as the
normalization denominators. No missing amplitude is set to zero. No division by
event coverage, altered denominator or replacement physiological metric is used.

For FB2412, 113 of 227 events contribute (49.7797%). There are 107 missing
baseline amplitudes and seven wrong-direction exclusions. Its observed sum is
24,066,436.484516714 percent·µm²·s. Normalization uses 810,658.8200000002 µm² and
1,200 s, giving 1,484,375.1705875914 percent·µm²·s per mm² per minute. The complete
total remains missing. All 17 observed sums are available and marked partial.

Historical candidate additions to the recording sheet (not recommended for
adoption after the scientific interpretation above):

| Field | Meaning |
| --- | --- |
| `ObservedHypoxicBurden` | Sum of available, current valid event composites |
| `ObservedHypoxicBurden_per_mm2_per_min` | That sum with the existing area/time normalization |
| `NumEvents` and existing `NumValidCompositeEvents` | Total detections and usable event contributions |
| `CompositeEventCoverage` | Usable event count / total detected event count |
| `NumUnavailableAmplitudeEvents` | Events with unavailable saved amplitude |
| `NumWrongDirectionExcludedEvents` | Finite amplitudes excluded from sink deficit burden |
| `BurdenCompleteness` | Complete, partial or unavailable, with existing complete fields retained |

Keep all existing complete burden fields, event ingredients and formulas. Add
an explicit event contribution status to the existing event sheet. The observed
value is a usable description of the measured subset; it is not an estimate of
the full recording burden. Comparisons must retain the missingness information.
If all detected events lack contributions, the observed value must be missing,
not zero. A true zero-event recording with known valid exposure remains zero
under the existing recording registry rules.

## Verification and stopping condition

Artifact Tool formulas reproduce the independent saved-data sums for all 17
recordings. Doubling recording duration halves the normalized value; restoring
the original duration restores it. The saved XLSX is independently reread to
check all 17 summaries and all 5,407 event rows. Formula error scan is empty and
both sheets' relevant views are visually checked. This does not claim execution
inside native Excel. Source workbook and all 17 source audit hashes are unchanged.

Evidence and the single preview workbook are under
`reference-validation/boi-burden-missingness-review-20261015/` at workspace root.
The review ends after presenting the preview. GUI/export adoption remains a
separate decision because it changes published scientific outputs.

## Historical proposed implementation, withdrawn and not active

Add the fields and reasons above through the existing shared burden/export
helpers, preserving complete totals, normalization, original outputs, all
unrelated sheets, calculations and formats. No detector, amplitude or baseline
rule changes. Budget: two active hours, two focused MATLAB check invocations
covering complete/partial/all-missing/valid-zero and exposure cases, plus one
burden-only export to a separate copy of this named workbook (50 MiB ceiling).
Stop after arithmetic, missingness, preservation and GUI export verification.
Defer adoption and keep the separate preview if this change is not approved.
