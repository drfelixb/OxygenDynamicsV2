# FB2420 recognition review — revision 5

15 September 2026 · R3-FB2420-RECOGNITION-078

The researcher answered **“no i do not see one.”** for case 5, sink site 5/event 2,
audit row 33 (automatic measured frames 18–26; native frames 18–22).
Cumulative immutable revision 5 records `not_recognized` with empty boundaries
and preserves the first four judgments verbatim. No additional reason,
alternative interval, reference or physiological interpretation is inferred.
Earlier source-bound context observations remain unchanged.

All five sink cases selected by the frozen queue now have researcher judgments
of nonrecognition for the presented automatic cases. This does not negate the
separately identified contextual pockets, establish absence of sink events in
the recording, estimate a false-positive rate or authorize detector tuning.
Selection was purposive, not a representative or independent biological sample.

`feedback.json` retains the exact question/reply. MATLAB saved/reloaded revision
5, verified earlier history and unreviewed status for the next case, rendered
cases 5–6 and rechecked automatic source hashes. All 485 MATLAB files and 32
previous sealed artifacts are preserved. No detector, correction, measurement
or production-code changes were made; pre-append ledgers are in `before/`.

Case 6 is the first **surge** example: surge site 3/event 1, audit row 291,
selected by the frozen first-finite-amplitude rule. Native and measured bounds
both span **134–144**. The finite automatic amplitude is a source measurement,
not biological acceptance. Corrected intensity remains primary, with detection
score supporting; human surge recognition is pending. Sign-specific identity
is explicit, even though a sink example previously also used site number 3.

![Next frozen case](case-06-timing.png)

To open the frozen queue with explicit cumulative revision 5:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-05');
[Fig,UI] = openFB2420Revision05(6);
```

The wrapper attaches the explicit hash-checked revision; earlier launchers and
reviews remain unchanged. Portable `.m.txt` files are snapshots. Full automatic
data remain in the phase-074 local packet.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Event identity,
reference precision, anatomy/calibration, dynamic validity, transient impact
and evaluation independence remain unresolved. No global scientific policy
or physiological ground truth is inferred from this review.
