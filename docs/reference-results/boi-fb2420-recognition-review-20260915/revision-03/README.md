# FB2420 recognition review — revision 3

15 September 2026 · R3-FB2420-RECOGNITION-076

For case 3 (sink site 3/event 1, audit row 22), the researcher does **not recognize
a pocket at automatic frames 2–4**, judging this as fluctuation in the context of
the subsequent trace. This is saved as `not_recognized` with empty boundaries.
Cumulative revision 3 preserves both previous judgments verbatim.

Separately, the researcher identifies a pocket on this displayed corrected-
intensity footprint trace starting **around frame 7 until likely frame 27**.
The approximate onset and recovery, exact reply and contextual reasoning are
preserved in `feedback.json`. Recognition and timing certainty are separate:
the user identifies a pocket but gives approximate bounds. This observation is
not silently reassigned as boundaries of the rejected automatic event, mapped to
another native event, given a reference baseline or used for measurement. It is
not assumed identical to case 2's early observation from a different footprint.

Coordinates are one-based frames at externally controlled 1 Hz; modeled seconds
are frame minus one. Corrected intensity remains primary, with detection score
supporting. Biological variability and surrounding trace context remain material
to the researcher's recognition judgment; no new variability threshold is fitted.
No physiological ground truth, false-positive rate or global policy is inferred.

MATLAB saved and reloaded revision 3, checked preservation of revisions 1–2,
empty bounds for audit row 22 and unreviewed status for next row 106, rendered
cases 3–4 and rechecked automatic source hashes. All 485 MATLAB files and 32
previous sealed artifacts are preserved; no detector, correction, measurement
or production-code change was made. Historical standing ledgers are in `before/`.

The next frozen case is **case 4, sink site 17/event 1, audit row 106**, selected
for longest native duration. Native bounds are **101–160**, while measured bounds
are **86–171**. These remain distinct automatic intervals, with researcher
recognition pending. The queue and selection rules remain unchanged.

![Next frozen case](case-04-timing.png)

To open the live review with the explicit cumulative revision 3:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-03');
[Fig,UI] = openFB2420Revision03(4);
```

The earlier launchers remain intact. The new wrapper opens the same frozen queue
and attaches hash-checked revision 3; portable `.m.txt` files are snapshots.
Full automatic data remain in the phase-074 local packet.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Event identity,
reference precision, anatomy/calibration, dynamic validity, transient impact
and evaluation independence remain unresolved. Human review continues.
