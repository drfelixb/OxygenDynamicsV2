# FB2420 recognition review — revision 7

15 September 2026 · R3-FB2420-RECOGNITION-080

The researcher answered **“i dont see a surge there”** for case 7, surge site
1/event 1, audit row 279, automatic native/measured frames 1–10. Cumulative
immutable revision 7 records `not_recognized` with empty human boundaries.
The explicit judgment is not replaced with uncertainty because the acquisition
starts at frame 1. Preceding signal remains unobserved; no additional reason,
reference or physiological classification is inferred.

All six earlier judgments are preserved verbatim, including the recognized
case-6 surge with approximate human bounds 130–150. Prior source-bound contextual
observations remain unchanged. No automatic data, labels, masks or measurements
were altered and no detector or correction was rerun.

`feedback.json` retains the exact question/reply. MATLAB saved/reloaded revision
7, checked prior history and the recognized surge's bounds, verified case 8
remains unreviewed, rendered cases 7–8 and rechecked automatic source hashes.
All 485 MATLAB files and 32 prior sealed artifacts are preserved; pre-append
standing ledgers are in `before/`.

The next frozen case is **case 8, surge site 11/event 5, audit row 309**,
selected for longest native duration. Native and measured bounds both span
**971–1034**. Automatic amplitude is unavailable for insufficient clean
prebaseline. The preceding same-site native gap is four frames, an algorithmic
relation that does not establish biological recurrence or suitable reference
signal. Corrected intensity remains primary, detection score supporting;
human recognition is pending. The frozen queue remains unchanged.

![Next frozen case](case-08-timing.png)

Open the same queue with explicit cumulative revision 7:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-07');
[Fig,UI] = openFB2420Revision07(8);
```

The wrapper attaches the hash-checked review; prior launchers remain intact.
Portable `.m.txt` files are snapshots. Full automatic data remain in phase 074.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Event identity,
reference precision, anatomy/calibration, dynamic validity, transient impact
and evaluation independence remain unresolved. No representative accuracy rate,
physiological ground truth, tuning decision or global policy is inferred.
