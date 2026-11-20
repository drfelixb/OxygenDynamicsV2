# Researcher save: verified follow-up to phase 054

The researcher reported completing the requested save. The actual file
`BOI-researcher-review.json` was found beside the representative saved audit.
This is a real researcher-entered revision, separate from the phase-054 QA
fixtures. The preceding assistant prompt supplied the already confirmed
536–556 coordinates, so this was a guided workflow check, not blinded review.

Revision 1 identifies saved surge site 1 / event 4, audit row 309. Onset and
preferred onset are frame 536; recovery and preferred recovery are frame 556.
Reviewer: Felix. Saved recognition status: `uncertain`, retained exactly.
Reason: “New endpoints include the onset peak and offset peak.”
Original revision time: 2026-09-14T10:41:32Z. The original JSON is copied
byte-for-byte as `researcher-original.json`; no new researcher revision was
created by the assistant.

MATLAB validation matched audit/source hashes, event identity and frame clock.
A fresh reviewer loaded the actual file, restored all editor fields and showed
the two saved manual overlays at 536 and 556 without creating a draft. The
rendered editor was inspected. All prior selected-event measurement fields
remained identical. A separate evidence export retained the annotation and
complete history; it reopened and all 11 export artifact checksums passed.
The original review and audit stayed unchanged. All 179 sealed artifacts of
phase 054 remain unchanged; no production code or standing ledger was edited.

This verifies the actual researcher save and assistant-performed reopen.
A researcher-performed reopen has not separately been reported, and this does
not establish independent usability acceptance or physiological validity.
Earlier scientific uncertainty, recognition judgments, original correction,
external 1 Hz timing, both saved signs and BOI-only scope remain intact.
The next useful user check is the purple boundary placement in Timing review.

![Actual saved researcher revision reopened in MATLAB](reopened-researcher-review.png)
