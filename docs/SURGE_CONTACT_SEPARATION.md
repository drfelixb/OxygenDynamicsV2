# Experimental separation within existing surge candidates

This experiment tests an additional operation on the existing detector's
accepted connected regions. It is **not enabled in the analysis pipeline**.
It does not replace thresholding, normalization, admission filters, tracking,
event duration qualification or recurring-site assignment. The alternative
detector remains separate.

## Prespecified rule

`tests/analysis/separateSurgeCandidateContacts.m` considers splitting a current
accepted region only when it overlaps exactly two preceding output regions:

1. Both preceding regions have at least three seconds of uninterrupted history
   under the existing adjacent-frame link rules. No missing frame is bridged.
2. Each preceding region has at least half its pixels inside the current region.
3. The strongest current intensity in each overlapping support provides a marker.
   Markers must be at least 107.2 µm apart (the equivalent-circle diameter of the
   existing 9,025 µm² minimum surge area).
4. After subtracting the minimum intensity within the parent region, the
   connecting saddle must be no higher than 80% of the weaker marker's height:
   `1 - saddle / weakerPeak >= 0.20`.
   Grayscale reconstruction measures the strongest connecting path. A plateau
   is not separated. These thresholds are development assumptions, not calibrated
   biological boundaries.
5. Binary geodesic distance assigns every parent pixel to one marker; ties go
   to the lower linear pixel index. Both children must be connected and pass
   the existing minimum-area, circularity and tissue-support filters.

The input is the existing smoothed detection signal. Every admitted pixel is
conserved exactly once, including in frames where separation is declined.
Ordering is deterministic. This is a forward, history-dependent proposal: it
cannot separate two sources that were never resolved, and may lose separation
when peaks fuse or the existing tracker fails to continue a child.

Partitioned frames remain explicitly recorded per candidate and retained run.
Splitting can remove contacts from the subsequent overlap graph; fewer such
contacts do not demonstrate less ambiguity or biological independence. The raw
candidate cache and native graph are retained alongside the partitioned graph.
A single spatially distributed process can produce the same two-lobed image as
two independent processes. This rule cannot distinguish those interpretations.

## Full-recording protocol

Use the same four development reference recordings: ID400 and ID401 awake
baseline, FB2312 awake baseline, and the separately interpreted FB2411
fluorescence control. Preserve complete images, frame counts and acquisition
calibrations. These are four sources, not twenty independent recordings.

For each source, evaluate its unchanged movie and four constructed challenges.
Run full existing detrending, tissue estimation, normalization, smoothing and
candidate detection independently on every movie, then compare native and
partitioned candidates with the same existing tracker. This experiment does
not rerun master/statistics or recalculate amplitudes.

At frames 101–180 add smooth Gaussian light profiles to the original intensity:
`source * (1 + sum(relative profiles))`, followed by uint16 rounding. No clipping
is allowed. Each Gaussian is truncated at three standard deviations. The temporal
envelope is `sin(pi*j/81)^2`, j=1…80. All spatial quantities below are in µm:

| Case | Prescribed geometry |
| --- | --- |
| Separate pair | Two stationary centers 320 apart; sigma 60; peak fractions 0.20 and 0.16 |
| Approach pair | Separation 320 → 120 → 320 with a squared-sine trajectory; same widths and fractions |
| Crossing pair | Centers travel past one another, exchanging positions across the same 320 span |
| Single expanding | One fixed center; sigma 40 → 90 → 40; peak fraction 0.20 |

The origin is the rounded image center. Positions, amplitudes, thresholds and
scoring are fixed before inspecting outcomes. Gaussian widths describe imposed
optical profiles; they are not estimates of depth, oxygen concentration or
physiological event size. Existing smoothing remains pixel-based and therefore
has different physical widths across acquisitions.

## Interpretation of scores

The comparison summary keeps counting units explicit:

- `CandidateRuns` includes short rejected runs; `RetainedRuns` counts runs passing
  the existing ten-second duration rule. Neither is a recurring-site/ROI count.
- `ContactRetainedRuns` counts retained runs with an overlap-graph contact.
  `PartitionExposedRetainedRuns` counts retained runs containing partitioned frames.
- `PartitionEventFrames` sums partitioned frames over retained runs. Two children
  present in the same frame contribute two event-frames, not one second of
  recording time.
- `ProposedParentSplits` counts successful parent-frame partition operations in
  the experimental pass. It is repeated on the native/partition summary rows
  to identify their shared comparison; the native method applies none of them.
  It is not a count of independent events or recurring sites.

For each prescribed source, sum its known pre-rounding added light inside each
retained native event mask over frames 101–180. Divide by that source's total
imposed light to obtain `RecipeMassCoverage`. Choose distinct retained runs for
the two source recipes to maximize their summed coverage. An unmatched source
has zero coverage; one merged run cannot receive credit for both sources.
Zero assigned coverage does not mean that the source's light was absent from
all detections: it may be inside the same merged run assigned to the other
source. The all-retained coverage column exposes this distinction. Candidate
run IDs are local to each movie/method; equal IDs across methods are not an
identity match.

`RecipeContributionFraction` is the assigned source's share of the **imposed**
light inside the selected event. It excludes underlying recording intensity;
it is not oxygen specificity or purity. Also report coverage across all retained
runs and the number individually covering at least 10% of one recipe (a descriptive
fragmentation count, not an acceptance threshold).

Score unchanged movies against each identical hypothetical recipe. Higher
challenge coverage alone does not establish better detection: native background
events may already occupy that space, normalization can change remote candidates,
and a partition may split one distributed event. No source count or score is a
manual physiological label. This development set is not a held-out accuracy test.

`verify_surge_separation.py` reconstructs all constructed movie pixels in Python,
checks source/input hashes and reference metadata, and independently checks
exported mass arithmetic and distinct-run optimal assignment. It reads the
MATLAB candidate/run masks to verify full-frame pixel conservation, retained-run
bounds and candidate membership, and independently recalculates imposed light
inside those saved masks. It does not independently segment the images. MATLAB
also asserts exact candidate pixel conservation on every frame and tests resolved
peaks, plateaus, history, gaps, child filters, ordering and the injection recipe.

## Reproduction

From the repository root in MATLAB:

```matlab
setupOxygenDynamicsPath; addpath('tests/analysis');
s=parallel.Settings; s.Pool.AutoCreate=false;
runSurgeSeparationValidation(referenceRoot, newOutputRoot);
```

The output directory must not exist. Python verification requires NumPy, Pillow and h5py:

```text
python -B tests/analysis/verify_surge_separation.py OUTPUT_ROOT
python -B -m unittest discover -s tests/analysis -p 'test_verify_surge_separation.py' -v
```

The [completed four-source comparison](reference-results/surge-separation-20260909/README.md)
shows stationary-pair benefits in ID400/ID401, unresolved approach/crossing cases
and no coverage gain in the finer source. The prototype remains experimental.
`trace_surge_separation.py OUTPUT_ROOT` exports the decision at each prescribed
peak location to distinguish admission/history limitations from saddle rejection.
