# Baseline sensitivity in the existing MATLAB review

R2-BASELINE-COMPARISON-037 handoff. **Proposed implementation scope; not implemented in this phase.** The scientific baseline choice remains open.

The controlled comparison supports making reference dependence visible to researchers. It does not justify applying a fitted line automatically. Build on the existing BOI event-review workflow and its saved original-source traces rather than introducing a separate analysis application.

1. Show the actual baseline samples, native footprint identity, baseline duration, measurement/native windows and original mean reference. Preserve the distinction between original-source measurement and normalized detection scores.
2. Provide an explicitly labeled diagnostic overlay for a line fitted only to the same clean baseline samples, with its extrapolation interval visible. A diagnostic must never overwrite the saved amplitude, event timing, statistics or measurement dictionary definition.
3. Make full-window and two-half slopes and raw variability inspectable alongside the trace. Do not label these as substrate kinetics or invent an automatic stable/unstable threshold. Show what the calculation used and why a diagnostic is unavailable when the existing baseline lacks required samples or yields an invalid reference; no earlier search or clipping.
4. If a diagnostic alternative amplitude is displayed or exported, identify its reference, units, calculation version and relation to the original result unmistakably. Preserve negative and unavailable values; distinguish machine-precision sign differences from a biological interpretation without introducing a hidden scientific cutoff.
5. Initially check the same three saved FB2314 audit cases and the existing missing-baseline fixtures. Verify that opening/exporting the diagnostic cannot change saved production measurements. Test evidence links and review reopening, then inspect the actual MATLAB display. Do not claim cross-mouse or independent usability validation from these implementation checks.

Before accepting a production baseline change, the researcher must be able to distinguish net local source change from deviation relative to an expected/shared signal and understand that a shared fluctuation can be biologically meaningful. Preserve that scientific question and the existing cohort scope.
