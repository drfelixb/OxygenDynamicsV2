# FB2420 recognition review — revision 8

15 September 2026 · R3-FB2420-RECOGNITION-081

The researcher answered **“i do not recognize a surge there”** for case 8,
surge site 11/event 5, audit row 309, automatic native/measured frames 971–1034.
Cumulative immutable revision 8 records `not_recognized` with empty human
boundaries. No additional rationale, alternative interval, reference or
physiological classification is inferred.

All seven earlier judgments are preserved verbatim, including the recognized
case-6 surge at approximate human frames 130–150. Earlier contextual observations
remain unchanged. No automatic data, labels, masks or measurements were altered;
no detector or correction was rerun.

`feedback.json` retains the exact question/reply. MATLAB saved/reloaded revision
8, checked prior history and the recognized surge's bounds, verified the final
case remains unreviewed, rendered cases 8–9 and rechecked automatic source hashes.
All 485 MATLAB files and 32 prior sealed artifacts are preserved. Pre-append
standing ledgers are in `before/`.

The last frozen example is **case 9, surge site 2/event 4, audit row 283**,
selected for closest same-site recurrence. Native and measured bounds both span
**105–126**. The one-frame native gap is an algorithmic relation, not proof of
biological recurrence or an acceptable reference baseline. Automatic amplitude
remains unavailable for insufficient clean prebaseline. Corrected intensity is
primary and detection score supporting. Recognition is pending, so the nine-case
recognition phase is not yet complete. No queue expansion or method change occurs.

![Last frozen case](case-09-timing.png)

Open the same queue with explicit cumulative revision 8:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-08');
[Fig,UI] = openFB2420Revision08(9);
```

The wrapper attaches the hash-checked review; earlier launchers remain intact.
Portable `.m.txt` files are snapshots. Full automatic data remain in phase 074.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Event identity,
reference precision, anatomy/calibration, dynamic validity, transient impact
and evaluation independence remain unresolved. This purposive review does not
establish representative accuracy, physiological ground truth or a global policy.
