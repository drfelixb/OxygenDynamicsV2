# Pocket episode assembly: results and keep/change assessment

10 November 2026. POCKET-VIDEO-DETECTOR-10; owner root, no delegation.
Experimental implementation beside the existing detector. **Not adopted in
MATLAB, scientific measurements or exports.**

The frozen assembly prototype completed all twelve development recordings. It
can retain several minima within one episode and follow raw evidence beyond a
short seed window. The broader comparison also exposes its present limits:
some episodes absorb earlier activity, reference selection can give misleading
return evidence, and competing assignments remain numerous. Wider intervals
and fewer duplicate proposals do not establish better biological detection.

Open the [six cards and existing movies](../../reference-validation/boi-episode-assembly-20261110/review.html),
the [overview image](../../reference-validation/boi-episode-assembly-20261110/comparison-board.png)
or the [thirty-view diagnostic comparison](../../reference-validation/boi-episode-assembly-20261110/episode-comparison.csv).
These are detector-development outputs, not a scientific event or burden export.

## What was implemented

The new `prototypes/boi_episode_assembly` package consumes the saved primary
proposal catalogue and all its seed masks. Each proposal has a fixed consensus
core for its raw trajectory and a separate union support. It searches recorded
context beyond the seed's phase window, permits multiple minima and a flat
trough, checks raw return on fixed cohorts and continuing support blocks, and
retains regional comparisons as conditional evidence. A changing regional
signal is not promoted to a verified quiet reference.

The frozen diagnostic configuration uses twenty finite pre-state samples,
three consecutive deficit samples and ten consecutive return samples, with
recorded robust fluctuation allowances. These are experimental detection
settings, not oxygen thresholds, validated noise estimates or changes to the
scientific amplitude baseline. One-block spatial gaps can be flagged without
filling them as area. Dim or small support is not excluded solely by brightness.

Indexed assembly requires compatibility with every member of a proposed group;
an A–B–C association chain alone is insufficient. Each original proposal has
one primary disposition. Competing group assignments remain alternatives, not
multiple accepted scientific events. The original grouping decisions are
preserved alongside reporting consistency annotations.

The input scope is unchanged: twelve cached 128 × 128 raw fields, each block a
4 × 4 native-pixel mean, with 14,378 supplied 1 Hz samples. Existing 512 × 512
snapshots and movies provide context. No proposal generator, native segmentation,
original image decoding or movie encoder ran. The five reserved recordings
(FB2420, FB2316, FB2320, FB2404 and FB2406) had zero new image/trace-array reads.

The thirty views retain their different authority: four located positive
targets, one positive-presence window, three rejected targets, one
no-pocket-seen window, one contested-timing view and twenty unlabelled views.
No exhaustive labels, exact biological boundaries or accepted native areas are
invented. This comparison cannot estimate sensitivity, specificity or a
false-positive rate. The reserved recordings are excluded from this experiment;
they are not claimed to be historically unseen material.

## Accounting and interpretation

| Development-wide diagnostic | Records |
| --- | ---: |
| Original primary seeds accounted for | 320,824 |
| Original candidate records accounted for | 128,931 |
| Candidates with a primary episode membership | 95,791 |
| Resulting episode candidate records | 76,428 |
| Other disposition: regional context | 63 |
| Other disposition: unsupported | 9,179 |
| Other disposition: unresolved | 23,898 |

There are 19,363 original grouping links. Every candidate and seed remains
accounted for, with no accepted double counting. The resulting 76,428 records
are highly dependent experimental hypotheses, not a biological pocket count.
The assembler reassesses all saved proposals, including previously uncertain
or unsupported ones; these totals therefore cannot be compared as a detection
rate against the earlier local-cycle-only subset.

After the reporting consistency annotations, 829 records retain the diagnostic
complete-candidate label and 75,599 remain uncertain. The frozen classifier's
original labels were 2,261 complete and 74,167 uncertain. Neither version is a
validated pocket count. The annotation does not turn the remaining 829 into
scientifically validated events.

The reporting repair supplies the previously omitted decision-time alternative
episode IDs. An alternative records a competing assignment at that original
decision, not a certified final partition compatible with every later member.
The original timings, supports, memberships and classifier labels remain
byte-preserved. Display confidence is withheld when the same record reports
identity ambiguity or an unusable diagnostic reference. Original classifier
counts and corrected display counts are retained separately in the linked
per-recording and run-wide summaries.

## What the six cards establish

**FB2413 site 3/event 6:** the displayed association extends to 784–862,
including earlier activity. It gets beyond the former short deep-core window
but has not separated the later pocket from its preceding context. Its shown
cohort's diagnostic pre-state at 730–749 is not an accepted measurement
baseline for the discussed decline around 826–827. Frames 823–825 remain only
a timing cue; the scientific baseline stays unresolved. Full context and
branch identity are essential before interpreting the proposed return.

**FB2412 site 20/event 1:** the displayed association spans 105–171 on different
coarse pixels. Its shown diagnostic reference is 75–94. This does not reproduce
the reviewed original 2,511-pixel footprint, baseline 104–113 or timing 114–182.
A stable earlier low reference can let a recovering signal cross its band
before restoration to the immediate pre-decline level. That is a reference
suitability problem even when the return-band arithmetic is correct. The
reviewed baseline and recovery remain unchanged; responding patch 82 is still
regional comparison evidence, not a quiet reference.

**FB2407 site 12/event 7:** the displayed 508–659 association is longer than the
earlier deep-core proposal. Its long context and competing assignments still
prevent accepting that entire duration as one biological pocket.

**FB2410 site 66/event 2:** the displayed 671–707 association covers more of the
recognized dip. Recognition from the trace does not validate the proposed
coarse support or give a complete native area measurement.

**FB2402:** the researcher recognized local pockets in this window. The fixed
display selection illustrates one candidate and its alternatives; presence
somewhere in the movie does not validate that particular location, boundary or
all overlapping candidates.

**FB2419:** of the earlier 63 local proposals intersecting the no-pocket-seen
window, 61 become members of 55 episode candidate records and two are
unsupported. Only six of those proposal records consolidate into another
primary episode membership. The new full catalogue has 1,118 candidate
intervals intersecting frames 721–1080, including long/open intervals that
originate earlier. These are not 1,118 newly verified events or confirmed false
biological events. The large number of uncertain alternatives shows that
discrimination and consolidation remain inadequate.

The selected FB2419 candidate is a 761–790 raw dip in a small upper-edge
cohort: four support blocks, with three blocks in the plotted fixed core. It
differs from the central geometric probe shown above it. A plausible scalar
cycle at that small location does not establish tissue identity, exclude a
vascular/boundary explanation or override the researcher's window judgment.

**Previously rejected targets:** FB2317 site 13/event 5 has fourteen overlapping
episode associations, all uncertain; the previous detector had no local-cycle
promotion at that rejected marker. This is a regression risk from reassessing
the larger proposal pool, not evidence that the reviewed rejection was wrong.
FB2319 site 7/event 2 and FB2412 site 1/event 1 have zero marker associations.
Their wider clips still contain candidates; absence at a marker is not a
whole-clip specificity result. All three scientific review exclusions remain
preserved.

The cards show original native-ROI/probe traces separately from new fixed-cohort
traces. Cyan identifies the old ROI/probe, magenta the assembled diagnostic
support and yellow the plotted cohort. One displayed branch cannot summarize
every branch's return evidence. Near, far and field curves are centered only
for display; this centering is not burden normalization. Existing movies retain
their original windows and may be shorter than the extended cached trace
context. Two inherited movie compression limitations remain explicitly marked
in the thirty-view review; no new native-video validation is claimed.

## Engineering checks and remaining method limits

The eighteen predeclared constructed scenes passed on their second execution:
36 state-scene executions, after one pre-freeze repair. That repair corrected
the comparator grid for small constructed fields and exact one-block-gap
connectivity. Fixture realizations and expectations did not change. One
configuration and 27 source/contract files froze before development arrays.
All twelve recording state passes completed in twelve attempts.

Independent reporting checks replay reference arithmetic and reported return
evidence for twelve fixed saved-episode selections and eighteen constructed
examples. They check all thirty source-coordinate association lists, mask
votes for the selected saved branches, candidate/seed conservation, and every
episode's scientific-readiness flags. Agreement of this arithmetic does not
independently prove reference selection, optimal grouping or biological recovery.

The 145 scalar comparisons match exactly (maximum relative difference zero).
No reported return-confirmation arithmetic failure remains in those fixed
replays. Two selected reference-context warnings remain, in FB2317 and FB2407:
the immediate pre-decline level differs from the selected earlier pre-state by
more than its diagnostic allowance. This descriptive warning is not itself a
biological invalidity test and was not used to retune the model.

The initial independent check exposed omitted alternative IDs and complete
labels inconsistent with their own uncertainty/reference flags. The second
and final engineering repair is confined to output consistency: eighteen
generated grouping-only parity checks and twelve saved-output metadata replays
recover those links and annotate confidence. Every original grouping decision
field must match exactly; no raw state profile or proposal generator is rerun.
Original reports and repair sources remain preserved in the checkpoint.

The original classifier has 36,734 reported metadata-contract gaps: 35,139
episode records omit alternative IDs, 1,388 complete labels conflict with
identity ambiguity and 207 complete branch labels have an unusable reference.
The reporting annotation leaves zero delivery-contract gaps under the declared
checks, while preserving that original audit. It recovers 280,148 decision-time
alternative links, for 299,511 stored links including the original group links.
All twelve metadata replays match every original grouping decision field exactly.

Total conservative counters are 54/54 constructed executions (36 state-scene
executions plus eighteen grouping-only parity checks), twelve full recording
attempts, six reporting workers, four batches and both permitted repair cycles.
All 128,931 initial state assessments and 128,931 grouping-metadata replay
reservations count toward the 257,862 assessment ceiling; no additional state
fits occur during the metadata replay. Successful workers peak at about 848 MiB
RSS, below 2 GiB. No additional configuration or development-outcome tuning was
introduced.

Closeout preservation checks match all 2,640 protected inputs, 27 frozen
source/contract files, 339 prior immutable delivery files, sixty prior saved
pass artifacts, twelve cache/receipt pairs and twelve original recording byte
hashes and file stats. Historical definition-review pins are checked against
their preserved planning snapshots where the current status documents have
since advanced. All six final cards and the overview were visually inspected;
the HTML structure and 67 local links passed static checks. Live browser
interaction was not verified. Derived evidence was about 219 MiB at closeout,
below the approved 512 MiB. See the [preservation and delivery check](../../reference-validation/boi-episode-assembly-20261110/closeout-checks.json)
and [independent arithmetic/contract audit](../../reference-validation/boi-episode-assembly-20261110/independent-verification.json).

The frozen classifier itself still contains these output-contract weaknesses;
the diagnostic reader supplies an explicit annotation layer. A permanent
classifier/API correction and its scientific-impact review are required before
production use. The parity check is not proof of a unique biological partition.

There are also substantive unresolved requirements: onset can select an earlier
maximum, a stable but remote pre-state can be inappropriate for a later decline,
and recovered-band crossings do not establish a suitable scientific baseline.
The prototype supplies point proposals and ambiguity flags rather than
validated onset/recovery uncertainty brackets. Whole-group compatibility and
the constructed gap cases do not establish general native spatial continuity.
No footprint union is accepted as constant area, and no complete native area
trajectory is inferred from the coarse masks.

## Keep, change and stop

Keep fixed branch cohorts, multiple-minimum episode states, full available
context, original-proposal membership, regional comparisons and explicit
alternatives. They make the previous shortening problem inspectable.

Do not adopt the current episode identity, proposed onset/recovery or support
as measurement inputs. Before a further implementation milestone, review the
six cards to decide how to separate prior activity, distinguish a relevant
pre-decline state from an older stable level, and handle ambiguous neighbouring
origins. A new fixed timing threshold alone would not resolve those problems.
This is a proposed design discussion, not authorization for another campaign.

The burden formula, normalization, strict complete-contribution rule, individual
scientific references, originals, automatic/reviewed results, MATLAB workflow,
workbooks and export formats remain unchanged. FB2412 site 1's saved longer
interval and shorter unsaved preview remain separate. All new records remain
measurement-ready and burden-ready false. No partial sums, imputed zero areas,
new amplitudes, accepted durations, burden values or totals were produced.
