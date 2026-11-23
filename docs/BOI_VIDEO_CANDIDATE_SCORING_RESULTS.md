# Context and candidate scoring: completed experimental assessment

9 November 2026. POCKET-VIDEO-DETECTOR-07, root without delegation.

**Keep the phase representation; replace this context/scale decision before production use.**
The correction passes all eighteen declared constructed cases, but still misses
FB2413's later pocket and loses FB2412's core-local support. It is a completed,
verified experiment with a failed transfer to the saved examples. It is not a
validated detector improvement or a new scientific method for measurement.

The two [whole-episode cards](../../reference-validation/boi-video-candidate-scoring-20261109/review.html)
show the unchanged spatial evidence, full saved windows, enlarged target traces,
original-ROI raw/corrected context, surrounding patches and the new fit. Existing
movies remain available beneath each card with their original overlays.

## What changed in this isolated prototype

- Pre/post context has separate monotone rising or falling modes, with no free
  reversal inside a context state. The null comparison uses the same nuisance
  family and change penalty. A sufficiently resolved decline–low–rise cycle
  must use candidate phases. Flat lows and asymmetric rise/fall remain possible.
- Variation comes from each channel's fixed twenty-second line-residual windows,
  excluding all proposed decline/low/rise samples and three-second margins.
  An initial observed rise without a decline is continuing context. The final
  scale is the maximum of grid spacing, median context innovation and 2.5 times
  median context residual MAD. At least two windows and scale consistency within
  four proposal/exclusion passes are required. There is no correlation multiplier
  or transfer of noise from a different ROI.
- Insufficient calibration produces `noise_context_unresolved`, preserves
  uncertainty and cannot establish absence. The initial all-window scale is
  explicitly provisional. The scale is a conservative diagnostic allowance,
  not an independently calibrated measurement of camera noise.
- Initial continuing recovery no longer erases observed pre-decline samples.
  Those samples are characterized without accepting a measurement reference.
- Temporal shape, context adequacy, frozen spatial/regional evidence and
  scientific reference/return eligibility are separate fields. Dependent returns
  remain conditional. Every measurement-ready and burden-ready field is false.

## Saved example results

All times below are recording frames at the supplied external 1 Hz. Fit windows
remain FB2413 608–1114 and FB2412 5–839. Point estimates are accompanied by
comparable-cost alternatives; these ranges are not confidence intervals.

| Fixed channel | New frozen result | Twelve declared stability runs |
| --- | --- | --- |
| FB2413 target, 73 blocks | Later pocket not isolated; no retained candidate | 0/12 target associations |
| FB2413 earlier, 55 blocks | No retained candidate | 0/12 associations |
| FB2412 core raw, 125 blocks | Onset best 120, alternatives 106–124; low 129–172; post-state best 185, alternatives 180–205; preceding context recovering | 11/12 target associations; best onsets 120–121, post-state 185 in those 11; all returns conditional |
| FB2412 wider raw, 2,024 blocks | Onset best 114, alternatives 101–123; low 147–169; rise interrupted by renewed decline at 193; return censored | 12/12 associations; onsets 112–123; post-state in 4/12 at 179–185, other 8 censored |
| FB2412 core-local residual | Shape retained only as an unselected diagnostic path; below contrast gate | 0/12 target associations |

The quiet-supported patches 50/144 and responding regional patches 68/82 have
no retained temporal candidate in this configuration. Their frozen spatial roles
are preserved; a temporal miss does not relabel a responding patch as quiet.
These are source-episode qualifications, not biological labels for every frame.

### Why FB2413 still fails

The graph's strongest unselected cycle starts at 680, is low at 781–810, and
enters post/context at 814. Frames 823–852 remain post/context; the later pocket
has no distinct decline/low/rise allocation. The best null-to-graph cost gain is
33.80, already above the required gain of 4. Lowering that final gain threshold
would not solve the miss.

The final context scale is 74.11 input units, versus a context innovation scale
of 13.09. The strongest decoded drop is 193.14 input units: 2.61 scale units,
below the required 3. The initial provisional scale was 55.60 and rose after
context exclusion. The earlier cohort similarly has scale 89.52 and a drop/scale
ratio of 1.72. These are diagnostic signal differences, not normalized scientific
amplitudes or burden contributions.

Restricting the context family fixes its mathematical ability to reverse freely,
but does not guarantee that a smaller real cycle is resolved at the chosen
variation scale. The twenty-second residual windows can still contain biological
variation and undetected structure. The conservative setting needed for the
constructed noise control therefore does not transfer adequately to this busy
recorded context. The method has not established candidate-independent background
noise for FB2413. The saved miss is not evidence that the pocket is absent.

### What improves, and what remains unresolved, in FB2412

The core raw channel retains the dip and now correctly characterizes its
preceding observed samples as recovering, instead of declaring them unavailable
because the window begins in a rise. However, plausible onset paths extend from
106 to 124 and post-state paths from 180 to 205. A narrow range of best endpoints
in the perturbations does not remove that within-fit ambiguity.

The core-local scale is 10.46 input units and its decoded drop is 23.70, below
the contrast requirement. Its rejected path remains stored; it has not been
reclassified as biological absence. The wider region still has context-sensitive
spatial evidence and an interrupted rise. Shape alone cannot choose its extent
as the pocket area.

The accepted **original-ROI baseline 104–113 and onset/recovery 114–182 remain
unchanged**. The 125-block diagnostic core is a different footprint from the
2,511-pixel original ROI. Experimental timing on that core does not revise the
accepted scientific interval. FB2413's 823–825 annotation remains a timing cue,
and its measurement baseline stays unresolved.

## Finite checks and preservation

The original sixteen fixture shapes and expectations are preserved. The two new
cases are a smaller second flat-bottomed episode after an earlier return, and a
rectangular decline–hold–return. All eighteen pass, including the unchanged
noise-only negative expectations and independent tiny-grid recurrence checks.
Their expected semantics were recorded before evaluation.

Two method repairs occurred before freezing: restoring the existing context
change cost within the restricted family, then increasing the conservative
within-context residual allowance from 1.5 to 2.5. The first check passed 17/18
(separated return failed); the intermediate check passed 17/18 (correlated-noise
control failed); the final check passes 18/18. No assertion was relaxed. A first
launch without NumPy failed before evaluation; the existing Python environment
was then used without installing anything. Failed attempts are preserved.

One configuration was frozen before nine saved-signal fits and sixty declared
residual-block stress fits. Raw/local core perturbations use exactly aligned
indices. No post-freeze model tuning or scientific-source repair occurred.
Independent checks reproduce five full graph/null solutions, **14,076 transition
profile points, 48,362 legal path transitions and 121 reference-candidate
calculations**, plus all nine source channels and all sixty resampling sequences.
All 69 numerical result files have exact preservation hashes.

These are software and finite stability checks, not independent biological
validation. When a base fit misses an event, its residuals can still contain
that structured event; resampling them cannot establish a confidence interval
or an estimate of population sensitivity/specificity.

Four batches and two pre-freeze model repairs were used, within six active hours,
2 GiB per worker and 256 MiB new evidence. Peak measured worker memory is about
306 MiB. One cosmetic card-layout pass shortens a title; all numerical outputs
remain exact. The [verification receipt](../../reference-validation/boi-video-candidate-scoring-20261109/verification.json)
records final counts, resource usage and preservation checks.

All 1,557 protected files, the four source movies, prior evidence and original
automatic/reviewed results are preserved. There is no new source-image decoding,
regional fit, mask selection, accepted baseline, amplitude, area, burden,
partial sum or recording total. The burden formula, normalization, strict
completeness rule, exports and MATLAB production workflow are unchanged.

## Keep / replace and stopping point

Keep the explicit phase representation, flat/asymmetric shapes, source-bound
spatial roles, conditional dependency fields and corrected preceding-state
bookkeeping as design elements. **Replace this scale/context discrimination and
do not adopt its automatic timings or integrate it into the GUI.** Passing the
constructed examples does not outweigh the known saved-signal misses.

A future proposal should establish usable variation/context independently of
the candidate it is trying to detect and test whether adjacent spatial behavior
resolves the later local cycle. Another final-threshold adjustment or another
request for frame-by-frame researcher labels is not supported by these results.
That would require a separately bounded scope. This experiment is delivered and
stopped; no subsequent implementation or recording expansion is active.
