# Bounded BOI timing panel

13 September 2026 · R2-TIMING-PANEL-042

The development panel is selected and its saved inputs checked. It contains **48 unique events from four recordings**, with both signs retained. This phase freezes the comparison and verifies feasibility; it does not calculate new timing landmarks, establish physiological accuracy or change production methods.

## Recordings and selection

| Recording | Existing analysis context | Selected sinks / surges | Native duration range, samples | Saved amplitudes available / unavailable |
|---|---|---:|---:|---:|
| FB2314 awake | Reviewed restricted ROI; existing annotated examples | 5 / 7 | 1–41 | 4 / 8 |
| ID400 awake | Historical whole-field normalization; 4.75 µm/pixel | 6 / 6 | 3–81 | 6 / 6 |
| FB2316 KX | Historical whole-field normalization; 2.35 µm/pixel | 6 / 6 | 3–115 | 4 / 8 |
| HP_ECS_CSV2_identity_pending | Previously analyzed local acquisition; identity, preparation and anatomical support remain unresolved | 6 / 6 | 3–204 | 3 / 9 |

All four are already development-exposed. The HP label is a recording-specific provisional identity, not a fourth verified animal. This panel is a purposive engineering/scientific comparison, not a representative biological sample or condition contrast. Different tissue support and processing histories remain separate; no new ROI, corner crop or pooled estimate is introduced. Biological interpretation of the weak/strong and duration proxies remains open.

Before reading event tables for selection, `prespecification.json` froze four recordings and six slots per sign: nearest lower/upper quartile of absolute saved detector magnitude, shortest/longest native duration, limited baseline context, and closest same-site recurrence. Ties use site ID, event ID, then original audit row. The context slot maximizes overlap-excluded samples before minimizing clean samples. The recurrence slot chooses the later event in the smallest nonnegative inter-event gap. Duplicate selections retain both reasons without replacement. FB2314 surge site 1/events 3 and 4 are added as known researcher anchors. Fifty filled slots yield 48 unique events.

All events are named in [selected-events.csv](selected-events.csv); [selection.json](selection.json) retains every slot, tie outcome and source audit row. There was no selection on new timing agreement, desired amplitude direction or expected state effect. Thirty-one selected events have unavailable saved amplitudes because their pre-event context is insufficient; they remain included. Twenty-nine have saved baseline overlap and two meet acquisition boundaries. These are coverage facts from existing audits, not new timing results. Irregular morphology, spatial change and incomplete physiological recovery remain properties to inspect, not labels guaranteed by numerical selection.

## Frozen comparison

The next run will keep original quantitative source, existing cubic-corrected detection source, normalized detector traces, native masks and saved measurement boundaries separate. It will describe positive and negative connected corrected runs independently, rather than choosing a direction to agree with the detector label. Each is seeded at its finite native maximum/minimum when that sign exists. Disagreement, native sign interruptions and missing/censored recovery remain results.

Searches are bounded to 30 frames outside native support, acquisition edges and midpoint partitions to immediate same-site same-sign neighboring events. Those limits are inspection safeguards, not physiological duration cutoffs. Any alternative amplitude uses the same original footprint, current sign-specific formula and exactly 20 immediate pre-event samples, screened against saved native events of both signs. No shifted earlier search, shortened reference, post-event fallback or new decay fit is allowed. An absence of saved-mask overlap is not proof of biological quietness.

At external 1 Hz, sample-time separation and inclusive sample duration remain distinct. The researcher's approximate intervals and uncertainty are retained; they are not ground truth. No causal substrate interpretation is assigned to a recording-derived trend. Recordings can differ.

One diagnostic replay per recording is budgeted at at most 10 minutes each and 1 GiB total new evidence. Numerical source/support inconsistencies stop the affected recording, with a recorded reason. No automatic tuning or case substitution follows. Initial researcher review is limited to ten cases: the lower-quartile sink and limited-context surge from each recording, plus the two known annotations, deduplicated. [Review queue](initial-review-queue.json) records this selection before new timing outcomes. No immediate manual annotation is needed to complete this preparation.

## Feasibility and preservation

All 48 selected events have full-length saved original, cubic-corrected, normalized and filtered traces, native frames and footprints. The trace/header inventory took 2.93 seconds in MATLAB, excluding startup. ID400 has 600 samples; each other recording has 1,200. No new movie read or detector/statistics run was needed. Older ID400 and FB2316 audits do not contain the optional saved spatial-normalized trace; it will remain unavailable rather than being reconstructed silently.

The current GUI reviewer initially rejected a historical audit because its `AnalysisInfo` lacks `FrameSize`. The failed attempt is retained. Direct read-only association verifies dimensions from saved site tables and checks exact master/audit metadata equality, selected identities, saved measurements, native runs and union footprints. The old audits and reviewer are unchanged. This is a compatibility limitation for opening these historical audits directly in the current GUI; it is not evidence of a physiological failure.

Independent Python selection verification reproduces all 50 slots and checks 16 frozen input hashes and all 469 unchanged MATLAB implementation files. `preflight.json`, `native-associations.json`, `selection-verification.json` and `completion.json` record the precise completed checks. `inputs.json` binds audit and master snapshots now; those master checksums are not retrospectively attributed to old audit creation. The phase-041 artifact inventory is verified with phase-start copies for the standing documents subsequently appended here.

The portable packet contains internal research provenance, including local paths; it is not a public or de-identified release. Source movies and full MAT payloads remain in their existing locations. Saved code copies and the inventory support reproduction without replacing previous results.

## Decision

**Freeze this bounded development panel; retain production timing and correction.** New timing calculations are pending. BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements. The panel is not a cohort eligibility freeze, biological validation, or a completed independent researcher walkthrough.

Next: execute the frozen saved-trace/native-mask comparison, report per-recording results and missingness, and bring only the initial review queue forward for researcher interpretation. An inconclusive comparison defers a timing rule; it does not trigger an open-ended fit to these examples.

Source clarification from the completed association check: all four selected
audits used the original/raw input for detection; no denoised input was saved.
Thus the raw and corrected traces here share a source. Native association
verification took 1.83 seconds, excluding MATLAB startup.
