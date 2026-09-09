# Publication readiness: existing V2 analysis

The target is a single reanalyzed cohort using a frozen, reliable pipeline. Backwards compatibility is not a requirement. The alternative detector is maintained separately. Passing numerical tests or processing an unlabelled movie does not establish biological detection accuracy.

## Immediate next investigation

The existing surge path now uses a physical area cutoff, adjacent-frame tracking
with bounded isolated shape continuity, explicit recurring sites and a separate
ledger of short rejected candidates. Missing frames are never automatically
bridged. The same twenty full-movie reference inputs are used to compare each
tracking revision; see [current rules and validation](SURGE_TRACKING.md).

The [full-movie signal evidence](SURGE_SIGNAL_EVIDENCE.md) now reproduces an
ID401 missed pulse with 14 consecutive accepted-pixel frames split into two
seven-frame runs. Eight growing/shrinking challenges show partial detection,
large-footprint dilution and undetected rising tails in nominally valid
baselines. The three BOI sources and separate fluorescence control are the same
recordings as before, not an independent held-out cohort.

The [split/merge comparison](SURGE_BRANCH_POLICY.md) now tests four linking
policies with controlled contact/identity scenarios and six complete movie
replays. Majority linking recovers the selected missed pulse, but can mix source
identity through contact; the current primary rule can also do this. Stopping
all contacts reduces retained support. None of these diagnostic policy changes
has been promoted to production.

The [contact records](SURGE_CONTACT_PROVENANCE.md) are now integrated into normal
master and statistics outputs, including rejected siblings, unique contact
frames, native-event exposure and explicit assessment coverage. Tracking,
amplitude and baseline rules remain unchanged; output contracts advance so old
analyses cannot be silently treated as contact-free.

The [local candidate-separation experiment](SURGE_CONTACT_SEPARATION.md) tests
persistent resolved peaks within accepted regions against stationary, approaching
and crossing Gaussian pairs, single expanding profiles and unchanged controls.
Stationary-pair improvements in ID400/ID401 do not generalize to all tested
geometries or the finer-resolution source. The prototype remains validation-only;
contact provenance remains necessary. See the
[full comparison](reference-results/surge-separation-20260909/README.md).

The [paired-source amplitude audit](SURGE_AMPLITUDE_SUPPORT.md) now compares full
footprints with fixed 50%/75% occupancy cores, using identical baseline exclusions.
All 228 stored amplitudes/statuses reproduce exactly. Smaller supports improve
imposed-signal capture but can also increase baseline contamination: in one
FB2312 matched core, the known rising phase raises the prebaseline by 12.43% and
reduces the baseline-referenced peak by 14.29 percentage points relative to its
paired-source diagnostic. Source fluctuations remain a separate contribution.
These diagnostics do not provide a correction for spontaneous events.

Next develop and test a bounded event-local onset/reference procedure, beginning
with the current full-event spatial support. Screen positive-recovery locations
for tissue eligibility before signal construction; keep admission-failure tests
separate. Compare estimated onset and baseline bias against known imposed starts,
and monitor unjustified early shifts on unchanged controls. Preserve uncertain
onset and unavailable-baseline states. Then repeat with candidate cores before
choosing a new endpoint. Statistical surge parity and final cohort reanalysis
follow those definitions.

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
