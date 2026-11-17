# Surge signal, region identity and baseline evidence

This investigation extends the **existing** analysis validation tools. The
production detector, measurements and statistics remain at commit `03bdce8`'s
contract; no thresholds were changed to improve challenge counts. The alternative
detector is separate. See the [complete experiment and results](reference-results/surge-shape-evidence-20260909/README.md).

Follow-up: the [split/merge policy comparison](SURGE_BRANCH_POLICY.md) recovers
the selected missed pulse but demonstrates identity mixing through contacts,
including under the current primary rule. Its six complete replays support
explicit contact provenance and further separation tests before changing the
production linking rule.

## What the new tools establish

`auditSurgeCandidateEvidence` follows a fixed union of each imposed signal's
pixels through preserved input, cubic detrending, frame-wise spatial SD
normalization, pixel-wise temporal SD normalization and smoothing. These columns
have different units and are not interchangeable amplitudes. Separate per-frame
columns count imposed pixels selected by the percentile rule, surviving region
filters and belonging to retained events.

The audit reconstructs area, circularity and tissue-exclusion decisions and
checks them against production candidates. An independent overlap calculation
explains candidate transitions using mutual coverage, smaller-region coverage,
area ratios, competing partners and actual run IDs. It includes short rejected
runs. Reconstructed final masks and candidate/gap ledgers must exactly match the
saved outputs. This reuses production preprocessing; it is a stage-localization
tool, not an independent biological detector.

The source movie provides a counterfactual available only for these imposed
signals: on identical pixels and frames, subtracting the unchanged source from
the challenged movie isolates the applied increment, including rounding. The
audit separately reports that increment in the native pre-event window and over
the event footprint. It does not assume that a 20% local imposed peak should
produce a 20% average over a larger detected region.

## Findings in dependency order

### 1. Establish spatial identity before relaxing continuity

In ID401's first smooth-pair window, the imposed pixels survive candidate
selection for 14 consecutive frames. At frames 50→51, the roughly 113,106 µm²
candidate splits into roughly 43,546 and 61,235 µm² components. All 1,009 imposed
pixels are in the latter component; the former contains none of this imposed
signal, but can contain fluctuations already present in the recording.

The signal-containing edge has mutual coverage 0.5286, smaller-region coverage
0.9764 and area ratio 1.8471. It fails the primary 0.6 rule and would satisfy the
shape limits, but the competing successor blocks the isolated fallback. The two
native runs, frames 44–50 and 51–57, are each seven seconds and both fail the
ten-second minimum. No empty frame separates them.

This is a region split/identity problem. Normalization did not erase this
particular imposed rise. Permitting this match requires an explicit policy for
which component continues an event and what happens to its sibling. Simply
removing the isolation safeguard is not justified: the original fluctuations
outside an injected circle are not known false events.

**Next correction to evaluate:** a separately tested split/merge policy within
the existing tracking path, with one-to-one pixel ownership, visible ambiguity
and sibling identities. Test single signals adjoining background activity,
two independent neighboring signals, true splits/merges and crossing/moving
signals before changing defaults. Candidate separation may be necessary before
tracking can assign meaningful individual-event identities.

### 2. Define the spatial amplitude endpoint

A detected region can contain substantial area outside the imposed patch. Its
fixed event-union footprint averages those pixels with the locally changing
pixels. Growth, shrinkage or motion changes how much of that footprint is
involved at any instant. A local injection coefficient, its averaged contribution
on the detected footprint and the total recorded change are three different
quantities.

The ID401 growing challenge illustrates this distinction: the reported peak is
about 11.2%, while the maximum applied increment on its detected event footprint
is about 4.5%, despite a local imposed peak near 20%. The reported quantity also
contains the original recording's changes and uses a different baseline. These
numbers cannot be interpreted as a direct 11.2/20 recovery fraction.

**Dependency:** decide whether the publication endpoint represents average
change across an event's full footprint, a stable local core, or changing active
pixels. The latter alternatives need tests for spatial selection bias, motion,
per-pixel baseline availability and empty cores. They must not silently replace
the existing fixed-footprint quantity while retaining its name.

### 3. Validate onset and baseline together

The native threshold onset can occur after a smooth rise has started. Baseline
checks exclude overlapping **detected** events and require enough finite,
positive-baseline observations. Undetected tails can remain in the pre-event
window. `BaselineStatus = valid` certifies these implemented conditions, not a
physiologically event-free baseline.

Counterfactual diagnostics measure the actual applied increment in the entire
native pre-event window, including frames that production may exclude. They are
not replacement amplitude calculations. For a production-valid baseline the
whole required window passes, so a nonzero imposed increment directly documents
a known tail admitted into that baseline. For an unavailable baseline it
explains the surrounding signal without claiming a usable measurement.

**Dependency:** use the agreed spatial support, then evaluate event-local onset
and recovery searches with explicit bounds, neighboring-event limits and
unresolved states. Separate onset changes from baseline estimation and keep
missing amplitudes unavailable. Larger search windows or relaxing missingness
cannot be justified merely by producing more finite amplitudes.

### 4. Keep normalized contrast separate from optical baseline change

The implemented SD calculations pass numerical tests. A direct invariance test
shows that, **at the input to spatial normalization**, multiplying each frame
by a positive gain and adding a frame-wide offset leaves its spatial z-scores
unchanged; subsequent temporal normalization also remains unchanged within
floating-point tolerance. This test does not assert invariance of the entire
pipeline to arbitrary gain changes applied before detrending.

Thus normalized local contrast and preserved-input intensity relative to a
baseline are distinct signal definitions. The former deliberately removes
frame-wide scale/offset information. Correct SD arithmetic does not establish
that every oxygen-related intensity change survives as a local event.

**Dependency:** publication outputs should identify local contrast detections
and optical baseline changes separately. Any field-wide intensity analysis
requires its own reference, acquisition/artifact assessment and interpretation;
it is not calibrated oxygen concentration.

### 5. Finish physical scaling after the signal/identity rules

The surge area threshold is physical, but the spatial averaging kernel remains
21 pixels wide: 49.35, 99.75 and 141.75 µm at the three selected calibrations.
The changing-radius challenges use 60–120 µm radii. Smoothing can therefore act
at materially different physical scales. All four sources here are sampled at
1 Hz; this is not a frame-rate invariance experiment.

Cross-source differences cannot be attributed to pixel calibration alone:
recording content, acquisition and the fluorescence-control modality also differ.
A controlled resampling/physical-smoothing experiment should follow the signal
and spatial-identity decisions, with threshold and duration sensitivities
reported separately.

## Scope of this update

No biological sensitivity or specificity estimate is made. The eight new movies
are technical perturbations of four source recordings, alongside rescoring of
their existing unchanged controls. The FB2411 fluorescence recording remains a
separate control. Source hashes, recipe ledgers, complete-movie numerical checks,
transition evidence and baseline diagnostics are retained with the report.
