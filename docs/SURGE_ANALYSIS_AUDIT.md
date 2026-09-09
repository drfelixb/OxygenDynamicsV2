# Surge detection and analysis audit

This audit distinguishes the final preserved-input measurements from intermediate
V2 calculations and from scientific validation of the detector. The priorities
below reflect consequences for interpretation; dependencies are explicit.

## 1. Primary surge amplitude versus an obsolete secondary ratio — corrected

The authoritative exported surge amplitude was already computed by the shared
`finalizeOxygenEventMeasurements`: average preserved-input pixels over the
individual event's fixed footprint, then take the maximum fractional change
within its event bounds relative to a complete clean pre-event baseline.
`NormOxySurgeAmp = max((trace - B0)/B0)` and its percent column is 100 times that
fraction. A value of 0.2 means a 20% optical increase; a negative value is retained.
This is not calibrated oxygen concentration. Event footprints, native geometry,
both-sign baseline exclusion and recording-aware identities already applied to
both sinks and surges.

However, the BOI surge collator still first calculated a ratio of mean z-scored
site traces, could use a post-event baseline, and applied an absolute value.
The finalizer overwrote the primary amplitude correctly, but copied that obsolete
value into `SiteTraceAmplitude`, which was also exported. Ratios of centered
scores have no appropriate relative-intensity interpretation and can be unstable
near a zero denominator.

The BOI collator now supplies native bounds and unavailable amplitude placeholders;
only the shared raw-footprint finalizer populates the actual amplitudes. The
secondary `SiteTraceAmplitude` column is removed for both BOI event signs to avoid
mixed measurement definitions. The separate iOS ratio helper has an explicitly
iOS name and is no longer part of BOI event construction. The primary raw-amplitude
formula itself is unchanged. Unit tests cover signed increases/decreases,
contaminated baselines and refusal of a post-event fallback.

**Dependency:** numerical correctness does not guarantee that the detected bounds
or footprint describe the whole physiological event. A clean/valid baseline
means no *detected* overlapping event, not proof of no underlying signal change.
With native surge onset delayed by threshold crossing, a smooth undetected rise
can already contribute to the pre-event baseline and attenuate the measured
fractional amplitude. An independent arithmetic match cannot rule this out.

## 2. A final valid event could never be seeded — corrected for both signs

Both trackers stopped seeding at `N - minimumDuration`, excluding a run that
starts at the last position with enough frames remaining. They now include
`N - ceil(minimumDuration) + 1`. The ceiling respects fractional-frequency
minimum durations. Tests cover exact minimum-length terminal runs and a recording
whose entire length equals the minimum duration. The existing surge matching
order/rule is otherwise unchanged. The shared tracker correction also applies
to the separate iOS callers.

**Dependency:** terminal native bounds indicate possible acquisition truncation;
a detected last-frame event is not proof that its physiological end was observed.

## 3. Surge timing and recurrence were less explicit — status added, timing unresolved scientifically

Sinks refine bounds using a filtered site trace, fitted trend and bounded return
search. Surges retain native threshold-mask bounds. The update exports
`NativeStartFrame`, `NativeEndFrame`, `TimingMethod = native_mask_bounds_not_refined`,
and flags for touching the recording start/end. It does not invent a resolved
physiological boundary status. QC therefore continues to count surge timing as
not assessed.

The same native-gap annotation is now available for both signs (within each final
site and recording), with separate 20-second development review settings. Surge
runs were not subject to the removed sink-spacing deletion, so this annotation
does not itself add or remove surge detections. Both members of a close pair are
flagged; noise fragmentation remains possible. Recurrence assessment is now
reported for surges rather than being entirely unassessed.

**Dependency:** amplitude extrema and duration are measured inside these native
surge bounds. Smooth tails, delayed threshold crossings and split masks can alter
the measurement even when its arithmetic is correct. Copying the sink polynomial
boundary rule to surges without validation is not justified by symmetry alone.

## 4. Important detection asymmetries remain — not tuned in this update

| Rule | Sinks | Surges | Consequence |
|---|---|---|---|
| Frame threshold | Darkest 1% of clipped field | Brightest 10% of full field | Different pixel budgets and context sensitivity |
| Minimum region size | 100 pixels | 400 pixels | Physical size cutoff changes with pixel calibration |
| Maximum region size | 6,400 pixels | None | Different spatial population admitted |
| Minimum native duration | 3 seconds | 10 seconds | Short surges are excluded by design |
| Maximum native duration | 150 seconds | None | Long components are treated differently |
| Tracking overlap | >60% of current union or candidate | >390 pixels with the original seed at defaults | Small or moving surge regions can fragment or disappear |
| Correlation processing | Three site merge/rejection passes | None | Not equivalent noise handling |
| Detection border | 20 pixels removed | Full field | Different edge-artifact exposure |

For a 400-pixel square, a one-pixel translation leaves 380 overlapping pixels,
below the required >390. The fixed surge rule thus demands almost complete
spatial overlap for its smallest allowed regions. A large surge has a much more
permissive relative-overlap requirement. The fixed initial seed also limits drift.
An isolated 12-frame candidate-mask diagnostic confirms this: the stationary
400-pixel square produces one retained surge; translating it one pixel per frame
produces zero. The sink tracker retains one run in both cases. These are
prescribed candidate masks, not an end-to-end noise model or a biological
sensitivity estimate. This identifies a specific tracking limitation; it does
not establish that all retained surges are false or select a replacement rule.

Both signs still use frame spatial normalization followed by temporal SD
normalization. Their labels describe relative processed contrast; a local signal
can become relatively brighter while its preserved intensity decreases. The
prior cropped less-dimmed-patch result did not reproduce on the full recording.
No detector accuracy or robustness across acquisition contexts follows from that
single example.

**Dependency:** these detection choices must be tested on smooth/moving/noisy
signals and multiple source backgrounds before calibrating event rates or imposing
symmetrical defaults. Area cutoffs are currently pixel-based, not fixed physical
areas. The smooth challenges use 4.75 and 6.75 µm/pixel. A separate unchanged
FB2312 recording at 2.35 µm/pixel receives an amplitude audit; that does not
provide a smooth/moving-signal sensitivity test at this finer calibration.

## 5. Experimental-baseline and group statistics are not at parity — still missing

Surge events, native occupied area traces, site-level summaries and per-site
recurrence in events/minute are exported. `MeanOxySurgeEvent_NormAmp` is a site's
mean of available event amplitudes, not a mouse-level treatment effect. Grouped
surge metric sheets place site values under mouse columns; this does not compute
equal-weight recording-then-mouse averages.

The newer `RecordingWindowMetrics`, paired experimental-baseline contrasts and
hypoxic burden/mouse summaries are still called with sink tables. They do not
provide corresponding surge-specific recording/window contrasts or an equivalent
mouse-level surge summary. This must not be confused with the per-event pre-event
baseline, which already works for surges.

**Dependency:** define explicit surge recording/window metrics and missingness
rules, then export paired contrasts and mouse summaries. Do not rename hypoxic
burden as a calibrated hyperoxic quantity. Native-run versus physiological-event
uncertainty remains relevant to any count comparison.

## Validation and migration

The source-locked smooth-signal runner uses complete ID400 awake, ID401 awake,
and FB2411 fluorescence-control movies. Four inputs per source are paired control,
smooth pairs with 5/15/30 empty-second gaps, a single clean smooth pulse, and the
same single pulse plus recorded Gaussian intensity perturbations. Both signs
are injected at separate fixed sites with 85.5-µm radii. No noise amplitude or
detection threshold is tuned to the outcome; the noise is not a calibrated
photon-noise model. All native events receive an independent raw-footprint
amplitude/baseline audit. Control movies are scored in the same target windows.

The [saved results](reference-results/smooth-surge-audit-20260909/README.md)
contain 1,549 audited events across the twelve challenges and 424 in the unchanged
FB2312 rerun, with zero numerical/status mismatches. Of FB2312's 58 surge runs,
28 have finite amplitudes and two of those are negative in preserved intensity.
These signs are retained and flagged, not repaired with an absolute value.
Smooth sink pairs intersect detections in 6/6 imposed windows on each background;
surge pairs intersect 3/6 on each BOI background and 0/6 on the fluorescence
background. Intersection is not an accuracy criterion. Surge detection and
physiological timing remain insufficiently validated despite arithmetic agreement.

**Recommended order:** first test a physical-size-aware, fractional-overlap surge
tracking correction against the fixed motion/size challenges and full backgrounds;
then evaluate surge timing and baseline contamination with smooth signals. Add
explicit surge recording/window contrasts and equal-mouse summaries with these
measurement limitations carried into QC. No inferred oxygen concentration or
confirmed biological event count should be substituted for optical measurements.

The detector contract is now `existing-v2-retain-close-terminal-3`, measurement
`event-footprint-sign-qc-4`, statistics `mouse-strict-sign-qc-5`. Earlier saved
masters must be reanalyzed before pooling. Historical reports retain their
original contract identities and are not current reruns.
