# OxygenDynamics software development plan

## Mission

Maintain the MATLAB workflow for bioluminescence oxygen imaging (BOI). Researchers should be able to trace a reported sink or surge measurement to its source recording, event, reference, units and review status. [Researcher workflow and traceability](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md)

## Current software

On `main`, the Batch Editor prepares and resumes recording queues, opens saved results and exports automatic or reviewed measurements to workbooks. The compact workbook presents the saved values for postprocessing. [Batch Editor guide](BOI_BATCH_EDITOR.md)

The optional multichannel workflow analyzes two oxygen channels independently or measures fluorescence on an oxygen event’s footprint. Paired sink depth uses the same saved amplitude, reference frames and review flags as single-channel analysis. Surges use the strict pre-event reference. [Multichannel guide](BOI_MULTICHANNEL.md)

24 November 2026 (VERSION-01). The researcher approved 4.0.0 as the next release, with a candidate first. Saved calculations and exports record the development version, source commit and checkout state.

24 November 2026 (RELEASE-AUTO-01). The researcher approved a fixed candidate and final release procedure. The implementation owner is the root Codex chat. Acceptance covers the Mac gates and a verified GitHub dry-run artifact. Delivery stops at a pull request for review. [Release runbook](../RELEASING.md)

27 November 2026 (OFFSET-01, issue #25). Add optional per-recording and per-channel camera offsets to optical ratios for 4.0.0. Verify original-count detection, saved-definition replay and mixed exports on synthetic recordings. [Measurement guide](CAMERA_OFFSET.md)

## Open researcher decisions

- Choose the cutoff for linking candidate pockets between channels.
- Define the hypoxia-amyloid analysis as a separate task.
- Decide whether to design a new vascular analysis feature.
- Decide whether flagged sink references belong in between-channel comparisons.

24 November 2026 (CLEANUP-03). The two batch editors and pocket traces start from the project folder. Other commands are grouped by purpose and are available after `setupOxygenDynamicsPath`. Recording manifests cover the whole project.

24 November 2026 (CLEANUP-02). The researcher approved retirement of the original launcher, curation, iOS, vascular and legacy checking pathways. Use the BOI Batch Editor and its software checks.

There is no active development milestone. The researcher approved the development-record cleanup on 24 November 2026. The complete earlier plan and evidence are preserved in the [pre-cleanup-20261124 tag](https://github.com/drfelixb/OxygenDynamicsV2/tree/pre-cleanup-20261124).
