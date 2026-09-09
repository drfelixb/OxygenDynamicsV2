# Existing BOI surge tracking: size, shape continuity and recurring sites

This change replaces the BOI surge tracker's fixed initial seed and absolute
390-pixel overlap rule. It remains the existing normalized-image detector;
the separately developed alternative detector is not incorporated here.

The later [split/merge policy comparison](SURGE_BRANCH_POLICY.md) is test-only.
It demonstrates that even primary overlap links can mix source identities at
contacts. The production rules below remain active; detailed contact-edge export
is proposed as the next correction.

## Rules and their order

1. **Candidate formation:** retain the existing spatial-then-temporal SD
   normalization, smoothing, brightest-10% frame threshold, recording-area
   filter and circularity rule. Surge regions have no maximum area.
2. **Physical minimum area:** use 9,025 µm², converted to pixels with
   `ceil(9025 / PixelSize^2)`. This is the old 400-pixel cutoff at 4.75 µm/pixel:
   a development reference, not a demonstrated biological minimum. At 2.35,
   4.75 and 6.75 µm/pixel the cutoffs are 1,635, 400 and 199 pixels respectively.
   Rasterization introduces less than one pixel's area of rounding.
3. **Within-event tracking:** link regions only between adjacent frames when
   `intersection / max(previous area, current area) >= 0.6`. This requires at
   least 60% coverage of each region by the other, so a tiny region contained
   in a large one does not automatically become its continuation. Follow the
   most recent region, allowing cumulative motion away from the original seed.
   Candidates have at most one predecessor and one successor. Eligible links
   use decreasing coverage, with canonical pixel order for deterministic ties.
   If this primary test fails, an **isolated shape-change** link is permitted
   only when intersection / smaller area is at least 0.8, larger / smaller area
   is at most 2, and each endpoint has exactly one nonzero-overlapping candidate
   partner. This handles bounded expansion/contraction. Even a small contact
   with a second admitted candidate blocks the fallback. These development
   limits were specified before the current reference rerun.
4. **Duration:** keep contiguous native runs of at least 10 seconds, using
   `ceil(10 * fs)` frames. No missing frame is filled, and separate short runs
   cannot accumulate enough duration to pass. All tracked candidates, including
   terminal fragments too short to qualify, remain in a separate QC ledger.
5. **Recurring sites:** after duration filtering, compare each retained event's
   union footprint with the first retained event footprint of an existing site.
   The same mutual-overlap threshold, 0.6, applies. That anchor never expands
   through successive matches. Require at least one empty frame between events
   assigned to a site, so grouping cannot join adjacent runs or change event count.
   The best eligible site is used; equal scores use the earliest site ID.

Tracking and site grouping have separate settings: `surgeTrackingOverlapFraction`,
`surgeTrackingContainmentFraction`, `surgeTrackingMaxAreaRatio` and
`surgeSiteOverlapFraction`. They were not tuned to maximize the challenge scores.
At the default >50% mutual coverage, disjoint candidates cannot have two eligible
links to the same region; deterministic conflict resolution also supports the
lower thresholds used in sensitivity checks.

## What the output means

`SurgeID` identifies a recurring spatial site within a recording. `EventID`
identifies one duration-qualified native run at that site. A moving event can
occupy a broad footprint. Repeated events with sufficiently different footprints
can receive different site IDs; the site rule is a reproducible spatial grouping,
not proof of an anatomical or physiological unit.

The final event table adds:

- `TrackingMethod = adjacent_mutual_or_isolated_containment`,
  `TrackingOverlapFraction`, `TrackingContainmentFraction` and `TrackingMaxAreaRatio`.
- `ShapeChangeLinkCount` and `ShapeChangeLinkFrames`: fallback links and their
  right-hand frame numbers. `MinimumMatchedMutualCoverage` and
  `MaximumMatchedAreaRatio` describe the observed adjacent links.
- `CandidateRunID`: joins a retained event to the complete candidate-run ledger.
- `PotentialGapContinuation`: an endpoint overlaps another candidate run across
  one or more empty frames up to `surgeGapReviewMaxSec` (default two seconds).
  The endpoint mutual-coverage threshold is the tracking threshold (0.6).
  This can involve rejected short runs or different final sites.
- `SiteAssignmentMethod = first_retained_event_footprint_overlap` and
  `SiteOverlapFraction`.
- `AmbiguousTracking`: a run participated in a possible split/merge contact,
  defined by any nonzero overlap with multiple predecessor/successor candidates.
  This includes overlap below the tracking cutoff and candidates subsequently
  rejected by duration. The flag does not claim a true biological split/merge.
- `SiteAssignmentAmbiguous`: more than one fixed site anchor was eligible at
  assignment. An unflagged assignment is not proof of biological identity.

These flags are descriptive; they do not remove events or their otherwise usable
amplitudes. `EventMeasurementQC` reports ambiguous counts and missing-assessment
counts separately, by recording and sign. Current surge outputs are assessed;
sink tracking/site assignment, shape linking and gap review are not assessed
by these surge rules. Zero-event
recordings have zero event counts and unavailable measurement fractions.

## Candidate runs are not pooled events

Every recording saves `SurgeCandidateRunQC` and `SurgeGapReview` in its surge MAT,
with matching CSV files in `OxygenSurges_Output`. The first has one row per
contiguous candidate run before duration filtering: recording/local candidate ID,
native bounds, duration, keep/reject reason, tracking flags and shape-link frames.
Only retained runs have `SurgeID` and `EventID`; rejected rows contain NaN for
those IDs and never enter pooled event counts. The second table identifies
possible short-gap pairs by local candidate IDs, empty-frame gap and endpoint
coverage. Both IDs require the source recording identity when comparing recordings.
Within a saved recording, the event and candidate tables share `RecordingID`.
Pooled statistics can assign a custom `RecordingID` from the metadata CSV.
To trace a pooled event back, use its `StatsRecordingIndex` to select
`StatsInfo.Recordings(index).SurgesMatFile`, then join that source ledger by
`CandidateRunID`. Do not assume a custom pooled ID equals the original path ID.

A six-second fragment, one blank second and another six-second fragment remain
**two rejected candidates and zero retained events**. Two ten-second runs with
the same gap remain two retained events, potentially grouped at one site.
The masks alone cannot determine whether the gap is a missed observation or a
real return between events. The QC flag records that uncertainty without
filling masks, adding duration, merging runs or excluding usable amplitudes.
This two-second candidate review is distinct from `CloseNativeRun`, which uses
retained runs at the same final site and the separate 20-second review threshold.

`EventMeasurementQC` adds retained-event counts for shape links and possible
short-gap continuation, with separate missing-assessment counts. Complete
rejected-run ledgers remain per recording; they are not pooled into event or
mouse summary tables. Candidate pixel masks are not saved in the ledger; exact
reconstruction of rejected geometry requires rerunning the recorded input and
contract. Saved native masks still cover retained events.

## Dependencies and limitations

Surge timing still uses native threshold bounds. This update does not establish
physiological onset/return, resolve one-frame detection dropouts, reconstruct
split/merge lineages, or distinguish events from noise with biological labels.
Abrupt changes beyond the bounded fallback, overlapping neighbors, or missing
candidate frames can still split runs and cause pieces shorter than ten seconds
to be rejected. A linked shape change is algorithmic continuity, not proof of a
single physiological event. Broad
regions can tolerate a greater absolute translation than small regions. A
region with no overlap in consecutive sampled frames cannot be linked by this
rule; motion tolerance therefore depends on frame rate as well as region size.

Changing the tracking rule and physical area cutoff changes the admitted surge
population and spatial sites. It is not meaningful to interpret higher counts
alone as improved sensitivity. Smaller regions previously admitted in finer
pixel recordings are now excluded by the consistent physical area cutoff.
Normalization, smoothing and sink area/border rules still contain pixel-scale
or context dependencies. This update does not make the entire detector physically
scale invariant.

Primary amplitudes remain signed fractional changes in preserved-input intensity
averaged over each event's **fixed union footprint**. A moving local increase is
averaged with pixels not simultaneously involved, which can reduce the measured
peak relative to the local injected fraction. Delayed native onset can also
contaminate a pre-event baseline with an undetected smooth rise. Arithmetic
agreement does not establish physiological amplitude accuracy or calibrated
oxygen concentration. New surge masks can change sink amplitude availability
through the existing both-sign baseline exclusion, even with unchanged sink
masks and timing.

Surge-specific recording/window baseline contrasts and equally weighted mouse
summaries remain separate unfinished work. Per-event baseline measurements are
not experimental-baseline contrasts.

## Validation design

The physical candidate-mask sweep spans three pixel calibrations (2.35, 4.75,
6.75 µm/pixel), three sampling rates (0.5, 1, 2 Hz), four radii (45, 60, 85.5,
120 µm), five speeds (0, 4.75, 9.5, 19, 38 µm/s), and four tracking thresholds
(0.5, 0.6, 0.7, 0.8): 720 combinations. The prescribed region lasts 12 seconds.
The former pixel-area/fixed-seed rule provides a comparison, not ground truth.

Full-movie challenges use ID400 awake, ID401 awake, FB2312 awake and the separate
FB2411 fluorescence control. Each source has five cases: unmodified control,
smooth pairs, one clean smooth pulse, its noisy counterpart, and a moving clean
pulse. The first three sources' four static cases reproduce the prior recipes.
Both signs occupy separate 85.5-µm-radius circles, with approximately 20% peak
intensity changes. Moving patches travel 4.75 µm/s during frames 101–160, with
centres rounded to pixels. This is one prescribed drift, not a general motion
model. Independent pixel verification uses the saved fraction and position
ledgers; it does not independently regenerate MATLAB's noise RNG sequence.

Controls are evaluated in the same six pair windows and both stationary and
moving singleton supports. Scores use complete space-time supports and also
report the fraction within each detector's eligible tissue area. A nonzero
intersection is not a success cutoff. All resulting events, including background
runs, receive independent baseline/amplitude recalculation. Saved masks are
checked for adjacent coverage, physical area, fixed site anchor coverage,
duration and unique per-frame pixel ownership. Earlier identical-input sink
masks/timing are compared separately from amplitude availability.

The preceding mutual-coverage-only results are retained as a [historical report](reference-results/surge-physical-adjacent-20260909/README.md).
The shape-continuity rerun and controlled gap/size checks are documented in the
[current report](reference-results/surge-shape-continuity-20260909/README.md).

The same-contract [full-movie growth/shrinkage and signal-stage audit](SURGE_SIGNAL_EVIDENCE.md)
now localizes a missed ID401 pulse to a competing split and documents spatial
averaging and undetected-tail contributions to baseline measurements. It adds
validation tools without changing these production rules.

## Versioning

Reanalysis is required. The current contract is:

- Detector: `existing-v2-surge-shape-continuity-5`
- Measurement: `event-footprint-candidate-ledger-6`
- Statistics: `mouse-strict-shape-gap-qc-7`
- Schema: `3.0-dev`; normalization remains `spatial-sd_then_temporal-sd`.

The separate iOS path retains the previous fixed-seed tracker under an explicitly
iOS-specific helper name. Earlier reference results retain their original
contracts and must not be pooled as current outputs.

## Historical stage diagnosis that motivated shape continuity

Under the preceding mutual-coverage-only contract, reconstructing ID400 and ID401 smooth pairs and ID400 moving input reproduces the
saved final surge masks exactly. These traces reuse production preprocessing;
they locate losses rather than independently validate the detector.

ID400 missed pair windows 3, 4 and 5 have 12, 13 and 10 frames with accepted
candidate pixels, but their longest intersecting adjacent tracks span only 6,
6 and 8 frames. All are removed by the ten-second minimum. ID401 missed windows
1, 4 and 6 have longest intersecting tracks of 6, 3 and 7 frames. Window 1 has
accepted pixels in 14 consecutive frames, so changing region geometry/assignment
also contributes to fragmentation, even without an all-candidate dropout.

For the ID400 moving singleton, percentile selection intersects all 60 imposed
frames; geometry/tissue filtering leaves intersections in 50. Tracking produces
18 intersecting pieces, of which only one ten-frame run survives. Post-detection
amplitude or timing refinement cannot recover an event discarded at this stage.
The current change tests bounded shape continuity and explicitly reports short-gap candidates. It does not infer missing observations. Simply reducing the minimum duration or increasing count is not sufficient evidence of improvement.
