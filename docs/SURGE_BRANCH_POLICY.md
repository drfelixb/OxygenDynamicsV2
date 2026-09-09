# Surge split/merge policy comparison

This is a test-only extension of the **existing candidate tracker**, not the
outsourced alternative detector. Production calculations and contracts remain
unchanged. See the [replay evidence](reference-results/surge-branch-replay-20260909/README.md)
for recording identities, results and reproduction commands.

## Question and fixed policies

Can a surge continue through a candidate split without losing its neighboring
component or silently changing event identity? Candidate formation, normalization,
physical area cutoff and the ten-second contiguous-duration rule are fixed.
Every policy preserves all accepted candidate pixels exactly once, including
short rejected runs. No policy fills missing frames or combines durations across
a gap. Qualification applies to each run separately; sibling durations are never
added together.

For adjacent disjoint candidate regions, define mutual coverage as intersection
divided by the larger area, containment as intersection divided by the smaller
area, and area ratio as larger divided by smaller. A contact means either
endpoint overlaps more than one candidate in the other frame. Even a tiny
nonzero overlap counts; contact is geometric evidence, not proof of a biological
split or merge.

| Replay policy | Exact rule |
|---|---|
| `isolated_shape` | Current production rule: mutual coverage at least 0.6, or an isolated link with containment at least 0.8 and area ratio at most 2. |
| `majority_shape` | Also allow non-isolated links with **strictly greater than 0.5** mutual coverage, containment at least 0.8 and area ratio at most 2. |
| `split_only` | Apply that extension only when the successor has one overlapping predecessor. **Existing primary merge links remain allowed.** This is a split-only extension, not a prohibition on merges. |
| `segment_contacts` | Break every link at a contact, including links that pass the existing 0.6 primary rule. Preserve the connected pieces as separate runs. |

The strict majority boundary follows a geometric uniqueness property, rather
than being fitted to the missed pulse: two disjoint successors cannot each
contain more than half a predecessor, and conversely for two predecessors.
The isolated fallback still permits exactly 0.5 mutual coverage with full
containment and a twofold area change. Equal competing 50/50 branches stay
unresolved. These properties ensure unique pixel ownership; they do not establish
physiological identity.

## What the controlled tests establish

Nine focused tests cover unequal/equal splits, merges of independent sources,
independent neighbors, loss of identity after contact, geometry guards, missing
frames, candidate-order invariance and equivalence to the production tracker.
The randomized equivalence/order test uses thirty five-frame candidate sequences.
These are prescribed candidate masks, not a new end-to-end injection experiment.

- A 1,000-pixel parent lasting seven frames can continue into a 550-pixel child
  for another seven frames under the majority extension. Its 450-pixel sibling
  remains a distinct seven-frame rejected run with a recorded parent connection.
- Two independent regions of 550 and 450 pixels can merge into one 1,000-pixel
  component. The same majority rule now attaches their combined signal to the
  larger predecessor. Ownership remains unique while signal attribution is mixed.
- If the dominant spatial support changes after separation, the same run can
  begin on source A and end on source B. Prescribed identities are known in the
  fixture; the observed masks themselves cannot resolve them.
- This problem also exists in the **current primary rule**: regions of 700 and
  400 pixels merge into 1,100 pixels and separate with their sizes reversed.
  Both dominant links pass 0.6, allowing a run to change source identity.
- Stopping all contact links prevents these joined paths, but fragments the
  otherwise continuous split fixture. It is not a free improvement in detection.

The `split_only` extension is therefore not sufficient protection: it leaves
primary merges intact, and an already merged component can pass into a child.

## Evidence retained

`compareSurgeBranchPolicy` returns every contiguous run plus every **nonzero
adjacent-frame overlap edge**, not only the chosen link. Each edge records frame
bounds, predecessor/successor run IDs, areas, shared pixels, coverage, both partner
counts, primary eligibility, chosen-link status and contact status. Run tables
retain duration, ambiguity and qualification. IDs are local to each recording
and policy; do not join IDs across policies.

This makes a short sibling and its relationship inspectable even when it never
becomes a counted event. Births/deaths without overlap have no edge; their runs
remain in the run table. These are observation relationships, not asserted
biological ancestry. They currently exist only in the comparison output.

The baseline replay must exactly reproduce saved production site masks and
candidate/gap ledgers. All policies check per-frame pixel conservation, unique
ownership and contiguous durations. A separate Python audit recomputes graph
arithmetic, eligibility, partner counts, durations, qualification and ambiguity
from CSV without importing the MATLAB implementation.

## Decision and dependency order

**Do not promote the majority extension solely because it recovers the selected
missed pulse.** It has a demonstrated attribution failure, and stopping all
contacts also sacrifices otherwise retained support. Full-event optical amplitude
and duration become difficult to interpret when a run incorporates another
component. The current ambiguity flag is valuable but does not describe which
frames and sibling components caused that uncertainty.

1. Bring explicit contact-edge provenance and contact-frame annotations into
   production, preserving all siblings and rejected fragments. Expose how much
   of each retained event's duration and footprint involves contact; distinguish
   that evidence from the count of independent biological events.
2. Use that evidence to test local separation within the existing detector's
   connected components. Prespecify when separation has enough evidence and
   when a contact must remain unresolved. Test independent neighboring injected
   signals through contact as well as a single changing signal before accepting
   a new event identity rule. Do not infer separate identities from geometry alone.
3. With support and identity settled, compare amplitude supports and validate
   surge onset/baseline together. Preserve signed optical changes and unavailable
   measurements. Do not interpret a larger event count as better biological
   sensitivity or a full-footprint amplitude as local oxygen concentration.

The prior [signal-stage audit](SURGE_SIGNAL_EVIDENCE.md) remains relevant:
large-footprint dilution, rising tails inside pre-event baselines and physical
smoothing calibration are separate problems that linking changes cannot settle.
