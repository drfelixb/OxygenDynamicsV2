# Reviewed optical calculation preview

15 September 2026. **R2-REVIEWED-OPTICAL-PREVIEW-068** — implementation and
verification complete. These new quantities are exploratory optical results,
kept separately from original measurements. No global scientific adoption.

Open the fresh MATLAB reviewer with all four accepted references loaded:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-reviewed-optical-preview-20260915');
[Fig,UI] = openReviewedOpticalExample;
```

The launcher checks ten source/definition hashes, loads boundary revision 05,
both matching native masters and the four reference judgments, then opens
row 321 in **Reviewed optical**. Earlier figures and launchers are preserved;
already-open figures keep their old callbacks. Select another row through
`UI.Select(row)`. The interval selector labels only saved preferences; its
initial display of recovery 1166 is not a preferred recovery judgment.

The upper plot shows the actual measurement source: preserved-input mean on
the original fixed native-event union. Blue samples are the exact accepted
reference, and B is their arithmetic mean. The lower plot shows signed percent
change on the inclusive reviewed interval. Use View corrected timing to return
to the researcher's primary visual-review trace. The table shows both signed
extrema, the separately named saved-sign directional amplitude, signed integral
and explicit numerical status. Original automatic results and uncertain
recognition remain visible. No detector sign, native pixel, correction,
boundary or reference judgment is changed.

Current verified results are in `verified/` (not the older `real-01/` or
`final/` display passes, which are preserved):

| Row | Reviewed interval | Reference samples | B (input units) | Signed minimum (%) | Signed maximum (%) | Signed integral (fraction s) |
|---|---|---:|---:|---:|---:|---:|
| 186 | 1154–1166 | 20 | 3791.76523 | −17.70581 | −0.08680 | −1.12885 |
| 186 | 1154–1167 | 20 | 3791.76523 | −17.70581 | +2.46570 | −1.10419 |
| 309 | 536–556 | 20 | 1866.53080 | −8.36339 | +1.01956 | −0.72681 |
| 308 | 496–516 | 20 | 2006.22592 | −9.52179 | +1.07786 | −0.88318 |
| 321 | 177–195 | 12 | 5137.82557 | −14.16810 | +6.02087 | −0.96080 |

The two remaining combinations, 1149–1166 and 1149–1167, have no accepted
reference and remain unavailable. Native-eligible counts within the accepted
selections are 14, 20, 20 and 0 for rows 186, 309, 308 and 321 respectively.
All selected frames remain included. The shorter reference has 12 samples;
it does not meet or redefine the original 20-sample rule. The saved-surge
convention reports the upper extreme, so its positive value is not the pocket's
negative signed minimum. Both remain explicitly visible. No absolute value,
sign clipping, biological relabeling or oxygen-concentration interpretation
is applied. Both sink offset alternatives remain intact.

`computeBOIReviewedOpticalInterval` implements exact selected-reference
arithmetic and numerical guards. `getBOIReviewedOpticalDefinition` binds the
exact proposed contract/dictionary 0.1.0-draft. `buildBOIReviewedOpticalPreview`
revalidates evidence and enumerates saved alternatives. The UI uses
`createBOIReviewedOpticalPanel`. Missing native sources withhold the preview
until complete support association is established; missing accepted reference,
nonfinite reference samples, nonpositive/nonfinite B, missing event samples or
nonfinite derived arithmetic withhold dependent quantities. Valid B remains
available when event samples are missing. Timing is independent of reference
availability. In an unavailable view, the actual frame range remains visible
and there is no zero trace. All tied extrema are retained without interpolation.

Export schema 9 adds ReviewedOpticalPreview.json, a separate MAT variable of
the same name, interval/sample CSVs, supplemental definition documents and
ReviewedOpticalMethods.txt. Exact raw ingredients, numerator/denominator,
reference membership, fixed pixels, acquisition evidence/QC, original results,
judgments, alternatives/preferences and source/software/definition hashes
accompany the result. Original Data matches the earlier phase-066 MAT exports
exactly. Fractions, percentages and fraction-seconds are explicit. The embedded
contract retains its historical proposal status; ImplementationStatus separately
identifies this implemented preview. Production dictionary and pipeline
contract are unchanged. The reference-membership tab remains a separate view.

Verification: 46 regression tests passed. After display/provenance refinement,
eight arithmetic/integration checks passed, then two GUI/export checks passed
for the final unavailable-state display. The final real-data runner verified
all 346 native-event associations, seven intervals (five computed, two
unavailable), exact selected samples, original MAT Data equality and all 80
final export artifacts. Five final screenshots were visually inspected.
Numerical results are identical across the retained display passes. No failed
tests occurred. Tests cover both signs, negative directional values, extremum
ties, a 12-sample reference, rectangle integration, missing/nonpositive inputs,
nonfinite derived arithmetic, definition drift, stale judgments and GUI resets.

475 MATLAB files remain unchanged; five prior files changed with before bytes
preserved and five files were added (485 current). All 71 sealed phase-067
artifacts, actual boundary/reference judgments and source definitions remain
preserved. Local MAT files retain exact typed evidence; portable copies omit
MAT binaries and store runnable MATLAB source as .m.txt. Current runnable
launcher and verifier are in the local reference-validation folder.

Next: inspect the baseline mean and signed trace for 177–195, then assess
claim-specific interpretation. No cohort statistics, composites, automatic
measurement overwrite, new substrate model or scientific acceptance follows.
General reference duration/precision, event direction, physiology, anatomical
support, normalization and independent evaluation remain unresolved. The four
guided examples do not replace the wider 48-event timing challenge. BOI-only,
biological variability, physiological relevance, feasibility, usability and
traceability remain standing requirements.
