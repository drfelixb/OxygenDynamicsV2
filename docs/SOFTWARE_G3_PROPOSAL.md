# G3 proposal — a clear daily BOI workflow

26 September 2026 · **SW-G3-01 through SW-G3-03 approved as a partial saved-result usability slice**

The G2 researcher walkthrough reached the saved ID400 result, opened corrected
intensity and its supporting detection score, and confirmed that selecting a
later event updated the trace. The first screen was confusing: it opened on a
frame-1 automatic event with technical labels and no clear next action. The
researcher did not make a biological judgment or request another labeling pass.
This is workflow feedback, not a reason to retune detection.

**Goal:** a researcher can start or reopen one BOI result, understand what is
selected, inspect both signs, and find the saved outputs without remembering
paths or development scripts. G2's shared engine and result index remain the
source of truth.

| Item / owner | Bounded user benefit and scope | Acceptance and stop |
|---|---|---|
| SW-G3-01 · workflow engineer | Make **New analysis** and **Open saved run** clear choices from the launcher. Reopening presents the selected run's recording, support, rate and output location and offers the last completed run in the chosen local output location; a file chooser remains available. A failed/incomplete run is never presented as complete. | A fresh MATLAB session can reopen the existing ID400 G2 result without copying a path from a report or rerunning analysis. Switching runs clears stale selections. Stop after this one route works. |
| SW-G3-02 · workflow engineer | Open event review on a neutral, plain-language event list with a short instruction to choose an event. Show sign, site, frame interval, automatic status and baseline availability. After selection, corrected intensity stays primary, score supportive, raw/correction QA optional, with clear marker explanations. No automatic event ranking or claim of biological validity. | The same saved first and later events can be selected and understood as automatic evidence; a first-time researcher can identify the selected event and the role of both plots. No new labeling campaign. |
| SW-G3-03 · technical lead | Keep the selected run visible while navigating recording windows, both event signs, workbook and existing evidence export. Make save/reopen/export targets explicit and show actionable errors for missing/changed artifacts. Existing boundary revisions remain separate; no full review-session redesign. | One bounded walkthrough opens both signs, a saved workbook/evidence export and the same result again. Missing/changed artifacts are identified without silently switching runs. Stop when the agreed journey works. |

The assistant would implement and self-review; the researcher remains product and
scientific owner. No independent reviewer is assigned. This proposal does not
start a team or authorize delegation.

**Expected effect and effort cap:** the visible launcher, event list and result
navigation change; saved automatic numerical tables, correction/detection rules
and existing result schemas do not. Plan three reviewable implementation slices,
with no broad refactor. If a slice requires a new scientific rule, data schema or
more than the named workflow, stop and re-scope before implementation continues.
Deferring G3 leaves the working G2 path available, including its file chooser
and confusing frame-1 first view; existing data are unaffected.

**Verification budget:** saved G2 ID400 results and small synthetic fixtures
first; zero fresh full-movie detector runs. Run the relevant local BOI regression
gate after implementation and one researcher walkthrough. The G2 exact-output
comparison remains the preserved numerical baseline; a new recording execution
would need a separate scope decision. No extra cohort cases or open-ended event
diagnostics.

**Boundaries:** BOI only; existing correction, detection, timing, measurements,
source-specific tissue support, uncertainty, missingness and automatic/reviewed
separation stay fixed. No protocol/stimulation/KX work, scientific output change,
full session persistence or release publication. If implementation exposes an
output-changing defect, document its scientific effect and bring the change to a
separate review before adopting it.

**Approved limit:** zero fresh full-movie detector runs. The fresh-run journey and remaining G3.2/G3.3 requirements are untested or deferred; this delivery cannot close all of G3.

**Completion gate:** the researcher can follow the stated journey without
path-copying or guessing which event/result is selected and accepts the essential
usability. Report local test results, untested platform behavior, remaining
limits and the next gate. G4 remains responsible for durable full review sessions.
