# Bounded next step: expose competing onset and recovery choices

## Question

Why does the wider corrected-trace rule choose an earlier shoulder than the
researcher for three of the four current examples, and what distinguishes a
minor internal fluctuation from onset or final recovery? Detection scores may
help identify structure, but their extrema cannot directly set boundaries.

## Scope to implement next

Use the saved phase 043 traces, phase 047 search limits, seeds, plateau definitions
and candidate records. Begin with the four current FB2314 cases. Show every
already eligible corrected shoulder on each side of each existing directional
seed within those limits, retaining its exact plateau and neighboring samples.
Keep acquisition, native-neighbor and nonfinite barriers visible. If a supplied
mark is not an exact turning-point sample, retain it separately rather than
moving it to a nearby extremum or inventing a flatness tolerance.

For each shoulder, expose the corrected value and seed-to-shoulder difference,
its temporal order and intervening extrema, and the existing filtered event and
site scores at that frame and its immediate neighbors. These are descriptive
quantities with different support, not a combined ranking score. Display the
whole existing bounded context, so that a researcher can inspect the excursion
and subsequent recovery rather than an isolated peak crop.

The existing wider-panel examples must also be carried as challenges: the two
ID400 events, FB2316 decline and non-recognized surge, and the HP recognized surge
and non-recognized dip. This makes ten previously reviewed examples in total,
without requesting another blanket round of annotations. Use their existing
marks and preserve recognition-negative cases without fabricated boundaries.
Retain the other 38 events as the broader frozen panel for any later candidate
evaluation; do not call any of these inspected examples held-out validation.

## Constraints and outputs

- No movie read, new correction/filter, detector rerun, amplitude baseline
  adjustment or production timing edit. No automatic branch choice from the
  manual answer, endpoint hybrid chosen by agreement, exclusion or relabeling.
- Do not rank shoulders, choose an optimal context length, impose sustained
  recovery, or declare thresholds from these examples. Use the existing local
  extrema definition; missing or non-observed boundaries stay unresolved.
- Export event and candidate IDs, source hashes, frame/time coordinates, fixed
  event versus site support, every eligible shoulder and its descriptive values,
  current and prior annotations, barriers and a readable explanation.
- Bound work to ten existing examples × two existing directional branches,
  with one pass through each saved trace, ten minutes total and 100 MiB of new
  evidence. Stop with an explicit limit/failure record if exceeded. Do not widen
  search bounds or add examples because the result disagrees with a mark.
- Check extracted sample identity, exact plateau membership, both branches,
  missingness and inclusion of all eligible shoulders. Verify that saved T2/T3
  choices can be located in the inventory and explain any source incompatibility.
  Inspect the rendered plots. These are numerical/display checks, not biological
  accuracy tests.

## Completion decision

Conclude with the observed ambiguity in each case and which facts would be
needed to propose a reproducible selection rule. If the evidence does not
distinguish multiple plausible shoulders, keep them as alternatives. A single
automatic interval is not a required outcome. Any subsequent ranking/timing
hypothesis must be frozen before testing on all 48 existing events, with both
signs and every earlier failure retained. Independent biological validation
requires data and review outside this development history.
