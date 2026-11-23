# Detector revision for recovering references and regional responses

7 November 2026. Approved milestone POCKET-VIDEO-DETECTOR-04, owned by Codex (root).

The next revision would assess a renewed local decline while the preceding signal is still recovering, with a separate decision about measurement reference eligibility. It would assign explicit roles to surrounding patches and retain the regional response when assessing an additional local change. The two reviewed previews provide the regression examples for this work.

## Evidence from the previews

| Example | Review conclusion | Required detector behaviour |
| --- | --- | --- |
| FB2413 site 3/event 6 | Frames 823–825 are a timing cue. The measurement baseline is unresolved. Every ten-frame window in 806–825 rises on the saved raw footprint. | Retain evidence for the later decline and return, assess its preceding recovery, and expose reference uncertainty. The timing cue remains a review annotation. |
| FB2412 site 20/event 1 | The reviewed baseline is 104–113. Patch 82 is a responding regional comparison. During 151–170, patch 82 and the supported band outside both footprints fall about 3.6% and 3.8%, while the event footprint falls about 6.0%, each relative to its own 104–113 mean. | Identify the shared nearby response and assess the deeper local departure, with explicit comparator roles and uncertainty. |

The previous pilot retained the later FB2413 trough but chose context 826–830. Its FB2412 context was 114–118. The current helper selects a short high window before the assessed trough, and its surrounding patch bank is screened by observability and signal confidence. The next revision addresses those two assessment choices. Reuse the archived primary proposals, fixed cohort extraction and whole-field context. [Previous pilot results](BOI_VIDEO_EPISODE_SEPARATION_RESULTS.md) · [Existing review cards](../../reference-validation/boi-video-episode-separation-20261107/review.html)

The latest preview annotations carry the reviewed timing cue, reference status and comparator role. [FB2413 preview](/Users/zcm361/.codex/visualizations/2026/10/14/01a13994-3c33-7b83-93a3-aaceb367698e/boi-fb2413-recovery-preview-20261107/FB2413-raw-recovery-preview.png) · [FB2412 preview](/Users/zcm361/.codex/visualizations/2026/10/14/01a13994-3c33-7b83-93a3-aaceb367698e/boi-fb2412-patch82-preview-20261107/FB2412-patch82-raw-preview.png)

## Proposed assessment changes

1. Compare preceding state and onset together. Retain plausible onset ranges from the observed trajectory, then compare a stable level, continuing recovery and ambiguous change on samples before each trial onset. Use low-complexity constant and monotone trend alternatives with empirical variation estimates. The decline and subsequent rise need corroboration in the same raw cohort and coherent spatial support. Retain competing event boundaries when the evidence supports several interpretations.

2. Record reference eligibility separately from recognition. A recovering preceding state can support a candidate while its scientific reference remains unresolved. Keep the fitted trajectory and its uncertainty visible as recognition context. Scientific amplitude references retain the source-bound review contract and event-specific reference policy. The comparison should expose absolute raw return, raw rise and return relative to the surrounding response separately.

3. Qualify patches and assign roles per episode. Use archived support coverage, observation quality, signal confidence and geometry to propose disjoint surrounding regions. Assess quiet tissue, responding regional tissue, peripheral drift checks and uncertain patches as distinct roles. Quiet and responding cohorts feed separate comparison terms, with peripheral patches retained as acquisition checks. Preserve fixed membership through the comparison. Use multiple qualified regions and repeat the decision with individual regions omitted. Low comparator agreement carries uncertainty into the result.

4. Compare regional and local explanations explicitly. Compare a regional response alone with a regional response plus a local decline and return. Estimate regional trajectories on one disjoint comparator subset and check them on another subset. Use the candidate's raw cohort for local evidence. A high model fit needs additional raw and spatial evidence to support a local event. Preserve both component traces, their footprints and boundary uncertainty. The existing whole-phase and local-core alternatives provide the spatial starting points.

The publication reports spatially defined hypoxic pockets associated with local capillary flow interruptions. The design inference here is to retain spatial extent, regional co-response and observed local recovery throughout assessment. [Original publication](https://pubmed.ncbi.nlm.nih.gov/38547288/)

## Bounded work items

| Item | Work | Acceptance evidence |
| --- | --- | --- |
| VCTX-01 | Add preceding-state assessment and reference eligibility to the experimental episode comparison. | Constructed stable and recovering cases have distinct states. The preceding fit for a fixed trial onset is invariant to later samples. The FB2413 card shows onset alternatives, the earlier recovery and reference eligibility. |
| VCTX-02 | Add comparator qualification and roles, then assess regional-only and regional-plus-local alternatives. | Constructed regional change, nested local change and misleading comparators have distinct outcomes or explicit uncertainty. Patch roles are inferred from inputs. The reviewed role of patch 82 is used afterward to compare outcomes. |
| VCTX-03 | Freeze one configuration, evaluate the two windows and deliver two updated comparison cards. | Independently replay selected traces, phase evidence, support counts and role decisions. Verify source and result hashes. Report improvements, misses, unstable decisions and remaining reference problems against the preceding pilot. |

Use the same full-field windows, FB2413 frames 608–1114 and FB2412 frames 5–839. The saved footprint identities, reviewed timing and preview labels are comparison annotations applied after inference. Selection of displayed matches follows the frozen spatial and temporal overlap rule. These familiar examples serve as regression fixtures.

Eight constructed checks cover a stable local cycle, a renewed local decline during earlier recovery, recovery without an added event, recurrent dips with ambiguous separation, uneven regional change, a local event within regional change, an influential or poorly supported comparator, and unavailable phase evidence. Reuse the existing controls where applicable. Freeze criteria after those checks and before the two recording runs.

## Outputs and scientific contract

Deliver two experimental review cards with the existing videos, raw matched-cohort traces, onset and return ranges, preceding-state assessment, qualified patch roles, regional and local components, and reference eligibility. Provide one verification receipt and a short comparison with the preceding pilot.

Treat the burden formula, normalization, original recordings, automatic and reviewed results, scientific references, production MATLAB workflow and export contract as protected read-only inputs. The existing complete-burden missingness rule requires valid contributions for every included event. The FB2412 scientific reference remains sourced to the accepted 104–113 review. The FB2413 preview carries the 823–825 timing cue and unresolved measurement reference.

## Budget and stopping condition

The approved budget is four active engineering hours, three batches, eight constructed checks, two recording windows, one frozen configuration and one engineering repair. The batches are implementation with constructed checks, the frozen recording comparisons, and independent verification with review cards. Reuse the existing Python environment and archived inputs. Run each recording and each independent check in an isolated worker under a measured 2 GiB memory cap. Limit new derived material to 256 MiB.

Stop after the two cards and verification report. A resource or source-integrity boundary produces a preserved partial checkpoint. Real-example discrepancies are reported under the frozen configuration. Any broader evaluation or production adoption has its own scope decision. Deferring this revision leaves the existing previews available for review.

The researcher approved this bounded implementation under the [workspace rules](../AGENTS.md).


## Delivery record

The approved experiment is delivered and stopped on 7 November 2026. Three batches, one configuration and one repair were used. The [results report](BOI_VIDEO_CONTEXT_REVISION_RESULTS.md) and [two comparison cards](../../reference-validation/boi-video-context-revision-20261107/review.html) record demonstrated behaviour, failures and unresolved boundaries. No production adoption or scientific-result change occurred.
