# Portable automated checks and environment delivery

4 October 2026 · NEXT-05 · Owner: implementation assistant

The accepted calculations and exports are connected to the BOI runner through
**26 added portable cases** and the existing portable saved-result checks.
Final hosted gate: **133/133 passed**, zero failures/incomplete cases, on exact
source commit [5c23b02](https://github.com/drfelixb/OxygenDynamicsV2/commit/5c23b0259806b74364183726e6a886d4ecf4488b).
[Successful Linux workflow](https://github.com/drfelixb/OxygenDynamicsV2/actions/runs/37233031802) ·
[JSON/JUnit artifact](https://github.com/drfelixb/OxygenDynamicsV2/actions/runs/37233031802/artifacts/11314222880).

## Named environment and support evidence

| Environment | Actual automated result | Demonstrated scope |
|---|---|---|
| macOS 27.0, Apple silicon, MATLAB 25.1.0.2943329 (R2025a), MACA64 | One selected full gate: 132/133 passed, one fixture expectation failed. Two repair/compatibility checks passed on 171e933; one temporal portability recheck passed on 5c23b02. | Portable calculation/export/read/rejection checks; final whole gate was not repeated. |
| Ubuntu 24.04.5, MATLAB R2025b, GLNXA64, GitHub-hosted | Final 133/133 passed on 5c23b02. First run: 132 passed, one failed/incomplete local-path-dependent test. | Complete final portable gate, Image Processing and Statistics and Machine Learning toolboxes configured. |
| Desktop/native chooser | No new automated usability claim | 29 programmatic GUI cases are explicitly separate; accepted earlier native-chooser and Step 4 saved-installation evidence are retained. |
| Windows, other MATLAB releases/platforms | Not tested here | No compatibility claim. |

Run `runBOISoftwareChecks('portable','ci-results')`. Optional `'desktop'` or
`'all'` selects the separately named programmatic GUI checks; no native chooser
or independent researcher behavior is inferred. [Check guide](BOI_AUTOMATED_CHECKS.md).
JSON/JUnit identify release, computer, each case, counts and hosted source SHA.
The workflow enables development-existing-analysis-v3 and has a 30-minute job
cap. Actual push-triggered durations were approximately 2:10 and 3:04, below it.
Reports are uploaded even on failure and retained on GitHub for 14 days;
local evidence/logs remain in reference-validation/software-next05-portable-ci-20261004.

## Protected behavior

Independent frozen Step 2/3 fixtures now live under tests/fixtures, without
local research paths. They protect sink/surge inclusive duration, native event
area, union tissue occupancy, onset rate, concurrent density, signed integrals
with cancellation/negative values and fraction/percent seconds, area/time
composite normalization, unequal recording/mouse weighting, strict missingness,
zero events and exact contributors. Automatic amplitude fixtures preserve
negative/legacy signs, unavailable values, summary rules and workbook/CSV/MAT
round trips. Original calculator software/contract is distinct from current
reader/exporter; explicit original identity is retained and unknown stays unknown.

Reviewed-pocket fixtures use eight scalar samples and fixed pixels: raw
−20%, saved corrected −25%, with positive raw denominator, explicit frames,
provisional/conditional surge qualification and unresolved recovery. Preview,
new save, reopen without replay, portable/selected-event export, exact automatic
row preservation, immutable folders, missing correction/clock/reference and
unsupported/incomplete artifacts are protected. Current indexed saved-run/
request schemas reopen; future schema, failed run, changed artifact, incomplete
audit and mismatched historical dimensions/source metadata are rejected.
Twelve generic legacy shape traces (6–12 samples) preserve existing descriptors.
Temporary synthetic arrays/TIFF/MAT fixtures are created and cleaned; no local
research folder or supplied recording is needed, and no recording or statistics
pipeline was run. Scientific definitions and numerical results were not changed.

## Retained failures and repairs

Local full gate on [0074c0b](https://github.com/drfelixb/OxygenDynamicsV2/commit/0074c0b1f9682b19a371df6cdd7c11878701e5a2):
132 passes, one historical FrameSize expectation used a column rather than the
supported row vector. Test expectation repaired, production reader unchanged.
Unsupported indexed run/request assertions were strengthened. A targeted
dispatcher first failed suite-array conversion before evaluating a case; its
cell-suite assembly repair and 2/2 passing targeted checks are retained.

[First Linux run](https://github.com/drfelixb/OxygenDynamicsV2/actions/runs/37232714291) on 171e933 failed one older
temporal check because its generic golden JSON was read from an uncommitted
reference-validation folder. Move only those synthetic fixtures under
`tests/fixtures`; the original file and calculation helper remain unchanged.
One affected local check passed, then final hosted 133/133 passed. No scientific
output-changing defect or adoption decision was demonstrated.

HTTPS push was rejected for missing workflow scope, and the connected app
could not update the branch. Existing SSH credentials completed normal
fast-forward pushes. These authentication failures consumed zero hosted runs;
both successful source pushes consumed the two allowed executions. No retries
or third hosted execution remain authorized under this task.

## Source, candidate and stopping identity

Development version stays **3.1.0-dev.2**, build **2026-10-04 21:37:28 +02:00**.
Accepted Steps 2–4 were committed in 0074c0b; two test-only repairs follow in
171e933 and 5c23b02. The final hosted tested commit is **5c23b0259806b74364183726e6a886d4ecf4488b**.
Mac full/targeted commit identities remain separate in the table above.
The completion-record commit contains only documentation/status and skips CI,
using [GitHub's commit-message mechanism](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs).
It is a descendant of the tested source; do not describe its tip as having a new
complete CI run. Tests/workflow/scientific source are unchanged by that record.

The preserved Step 4 ZIP SHA256 is
`246274ea9bad0ee7d1ac54d61216b77ecf39a32fe5edd8167ea7d05e3851765b`.
Its original base was b0f6d20 plus modified source, never identical to that
commit. **All 443 packaged source/document hashes match the tested 5c23b02
source.** The tested commit additionally includes portable tests, CI and
repository documentation absent from the candidate. Candidate folder/ZIP/
extraction and previous candidate are preserved; it was not rebuilt here.
All 1725 pinned original/candidate files match. No recordings or generated
research evidence entered Git; changes are textual source/tests/docs only.

One selected local gate plus three passing targeted checks, two hosted
executions capped at 30 minutes, under four active hours. Exact budget/source/
input receipts are in the local evidence packet. Historical failures and
scientific limits remain: C02 reference conditional, FB2312 recovery unresolved,
corrected reviewed trough exploratory and automatic/reviewed outputs separate.
No physiological validation, full detector/runtime or recording evidence,
licensing clearance, containment or release publication is claimed. Step 5 is
delivered for researcher acceptance; development stops before Step 6.
