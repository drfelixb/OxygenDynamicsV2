# Guided timing review — first two examples

14 September 2026. Researcher interpretation is pending; this record does not adopt a timing rule.

## Correction to the phase 043 walkthrough

For FB2314 awake **sink site 15/event 36**, the censored edge is **onset**, at the same-site neighbor partition at frame 1151. Recovery is numerically bracketed at **1166–1167**. The earlier first-case explanation incorrectly called recovery unresolved. Its underlying CSV, calculations and verification were correct and are preserved. This dated note supersedes that narrative; physiological interpretation of either boundary still requires judgment.

[First trace](../boi-timing-execution-20260913/review/FB2314-awake/sink-site15-event36/timing-review.png): native bounds 1157–1164, saved measurement 1156–1165. The pre-event reference has 14 of 20 samples after overlap screening. Look at the downward excursion around 1150–1167 and consider whether its onset can be separated from earlier activity. The search partition is a computational safeguard, not a biological boundary.

[Second trace](../boi-timing-execution-20260913/review/FB2314-awake/surge-site5-event1/timing-review.png): native bounds 183–193. The corrected source contains a positive excursion 163–184 and a negative excursion 185–188. Each intersects only part of the native interval. The saved amplitude baseline has 0 of 20 clean samples. These separate trace/detector descriptions do not determine whether the biology comprises one event, multiple events or an ambiguous case.

Approximate frame ranges or an unresolved interpretation are sufficient. Existing correction, detector labels, native masks, baseline rules and all earlier results remain unchanged. BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements.


## Researcher annotation for example 1

The researcher places onset at **1154**, because the signal drops rapidly
within the following two frames, and offset at **1167**, the small recovery
peak. The immediate subsequent decrease could be biological; that possibility
remains unconfirmed. The brief peak is accepted by the researcher as this
case's offset without requiring a sustained flat recovery afterward.

These are case-specific guided annotations. No general onset/offset rule,
production boundary or amplitude has been changed. The marks are 13 seconds
apart at external 1 Hz and include 14 samples; no duration convention is
selected from that distinction. No additional numerical uncertainty band is
invented. Verbatim feedback and rationale are in `feedback-01.json`.

Next: example 2, FB2314 awake surge site 5/event 1, remains awaiting researcher
interpretation of the rise and subsequent dip.


## Researcher annotation for example 2

For FB2314 awake surge site 5/event 1, the researcher places onset at the
peak around **177–178** and offset at the peak at **195**. Preserve the range
and mark as given. They span the downward excursion and recovery, extending
beyond both the short corrected negative run185–188 and native bounds183–193.
No detector label, production timing or amplitude was changed. The marks are
17–18 seconds apart at external1Hz and include18–19 samples; the duration
convention remains open. Verbatim feedback is in `feedback-02.json`.

The first two annotations support a working interpretation based on the
local turn into a pronounced decline and the following recovery peak. This
is case-based evidence, not an adopted rule for choosing every peak.
Recordings, neighboring activity, small fluctuations and absent recovery may
require different judgments; biological variability remains a requirement.

Next fixed example: ID400 awake sink site45/event1. This is a different
recording with historical whole-field processing; its interpretation remains
separate from the restricted-ROI FB2314 examples. Researcher feedback is pending.


## Researcher annotation for example 3

For ID400 awake sink site 45/event 1, the researcher marks **onset 297**
and **offset 312 or 313**, at the recovery peak maximum. The two possible
offset frames are retained; no extra tolerance or onset rationale is inferred.
This provides a case-specific annotation in a second recording, not a general
peak-selection rule or independent physiological validation.

The endpoint sample times differ by 15–16 seconds at external 1 Hz and the
interval contains 16–17 samples. The duration convention remains open. No
production timing, correction, detector label or amplitude changed.
Verbatim feedback is preserved in `feedback-03.json`.

Next fixed example: ID400 awake surge site 4/event 6. Its detected interval
contains an upward local excursion; researcher interpretation and boundary
annotations remain pending.


## Additional onset for example 3 and annotation for example 4

For ID400 awake sink site 45/event 1, the researcher adds the peak around
**295 s** as another plausible onset, retaining the previously stated297 and
offset312–313. These are alternatives, not a forced continuous interval or
replacement of the original annotation. The source wording says seconds,
while the figure labels one-based frames; retain295 provisionally as the
referenced plot coordinate and keep the one-sample origin distinction open.
No silent conversion to frame296 or revised biological duration was made.

For ID400 awake surge site 4/event 6, the researcher explicitly marks the
**surge from the rise at529 through546**. This positive-event interpretation
remains alongside the downward-event annotations. Verbatim text and the two
updates are in `feedback-04.json`. Production labels, correction, timing and
amplitude remain unchanged.

Next fixed example: FB2316 KX sink site 14/event 6. The negative corrected
run reaches the30-frame extension limit at its left edge and the same-site
neighbor partition at its right edge. Both numerical boundaries are censored;
researcher interpretation remains pending.


## Researcher annotation for example 5

For FB2316 KX sink site 14/event 6, the researcher marks **onset 717** and
**offset 772**. No additional range or rationale was supplied. The marks
remain distinct from the saved measurement716–779, native interval741–772
and censored negative-reference diagnostic711–792. This provides a finite
researcher-marked interval even though the reference-crossing diagnostic
does not bracket it; no general rule or mechanistic explanation is inferred.

At external 1 Hz the endpoint sample times differ by 55 seconds and the
interval includes 56 samples; the duration convention remains open.
No production timing or amplitude changed. Verbatim feedback is preserved
in `feedback-05.json`.

Next fixed example: FB2316 KX surge site 10/event 3. Its corrected source
stays positive across the displayed context. The positive diagnostic is
limited by the preceding same-site event partition and right-hand search
limit; researcher interpretation remains pending.


## Researcher judgment for example 6: no visible surge

For FB2316 KX surge site 10/event 3, the researcher states: **“i do not see a
surge here.”** No onset or offset is assigned. Record this as a negative
event-presence judgment for the displayed candidate, distinct from an
inability to choose precise timing. The saved surge detection remains intact.
No automatic exclusion, inferred mechanism or false-positive ground truth
was introduced. Verbatim feedback is in `feedback-06.json`.

Six fixed cases now have researcher feedback: five have timing annotations
and one is not identified as a visible surge. These are selected development
examples, not an accuracy denominator or independent validation set.

Next fixed example: local HP recording with provisional identity, sink
site 15/event 4. Its small native mask lies near the upper-right field edge;
craniotomy membership and physiological relevance remain unresolved.


## Researcher judgment for example 7: no distinct event

For the provisional HP recording, sink site 15/event 4, the researcher does
not identify a native event: **the brief, small decrease does not stand out
from the variability before and after it**. No onset or offset is assigned.
This stated temporal rationale is preserved separately from the unresolved
anatomical location near the upper-right image edge.

Local variability matters to event recognition, but this qualitative feedback
does not define a numerical threshold or justify a universal exclusion of
weak or brief events. Original native masks, labels and saved measurements
remain unchanged. Verbatim feedback is in `feedback-07.json`.

Seven new fixed cases have feedback: five with boundaries and two not
identified as distinct events. These selected examples are not an accuracy
denominator. Next: provisional HP surge site 6/event 3, with researcher
interpretation and boundaries pending.


## Researcher annotation for example 8

For the provisional HP recording, surge site 6/event 3, the researcher
explicitly recognizes a surge **from235 to356**. No additional boundary
uncertainty or causal rationale was supplied. Preserve the marks separately
from native detection248–389 and the censored positive-reference run231–419.
The marked sample times differ by121 seconds at external1Hz and include122
samples; the duration convention remains unresolved. No amplitude was
recomputed or production interval changed. Verbatim text is in `feedback-08.json`.

Eight new fixed examples have now received feedback: six with boundaries
and two without a recognizable event. The two earlier FB2314 site1 anchors
retain their existing annotations and uncertainty, without implying new
confirmation during this walkthrough.
