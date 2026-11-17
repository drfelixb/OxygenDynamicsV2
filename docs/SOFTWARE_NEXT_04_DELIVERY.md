# Installation candidate delivery

4 October 2026 · NEXT-04 · Owner: implementation assistant

Fresh candidate: `OxygenDynamics_3.1.0-dev.2_NEXT04_candidate01.zip` in workspace
`reference-validation/software-next04-package-20261004/`.
ZIP SHA256: `246274ea9bad0ee7d1ac54d61216b77ecf39a32fe5edd8167ea7d05e3851765b`.

Packaged version **3.1.0-dev.2**, build **2026-10-04 21:37:28 +02:00**.
Base commit **b0f6d20be415f9dc64f99c05585147e21633d8db**, branch
`development-existing-analysis-v3`. This is a **modified, uncommitted source
snapshot, not identical to that commit**. `RELEASE_MANIFEST.txt` gives the
ancestry-only base commit, source-state statement, policy SHA256 and every
packaged source SHA256. The manifest hash is
`5f3f584a270f8f7c4ada4e8c648ec2546a7126a894f75037f12876c9f9a6e19d`;
policy hash `2170b2ab0d10b3ba6d7f71b35fca4a30d9a4945610ff8bc627fcee57b44e24fc`. No commit/push/publication occurred.

## Contents and installation

The explicit policy now includes the accepted reviewed-pocket workflow,
automatic-amplitude companions, provenance helper, required measurement/review
JSON definitions and reader guides. 443 exact source/document files plus the
manifest; no recursive folder copying. Recordings, generated results, private
source maps, tests and development evidence stay excluded. The previous
candidate is hash-preserved. Historical repository-only documentation links
are plain paths; all package-local reader links resolve within the package.

Extract into a new folder, keep previous installs/results, and in MATLAB change
Current Folder to the extracted root. Run `setupOxygenDynamicsPath`, then
`getOxygenPipelineVersion` and `openBOIRecordingWorkflow`. Supply an existing
completed run separately. Avoid another OxygenDynamics checkout on the path;
`which openBOIEventReview -all` must point to this installation.
[Simple installation instructions](../INSTALLATION.md) are also inside the ZIP.

## Verification

- Batch 1: exact policy, source hashes, documentation links and size/free-space
  preflight pass; 1,751,868 source bytes before manifest. Free space exceeded
  115 GiB. Space/growth checked before extraction and the repair recheck.
- Batch 2: complete file lists and SHA256 match source → candidate folder →
  ZIP entries → extracted files. 444 candidate files; no added research payload.
- Batch 3: saved sink-window load/export passed; five route checks failed in the
  harness after accepted preview/save/reopen/export values had passed. The UI
  flag assertion inspected a draft state; CSV serialization was incorrectly
  compared by exact binary equality. Failures/logs/artifacts are retained.
- Batch 4: final **6/6 installation routes pass** after harness-only repairs:
  reload saved revision before flag check; typed CSV import with established
  1e-10 relative numerical tolerance and exact counts/missingness. The running
  driver retained its six-route default and also repeated the already-passing
  window route; this extra check is charged and retained. Candidate unchanged.
- Batch 5: final source/archive/extraction hashes, original inputs, previous
  candidate, protected Step 2–3 work, session exit and status/whitespace checks.

Extracted routes: ID400, FB2312 and C02 reviewed pocket preview/new save/reopen/
portable export/selected-event export/portable reopen; G2 ID400 and C02 saved
statistics automatic amplitude workbook/CSV/MAT companions and manifests;
G2 sink-window saved metric export. Accepted corrected/raw percentages are
ID400 −5.0523405688433565/−4.328656254545948, FB2312
−8.362579856515431/−8.138502968125097, C02
−12.383756977559301/−11.104931801071126. Exact frames/minima/footprints,
automatic rows and saved revision exclusion of unsaved drafts are preserved.
C02 remains conditional with automatic amplitude unavailable; FB2312 recovery
unresolved; surge-footprint qualifications retained. Exporter dev.2 is separate
from unknown original statistics software. No arithmetic definition changed.

MATLAB default path was restored, cached functions cleared, Current Folder set
to extraction, and only extraction/support plus evidence-only driver added.
Every policy-listed MATLAB implementation resolves to its exact extracted file;
loaded-function/path checks before and after each route exclude the development
checkout. Resolution receipts are retained. Routes use programmatic GUI handlers;
this is not a new researcher native-chooser usability walkthrough. Captured
ID400 preview and C02 portable viewer were visually inspected and readable.

One build, five focused batches, one packaging/saved-data MATLAB session,
12 route evaluations (six first attempts plus six repair checks); worker exited
0. All artifacts and logs remain below 150 MiB; exact final accounting and active
upper bound are in budget.json. No recording, detector/statistics-pipeline rerun,
calculation change, containment work, commit, push or publication.

## Limits and stopping condition

Named saved-data routes are demonstrated on macOS/MATLAB R2025a. This is not
fresh-recording validation, a full test-suite run, all-platform/toolbox support,
independent scientist review, hosted CI, licensing clearance or release approval.
Original calculator identity cannot be recovered for the saved statistics;
C02 conditional reference, FB2312 unresolved recovery and exploratory corrected
trough meaning remain. Broader G5/release blockers and historical failures stay.
No package-specific numerical decision remains. Step 4 awaits researcher
acceptance; development is stopped and Step 5 requires separate approval.

## Researcher acceptance — 4 October 2026

Accepted within its demonstrated saved-data scope and documented limitations.
Step 5 separately approved; candidate ZIP and its historical identity preserved.
