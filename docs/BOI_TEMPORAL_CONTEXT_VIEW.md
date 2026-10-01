# Optional BOI temporal context view

R5-CONTEXT-VIEW-087, 15 September 2026. This optional, read-only view exposes the
completed fixed-interval context diagnostic. It is not a recognition classifier,
a boundary finder, a baseline policy or a new optical measurement.

## Open and use

From the `existing-analysis` folder in MATLAB, run:

```matlab
setupOxygenDynamicsPath;
openBOIEventReview;
```

Choose the saved `event-amplitude-audit.mat`. Reopen the viewer to load the updated
code; an already open window retains its earlier implementation. Select an event,
open **Optional context**, then press **Show context**. Context is only calculated
when requested. Selecting another event clears the prior display and export state.

Load the saved boundary revision through the existing researcher-boundary controls.
Use **Load accepted references** for saved reference-judgment JSON files, and
**Attach both native sources** for the matching sink and surge master files.
Attachments are optional: missing native support means unknown, never clean or zero;
unloaded judgments do not mean that no researcher reference exists.

Select the automatic interval or a current saved researcher alternative, then
10 or 20 samples per side. Draft edits are excluded. Current preferred choices
and uncertainty are retained; previous revisions appear as history in the text
below the table, not as current selectable boundaries.

## Read the display

- The unsmoothed saved corrected-intensity trace is the primary signal. The original
  recording-specific correction is unchanged. Continue using the main review
  trace panels for the supporting detection score and correction QA.
- Pale blue/green bands show before/after min–max range; darker bands show median
  plus/minus unscaled MAD; solid lines show each side's median.
- Red dashed lines mark the saved automatic interval. Purple dotted lines mark
  the selected saved researcher interval, when present.
- Black bottom ticks show native contact; purple ticks show current saved human
  interval/contact evidence, including approximate contextual observations.
  These are descriptive flags and do not exclude frames or certify quietness.
- Orange ticks show exact loaded accepted-reference frames independently of the
  diagnostic windows. The text identifies the associated onset and frames.

The table retains signed rise and decline contrasts, side availability, medians,
range, MAD and endpoint relationships. Values describe the selected interval and
its footprint. They are not calibrated oxygen changes or recognition probabilities.
For interval `a:b`, the windows are `a-W:a-1` and `b+1:b+W`, where `W` is 10 or 20.
Each side requires every sample to be present and finite; incomplete windows remain
unavailable. The view is limited to the external 1 Hz clock: frame 1 is modeled
0 seconds. Exposure remains a separate quantity.

For the reviewed 177–195 pocket, accepted frames 165–176 remain separate from
both diagnostic windows. The 20-sample preceding window is 157–176 and contacts
the approximate preceding pocket. The view never replaces the accepted reference
with that window or calculates a new optical baseline. The native event label
may differ from the researcher's biological description; both are retained.

## Legacy saved audits

For a saved audit lacking `AnalysisInfo.FrameSize`, use the dedicated context
launcher with its matching saved masters:

```matlab
openBOITemporalContext(auditPath, sinkMasterPath, surgeMasterPath);
```

These variables must contain the actual paths to that recording's files. Supplying
only the matching sink master permits explicit geometry loading with native contact
remaining unavailable until both masters are attached. Dimensions come from its
saved native table, not an assumed 512-by-512 grid. Geometry source path, hash and
original metadata status are retained. The original AnalysisInfo is unchanged.
This dedicated compatibility path does not add legacy compatibility to every
panel in the main event-review viewer.

## Export and traceability

**Export context evidence** creates a new folder containing exact corrected samples,
fixed-footprint pixel IDs, all interval/scale descriptors and frame sets, native
contributors, current/history roles, accepted-reference documents, source and
implementation hashes, geometry evidence and an artifact checksum inventory.
`DisplaySelection` records the selected view; it does not adopt an outcome.
Existing export folders are never overwritten. Changed audit, boundary, reference,
native or geometry files require reloading before further display/export.

The source movie is not reread. Detection, correction, scientific rules, saved
annotations and measurements remain unchanged. This feature contributes to R5
usability; it does not complete independent researcher validation or establish
physiological event timing.

See the [whole-project overview](BOI_PROJECT_OVERVIEW.md),
[context comparison](BOI_PANEL_TEMPORAL_COMPARISON.md), and
[evidence packet](reference-results/boi-context-view-20260915/README.md).
