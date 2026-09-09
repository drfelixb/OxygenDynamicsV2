# Contact records in the existing surge analysis

The normal BOI master now exports the candidate connections and contact frames
previously available only in the branch-policy experiment. The tracking rule,
duration cutoff, site grouping, normalization, baseline selection and amplitude
formula are unchanged. The separate alternative detector is not incorporated.

A contact occurs when a candidate has more than one nonzero-overlapping
predecessor or successor in the adjacent frame. Both endpoints are annotated,
including candidates that fail the duration cutoff. This is evidence of possible
split/merge ambiguity; it does not establish biological ancestry, contamination,
or independent oxygen events. A tiny nonzero overlap can trigger contact.

## Normal recording outputs

The surge MAT file and `OxygenSurges_Output` contain:

| Output | Row means | Purpose |
|---|---|---|
| `SurgeCandidateRunQC.csv` | One contiguous candidate run, retained or rejected | Duration, qualification, event/site identity when retained, and detailed contact exposure. |
| `SurgeTrackingEdges.csv` | One nonzero overlap between adjacent-frame candidates | Both candidate IDs, frame numbers, areas and shared pixels, partner counts, primary/fallback eligibility, actual link decision and contact flag. |
| `SurgeContactFrames.csv` | One candidate run at one contact endpoint frame | Frame/time, whole-candidate area, incoming/outgoing contact counts, linked-contact count and qualification. |
| `SurgeGapReview.csv` | One possible continuation across an empty-frame gap | Existing geometric review only; no gap filling or automatic joining. |

Tracking edges include isolated overlaps as well as contacts and include
unchosen connections. Births and deaths with no overlap have no edge but their
runs remain in the candidate table. A chosen link can have the same candidate ID
at both ends; the distinct frame numbers identify the two observations.

Every table carries the recording's canonical path as `RecordingID`. Candidate
IDs are local to that recording. Both edge endpoints have `KeptAsEvent` and
event/site IDs; rejected endpoints have unavailable event/site IDs. All rejected
fragments remain outside the counted event and site tables.

When statistics assigns a user-supplied recording ID, use an event's
`StatsRecordingIndex` to locate `StatsInfo.Recordings(index).SurgesMatFile`, then
join its `CandidateRunID` to that recording's ledger. Do not join candidate IDs
across recordings or interpret a file-name match as an identity match.

## Fields on each retained surge event

The same fields appear on all candidate runs in the per-recording QC table.

| Field | Definition |
|---|---|
| `ContactFrameCount` / `ContactFrames` | Number/list of unique native frames that are endpoints of contact edges. Multiple edges at one frame do not duplicate that frame. Lists use semicolon-separated 1-based frame numbers. |
| `ContactDurationSec` | Contact-frame count divided by sample rate. This follows the pipeline's frame-count duration convention, not the time between first and last endpoints. |
| `ContactFrameFraction` | Contact-frame count divided by native run duration in frames. |
| `ContactFrameFootprintFraction` | Unique pixels in whole candidate masks at contact frames divided by unique pixels in the whole native event footprint. Repeated pixels count once. |
| `ContactEdgeCount` / `LinkedContactEdgeCount` | Distinct incident contact edges / those chosen by the tracker. A link within the same run counts once, although both endpoint frames are annotated. |
| `ContactNeighborCandidateRunIDs` | Distinct other candidate runs directly connected by a contact edge; excludes the event's own candidate ID. |
| `ContactWithRejectedCandidate` | At least one of those other runs fails the contiguous-duration cutoff. The rejected fragment does not become a counted event. |

The footprint fraction is **not the fraction of pixels known to be contaminated**.
For a nearly stationary region, even two contact frames can cover its entire
event footprint, making this fraction one while the duration fraction is small.
The frame table's area also describes the whole candidate mask. Shared-pixel
areas are available separately in the edge table.

The existing `AmbiguousTracking` flag must agree exactly with
`ContactFrameCount > 0`. These fields explain that flag without changing which
runs qualify. A retained run's duration is never combined with a rejected
neighbor's duration. No amplitude is replaced or removed because of contact.

## Statistics and units

`OxySurgeEvents` retains the detailed fields. `EventMeasurementQC` adds:

- `ContactTrackingEvents`: number of retained runs with contact frames.
- `ContactTrackingNotAssessedEvents`: retained runs lacking detailed assessment.
  Current surges are assessed; sink tracking is not assessed by this rule.
- `ContactWithRejectedCandidateEvents`: retained runs touching rejected fragments.
- `ContactEventFrames`: contact-frame counts summed over retained events.
- `ContactEventDurationSec`: contact durations summed over retained events.

The last two are **event-frames and event-seconds**, not unique affected recording
frames or elapsed recording time. For example, two events in contact during one
image frame contribute two event-frames. They also do not count contact episodes.
Shared edges can likewise be incident to two runs; do not sum per-event edge
counts as the recording's unique edge count. Use the edge table for that count.

Zero-event recordings have zero counts. Unassessed events are reported separately
from assessed events without contacts. Incomplete contact metadata is rejected.
The workbook's `MetricDefinitions` sheet includes these meanings and units.

## Contract and remaining work

The detector stays at `existing-v2-surge-shape-continuity-5`. Output measurement
and statistics contracts advance to `event-footprint-contact-ledger-7` and
`mouse-strict-contact-qc-8`. Reanalysis is required before pooling under these
contracts, even though this update changes annotation rather than the numerical
amplitude formula. Old saved outputs are not silently upgraded or treated as
contact-free.

Next test local separation of neighboring signals within the existing detector's
connected components, using these explicit contacts and controlled overlapping
injections. Preserve unresolved identity when separation is unsupported. Then
settle amplitude support and event-local surge onset/baseline together. The
[branch-policy comparison](SURGE_BRANCH_POLICY.md) and
[signal-stage audit](SURGE_SIGNAL_EVIDENCE.md) explain why relaxing overlap alone
does not resolve these issues.
