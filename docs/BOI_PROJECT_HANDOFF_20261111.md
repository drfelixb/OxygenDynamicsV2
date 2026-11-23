# Project handoff: return to calculations and a useful Excel export

> **Historical record, added to the repository on 23 November 2026.** This note was written on
> 11 November 2026 and is reproduced unchanged below. It predates the compact workbook delivered in
> 3.1.0-rc.1. Five links point to files that are not on `main`: four are preserved on the branch
> `archive/dev-checkout-20261123`, and the saved-output comparison under `reference-validation` was
> never published.

11 November 2026. This record supports continuing here or restarting elsewhere.
The researcher reaffirms the original detector as the foundation. The only new
execution approved on this date is the bounded saved-output comparison across
twelve development recordings. Further detector development is not authorized.

## The original goals and their actual delivery

The practical goal is **CSV → analysis → a compact, understandable export for
postprocessing**, with checked calculations and scientifically honest missing
values. Detector replacement must not become a prerequisite for that workflow.

| Goal | Delivered evidence | Remaining limitation |
| --- | --- | --- |
| Check duration, native area, occupancy and event rates | [Duration/area delivery](SOFTWARE_NEXT_02_DELIVERY.md): eight frozen small fixtures and saved ID400, nine final passing cases. Saved sink/surge events, frame unions and exports agree with independent arithmetic. No formula defect demonstrated in that scope. | This is a named-example calculation check, not certification of every result or every line of the originally supplied script. Native support and timing can remain biologically questionable. |
| Check integrals, composite burden, normalization and summaries | [Integral/composite delivery](SOFTWARE_NEXT_03_DELIVERY.md): six fixtures plus saved ID400/C02, eight final passing cases; signed integrals, normalization, strict completeness, mouse/group weighting, contributors and round trips checked. No numerical formula defect demonstrated. Exporter versus original calculator identity was clarified. | Unknown historical calculator versions and scientific reference suitability remain explicit. The intended formula being implemented correctly does not establish valid amplitude, duration or area for every event. |
| Run and export a batch | Batch editor, execution, saved-run inspection and [existing stats/export connection](BOI_BATCH_STATS_EXPORT_DELIVERY.md) delivered. The named 17-recording export matched individual saved tables/traces. Large MAT-variable omissions were repaired as serialization defects. | The detailed output is large; it is not a compact primary postprocessing workbook. These are historical delivered checks, not fresh executions in the current comparison. |
| Make Excel compact and useful | Readable event/window/amplitude/burden companions and navigation exist. The existing export formats and worksheet writer were preserved when batch export was connected. | **A compact main combined workbook has not been delivered.** The original combined workbook had 108 sheets; the later pre-episode export had 109. Compact companions do not fulfil this main-workbook goal. |
| Obtain scientifically usable complete normalized burden | [Pre-episode reference implementation](BOI_PRE_EPISODE_IMPLEMENTATION.md) and [fresh combined export](BOI_PRE_EPISODE_COMBINED_EXPORT.md) preserve the burden formula/normalization and original results. The historical export had 3,256 usable of 5,407 contributions and zero complete recording burdens out of seventeen. | Baseline/episode/area availability remains unresolved for retained events. Partial sums, imputed zero area and concealed omissions are not acceptable replacements. Those counts describe that saved export, not a new seventeen-recording evaluation. |
| Improve detector performance | Experimental trace/video/episode work and explicit uncertainty records exist; [latest detector results](BOI_VIDEO_LOCAL_REGIONAL_BASELINE_RESULTS.md) disclose remaining failures. | No demonstrated net biological advantage over the original. The prototype remains unadopted and is not a burden input. |

The [calculation guides](BOI_DURATION_AREA_AND_EVENT_RATES.md) and
[integral/summary guide](BOI_INTEGRALS_COMPOSITES_AND_SUMMARIES.md) state formulas,
units and denominators. Preserve their distinction between numerical agreement
and physiological validity. Retaining the original **detector** does not roll
back approved reference rules, reviewed exclusions or strict burden missingness.

## How the work drifted

Missing burden contributions led into baseline/recurrent-event review. Some
reviewed detections were not pockets, while others had incomplete timing.
That led to whole-event recognition, then trace-pattern and video prototypes,
followed by repeated timing, spatial and episode revisions. Each step addressed
a real issue, but the assistant failed to keep the calculation audit and compact
Excel deliverable central and to compare against the original detector early.
Approvals of individual experiments did not establish that this growing strand
was the best way to complete the original goals.

The [strategy audit](BOI_DETECTOR_STRATEGY_AUDIT.md) and
[saved-output comparison](../../reference-validation/boi-original-new-comparison-20261111/RESULTS.md)
separate those strands. All twelve development recordings have saved-output
associations. Four located positive examples were already original detections;
their incomplete timing must not be reported as evidence that the original
missed them entirely. Detector-independent biological reference review remains
incomplete; no whole-recording miss/false-positive rate is established.

## A focused restart

1. Keep the existing MATLAB detector and usable batch/stats/export workflow.
   Preserve experimental code/results as inactive evidence rather than deleting
   them or integrating them into production.
2. Reconcile the exact original source/version with a concise calculation
   checklist: already checked, not yet checked, demonstrated defect, and
   scientific definition unresolved. Reuse the saved independent checks;
   correct a numerical defect only with a reproducible before/after example.
3. Design a compact **companion workbook from existing result tables**, keeping
   the detailed legacy export. A proposed layout is `Recording summary`,
   `Events`, `Availability`, and `Definitions`. Keep sink/surge and automatic/
   reviewed identity explicit, with units, tissue/time denominators, complete
   normalized burden and clear unavailable reasons. Detailed traces, frame
   ledgers and grouped outputs can stay in the existing bundle.
4. Judge completion by whether the researcher can postprocess an ordinary
   batch without navigating more than a hundred sheets. New detection methods
   and resolution of every scientific baseline are not prerequisites for
   improving this presentation. Missing scientific values must stay missing.

These are proposed follow-on tasks, not an implementation started by this
handoff. No workbook was redesigned or scientific calculation changed during
the current comparison.

The five reserved recordings are **FB2420, FB2316, FB2320, FB2404, FB2406**.
They were excluded from the current comparison. Formula, normalization,
source-specific support, individual references, exclusions and originals remain
protected. No partial burden or zero-area substitution is permitted.

Current checkout: `existing-analysis`, branch
`development-existing-analysis-v3`, HEAD
`2acd9e8532f6786fa9d3ed545c88357450b2bde1`. This is not the complete source state:
pre-existing uncommitted work is preserved, with 108 files pinned before this
task. Comparison code/evidence is separate under
`reference-validation/boi-original-new-comparison-20261111`; neither that folder
nor a Git clone alone should be mistaken for a complete research-data package.
No commit, push, release, cleanup, worktree or project migration was performed.

For a fresh collaborator: read `AGENTS.md`, the current development plan/status,
this handoff and the two calculation delivery records first. Do not execute
historical "next steps" or resume the detector experiments automatically.


## Continuation decision — 11 November 2026

The researcher chooses to continue here. The current deliverables are the
[calculation coverage/error inventory](BOI_CALCULATION_COVERAGE.md) and
[compact export plan](BOI_COMPACT_EXPORT_PLAN.md). This supersedes the earlier
undecided restart direction. Implementation is not started; the accepted
original detector, burden formula, normalization and source results remain.
