# Pre-episode reference and burden exports

Local 3.1.0-dev.9; derived measurement `boi-pre-episode-1`.
Approved by Felix on 16 October 2026, including withholding a reference shifted
more than 20 seconds from the event's usual baseline.

## What changes

Closely recurring pockets can lack a full clean immediate baseline because it
contains the preceding dip. Consecutive native sink runs at the same saved site
with an empty gap strictly below 20 seconds and intersecting event footprints
share the period before the first event. Each event's own fixed footprint is
sampled over that period: the intensity value is never copied between footprints.
The existing full baseline duration is retained (normally 20 seconds), with
finite samples, a positive mean and no overlapping native detections of either
sign. No earlier-window search, shortened reference or trend fit is introduced.

The reference-period shift is `(event measurement start - first episode event
measurement start)/SampleF`. Exactly 20 seconds is allowed; a larger shift is
withheld for review. The reference is never automatically reset within a linked
series after it becomes too old. A separate series starts when the native link
rule is no longer met. This numerical grouping does not establish physiological
recovery. The reference remains a relative optical measurement.

An episode beginning at acquisition frame 1, or with its first measurement start
at frame 1, stays `recording_start_recovery_unclear`. No post-event window is
selected automatically. Areas, individual event identities, native masks,
measurement intervals and observed durations remain unchanged.

## Existing batch workflow

Use the batch editor's existing review/export controls to create a fresh stats
output folder from completed saved runs. Saved original amplitudes stay in their
original columns. New stats derive the additional reference from the saved
event audit only when its receipt binds the exact sink and surge masters and
source fingerprint. All sites and both native signs are considered before
curation. Source movies and detectors are not rerun for this derivation.

For older saved runs lacking a receipt-bound audit, derived amplitude is
unavailable with `saved_evidence_unavailable`; original amplitudes remain visible.
Do not invent a reference or silently substitute an old amplitude for a withheld
derived measurement. Future master runs save both measurements directly.
Historical output folders and workbooks are never migrated or overwritten.

No extra mandatory CSV fields and no manual review of every event are added.
The batch export operation still needs its normal selected recordings/destination
review. This implementation did not re-export all 17 recordings automatically.

## Sheets for postprocessing

| Sheet | Use |
| --- | --- |
| `HypoxicBurden_EventBased` | Per-event original amplitude, derived reference, selected amplitude and contribution, with identity and availability reason |
| `HypoxicBurden_ByRecording` | Strict recording burden and the unchanged normalized burden, plus reference/review counts |
| `HypoxicBurden_ReferencePolicy` | Version, linking rule, 20-second limit and recording-start policy |
| `HypoxicBurden_Basis` | Existing formula, exposure and units guide |
| `AutomaticAmplitudeAvailability` | Availability of original automatic amplitudes; composite counts use the selected burden reference |

In event rows, `NormOxySinkAmpPercent`, `BaselineValue` and `BaselineStatus` retain
the original automatic result. `EpisodeAmplitudePercent` is the additional
signed positive-drop amplitude. `EpisodeReferenceKind`, `EpisodeHeadEventID`,
start/end frames, value, valid/required samples, shift, status, review flag,
source, audit checksum and version explain its derivation. `valid` means the
numerical reference requirements passed; it does not establish physiological
normality. A wrong-direction derived amplitude retains its sign and is excluded
from the burden input. `BurdenAmplitudePercent` is the selected nonnegative
amplitude; `BurdenAmplitudeSource` identifies its method.

Recording rows include `NumValidEpisodeReferenceEvents`,
`NumPreEpisodeReferenceEvents`, `NumOldEpisodeReferenceEvents`,
`NumStartReferenceUnresolvedEvents`, `NumUnavailableEpisodeEvidenceEvents` and
`NumEpisodeReferenceReviewEvents`. Existing `NumValidCompositeEvents` also
requires available area and duration. Review counts can overlap other counts.
Original automatic measurement QC and derived-reference QC describe different
calculations and need not have the same missing counts.

## Preserved burden calculation

`xi_i = BurdenAmplitudePercent_i * BurdenArea_um2_i * BurdenDuration_sec_i`

`Xi = sum(xi_i)` with strict missingness.

`Xi_per_mm2_per_min = Xi * (1e6 / recording_area_um2) * (60 / recording_duration_sec)`

An unavailable required event contribution keeps the recording total unavailable;
there is no partial-burden substitute or coverage correction. Successful
event-free recordings remain valid zero. Unresolved event timing, tissue
support and acquisition qualifications remain separate. Original optical trace
integrals and site amplitude means retain their original reference.

## Named software regression

FB2412 site 1 event 3 uses frames 639–658 and gives 6.012181174339028%, with
normalized event contribution 2608.970112849447 using its saved burden area,
duration and full recording exposure. Isolated event 4 retains 7.465059534213714%.
Event 1 remains unresolved. These selected examples establish arithmetic and
provenance, not a complete recording burden or biological ground truth.
See the [implementation record](BOI_PRE_EPISODE_IMPLEMENTATION.md).
