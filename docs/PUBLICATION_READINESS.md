# Publication readiness: existing V2 analysis

The target is a single reanalyzed cohort using a frozen, reliable pipeline. Backwards compatibility is not a requirement. The alternative detector is maintained separately. Passing numerical tests or processing an unlabelled movie does not establish biological detection accuracy.

## Immediate next investigation

The existing surge path now uses a physical area cutoff, adjacent-frame tracking
with bounded isolated shape continuity, explicit recurring sites and a separate
ledger of short rejected candidates. Missing frames are never automatically
bridged. The same twenty full-movie reference inputs are used to compare each
tracking revision; see [current rules and validation](SURGE_TRACKING.md).

Remaining surge signal-definition work has priority over count-based threshold
tuning: native threshold bounds can truncate a smooth rise, contaminate its
pre-event baseline and dilute amplitude when a moving event is averaged across
its fixed union footprint. Determine onset/recovery and measurement-support
behavior with known stationary, growing and moving signals before declaring a
publication endpoint. Rejected-candidate QC localizes gaps without establishing
whether they are detection dropouts or real returns.

The sink timing search already uses an [event-local rule](LOCAL_SINK_TIMING.md)
with disjoint searches, a provisional 20-second bound and unresolved-boundary
flags. Timing sensitivity and raw-versus-normalized sign changes remain relevant
for both signs. Surge-specific experimental-baseline contrasts and equal-mouse
summaries still need implementation after the event measurement definition is
settled. Archived intensity preparation and physical scaling of smoothing also
remain unresolved before cross-acquisition comparisons.

## Work in dependency order

| Priority | Work | Dependency / completion criterion |
|---|---|---|
| 1 | Establish calculation and provenance contracts | Implemented development boundary: correct temporal SD; distinct events/sites/recordings; source checksums; strict baseline/missingness rules. Finish audit of remaining historical column names and units. |
| 2 | Run archived biological references | Eight complete recordings passed master/statistics under an earlier contract. Current surge continuity validation covers twenty master runs on four sources plus synthetic master/statistics integration. Event/site counts and amplitude availability remain separate; the broader cohort must be rerun under the final contract. |
| 3 | Expand reference coverage | All 87 archive assets inventoried; eight complete recordings from six animals cover two paired awake/isoflurane cases, finer sampling, KX, awake-mobile and a separate fluorescence control. Four metadata mappings remain unresolved. Intensity preprocessing remains incompletely established; do not pool acquisitions on that assumption. |
| 4 | Test existing-detector sensitivity to settings | After reproducible runtime, vary thresholds, smoothing, duration and correlation rejection in controlled runs. Record changed event identities, timing, masks and measurement availability. Review physical units across pixel sizes and sampling rates. Do not tune merely to reproduce old counts. |
| 5 | Assess recovery and failure modes without exhaustive labels | Use known-signal injections and controlled perturbations across sink/surge amplitudes, durations, sizes, overlap and background conditions. Optional targeted blinded inspection may resolve specific failures. Reviewing candidates alone cannot estimate missed events. |
| 6 | Resolve ambiguity and freeze detection rules | Keep evaluation recordings separate from tuning recordings. If annotations are collected, record criteria and reviewer uncertainty. Otherwise leave biological accuracy unestablished and freeze rules against documented numerical, simulation and robustness criteria. |
| 7 | Finalize publication statistics | Prespecify outcomes, baseline windows and exclusions. Separate optical amplitude from oxygen concentration. Choose inferential models appropriate to animals, repeated recordings and conditions; existing equal-mouse summaries are descriptive, not a complete inference plan. Check equivalent sink/surge coverage. |
| 8 | Freeze and reanalyze | Save code revision, contract, parameters, environment/toolboxes, input hashes and curation decisions. Rerun the complete cohort under that release. Require QC and exclusion reports before biological effect interpretation. |

## Validation when exhaustive manual labels are infeasible

Exhaustive manual event labeling is not a prerequisite for continued engineering.
Prioritize deterministic reruns, known-signal synthetic tests, injection/recovery
experiments on archived backgrounds, and controlled perturbations of thresholds,
noise, gain, smoothing and sampling. Quantify stability of event identities,
timing, masks, amplitude availability and recording summaries. Synthetic recovery
measures performance for the injected signal model, not all biological events.
Negative controls and surrogate movies require separate interpretation: they can
still contain real fluctuations or introduce artificial temporal structure.

A small blinded spot review may help resolve a specific failure, but is optional
and should not be presented as unbiased ground truth. If no independent labels
are collected, report detection accuracy as unestablished and describe the
numerical, simulation, control and robustness evidence instead. Stability alone
cannot prove that detected events correspond to oxygen changes.

## First pinned reference

- Published release: [DANDI 000891, version 0.240215.0831](https://doi.org/10.48324/dandi.000891/0.240215.0831).
- Asset: `8ba82dc1-aaba-411d-a196-ff8ef0b61fc3`, `sub-ID400/sub-ID400_ses-M400-01-baseline-awake_image.nwb`.
- SHA-256: `dbdb847b52a501eaf826b191f0affb2bcfc7078c95cddf035aa785e1aac3b23f`.
- Series: `/acquisition/1hz_mcor.tif`; 600 frames, 512 × 512, 1 Hz, metadata states 4.75 µm/pixel.
- Archived series indicates motion correction. It must not be presented as untouched camera data. The intensity-unit attribute is insufficient to establish camera units; the reference runner preserves the archived integer values without rescaling.
- This is a reference recording from one animal, with no manually reviewed sink/surge labels. Runtime, reproducibility, numerical consistency and parameter stability can be assessed. Sensitivity, specificity and false-negative rate remain unestablished.

## Outstanding engineering details

Site recurrence now uses explicit events/minute columns for both signs; recording-level measurement-availability tables expose missing amplitudes. Some low-level helper conventions remain historical even though old saved analyses are rejected. Current development contract identities are maintained manually; archive the actual code revision at release. Sampling-rate and pixel-size changes require a physical-units audit of detector smoothing. Correcting SD normalization changes score distributions, so existing default thresholds are provisional. The new window/composite outputs currently cover sinks; equivalent surge recording/window outputs remain to be specified.
