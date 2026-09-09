# Surge amplitude support and pre-event baseline

The normal amplitude is a preserved-input intensity change over a **fixed union
of one event's native masks**. It is not an average over an entire recurring site,
a brightest-pixel estimate, or a calibrated oxygen concentration. The reported
`EventArea_um2` is the mean native frame area; it is not necessarily the larger
union area used for the amplitude trace.

This validation-only comparison separates spatial averaging, imposed activity
in the pre-event reference, and underlying source fluctuations. It does not change
normal measurements or make missing amplitudes available. The
[completed results](reference-results/surge-amplitude-support-20260909/README.md)
show why onset/baseline validation must precede adoption of a tighter core.

## Fixed spatial supports

For each retained surge, compare three fixed sets of pixels over its existing
native event frames:

| Support | Definition |
| --- | --- |
| `full_event` | Union of all native masks for this event; current production definition |
| `persistent_50` | Pixels present in at least `ceil(0.50 * native frame count)` masks |
| `persistent_75` | Pixels present in at least `ceil(0.75 * native frame count)` masks |

The complete event mask defines the frame count, including the event's duration;
supports never follow a moving pixel subset during quantification. An empty core
is unavailable, with no fallback to another support. Occupancy thresholds were
fixed before reviewing results. Core selection does not rank raw intensity, but
the native masks still depend on the same recording: this does **not** eliminate
selection bias. Motion, growth, shrinkage and contacts can change the scientific
meaning of a persistent core.

The same full-event clean-baseline frame list is used for all three supports.
Both signs' retained event masks contribute to the exclusions. A smaller core
cannot recover a previously excluded baseline sample in this comparison. This
holds baseline availability constant while testing the spatial definition.

Each constructed movie also gets one `recipe_common_core_oracle`: pixels inside
the prescribed surge mask in **every** imposed frame. For these stationary,
growing/shrinking disks this is the 60-µm-radius central disk. It is determined
from the construction recipe, not the detector, and is not a deployable estimator.
It uses the entire known imposed window and a preceding twenty-frame reference,
with its own retained-event exclusions. Its tissue-eligible fraction is exposed;
it must not be assumed to lie entirely within eligible tissue.

## Exact paired-source decomposition

Let `X(t)` be the unmodified source mean on a fixed support and `Y(t)` the
constructed movie mean on exactly the same pixels. For the existing twenty-frame
native prebaseline, let `Bx = mean(X(pre))`, `By = mean(Y(pre))`, and
`c = (By - Bx) / Bx`. At the observed event peak `t* = argmax Y(native frames)`:

```text
Observed change       = (Y(t*) - By) / By
Counterfactual change = (Y(t*) - Bx) / Bx
Background component  = (X(t*) - Bx) / Bx
Applied component     = (Y(t*) - X(t*)) / Bx

Counterfactual change = Background component + Applied component
Observed change       = (Counterfactual change - c) / (1 + c)
Baseline effect       = Observed change - Counterfactual change
```

Components are evaluated at the **same observed peak frame**. Maxima of two
separate traces cannot generally be added or subtracted as if they occurred at
the same time. Baseline effects include the changed denominator, not just a
subtracted offset. Positive and negative imposed contributions are calculated
at the pixel level before spatial averaging and are retained separately.

The source recording `X` is only available because these events were constructed.
Its changing intensity can represent real activity or acquisition effects; it
is not automatically noise. The counterfactual removes the known imposed
contribution from the baseline while preserving the original source reference.
It does not establish a biologically quiescent baseline or isolate oxygen from
other influences. It cannot be applied directly to spontaneous events.

## Output meanings and missingness

- `StrictMeasuredPeakFraction` follows current prebaseline availability: a full
  twenty clean samples and positive baseline. `full_event` must reproduce the
  stored amplitude and status exactly. It remains NaN when the reference fails.
- `Unscreened*` fields are **diagnostics**, computed on a complete native prewindow
  even if detected activity makes that window unsuitable for reporting. They
  must never be pooled as rescued amplitudes. Truncated windows remain unavailable.
- `PeakPositiveAppliedVsSameFrameSource` is the largest ratio of spatially
  averaged positive imposed increments to the unmodified source intensity at
  that same frame, over the known imposed window. It quantifies how much of the
  prescribed optical increment that fixed support captures. It uses a different
  reference from the reported baseline amplitude.
- `PeakPositiveAppliedInNativeIntersection` restricts that diagnostic to the
  intersection of the native event and known imposed window. No temporal overlap
  gives NaN, not zero recovery. Negative/net contributions are separate fields;
  their extrema need not occur at the same frame and must not be added as peaks.
- `UnscreenedSourcePeakFraction` describes the largest source-only change over the
  same native frames and source baseline. It can reveal amplification of existing
  fluctuations when a tighter core is used, but is not a noise estimate.
- `EventRow` identifies a saved event within one movie; support rows are repeated
  measurements of it, not additional events. `EventRow = 0` is the recipe oracle,
  not an event. Session/case/event/support together identify a comparison row.

`BaselineStatus = valid` means the specified samples pass the implemented checks.
It does not establish absence of undetected rising activity, physiological
stationarity or freedom from drift.

## Validation protocol and reproduction

Audit all retained surges from the eight existing growing/shrinking challenge
movies: ID400, ID401 and FB2312 awake BOI references, plus the separately interpreted
FB2411 fluorescence control. Read their frozen historical master outputs without
upgrading their contracts or pooling them into current analyses. Reproduce every
stored full-event measurement using preserved pixels and both-sign exclusions.

Use the **previously selected** native spacetime-overlap match in each case for
targeted comparisons. Recheck the selection from masks; do not choose events by
which core produces the largest amplitude. Retain cases with no matched event.
All calculations use complete movies and their existing calibration.

```matlab
setupOxygenDynamicsPath; addpath('tests/analysis');
s=parallel.Settings; s.Pool.AutoCreate=false;
runSurgeAmplitudeSupportValidation(priorShapeRoot, newOutputRoot);
```

Independent verification requires NumPy, Pillow and h5py, run from the repository root:

```text
python -B -O tests/analysis/verify_surge_amplitude_support.py OUTPUT_ROOT
python -B -O -m unittest discover -s tests/analysis -p 'test_verify_surge_amplitude_support.py' -v
```

The verifier rebuilds occupancy/oracle supports, shared baseline exclusions,
pixel means and signed increments from the source and constructed TIFFs. It
independently checks the decomposition and missingness. This verifies numerical
measurement, not independent segmentation or physiological accuracy.

Next develop and test a bounded event-local onset/reference rule on these known
rises and unchanged controls. Do not select the lowest preceding intensity merely
to increase amplitude. Preserve unresolved onset and unavailable baseline states.
Only then decide whether a persistent-core measurement is justified as a distinct
endpoint. Explicitly exporting the actual amplitude averaging area would also
help distinguish it from native event morphology.
