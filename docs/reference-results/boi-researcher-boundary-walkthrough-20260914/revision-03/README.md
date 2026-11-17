# Third researcher save verified

Follow-up R5-RESEARCHER-BOUNDARIES-054-W3. The researcher reported “done” after
being asked to save the previously specified 177–195 boundaries for saved
surge site 5 / event 1 (audit row 321). The actual file
`BOI-researcher-review-03.json` was found beside the audit and copied exactly
as `researcher-original-03.json`. This was a guided workflow step, not blinded
recognition or an independent physiological acceptance decision.

Revision 3 records onset/preferred onset 177 and recovery/preferred recovery
195, reviewer Felix, status `uncertain`, and original save time
2026-09-14T10:57:23Z. Its reason is retained verbatim in the copied JSON.
The reason’s reference to a sink does not automatically relabel the saved
surge; the existing detector label and scientific uncertainty remain intact.

The production MATLAB loader verified the new file against the actual
saved audit/source identity and clock. Its first two revisions are exactly
unchanged: site 1 / event 4 at 536–556 and site 1 / event 3 at 496–516.
The parent-artifact checksum matches revision-file 02. All three annotations
remain saved as `uncertain`. Every prior measurement field for all three
selected events is unchanged; no amplitude, baseline, native-mask or
statistics changes were made. The original files and 51 sealed artifacts
from the preceding walkthrough records remain unchanged. No production
code was edited and no new researcher revision was authored by the assistant.

The next guided example is saved sink site 15 / event 36, row 186: previously
specified onset alternatives 1149 and 1154, with 1154 preferred; recovery
alternatives 1166 and 1167, with no stated preference. These are discrete
one-based recording-frame choices, not a continuous uncertainty range.
Record the actual researcher save separately and preserve all prior entries.
