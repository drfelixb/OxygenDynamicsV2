# Experimental onset-to-native-end peak interval

This experiment compares two measurement intervals on the same fixed support
and the same frozen selector onset and 20-second reference. The existing interval
is native start through native end; the alternative starts at the estimated
onset and ends at native end. Production detection, onsets, baselines, statistics
and contracts are unchanged. A larger maximum alone is not evidence of improvement.

## Rule specified before evaluation

Require the existing arithmetic/reference conditions. Check every newly added
frame from estimated onset through native start minus one. Any overlap with a
retained detection of either sign makes the expanded measurement unavailable;
do not skip frames or silently fall back to the native amplitude. Any nonfinite
added sample also makes expansion unavailable. Keep the native result separately.
Otherwise take the first maximum over the complete expanded interval and divide
by the unchanged reference mean. Preserve signed values and the existing
nonpositive-direction statuses; positive amplitudes remain provisional.

The cached union masks permit checking pre-native overlap. They do not identify
other events separately from the event's own native masks. This experiment does
not revalidate native-interval contact handling or claim to exclude every possible
source of native overlap. Undetected neighbors cannot be excluded by these masks.

## Evaluations

Replay every row of the preceding amplitude-eligibility audit: 11,124 planned
recipes and 309 controls on six recorded backgrounds plus a separate noiseless
support. Retain unavailable cases and use the same denominators. No onsets are
refitted and no detector is rerun. These are repeated constructed trace cases,
not independent biological observations.

For constructed traces only, export the imposed envelope at each selected peak,
relative to its maximum over the recording. Report peaks outside imposed support
and peaks at at least 90% of the envelope maximum (a descriptive, prespecified
screen, not a biological accuracy estimate). Decompose both observed peaks into
source fluctuation, imposed contribution and reference effect using the same
paired-source identity as the preceding audit. Preserve contamination of the
reference: changing the peak interval cannot remove it. Also quantify the increase
in the source-only maximum over the identical expanded interval and reference
frames. This paired diagnostic distinguishes extra background opportunity from
the imposed contribution; it is not available for spontaneous events.

Report changes on unchanged source controls separately. A larger source-control
maximum does not establish a false positive, but prevents interpreting increased
amplitude alone as recovery of imposed signal. Report the previous 18 negative
cases separately, without tuning the rule to make them positive.

Add deterministic challenges with a fixed known onset to isolate the interval
rule: an early target pulse; detected and undetected positive/negative neighbors
in added frames; a neighbor in the reference; a neighbor before the reference;
and a nonfinite added frame. Freeze onset to isolate measurement behavior, so
these challenges do not validate how the onset estimator responds to neighbors.
Independent reconstruction must verify all rows, masks, peak/reference arithmetic,
paired diagnostics and challenge outcomes before considering integration.
