# Next bounded method: strict working-ROI support

R1-C02-ROI-RUN-031 handoff specification. **Proposed for implementation and
development comparison; not executed, adopted as a final method or validated.**
The user has accepted the displayed FB2314 outline as the working starting ROI.
The completed support-only arm supplies the comparator and demonstrates its
remaining exterior support. Exact surgical boundaries and other recordings' ROIs
remain separately reviewable.

## Proposed operations

| Stage | Restricted-support candidate | Kept fixed |
|---|---|---|
| Source and timing | Keep full original TIFF, native coordinates and a separate logical ROI; fail explicitly on unsupported input | External 1 Hz, all original frame indices, original quantitative intensities |
| Detection detrending | Existing per-pixel cubic detrending; exterior values must not influence interior calculations | Polynomial order and detection-source selection |
| Spatial normalization | For each frame, compute mean and sample SD from included ROI pixels only; retain the existing temporal z-score at each included pixel | Standardization sequence; constant signals must not create nonfinite candidates |
| Spatial smoothing | Normalize the same fixed kernel over included neighbors: conv(Z·ROI,K) / conv(ROI,K), evaluated only inside ROI | Kernel dimensions and subsequent temporal smoothing; save neighbor-weight map |
| Candidate thresholds | Compute each sign's existing percentile using eligible pixels only; intersect thresholded support with the sign-specific ROI **before** connected components and shape/size filtering | Percentiles, physical size/circularity/duration filters; current sink image-border rule remains separately explicit |
| Tracking and refinement | Operate on restricted native candidates; verify every final native pixel remains inside its sign support | Tracking/correlation/contact rules and native/refined timing definitions |
| Quantification | Fixed union of the new event's native pixels, all inside ROI; use original source values at those pixels | 20-sample clean pre-event baseline, both-sign overlap screening, NaN and signed values; no post-hoc clipping of an old trace |
| Exposure and summaries | Use recorded sign support and original modeled intervals; export the actual numerator/denominator and availability | Current descriptive formulas and uncertainty states |

Exterior computational fill values are not observations or valid zeros. Mask
support must govern every reduction and candidate operation; merely setting the
outside image to zero does not satisfy exterior independence. Near the ROI edge,
kernel renormalization changes effective neighborhood size. Retain its weight
map and assess edge behavior rather than adding an unrecorded erosion or coverage
cutoff. A region crossing the boundary can fragment when restricted before
components; preserve that geometry consequence and do not equate fragments with
independent biological events without evidence.

ROI-only spatial standardization can suppress a response shared across the ROI.
Its physiological implications are not settled by removal of exterior pixels.
Preserved-input traces and broad optical changes must remain inspectable, and
this candidate must not be described as a new absolute-oxygen estimator.

## Required implementation checks before a biological-source comparison

1. **Exterior independence:** changing finite values outside an unchanged ROI,
   including strong pulses/noise, leaves interior normalization, smoothing and
   candidates unchanged within stated numerical precision.
2. **Containment:** every detected/native/quantitative-footprint pixel is inside
   the recorded sign support, including after tracking/refinement. Require exact
   set containment, not a tolerance or expected event count.
3. **Known arithmetic:** independently calculated small ROI examples reproduce
   normalization and weighted smoothing. Constant interior data and zero-event
   cases remain well-defined; invalid/empty support is not a valid zero.
4. **Both signs and boundary behavior:** deterministic weak/strong, sustained,
   recurrent and boundary-crossing examples retain traceable source supports.
   These checks test implementation, not anatomical or physiological validity.
5. **Version and replay:** save an explicit method identity and effective support
   policy; update audit reconstruction and readable run definitions together.
   Prevent accidental mixing with the historical whole-image method. Preserve
   old outputs and provide the appropriate replay path for each version.

After these pass, specify one FB2314 awake development run against the saved 031
support-only arm, with the same working ROI, source and unchanged unrelated
settings. Compare native support, availability, source traces and resource use.
No count or treatment-effect target defines success. Numerical containment and
exterior independence are necessary implementation properties, not sufficient
scientific acceptance. Broader biological/acquisition variability, uncertain
boundaries, global responses and independent researcher usability remain in the
standing plan. Do not automatically expand to other animals or states.
