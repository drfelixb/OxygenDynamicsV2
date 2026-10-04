# Duration, area, occupancy and event-rate calculations

4 October 2026 · NEXT-02 · Owner: implementation assistant

Researcher approved Step 2 as one complete calculation-and-repair task.
User benefit: explain and check the time, pixel and tissue denominators behind
both sink and surge exported descriptive measurements.

Start: branch development-existing-analysis-v3, commit
`b0f6d20be415f9dc64f99c05585147e21633d8db`, software `3.1.0-dev.1`, clean worktree.
Inputs: saved G2 gui-run ID400 statistics packet at
`reference-validation/software-g2-workflow-20260923/gui-run/statistics/Stats_Output_20260923T102730/`.
All 18 original files are pinned in the new evidence packet's saved-input-pins.json.
No source TIFF is opened. Ingredient-only inspection of saved tables/masks
precedes freezing independent answers; no case evaluations occur before freeze.

Budget: six active hours, four validation batches, 40 focused case evaluations,
two saved-data-only MATLAB sessions, 100 MiB total new evidence. Counter file:
`reference-validation/software-next02-calculations-20261004/budget.json`.
One named case means its frozen input scenario, both signs, associated
calculation/export/preservation assertions; repeat attempts consume another
evaluation. Nine cases (eight small fixtures and one saved ID400 case) maximum
per full batch. No unrelated suites or matrix expansion.

Planned fixtures: single frame at 2 Hz; native area with refined sink bounds;
overlapping masks; fractional window edges; acquisition boundary/ongoing and
end-boundary exclusion; empty events; missing calibration; invalid timing.
Exact pixels, intervals and independent expected values are frozen in
`cases.json` before evaluation. Independent saved expected answers are formed
from saved native pixel-count ingredients and original exported frame/event
ledgers, without calling production calculation helpers.

Acceptance: follow duration, native event area, union occupancy, onset rate and
concurrent density through both signs and exports; compare to independent
answers; distinguish zero, unavailable and blocked. Preserve definitions,
contracts, detector, correction, native/refined distinction, old results and
automatic/reviewed separation. Prepare any demonstrated defect repair and
report old/new scientific values before adoption; adoption awaits researcher
review. Ordinary harness/documentation repairs use this same bounded budget.

Stop with a short guide, worked examples, final-code named checks or precise
unresolved decision. No recording/detector/statistics pipeline run, source-movie
reconstruction, containment diagnostics, release work or automatic Step 3.
No commit/push is presumed by Step 2 authorization.

## Frozen case matrix — before evaluation

Eight fixtures F01–F08 and saved case S01 are frozen in cases.json and
saved-expected.json. Preparation uses a separate Python arithmetic writer.
The MATLAB inventory job returned successfully with zero case evaluations;
first sandbox invocation exited 1 without receipts and is charged as one
MATLAB session attempt. The second invocation is the remaining saved-data
session. No additional MATLAB launch is allowed.

All fixture frame grids contain four 3 × 4 frames. Sink support is pixels 1–4;
surge support is pixels 1–8. Scale is 2 µm/pixel unless unavailable. Native
per-frame pixels and exact measurement bounds are in next02FixtureInputs.m;
expected values and window limits are frozen in cases.json.

| Case | Input/acceptance focus | Independent expected examples |
|---|---|---|
| F01 | Frame 2 alone, 2 Hz, whole [0,2) | duration 0.5 s, native area 4 µm²; sink occupancy 0.0625, onset 1,875,000/mm²/min, density 15,625/mm²; surge values half |
| F02 | Native frames 1–2; sink measurement frames 1–3 | area 8 µm² for both; sink duration 3 s, surge 2 s; covered area-time 16 µm²·s for each |
| F03 | Masks {1,2}/{2,3} and {3,4} overlap in frame 2 | frame union area [8,12,0,0] µm²; covered 20, sink occupancy 0.3125; three event-seconds, two onsets |
| F04 | Same masks, window [0.5,2.5) | overlaps [0.5,1,0.5,0] s; covered 16; 2.5 event-seconds, one onset; sink occupancy 0.5 |
| F05 | Frames 1–3 plus event at frame 4; window [1,3) | ongoing at start 1; onset at window end excluded; zero onsets, two event-seconds; sink occupancy 0.5 |
| F06 | No events/sites; valid clock/calibration/support | zero occupancy, rate and density; empty event measurements |
| F07 | Nonempty events with missing pixel scale and area | finalizer blocks invalid calibration; window normalized outputs unavailable, count 1 and active time 2 s retained; saved reader rejects invalid calibration |
| F08 | Nonempty events, sampling rate 0 | finalizer and window helper reject invalid clock; no valid zero or export |
| S01 | Saved ID400 G2, 600 frames, supplied 1 Hz, 4.75 µm/pixel | 192 sink / 54 surge events; duration sums 2501 / 781 s; independent native counts and frame unions reconcile all exported values |

Saved independent answers: sink area 4,050,555.375 µm², covered area-time
14,815,462.5625 µm²·s, occupancy 0.006096062223113458, onset rate
4.740090733853997 events/mm²/min, concurrent density 1.029076990049379
events/mm². Surge area 4,339,851.75 µm², covered 28,751,664.5 µm²·s,
occupancy 0.011041722988195007, onset 1.2442821347526447 events/mm²/min,
density 0.29993344050673315 events/mm².

First saved sink event: native/refined frames 1–3, duration 3 s, area
5475.166666666666 µm². First saved surge: frames 3–14, duration 12 s, area
17051.609375 µm². Two sink acquisition-boundary onsets remain descriptive,
without asserting a new physiological onset; no surge frame-1 onset exists.

Fixed checks per case: both-sign helper calculations, unchanged inputs, native
versus refined bounds, union/tissue denominators, event workbook round trip,
window CSV/MAT readable export/replay when admissible, and appropriate
missing/invalid guards. S01 additionally checks the original workbook and
per-frame CSV against saved MAT/native pixels, replays saved-time helpers and
exports only compact selected-window/event evidence (no full statistics export).
Relative numeric tolerance 1e-10 × max(1, expected) for spreadsheet arithmetic;
integer identity/counts exact, finite/NaN availability exact. Hashes gate inputs.

Batch-1 protocol repair: missing calibration is rejected at the surge source-bound
wrapper (InputContractIdentity), rather than exported as a window. This correct
blocking behavior is accepted by the existing requirement; generic primitives
are additionally checked for unavailable outputs. Frozen numeric answers remain
unchanged. Empty-shape and character concatenation harness errors are retained
and repaired before recheck. No scientific formula was changed.

## Completion

Delivered: [report](SOFTWARE_NEXT_02_DELIVERY.md), final 9/9 pass in batch 2.
Two batches/18 evaluations, two charged MATLAB attempts with one successful
saved-data session, 42.16 MiB evidence at completion, no calculation changes.
All original packet and production hashes preserved. Session exited 0; stopped.
No automatic Step 3, commit/push or release.
