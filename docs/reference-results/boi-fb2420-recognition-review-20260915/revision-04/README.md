# FB2420 recognition review — revision 4

15 September 2026 · R3-FB2420-RECOGNITION-077

The researcher answered **“no pocket”** for case 4, sink site 17/event 1,
audit row 106 (automatic measured frames 86–171; native frames 101–160).
Cumulative immutable revision 4 records `not_recognized` with empty human
boundaries and preserves the first three judgments verbatim. No additional
reason, alternative interval, reference or physiological interpretation is inferred.
Earlier contextual observations remain preserved in their source-bound feedback
records; this reply does not revise those observations or any automatic result.

`feedback.json` retains the exact question/reply. MATLAB saved/reloaded revision
4, verified prior history, checked the next case remains unreviewed, rendered
cases 4–5 and rechecked source bindings. All 485 MATLAB files and 32 previous
sealed artifacts are preserved. No detector, correction, measurement or
production-code change was made. Pre-append ledgers are retained in `before/`.

Case 5 is sink site 5/event 2, audit row 33, selected by the frozen closest
same-site recurrence rule. Native bounds are **18–22**; measured bounds are
**18–26**. The native gap from the preceding same-site event is one frame.
That is an algorithmic temporal relation, not proof of biological recurrence.
Automatic amplitude remains unavailable for insufficient clean prebaseline.
The corrected-intensity trace is primary; detection score is supporting context.

![Next frozen case](case-05-timing.png)

Open the same frozen queue with cumulative review revision 4:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-04');
[Fig,UI] = openFB2420Revision04(5);
```

The wrapper attaches the explicit hash-checked revision; older launchers and
reviews remain unchanged. Portable `.m.txt` files are snapshots; full automatic
data remain in the phase-074 local packet.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Event identity,
reference precision, anatomy/calibration, dynamic validity, transient impact
and evaluation independence remain unresolved. This purposive review does not
establish a false-positive rate, independent validation or a global policy.
