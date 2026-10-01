# Why the three source signs and detector labels disagree

**R2-C02-NORMALIZATION-034 — mechanism audit complete; physiological acceptance
remains open.** The ROI-wide reference dominates the local residual at the
strongest native frames of all three inspected events. Subtracting that reference
changes the direction of the relative spatial score compared with raw change
from the event baseline. The signed source amplitudes remain numerically correct.

This audit uses the unchanged [033 results](../boi-c02-strict-roi-20260912/README.md):
FB2314 awake, the same full source and working ROI, all three signed disagreements,
their original native and measurement windows, and their original 20 clean
baseline frames. No detector/statistics rerun, mask edit, parameter change,
baseline replacement or cohort expansion occurred. Timing remains the externally
triggered 1 Hz grid; camera exposure and physiological validity are separate.

## What the calculations show

At each event's **strongest mean filtered score over its saved native pixels**:

| Event / original frame | Local raw change | Local residual change | ROI residual change | Spatial-score change | Temporal-score change |
|---|---:|---:|---:|---:|---:|
| Sink 10/1 / 69 | +4.712% | −18.11 input units | +268.63 input units | **−0.5584** | −0.9906 |
| Surge 1/3 / 508 | −9.165% | −173.67 input units | −377.14 input units | **+0.3328** | +0.6612 |
| Surge 1/4 / 545 | −7.370% | −124.44 input units | −340.86 input units | **+0.3227** | +0.6148 |

Every change uses the same event's original clean baseline. Native anchor frames
were selected by the rule fixed before reconstruction. The independent second
anchor is the saved raw-amplitude extreme; both anchors and all 1200 frames are
exported in [anchor arithmetic](anchor-decomposition.csv) and the case folders.

For the sink, raw intensity is above baseline, but removing its rising fitted
trend produces a residual decline. The ROI residual rises much more than that
local residual, pushing the spatial score further negative. The measured source
minimum is at frame 73: raw change +4.70 units, removed-trend change +90.45 units,
residual change −85.74 units. Frame 73 is inside the refined measurement window
but outside the native run; it must not be interpreted as a native threshold
crossing. The stored sink amplitude remains **−0.395%**.

For both surges, the local residual falls, but the ROI residual falls farther
in absolute intensity units. Subtracting the ROI reference therefore produces
a positive local spatial-score change. At frame 508, surge 1/3's raw footprint
falls **9.165%**, while the raw ROI mean falls **9.130%**. Their baselines differ:
1998.34 versus 4453.36 input units. Nearly equal fractional decreases coexist
with a positive normalized local score. This suggests sensitivity to shared
changes and baseline brightness; a controlled challenge is needed to isolate
those effects. It does not prove a local physiological increase.

The frame-dependent spatial SD partly offsets the reference contribution at
these strongest-native anchors. Temporal normalization strengthens the score
changes, but the direction disagreement already exists after spatial
normalization. Neither stage is treated as an absolute oxygen measurement.
[Compact numerical summary](mechanism-summary.json).

![Surge 1/3: unchanged source and exact normalization contributions](surge-site1-event3/decomposition.png)

## Exact decomposition

Let `r(t)` be the event-footprint source mean and `h(t)` its effective removed
per-pixel cubic trend, so `d(t)=r(t)-h(t)`. Let `m(t)` and `s(t)` be the ROI mean
and sample SD of the detrended input. The footprint's spatial-score mean is

```text
a(t) = [d(t) - m(t)] / s(t)
```

For the original clean baseline frames `B`, define `Δx(t)=x(t)-mean_B(x)` and
`sB=mean_B(s)`. This is an accounting reference, not a replacement normalization
or baseline. The exact identity is

```text
Δa(t) = Δd(t)/sB - Δm(t)/sB
        + Δ{[d(t)-m(t)] × [1/s(t)-1/sB]}
```

Thus at the strongest native anchors:

| Event | Local residual term | Minus ROI residual term | Variable-SD correction | Sum |
|---|---:|---:|---:|---:|
| Sink 10/1 | −0.03683 | **−0.54613** | +0.02454 | −0.55842 |
| Surge 1/3 | −0.28645 | **+0.62207** | −0.00285 | +0.33276 |
| Surge 1/4 | −0.21115 | **+0.57836** | −0.04452 | +0.32269 |

The CSVs further split local and ROI residual terms into their original-source
and removed-trend contributions, giving five terms. The effective removed
trend is defined as source minus the actual saved-precision residual, so
floating-point residual precision is included rather than hidden. The terms
sum exactly; their attribution depends on the explicitly defined `sB` reference
and is not a unique physiological causal decomposition.

Temporal normalization is performed per pixel, then averaged over the footprint.
It therefore reweights pixels by their full-record spatial-score SD. The audit
retains every footprint pixel's temporal mean and SD and verifies the weighted
identity, including its centering offset. It does not incorrectly compute a
single temporal z-score of an averaged footprint trace.

The detector uses sign-specific percentiles at each frame, not a mean-score
zero crossing. All **193,344/193,344** saved native pixel-time samples satisfy
the implemented sign-specific percentile rule: 1618 sink samples, 88,205 surge
1/3 samples and 103,521 surge 1/4 samples. This checks membership of already saved
native pixels; it is not another component/tracking or event-detection run.

## What this means for interpretation

The current detector uses spatial deviation from the contemporaneous ROI,
followed by per-pixel temporal normalization. The exported amplitude uses original
intensity relative to the event's measured pre-event baseline. These quantities
can disagree in sign even with correct computation and complete ROI containment.
The audit explains that arithmetic disagreement; it does not establish which
representation answers the physiological question or justify relabelling an event.

The sink still touches an uncertain upper anatomical boundary. The two surges
still involve a dark internal band and touch the working boundary. No internal
dark region was removed, and no boundary was eroded to remove the disagreements.
Biological variability, anatomical validity, shared/global optical responses,
local physiological relevance, baseline meaning, timing and exposure remain
standing questions. The previously established experimental state is distinct
from the measured event-local baseline used here.

## Evidence and reproducibility

- One MATLAB reconstruction reproduces the saved detrended and filtered traces
  exactly for these footprints. Maximum spatial/temporal mean-score difference
  from the saved single-precision audit is **5.1×10⁻⁹**.
- [Independent Python verification](verification.json) replays all 3600 case-frame
  arithmetic rows, 1200 ROI source means, 3600 footprint source means, temporal
  weights and six anchor rows. Spatial decomposition discrepancy is below
  **4×10⁻¹⁴**. MATLAB reconstructs per-pixel detrending, smoothing and actual native
  percentile membership; Python does not claim an independent detector replay.
- All three decomposition panels were visually inspected. [Sink](sink-site10-event1/decomposition.png),
  [surge 1/3](surge-site1-event3/decomposition.png),
  [surge 1/4](surge-site1-event4/decomposition.png).
- All 467 MATLAB implementation files and all 227 sealed 033 artifacts were
  verified unchanged before standing-document updates. Original source and
  prior outputs remain preserved. [Preservation record](preservation.json).
- MATLAB audit time **34.92 s**, process time **43.89 s**, peak RSS **14.15 GiB**,
  two thread workers, no source copy. [Resource record](resource-summary.json).

Each case folder contains `decomposition.csv`, `pixel-normalization.csv`,
`summary.json` and the plotted decomposition. [ROI reference](roi-reference.csv)
retains full-record raw mean, removed trend, residual mean, sample SD and both
sign thresholds. The local evidence root is
`workspace/reference-validation/boi-c02-normalization-audit-20260912`; it retains
the executed script, prespecification, logs, verification and artifact hashes.

## Next bounded challenge

The [fixed challenge specification](next-challenge-specification.md) separates
shared additive and multiplicative changes from known local changes, with
heterogeneous baseline brightness and matched noise controls. It is specified
but not executed here. Its purpose is to test the proposed mechanism before
choosing a normalization change. No new biological recording or final scientific
acceptance criterion is introduced by this audit.
