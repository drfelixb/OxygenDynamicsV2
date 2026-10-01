# FB2420 recognition review — revision 6

15 September 2026 · R3-FB2420-RECOGNITION-079

The researcher answered **“yes, but more from 130 - 150”** for case 6,
surge site 3/event 1, audit row 291. Cumulative immutable revision 6 records
`recognized`, onset frame **130**, recovery frame **150**, preserving the first
five judgments verbatim. The wording is retained as **approximate timing**;
no numerical uncertainty range or precise physiological endpoint is invented.
Preferred-endpoint fields remain empty because none was separately specified.

The automatic native and measured interval remains **134–144**. Purple human
marks are a separate annotation, not changes to native mask, fixed footprint,
detection, original measurements or reference baseline. No reference was selected
and no reviewed optical quantity is adopted from this reply. Corrected intensity
is primary and the detection score is supporting. Coordinates are one-based
frames under external 1 Hz sampling; modeled seconds equal frame minus one.

`feedback.json` retains the exact question/reply and timing qualification.
MATLAB saved/reloaded revision 6, verified earlier history and next-case
unreviewed status, checked purple marks at 130/150 and unchanged automatic
marks at 134/144 on all three timing axes, rendered cases 6–7 and rechecked
source hashes. All 485 MATLAB files and 32 prior sealed artifacts are preserved.
No detector, correction, measurement or production-code change was made;
pre-append ledgers are in `before/`. Prior contextual observations are unchanged.

The next frozen case is **case 7, surge site 1/event 1, audit row 279**.
Native and measured bounds are **1–10**, selected by both first-unavailable-
amplitude and shortest-native-duration rules. It is shown once with both reasons
retained. Acquisition begins at frame 1: preceding signal and onset history
are unobserved, and automatic amplitude is unavailable for insufficient clean
prebaseline. Human recognition is pending; no pre-recording baseline is inferred.

![Next frozen case](case-07-timing.png)

Open the frozen queue with cumulative revision 6:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-06');
[Fig,UI] = openFB2420Revision06(7);
```

The wrapper attaches the explicit hash-checked revision; prior launchers and
reviews remain unchanged. Portable `.m.txt` files are snapshots. Full automatic
data remain in the phase-074 local packet.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Event identity,
reference precision, anatomy/calibration, dynamic validity, transient impact
and evaluation independence remain unresolved. These purposive judgments are
not a representative accuracy estimate, physiological ground truth or global
policy. Detector/timing changes would require a separate decision and the
existing 48-event challenge; none is made here.
