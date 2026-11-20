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
