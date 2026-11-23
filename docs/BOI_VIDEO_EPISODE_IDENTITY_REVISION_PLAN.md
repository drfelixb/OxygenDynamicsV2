# Revise episode identity, local references and spatial evidence

11 November 2026. **Implemented and delivered as an unadopted experimental
quality checkpoint.** See the [results and remaining failures](BOI_VIDEO_EPISODE_IDENTITY_REVISION_RESULTS.md).
The proposed scope and approval history below are retained.
POCKET-VIDEO-DETECTOR-11; owner root, no delegation. This is one bounded
experimental revision beside the existing Python prototype. The previous
[episode-assembly experiment](BOI_VIDEO_EPISODE_ASSEMBLY_RESULTS.md) stays closed
and byte-preserved. No MATLAB integration or scientific-method adoption is
included.

## Outcome and reason

Represent the particular spatial depression that generated each proposal,
evaluate the state before its own decline, and distinguish local tissue
evidence from regional, vascular/boundary and unresolved explanations. Several
minima within one spatially coherent, unrecovered depression remain one pocket
episode. A recognizable episode can still have an unresolved scientific
baseline, onset, recovery or native area.

The saved review exposes three different failure mechanisms:

- **Episode substitution:** FB2413's displayed branch is anchored at 837, but
  its supported raw deficit is 793–800 with proposed return 801. The assembled
  784–862 interval therefore does not establish detection of the later pocket.
  The code can select the nearest qualifying depression when the anchor is
  outside every qualifying group. The selected FB2402 branch also has an
  anchor outside its proposed interval. Expanding context must not substitute
  a different event.
- **Reference mismatch:** FB2412's detection pre-state at 75–94 is at a lower
  level than the state immediately before the later decline. Return to that
  older band can be premature even with correct arithmetic. This is separate
  from its reviewed original-ROI baseline 104–113 and timing 114–182.
- **Insufficient spatial identity:** FB2419's selected 761–790 cycle occurs in
  a small upper-edge cohort. A dip-and-return mean trace does not distinguish
  a tissue pocket from vascular/boundary or displacement-like explanations.
  The full catalogue also retains many overlapping uncertain alternatives.

These are development observations, not newly saved biological judgments. The
aim is to repair these mechanisms across all twelve development recordings,
without optimizing only FB2413/FB2412 or forcing the FB2419 window to zero.

## 1. Keep a proposal attached to its own episode

Retain the original candidate ID, all contributing seed IDs, source masks,
seed times, scales and routes. Preserve the existing consensus core for a
same-pixel comparison with the preceding experiment; track any additional
spatial lobes as explicit child cohorts with their own pixel hashes.

Assess the whole available episode context without requiring one stereotyped
waveform or a monotonic decline/return. Flat troughs, unequal slopes and
regional changes remain possible.

Use the seed's observed spatial/time support as an identity constraint, rather
than requiring its anchor to be the exact trough. Follow the decline, low
period and return on those cohorts and their supported continuations. Context
can extend through the available recording; a narrow seed's span must not
truncate a slower edge. Every claimed association must have an observed
connection to the originating seed evidence. A nearby qualifying dip without
that connection cannot replace the target.

Raw and regional-comparison evidence must refer to the same episode. If an
absolute reference fails but a local contrast remains, retain an anchored
local-cycle candidate with its dependency recorded. If the connection itself
cannot be established, return unresolved identity. Never borrow another
cycle's onset, minimum or recovery to complete the record.

Assemble compatible proposals only after those identities have been checked.
Require whole-group temporal and spatial compatibility, retaining fixed branch
cohorts and recovery separators. Several minima alone do not create several
episodes; overlap, correlation or a bounding-box chain alone does not create
one episode. Record competing memberships directly in the numerical output,
with their IDs and reasons. Alternatives are not additional accepted counts.

Use at most **two deterministic boundary/reference refinement rounds** per
candidate pipeline invocation. Disagreement after round two produces explicit
brackets/alternatives or an unresolved result. No open-ended convergence loop,
parameter sweep or recording-specific adjustment is included.

## 2. Evaluate the state before this decline

Separate three outputs: the experimental episode interval, its diagnostic
pre-decline state, and any already accepted scientific measurement reference.
The new detector cannot accept or overwrite the third output.

Derive a provisional onset bracket from the anchored raw/local cycle and
spatial progression. Then examine exactly two local diagnostic windows:
**twenty and ten contiguous samples ending immediately before that bracket's
earliest supported onset edge**. If a second boundary round is necessary,
retain both rounds' windows and decisions. Missing samples remain missing.

For each window record the observed level, short-lag variation, two-half level
change, trend, prior-episode overlap and whether it lies in a continuing
decline or rebound. Check its consistency with the immediate pre-decline
context on the same pixels and with the conditional surrounding signals.
Do not search arbitrarily far backward for a stable lower level. Do not select
whichever window gives the largest depth or easiest recovery.

The twenty-sample window remains the starting diagnostic reference. The
ten-sample result is an explicitly flagged shorter-context alternative. If
only the shorter window is usable, any dependent return remains conditional;
this does not shorten the scientific baseline default. If neither represents
a supported pre-decline state, retain the episode candidate and withhold an
absolute reference. A stable segment by itself does not establish recovered
tissue. Distinct recurrent episodes receive separate reference assessments;
several minima within one unrecovered episode do not repeatedly reset it.

Keep the preceding experiment's starting numerical allowances: three supplied
1 Hz samples for continuation, a two-allowance diagnostic band/raw-rise check,
and ten consecutive observed samples for sustained return confirmation. Record
the start and confirmation-through frames separately. Evaluate return on all
continuing branch cohorts; missing pixels, mask disappearance or a brief
crossing cannot manufacture recovery. A shorter apparently cleared interval
retains split/merge uncertainty. Absolute raw return and local return relative
to responding surroundings remain separate states.

An onset/recovery bracket represents unresolved observed alternatives, not a
calibrated confidence interval. If its location depends on the diagnostic
reference choice, retain that dependency. Do not convert relative recovery
into an accepted scientific baseline or complete burden contribution.

## 3. Assess spatial evidence throughout the cycle

Use the existing 128 × 128 raw block movies, not only their mean traces. For
each anchored branch assess observed changes before the decline, through its
minima and during the proposed return. Record actual connected/continuing
support, overlap, expansion/contraction, branch-specific return, missingness,
extent in coarse blocks and fraction of the observed field. The latter is not
a validated tissue-area fraction.

Retain the current one-block gap allowance only with compatible observations
on both sides for three consecutive supplied samples. Do not fill the gap as
area. Test every continuing lobe before declaring spatial clearance. Spatial
bounding boxes and correlated regional drift are insufficient links.

Compare the target with the same fixed near, far and field comparisons. Show
their responses and disagreements; none is automatically a quiet control.
Any conditional regional loading/trend is estimated outside the provisional
episode, with no flexible interior fit that can absorb the slow decline or
return. Retain raw evidence beside all conditional comparisons. A local cycle
on a regional response can remain a candidate with unresolved absolute recovery.

Record coarse boundary gradients, proximity to observed field boundaries,
opposing neighbouring changes and existing displacement-like evidence as
possible confounders. These are observations, not new vessel segmentation,
motion correction or anatomical truth. Size or brightness alone must neither
prove nor exclude a pocket. Where the coarse field cannot distinguish tissue
from a vascular/boundary explanation, report **spatial identity unresolved**
and withhold complete confidence. Equally small, well-supported interior and
boundary cases must not be treated as equivalent solely because of their size.

Reuse existing native snapshots/movies for review. Add clearly labelled coarse
change/support maps from the cache at the assessed phases. If a reused native
snapshot is outside the revised interval, label it as orientation only. There
is no new native image decoding, vessel/tissue mask, segmentation or accepted
native pocket area in this milestone. If resolution is the limiting factor,
document that boundary instead of expanding the source scope.

## Fixed source and comparison scope

Development recordings remain **FB2311, FB2317, FB2319, FB2402, FB2403, FB2405,
FB2407, FB2408, FB2410, FB2412, FB2413 and FB2419**: twelve caches with 14,378
supplied 1 Hz samples, each a 128 × 128 field of 4 × 4 native-pixel means.
Account for all **128,931 primary candidate records and 320,824 seed records**.
Reuse existing proposal generation and retain the preceding raw-route-only
comparison unchanged. No new proposal search or ablation is included.

Keep **FB2420, FB2316, FB2320, FB2404 and FB2406 reserved**, with zero new
image/trace-array reads. Source metadata and existing preservation receipts
may be checked without decoding reserved signals. No KX/protocol work,
package installation, platform choice, MATLAB run, statistics or export run.

Retain all thirty benchmark views and their existing authority: four located
positives, one positive-presence window, three rejected targets, one
no-pocket-seen window, one contested-timing view and twenty unlabelled views.
Reviewed frames, original native ROIs and judgments are comparison evidence,
never detector inputs for selecting boundaries, references or spatial masks.
The existing seed masks are algorithmic proposal inputs, separately identified.

Existing researcher judgments are sufficient for this milestone. No new
comprehensive manual annotation or second-by-second boundary selection is a
prerequisite; uncertain boundaries stay explicit.

The six expanded cards remain the same examples. Freeze their displayed source
candidate IDs before new outcomes: FB2413 **J002459**, FB2412 **J001599**, FB2402
**J011922**, FB2407 **J006434**, FB2410 **J004342**, FB2419 **J000386**. These
are source-specific IDs, not shared biological site labels. Show an unresolved,
unsupported or missing target explicitly; do not substitute a more attractive
candidate. Show all associations in the thirty-view table independently of
these display choices. Compare old/new on identical cohorts where available;
otherwise label the support difference and avoid a same-ROI timing-error claim.

## Work items and acceptance

| Item; owner root | Bounded work and user benefit | Acceptance and stopping condition |
| --- | --- | --- |
| EID-01 | Pin sources, seed identity, review authority, output contract and counters. | All source identities/splits match; prior outputs and uncommitted work preserved. Stop at a source conflict. |
| EID-02 | Implement anchored identity and event-local diagnostic reference assessment. | No substitution of an unrelated depression; at most two rounds; both reference windows/reasons retained. Pass the fixed constructed checks before development arrays. |
| EID-03 | Integrate observed spatial continuation, regional/context evidence and source-level confidence/membership consistency. | No complete label conflicts with identity/reference/spatial uncertainty; all alternatives have IDs. Coarse support remains non-measurement evidence. |
| EID-04 | Run one frozen configuration over all twelve caches. | All original proposals/seeds accounted for, including unsupported/unresolved cases; thirty views compared without per-recording tuning. Stop at the finite run/resource limits. |
| EID-05 | Independently check arithmetic/provenance and present the six fixed comparisons. | Twelve recording-wide selections plus six displayed-source checks, twenty-four constructed arithmetic replays, all thirty source-coordinate lists, readable cards and a keep/change assessment. Report biological failures and stop before adoption. |

Reuse the eighteen prior deterministic scene realizations and their declared
physical expectations, then add six fixed cases before the first execution:

19. Two recovered depressions with a seed in the later one: no attachment to
    the earlier cycle or its reference/recovery.
20. A later seed with insufficient sustained evidence and a strong earlier
    qualifying dip: unresolved target, never substituted evidence.
21. An older stable low level, a higher pre-decline state and subsequent dip:
    return to the older low band cannot certify the later event's recovery.
22. Recurrent episodes with changed local levels; a twenty-sample window overlaps
    earlier activity while ten samples appear clean: keep individual references,
    flag short-context/recovery uncertainty, preserve scientific defaults.
23. A small boundary/displacement-like cycle and an equally small supported
    interior cycle: spatial evidence distinguishes confidence; no blanket size
    or brightness rejection, and no fabricated anatomical certainty.
24. Ambiguous group membership and contradictory completeness/reference facts:
    serialize every alternative and withhold inconsistent complete confidence
    in the source output, without a reporting-only concealment layer.

The inherited eighteen cases cover multiple minima, flat troughs, genuine
recovered recurrence, short-return ambiguity, distinct adjacent origins,
regional bridges, capillary gaps, distant correlated lobes, changing support,
missing pixels, local-on-regional change, broad field cycles, displacement,
dim valid signal, slow edges and recording-edge/relative recovery. Freeze one
realization and expected outcome per case; at most three executions each,
**72 constructed executions total**. Do not change expectations to hide failures.

Freeze numerical code, settings, identity rules, reference mapping, confidence
contract and all selection rules before development arrays. Keep the preceding
numerical modules byte-preserved; add the isolated experimental module
`prototypes/boi_episode_identity`, using existing readers/arithmetic where
suitable. All new outputs remain
measurement-ready and burden-ready false.

Audit identity/membership/readiness invariants over every candidate. Independently
replay the same twelve source candidate IDs selected by the preceding audit,
one per development recording, plus the six fixed displayed sources above.
Their identities are frozen in the [proposal record](../../reference-validation/boi-episode-identity-proposal-20261111/proposal.json)
before implementation or new outcomes. An unresolved/missing result gets an
explicit accounting/reference-unavailable replay, not a replacement case.
These are at most eighteen saved checks, not new detector fits. Replay all
twenty-four constructed outputs without new state fitting. Check every one of
the thirty source-coordinate/association lists and all input/output counts.

The real-data report must distinguish supported target association, unresolved
identity, reference dependency, spatial ambiguity and biological recognition.
For FB2413 explicitly check the later anchor's connection; for FB2412 show
reference choice separately from the preserved reviewed interval. For FB2407
retain multiple-minimum alternatives; for FB2410 separate local return from
regional decline. For FB2419 map all prior 63 proposals and subsequent episode
alternatives, including the fixed upper-edge source. Recheck the three rejected
markers; never reverse their saved scientific review exclusions.

No exact human frame matching, forced zero in a weak negative window, reduced
candidate count or all-uncertain output constitutes biological success. An
unresolved result is preferable to substituted evidence, but must not be
reported as successful pocket detection. No sensitivity/specificity or
false-positive-rate claim from these incomplete, dependent development labels.

## Finite budget and stop rules

Propose **eight active engineering hours, four batches, one frozen configuration,
two engineering repair cycles including reporting, 2 GiB worker RSS and 512 MiB
new derived evidence**. Batches are source/contracts; constructed implementation
and freeze; frozen twelve-recording application; independent checks/presentation.
One process per numerical worker; include child memory if any is introduced.
Stream one recording at a time and use sparse temporal/spatial associations.

Allow twelve planned full-recording passes and **eighteen attempts maximum**,
six reporting-worker attempts, twenty-four constructed scenes/72 executions,
six expanded cards and one overview. Maximum candidate pipeline invocations,
including retries and conservatively charged numerical/group reconstruction
replays: **257,862**. At most two identity/reference refinement rounds per
invocation: **515,724 round assessments maximum**. The two 20/10 windows and
fixed surrounding comparisons are declared within each round, not additional
configurations or an uncounted parameter search. Keep both counters explicit.
Cap stored primary and alternative association edges at **2,000,000**.

Zero new proposal-generator runs, original TIFF decodes, native segmentations,
movie encodes, reserved-array reads and scientific statistics/exports. Existing
cache arrays and prepared media are referenced in place. Do not store dense
candidate-by-frame-by-pixel graphs or silently drop alternatives at a limit.

Ordinary engineering decisions stay within the approved work items. After
freeze, memory/IO repairs must establish numerical parity; development outcomes
cannot trigger a method/threshold revision. Every retry, repair and partial
attempt consumes the same counters. Stop at any source, time, attempt, graph,
memory, storage or repair boundary with completed outputs, failure reasons and
unprocessed IDs preserved. Do not reset or reopen the previous experiment.

## Protected science, deliverables and approval

Preserve the burden formula, normalization, strict complete-contribution rule,
source-specific tissue support, original recordings, automatic/reviewed results,
individual scientific references, sink/surge separation, workbooks and export
formats. No accepted amplitudes, areas, durations, burdens or totals are
recalculated. No partial sums, imputed zero area or scientific default change.
Existing pre-episode reference-age limits and recording-start holds remain
unchanged in the scientific workflow.
FB2412 site 20 retains 104–113 and 114–182; FB2413 retains timing cue 823–825
and unresolved measurement baseline; FB2412 site 1's saved longer interval and
shorter unsaved preview remain distinct. No scientific review revision is saved.

Deliver a versioned experimental episode/member/reference/spatial-evidence
ledger, full thirty-view comparison, six fixed-source cards with reused movies
and coarse phase maps, independent verification, preservation receipts and a
keep/change assessment. Report what remains limited by coarse resolution or
reference suitability. No production adoption, Git transport or publication.

The alternative is to retain the current cards and defer another implementation.
This request authorizes planning only. [AGENTS.md](../AGENTS.md) states:
**“Before implementation, obtain approval for the milestone and its bounded
work items.”** Approval of this concrete plan is required before EID-01 through
EID-05 start; no implementation is active.

## Approval and execution record

The researcher explicitly approves on 11 November 2026: “I approve the bounded
revision plan. Go ahead with implementation across the 12 development
recordings, keeping the five reserved recordings untouched and preserving the
burden formula, normalization and original results.” The opening proposed text
is retained as scope history; the exact approved version is pinned in the
implementation evidence. Root works without delegation.

All twenty-four constructed cases pass on execution three (72 executions).
The two pre-freeze repair cycles, initial failures and sources are preserved;
fixture realizations and expectations remain unchanged. Repairs correct
provisional crest/reference and onset arithmetic, context extension for a
continuing flat depression, and conditional versus absolute endpoint semantics.
One configuration and 41 source/contract files freeze before development arrays.
The same twelve full-recording passes start, without recording-outcome tuning.
Evidence: `reference-validation/boi-episode-identity-20261111`.

## Completion record

All twelve frozen recording passes completed in twelve attempts. All 128,931
candidate records and 320,824 seeds are accounted for, with thirty comparison
views and the same six source candidates. Three reporting workers completed
on their first attempts. The 24 constructed cases pass after the two recorded
pre-freeze repairs (72 executions); no expectation or fixture changed.

Independent verification covers eighteen saved sources, twenty-four constructed
arithmetic replays and all thirty source-coordinate/association lists: 4,588
scalar comparisons have maximum relative difference 9.24e-14, with zero reported
arithmetic, narrow anchor-membership or source-confidence contract failures.
Source serialization contains explicit alternatives and conditional-reference
holds. These checks do not validate the intended biological episode identity,
reference suitability or native area.

The scientific detection requirements remain unmet: FB2413's fixed source
expands to 481–940, FB2412's fixed source is unresolved, FB2407 shortens to
611–651 and FB2410's fixed source becomes regional context. FB2419 remains
uncertain and the rejected FB2317 marker has more uncertain associations.
The results report retains these failures. The FB2402 current trace omits
its earlier source anchor; its unchanged previous same-cohort card is linked
as supplementary context, with no substitution or new rendering.

Counters finish at four batches, 72 constructed executions, two repairs,
twelve recording attempts, three report workers, 128,949 conservatively charged
candidate invocations, 257,862 reserved identity/reference round assessments
and 143,407 stored links. Successful RSS peaks near 1,002 MiB; evidence is about
225 MiB. All preservation checks pass, including twelve original byte hashes
and file stats. No reserved-array read, original TIFF decode, native segmentation,
new movie, proposal-generator run, scientific save/export or production adoption.

The bounded implementation/evaluation workflow is complete and stopped at its
documented quality checkpoint. Formula, normalization, strict complete burden,
references, originals and prior results remain unchanged. No next campaign or
scientific adoption is active.
