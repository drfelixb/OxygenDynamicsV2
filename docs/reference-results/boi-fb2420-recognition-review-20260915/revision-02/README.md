# FB2420 recognition review — revision 2

15 September 2026 · R3-FB2420-RECOGNITION-075

The researcher did not recognize a pocket **within the marked automatic interval**
for queue case 2 (sink site 1/event 1, audit row 1; measured frames 1–48).
The cumulative immutable boundary revision records `not_recognized` with empty
onset/recovery fields and preserves revision 1 verbatim.

The same reply contains two **tentative observations on the displayed footprint
trace**, retained separately in `feedback.json`:

| Observation | Approximate onset frame | Approximate recovery frame |
|---|---:|---:|
| A | 2 | 28 |
| B | 65 | 84 or 85 |

The researcher's “might,” “around” and “maybe” remain material uncertainty.
These observations do not assert absence of all pockets in the displayed trace.
They are not treated as confirmed native events, a split of the automatic event,
precise boundary annotations, reference windows or quantitative measurements.
No proposed interval is silently transferred to a different footprint. Earlier
signal outside acquisition remains unobserved. All coordinates are one-based
frames under external 1 Hz sampling; modeled seconds equal frame minus one.

`feedback.json` preserves the exact question and reply. `source-bindings.json`
binds the source audit, native masters, statistics, frozen selection and previous
review. `BOI-researcher-review-02.json` contains both saved judgments. MATLAB
saved/reloaded the new revision, checked the earlier judgment and unreviewed
next case, rendered cases 2 and 3, and verified all automatic source bindings.
No new detector, correction, baseline, measurement or production-code change
was made. All 485 MATLAB files and 219 prior sealed artifacts were verified;
standing-ledger histories are retained in `before/`.

Case 3 is sink site 3/event 1, audit row 22, selected by the pre-existing shortest
native-duration rule. Native and measured bounds are frames 2–4. Its fixed
footprint differs from case 2: the nearby time does not establish that it is the
same biological event or the researcher's tentative observation A. Available
pre-event context is limited and automatic amplitude is unavailable for
insufficient clean prebaseline. The corrected trace remains primary, score
supporting. Human recognition is pending.

![Next frozen case](case-03-timing.png)

The original phase-074 launcher remains an immutable revision-1 entry point.
To open the newer review in MATLAB:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-02');
[Fig,UI] = openFB2420Revision02(3);
```

This wrapper loads the same frozen queue and hash-checks the explicit revision-2
annotation before attaching it. Portable `.m.txt` files are snapshots; use the
local runnable files. Full automatic data remain in the phase-074 local packet.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Physiological identity,
reference precision, anatomy/calibration, dynamic validity, transient impact
and evaluation independence remain unresolved. No false-positive ground truth,
tuning decision or global policy is inferred from recognition feedback.
