# Researcher onset revision and baseline-frame judgment

15 September 2026. **R2-RESEARCHER-REFERENCE-FEEDBACK-061 — explicit feedback
saved and verified.** The researcher revised the preferred onset for sink
site 15/event 36 (audit row 186) from 1153 to **1154**, and explicitly included
**1152 and 1153** in the baseline. This is a researcher judgment transcribed
from the conversation, not a new GUI save or an automatic scientific inference.

The new immutable `BOI-researcher-review-05.json` preserves all four earlier
revision entries exactly and leaves their original files unchanged. Current onset
alternatives are 1149 and 1154, with 1154 preferred. The earlier alternative
1149 was not withdrawn and remains unresolved. Recovery stays 1166/1167 with
no preference; recognition remains uncertain. The previous intentional 1153
choice and its reason remain in revision 4 rather than being erased.

`researcher-feedback.json` preserves the original statement. The subsequent
answer “Include frame 1153 too” is preserved with the exact clarification
question in `researcher-frame-judgment.json`. That final record resolves the
initial pending clarification in the earlier `verification.json`; the latter
is retained as the completed boundary-save-stage evidence, not the final
baseline judgment.

For onset 1154, the proposed immediate 20-frame reference is **1134–1153**.
The unchanged native rule excludes 1148–1153, leaving 14/20. Applying only the
two explicit researcher inclusions in a separate membership diagnostic gives
**16/20**, with **1148–1151 still excluded and not adjudicated**. All candidate
input samples are finite. No baseline mean or reviewed amplitude is calculated.
These frame judgments apply only to this event/preferred onset; they do not
reject the contributing surge, change native masks, approve a global override
policy or imply that the four remaining frames were accepted.

`researcher-reference-membership.csv` retains native eligibility and the
explicit human inclusions in separate columns. The existing read-only MATLAB
preview still shows native-rule eligibility (14/20 for onset 1154); human
baseline-inclusion editing/overlays are not implemented in that tab. The
new boundary revision can be loaded in the already-open UI with:

```matlab
UI.LoadBoundaries(fullfile(fileparts(UI.CurrentReview().AuditPath),'BOI-researcher-review-05.json'));
UI.Select(186); UI.Tabs.SelectedTab = UI.ReferenceTab;
```

The baseline judgment is saved alongside this report, not represented as a
native-mask change in the preview. `native-rule-preview-revision-05` contains
the new source-bound export, actual annotation/history and original automatic
measurements. MATLAB verified the new history, preference, unmodified offsets,
reference frame set and 14/20 native count. A separate set-membership check
verified the two requested inclusions and 16/20 result. Original audit,
revision 4, masks, amplitudes, all 479 MATLAB files and all 339 sealed phase-060
artifacts remain preserved. No code or calculation policy changed.

Next is judgment of frames 1148–1151; the current evidence does not authorize
filling the remaining samples, using a partial reference, shifting the search,
or computing a reviewed amplitude. All standing BOI scope, biological
variability, physiological relevance, anatomy, feasibility, usability,
traceability and validation uncertainties remain in force.
