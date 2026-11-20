# Broader BOI workflow plan

30 October 2026. Planning only: no implementation is approved by this document.
The scientific inspection is stopped at Felix's request. The shorter FB2412
659–672 candidate remains a preview; the saved longer review and area draft are
preserved. Experimental area cutoffs are not adopted.

## Intended scientist workflow

**Load CSV → check setup → run ready rows → export together → postprocess.**

Review individual pockets when useful. Reviewing every recording, event,
reference or frame must not become a prerequisite for exporting the measurements
already available. An unresolved required contribution still withholds the
complete recording burden and all its normalized versions. Exporting other
measurements and the reason for missing burden remains possible.

The existing batch editor, queue, saved-run services, stats engine and export
formats are the starting point. Do not build another editor, analysis pipeline,
export format or review framework. Detector/correction/reference calculations
stay frozen at the approved checkpoint during workflow work.

## Already implemented

- CSV preparation with optional metadata, shared settings and row overrides.
- Explicit acquisition/calibration/support selection, row checks and holds.
- Sequential execution, persistent attempts/history and verified completion.
- Opening selected saved results without verifying unrelated rows.
- Collection of completed runs into the existing combined stats/export workflow.
- Separate source-bound reviewed decisions and event contributions, with
  original automatic evidence retained.
- Strict burden completeness and clear unavailable preview values.

These features need one coherent routine workflow and a clear postprocessing
handoff. Their presence does not establish biological validity of every event or
complete burden availability in the supplied dataset.

## Proposed first milestone: finish the routine batch-to-export workflow

Internal ID WORKFLOW-CLOSE-01; proposed owner root, without delegation.
User benefit: prepare one minimal batch and obtain understandable combined
outputs through the existing GUI, without command-line steps or mandatory
individual-event review.

1. Map the current controls to the intended sequence and list concrete gaps.
   Reuse working controls; avoid cosmetic restructuring without a demonstrated
   usability problem. Keep the shared support choice and the user's Run action
   explicit, while removing redundant review/confirmation steps where safe.
2. Keep only `Paths` mandatory in the CSV. Require necessary sampling rate,
   pixel size and support choice once in shared settings or explicit row
   overrides; do not make optional biological/descriptive labels mandatory.
   Preserve text identifiers, leading zeros, custom columns and optional
   stimulation metadata without inferring a protocol.
3. Distinguish Ready, Held, Running, Completed and Failed with a practical
   reason/action. Derive completion from saved receipts, not a manually editable
   analyzed flag. Show the output parent and completed run folder clearly.
4. Make combined export discoverable after completion and reuse the existing
   stats calculations, workbook sheets and CSV/MAT structures. Explain whether
   the export contains automatic results or explicitly selected saved reviewed
   decisions. Drafts and experimental previews never enter exports implicitly.
   If bringing the reviewed exporter into the GUI is a demonstrated missing
   connection, implement a small selection/summary step using that service.
5. Provide a concise postprocessing handoff identifying recording rows, event
   rows, reviewed exclusions, units, recording area/time denominators,
   normalization, reference source and missingness. Select primary measurements
   from the existing dictionary and publication; flag scientific interpretation
   questions rather than inventing replacement endpoints.
6. End with a short ordinary-user walkthrough from a minimal CSV to the combined
   result, showing where exported files are and how to reopen the batch later.

Acceptance is a complete finite user journey, not another recording campaign:
minimal CSV with blank optional fields; saved text/custom metadata roundtrip;
one valid row, one held row and one unresolved-measurement example; exact
selection of completed saved runs; distinct automatic/reviewed exports; no
preview/draft leakage; unavailable burden rather than partial/zero totals;
unchanged known complete products and normalizations; exported folder reopening.
Use existing synthetic fixtures and at most one named already-saved run for
integration, without rerunning detection or the 17 recordings.

Proposed budget: four active engineering hours, at most three bounded MATLAB
check starts, one ordinary desktop walkthrough, two repair passes and 100 MiB
new synthetic/test evidence. No new source-image reads or copying of full
recordings. If the existing saved example cannot support a check, report that
limit rather than expanding the dataset. Stop at a verified end-to-end workflow,
clear remaining limitations and researcher feedback. Exact implementation gaps
are fixed within this milestone; no new scientific method is included.

## Following milestone: reliability and reproducible handoff

Internal ID WORKFLOW-RELIABILITY-01; not approved. Exercise resume/reopen,
stop-after-current, failed rows, moved/unavailable storage, changed settings,
long paths and output collisions through existing services. Improve only
observed gaps. Prepare installation/source identity and current documentation
for a separately approved development distribution. Preserve old downloads;
package/release/licensing and broader platform claims remain separate decisions.
Propose its finite cases and budget after the first milestone, avoiding a broad
platform or infrastructure project.

## Separate scientific track: comparable hypoxic burden

Internal ID BURDEN-METHOD-PLAN-01; not approved. The formula and normalization
remain the target. Establish one explicit measurement contract for event
boundaries, individual-event references and time-varying area, grounded in the
original publication/script and approved changes. Keep detector-defined duration
separate from full trace recovery. Distinguish raw/local signal from correction
and background effects before adopting a change.

A method proposal needs prespecified representative examples and acceptance
criteria, including recurrent events, recording-start cases, clear negatives,
clear pockets and recovered context. Avoid selecting a cutoff to rescue one
pocket or obtain complete totals. Adoption requires numerical impact review and
explicit scientific agreement. A future all-recording export is a separate
request after the method is settled; never use partial sums or discard genuine
but difficult events simply to complete burden.

The last preserved reviewed 17-recording export has no complete recording
burdens. Workflow improvements alone do not fill those measurements, and this
plan does not promise that every recording can yield a valid complete burden.

## Decision and stopping point

Recommended next implementation is **finish the routine batch-to-export
workflow**. The other milestones remain proposals. Review this plan before
starting implementation; committing this document is a checkpoint and planning
action, not approval of any proposed scientific or product change.
