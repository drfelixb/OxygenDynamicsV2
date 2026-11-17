# Second researcher save verified

Follow-up to R5-RESEARCHER-BOUNDARIES-054-W1. The researcher reported:
“done. i can see the purple lines.” This follows entry of event 3 at 496–516.
The earlier “they do” confirmed event 4’s purple boundaries matched its
intended peaks. These are guided interface checks using previously discussed
coordinates, not blinded event discovery or physiological validation.

`BOI-researcher-review-02.json` contains revision 1 unchanged for saved surge
site 1 / event 4 (row 309), and revision 2 for saved surge site 1 / event 3
(row 308). The new onset/preferred onset is 496; recovery/preferred recovery
is 516. Event 4 remains 536–556. Reviewer Felix and both saved `uncertain`
statuses are preserved. The new reason is retained verbatim in the original
JSON snapshot; no spelling or scientific interpretation was changed.

The production MATLAB loader reopened the file successfully and checked both
event identities against the actual audit. The previous artifact checksum
matches the original review, and the previous revision is identical. All
prior measurement fields for both events are unchanged. Both original review
files and the source audit remain unchanged. The prior walkthrough’s 39
sealed artifacts were verified unchanged. No production code was modified.

The actual researcher file is copied byte-for-byte as
`researcher-original-02.json`; verification details are in `verification.json`.
The original save timestamp stays 2026-09-14T10:52:13Z. Assistant verification
has its own timestamp and does not create a researcher revision. Visibility
of event 3’s lines was explicitly reported; a new independent biological
acceptance decision or separate researcher restart/reopen was not reported.

Next guided example: saved surge site 5 / event 1, row 321, with the previously
specified 177–195 endpoints. Continue in the same loaded review and save a
new file so both site-1 entries remain in history. Recognition status remains
an explicit researcher judgment, separate from timing coordinates.
