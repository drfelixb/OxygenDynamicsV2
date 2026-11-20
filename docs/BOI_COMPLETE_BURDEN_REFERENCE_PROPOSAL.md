# Obtaining complete burden: remaining reference problems and proposal

16 October 2026. **Review and proposal only; no new method adopted.**

The remaining obstacle is identifying a suitable local reference for every
required event. It is not an export or summation failure. All 17 recording
totals correctly remain unavailable. A defensible workflow can recover some
references, but these recordings alone may not support complete burden for all
17. Producing a number for every recording cannot be an acceptance condition
that overrides the evidence.

## What was examined

AMP-COMPLETE-REVIEW-01; owner root, no delegation. The researcher requested
examination of the remaining issues and a proposal, preserving formula,
normalization and no partial sums. This review used all 5,407 verified sink
export rows, the same 17 saved audit/master pairs and eight fixed illustrative
events. No original movie pixels, detector, correction, statistics or export
were run. No candidate amplitudes or recording totals were generated.

The supplied manuscript defines cumulative burden as the sum of amplitude ×
area × duration across events, with recurrence contributing through summation.
The [Science study](https://pmc.ncbi.nlm.nih.gov/articles/PMC11251491/) describes
local recurring deficits and explicitly limits BLI to relative short-term oxygen
changes. The [published protocol](https://pmc.ncbi.nlm.nih.gov/articles/PMC11460448/)
describes a 20-second pre-event amplitude reference. Neither establishes a
universal biological recovery threshold, the current 20-second reference-age
limit, nor an automatic post-event reference. The rules proposed below are
inferences to test, not published validated recovery criteria.

Private source: `Beinlich-et-al_HypoxicPockets_Review_final.docx`, supplied by
Felix in the earlier conversation. Its cumulative-stress interpretation supports
retaining recurrence rather than selecting only isolated events. This optical
composite does not measure absolute oxygen debt, prove normoxia at reference,
or directly measure tissue injury.

## Findings across the 17 recordings

3,256 contributions are numerically available; 2,151 remain unavailable.
Current status categories are mutually exclusive and evaluated in order:
recording start, age, reference completeness, signal guards, direction. Thus an
age flag can conceal additional reference contamination. A clean reference
means native-mask/sample eligibility, not demonstrated physiological recovery.

| Current failure | Events | What the additional saved-data examination shows |
|---|---:|---|
| Reference shifted more than 20 seconds | 1,007 | 782 head-reference windows have all 20 clean samples; 213 overlap detections and 12 are truncated. Cleanliness alone cannot justify carrying an old level. |
| Incomplete clean reference | 973 | 912 overlap a sink or surge; 61 have too few acquired frames without overlap. Three of the 912 also have acquisition truncation. No nonfinite reference samples explain these failures. |
| Unresolved recording-start reference | 72 | These belong to 48 linked series whose heads genuinely begin at native frame 1, including 24 later linked events. |
| Wrong-direction optical amplitude | 99 | A full clean reference exists, but the event minimum is above its reference. This is not missing data and cannot be repaired with an absolute value or zero. |

Among the 973 incomplete references, 537 contact sinks and 400 contact surges,
with 25 contacting both. Only 59 contact their own site's native support;
482 have at least one frame contacting another sink without same-site contact
at that frame. These latter counts can overlap other categories. Therefore,
same-site recurrence alone cannot solve this problem. Native overlap can include
real signal contamination or detection/support disagreement; the review does
not establish which contacts may be ignored. Ninety-four windows have 19/20
clean samples. Accepting them automatically would still change the rule and
would not solve most missing references.

Old reference shifts are 21–40 seconds for 612 events, 41–60 for 219, 61–120 for
163 and 121–226 for 13. These are distances between measurement starts, not the
time from reference to every event sample. The age limit is a conservative
guard, not a demonstrated point at which tissue reference changes.

| Recording | Available / all | Old | Incomplete | Start | Wrong direction |
|---|---:|---:|---:|---:|---:|
| FB2412 | 143 / 227 | 40 | 34 | 1 | 9 |
| FB2413 | 148 / 251 | 37 | 56 | 4 | 6 |
| FB2419 | 171 / 254 | 52 | 23 | 4 | 4 |
| FB2420 | 203 / 340 | 72 | 31 | 9 | 25 |
| FB2311 | 142 / 240 | 43 | 48 | 1 | 6 |
| FB2316 | 176 / 318 | 100 | 31 | 4 | 7 |
| FB2317 | 136 / 257 | 62 | 47 | 1 | 11 |
| FB2319 | 167 / 308 | 83 | 41 | 6 | 11 |
| FB2320 | 184 / 367 | 103 | 71 | 6 | 3 |
| FB2402 | 177 / 347 | 61 | 103 | 4 | 2 |
| FB2403 | 196 / 339 | 69 | 68 | 2 | 4 |
| FB2404 | 224 / 332 | 22 | 79 | 6 | 1 |
| FB2405 | 340 / 487 | 43 | 95 | 7 | 2 |
| FB2406 | 339 / 520 | 66 | 110 | 5 | 0 |
| FB2407 | 233 / 356 | 52 | 60 | 5 | 6 |
| FB2408 | 107 / 174 | 40 | 25 | 2 | 0 |
| FB2410 | 170 / 290 | 62 | 51 | 5 | 2 |

Every row still lacks at least one required contribution. FB2413 has 1,178
frames; the other recordings have 1,200. The existing exposure calculation
already uses these actual durations at the supplied 1 Hz sampling rate.

## Examples that determine the recommendation

**An old reference may also be contaminated.** FB2413 site 3/event 6 is withheld
because its episode head is 49 seconds earlier. On event 6's footprint, the
head's reference at 766–785 has **0/20 clean samples**, all contacting other
sinks. Simply extending the age limit cannot make it valid. Its original
immediate reference at 815–834 has 20 eligible samples and the preserved original
11.232914% drop. The current grouping links whole event footprints if they
intersect anywhere; it does not establish nonrecovery on the target footprint
throughout the gap. Review whether that local immediate reference represents
recovery, rather than automatically inheriting the head's invalid reference.
No original amplitude has been reinstated into burden by this review.

**Long series can have large level changes.** FB2317 site 13/event 5 uses a head
226 seconds earlier. Its head-reference window is fully clean and has mean
4,883.545. The target event minimum is 2,364.391; two clean adjacent windows after
the series have means 2,334.647 and 2,251.413. A single old level and a later
local level would imply very different deficits. These numbers do not tell us
whether the difference is substrate/instrument drift, persistent oxygen change,
incomplete recovery, or a mixture. Automatically fitting away the difference
could erase biology; carrying it all forward could attribute background change
to the event. The existing saved correction is diagnostic evidence, not an
independently validated counterfactual.

**A single contact can reject a full window.** FB2412 site 20/event 1 has 19/20
clean samples before frame 142. One frame contacts another sink, with no
same-site or surge contact. This motivates looking for a nearby complete
reference, not declaring the overlapping sample harmless. Its later clean
windows have means 574.876 and 573.675, but numerical agreement does not establish
that either is the right pre-event state.

**Recording-start reference remains an evidence problem.** FB2412 site 1/event 1
has no pre-event samples. The earlier preview's clean post-event windows 36–55
and 56–75 have means 864.041 and 879.537 and imply 7.403022% versus 9.034434%
under those assumptions. Those are retained historical sensitivity calculations,
not newly accepted amplitudes. A clean window is not necessarily recovered
tissue, and a recovery overshoot is not the same reference as resting tissue.
FB2412 site 3/event 1 illustrates a separate boundary problem: onset frame 5
provides four, rather than zero, available pre-event samples. Padding or calling
that a complete 20-second reference would conceal missing information.

**Negative detection signal does not prove a drop from a chosen reference.**
FB2319 site 7/event 2 has clean raw reference mean 1,055.031 and raw event minimum
1,195.292, giving the preserved −13.294471% drop-oriented amplitude. Its saved
corrected event signal is negative (minimum −49.070), but the corrected reference
mean is even lower (−99.516). Thus substituting the corrected signal would not
automatically establish a downward excursion from that reference either. A
detection below a processing threshold and a decline from a biological local
state are different facts. Do not declare these 99 events artifacts solely
from their sign; examine the reference, local trace and correction context.

The short recurrent FB2412 site 1/event 3 remains a useful successful case:
20 clean samples before the series give 6.012181%, with the existing isolated
event 4 unchanged at 7.465060%. Numerical availability of these controls does
not independently validate their biological baselines.

## Recommended reference workflow

The target is a **local comparable non-pocket state on the same fixed event
footprint**. A reference is not required to be the brightest state or global
normoxia. Its selection must not depend on obtaining a positive or large burden.

1. **Keep the current successful rule as the starting point.** Retain original
   and derived results and the full 20-second reference requirement. Test
   alternatives only where needed. Native-mask absence is necessary under the
   current screening rule, but not sufficient evidence of recovery. Inspect
   raw intensity and saved corrected context separately.
2. **Try the closest complete pre-episode reference within the permitted local
   horizon.** For contamination at the immediate window, propose testing the
   nearest earlier contiguous 20-second clean window, selected by temporal
   proximity, never maximum intensity. Count the total displacement from the
   target's usual reference, including both any window shift and episode-head
   shift; do not stack two independent 20-second allowances. This earlier-window
   search is a new rule requiring approval, and no availability gain is claimed
   here. Keep the original footprint; do not silently drop contaminated pixels.
3. **Resolve episode references using recovery evidence on the target
   footprint.** A new local reference may be appropriate after supported
   recovery even when coarse native grouping links the events, as FB2413
   illustrates. Conversely, an empty mask gap need not mean recovery. Preserve
   individual event IDs, areas and durations; reference grouping must not
   merge or split detected events. For references beyond 20 seconds retain
   the current hold until an explicitly approved rule supports an exception.
   Stable pre/post anchors and local trace context could justify retaining a
   common level for some longer series; a changing level needs evidence about
   the reference trajectory. Do not merely raise the cutoff for all 1,007.
4. **For recording-start events, allow a supported recovered reference only
   as a separately identified option.** Test the first suitable complete local
   post-recovery window and its neighboring window for stability/comparability,
   including native overlap, raw/corrected trajectory and possible overshoot.
   Define and validate recovery/noise criteria before automatic acceptance;
   there is no defensible universal tolerance established by this inspection.
   Do not pick the highest window. If supported, retain the observed event
   duration and mark onset as acquisition-censored; do not invent pre-recording
   time. If no comparable recovered state is identifiable, reference remains
   unavailable.
5. **Treat direction disagreement as a separate decision.** Check detector
   context, reference suitability and the saved recording-specific correction.
   Reuse existing reviewed optical-measurement services when evaluating a
   candidate; do not build another parallel GUI. The existing reviewed service
   can express corrected excursions relative to a positive raw reference,
   keeping corrected near-zero values out of the denominator. It is an
   exploratory amplitude definition, not a drop-in repair for automatic burden,
   and the example above shows why it is not guaranteed to resolve the sign.
   Any adoption changes amplitude meaning and must be evaluated on controls as
   well as failures. Explicitly adjudicated non-events may be excluded with
   reasons and a retained inventory; unresolved or inconvenient events cannot
   be excluded just to obtain a complete total.

For long/drifting series with no identifiable local recovered state, a
counterfactual reference would need validated temporal/background information.
Nearby tissue may help diagnose common changes, but cannot automatically be
assumed oxygen-stable or substituted as the pocket's raw baseline. A free fit,
high-percentile envelope, pooled baseline across animals, or invented zero is
not an evidential substitute. Some historical recordings may genuinely lack
the information needed. Future acquisition with recorded context before and
after the intended analysis interval can improve this without changing the
analysis exposure or adding mandatory batch CSV fields; it cannot guarantee
recovery will occur.

## Preserve the endpoint exactly

For the retained observed events:

`xi_i = positive_drop_percent_i * event_area_um2_i * event_duration_sec_i`

`Xi = sum(xi_i)` with strict missingness.

`Xi_normalized = Xi * (1e6 / recording_area_um2) * (60 / recording_duration_sec)`

Use the existing full recording area and acquired duration, not valid-event
count, valid-reference time or a cropped quiet interval. Units remain the
existing percent·µm²·s composite and its per-mm²-per-minute scaling. Do not
replace the product with trace integral, occupancy, peak-free area-time, or a
different normalization. No subset sum or event-count correction is proposed.

Release a complete numerical recording total only when every required retained
event has a supported finite amplitude, area and observed duration. Keep all
reasons visible otherwise. If a future approved model estimates all missing
references, its all-event total would need explicit model/assumption and
uncertainty labels; it must not be presented as a directly established value.
No such imputation is recommended for adoption from this review.

Completeness is relative to the retained detected events and acquired interval;
it does not mean complete pocket lifetimes or all physiological hypoxia.
3,863 saved events retain unresolved timing flags. A baseline fix cannot validate
their full physiological boundaries, tissue support, absolute oxygen state or
all missed detections. Keep those qualifications without changing their areas
or durations inside this reference task.

## Concrete proposed next milestone; not yet approved

Produce one **recovery-aware reference preview** using the existing saved-run
and reviewed-measurement services. No mandatory review of every event and no
extra required CSV inputs. Prioritize episode-level decisions and show only
exceptions requiring evidence. Keep the same eight fixed examples and a small
synthetic set covering genuine recovery, recurrence without recovery, drift,
overshoot, acquisition censoring, contamination and wrong direction.

Bound the work to four active hours, at most four five-minute MATLAB runs and
100 MiB evidence. Compare the candidate windows and their scientific assumptions
before changing automatic calculation. Determine whether the nearest-window
and recovery rules can be specified reproducibly without optimizing for burden,
whether long-series reference propagation has enough evidence, and which
boundary cases remain unidentifiable. Show event-level numerical consequences,
control preservation and uncertainty. Stop at a concrete method decision.

Only after that scientific choice should one fresh all-17 saved-run export be
approved, retaining strict totals and the existing formats. Do not run the
37-minute export again merely to discover that a permissive rule still leaves
unresolved events. The alternative is to defer this method work and keep the
present exports and missing totals. No complete values for all 17 are promised.

## Verification and stopping record

All 5,407 diagnostic identities/statuses match the verified export. Eligible
sample counts replay for every valid, wrong-direction and incomplete-reference
row. The additional examination decomposes the age/start holds without accepting
them. Independent Python checks the classification counts and actual exposure
durations. Eight examples use saved full-precision traces on their original
footprints. No contribution sum was calculated.

Three headless starts took 6.42, 6.81 and 29.36 seconds. The first two stopped
in the diagnostic collector (empty struct initialization, then an incorrect
assumption of equal recording length). The final extraction passes; failures
and recipes are retained. The technical allowance was expanded to three starts
without expanding scientific scope. All 60 protected saved masters, audits,
exports and scientific helpers retain their SHA-256 hashes in every attempt.
No MATLAB production code, original recording, earlier result or workbook was
changed. No release, package or Git transport occurred.

Evidence: `reference-validation/boi-complete-burden-review-20261016/` at workspace
root, especially `review-findings.json`, `reference-diagnostics.csv`,
`saved-examples.json` and native receipts. Review delivered; implementation
remains inactive.
