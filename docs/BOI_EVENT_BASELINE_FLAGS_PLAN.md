# Event-specific baseline with reference flags

**Current delivery, 13 November 2026.** The separate revision-31 signed-selection
milestone is [implemented and verified on frozen synthetic inputs](BOI_REVISION31_DELIVERY.md).
Its reference calculator/version and the burden formula/normalization remain
unchanged. No individual examples were used or are reopened. No active milestone
or automatic further verification remains; compact export stays held. Earlier
hold and discrepancy notes below are historical, not a new sign-policy question.

**Current contract, revision 31, 13 November 2026.** The researcher explicitly
agrees to include finite signed contributions and flag negative values.
Negative contributions subtract in the unchanged complete sum; a finite signed
total may be positive, zero or negative. Preserve the twenty-second local
reference, burden product, area/time normalization and original results. No
absolute value, zero fill, new baseline or sign-based NaN gate is authorized.
Implementation and numerical verification of this revision are explicitly held.
No further individual-example investigation, trace/ROI/video review or event-level
biological adjudication is allowed. The previous baseline/reference milestone
was delivered under the former eligibility rule; its spent allowances are not
reset and its checks do not verify this new rule. Revision 31 of the
[measurement/export contract](BOI_COMPACT_EXPORT_PLAN.md) governs current behavior
requirements. Historical planning and delivery notes below retain their dates;
they do not authorize new execution or reopen examples.

## Historical clarification and delivery

**Historical inclusion discrepancy, 13 November 2026.** The delivered selector
retained the former nonnegative-eligibility gate, so finite negative amplitudes
were kept in event tables while their burden contributions were withheld.
Revision 31 resolves the contract by explicitly selecting signed inclusion and
negative flags. Its implementation remains held; previous arithmetic checks
are not evidence of that future behavior. The earlier wording is preserved in
the pre-revision snapshot. No individual examples are reopened.

**Delivered locally, 13 November 2026.** The researcher explicitly approved
steps 1–4 including BREF-05 and resumed implementation/verification within the
unchanged shared limits. [Delivery and limits](BOI_EVENT_BASELINE_FLAGS_DELIVERY.md):
12 constructed scenarios, 45 selected existing regression evaluations and one
three-example saved comparison pass. Original detector, formula, normalization,
results and review decisions remain preserved. Compact-export implementation
and cohort re-export stay held. The approval/hold statements below are the
preserved 12 November planning/interview history, superseded for BREF-01..05
only by this explicit resumption and delivery.

12 November 2026. **Bounded change approved; implementation and verification held by the researcher.**
BASELINE-FLAGS-01, owner root, no delegation. The researcher asks to keep the
original event-specific baseline calculation and flag short, overlapping or
post-event references instead of withholding computable amplitudes. Burden
formula, normalization and original results remain protected. This records
that policy choice. BREF-01 through BREF-04 are approved, but implementation
and verification must wait while the requirements interview continues.
Resume execution only on an explicit researcher instruction; “continue” in
this discussion advances the interview. Approval remains valid within the
bounded scope and need not be requested again.

**Consolidated specification:** the researcher completed the layout decisions
and requested consolidation, including multiple recordings/mice/conditions.
The current [measurement and compact export specification](BOI_COMPACT_EXPORT_PLAN.md)
(now revision 31) is authoritative for the agreed requirements. This document retains
the bounded baseline work items and their approval/hold. No coding, numerical
verification or execution is authorized by completing the interview.

## Result for the researcher

Each sink event has its own amplitude and a visible description of the reference
used. A reference-quality flag is distinct from numerical unavailability.
Computable flagged amplitudes feed the unchanged burden calculation and carry
their flags into event and recording outputs. Existing strict and pre-episode
measurements stay available as separately identified historical/alternative
columns. They do not silently override the newly selected event-specific result.

The scope restores the original **temporal reference selection**. Retain the
current event footprint, measurement timing and native event area; do not also
restore the old site-union averaging or global boundary search. Restore no
detector, correction or tissue-support rule. Surge measurements are unchanged.

## Measurement and flags

Use the configured baseline length (normally 20 seconds), converted using the
saved acquisition sampling rate. It is a requested duration, not a minimum
clean-sample requirement. Compute a fresh reference for every event, including
successive events at the same site; do not inherit the first episode reference.

| Situation | Reference and reporting |
| --- | --- |
| Ordinary event | Mean of the available frames immediately before its saved measurement onset, up to the configured duration. |
| Short prehistory | Use the available preceding frames; record requested/observed/finite sample counts and a short-reference flag. No earlier search or automatic 10-second substitution. |
| Native detection starts at recording frame 1 | Use available frames immediately after its saved measurement end, up to the configured duration. Flag post-event reference and recovery not established. |
| Other native sink/surge activity overlaps the event footprint during the reference | Keep those samples in the reference; flag overlap and report overlapping frame count. Assess all saved sites and both signs before statistics filtering. |
| Missing reference samples | Match the original omit-missing reference mean where finite samples remain; record missing-sample count and a separate flag. |
| No actual reference samples, no finite reference samples or nonpositive/nonfinite reference mean | Amplitude remains unavailable with a precise reason. Do not use an event sample as a fictitious pre/post-event reference at the recording edge. |

Keep current event-signal availability requirements. This milestone does not
relax missing event-signal rules. Preserve negative finite amplitudes and their
sign; do not take an absolute value or substitute zero. Reference-quality flags
may coexist and do not certify stability, recovery or physiological normality.

The sink amplitude remains `100 * (reference_mean - event_min) / reference_mean`
on the current fixed event footprint and current event interval. No trend fit,
background subtraction, automatic recovery test or new spatial measurement.

Append a versioned event-specific measurement rather than overwrite existing
`NormOxySinkAmpPercent`, `BaselineStatus` or `Episode...` columns. Proposed policy
identity: `boi-event-baseline-flags-1`. Store amplitude, reference type/bounds,
mean, requested/observed/finite samples, overlap count, short/overlap/post-event/
missing-sample flags, numerical availability, source evidence and version.
Use readable field aliases in the compact workbook. Saved historical files
retain their own version and selected amplitude.

## Interview decision: local dip above reference

The researcher explicitly considers a local decline a pocket even if its
minimum remains above the selected reference, because the background level
can change. A negative drop-oriented reference amplitude alone must not cause
a not-pocket classification, automatic rejection or mandatory pocket-review
gate. Preserve the signed measurement and an **above-reference** flag. Other
independent review reasons and existing explicit not-pocket decisions remain
separate.

The proposed weaker biological consequence is the researcher's hypothesis for
future dual imaging, not a conclusion established by this optical reference
comparison. Do not label these events harmless, physiologically normal or
biologically insignificant. Future dual-imaging work is not added to this scope.

The researcher has now selected **local decline magnitude** as the amplitude
ingredient for burden, with the above-reference flag separate. Preserve the
original reference-based amplitude, its reference and its measurement version.
A local decline measurement is a separate quantity, not an absolute-value
conversion of a negative original amplitude. The local reference is now the
selected original twenty-second event-specific mean with reference flags;
the separate recording reference is the first twenty seconds, with quality
flags and an optional explicit override.
Burden formula and area/time normalization remain unchanged; implementation
and verification stay explicitly held.

## Local baseline definition: 20-second duration selected

The researcher selects the original 20-second event-specific baseline with
reference flags. Use the mean over the configured 20-second interval before
each event's saved or explicitly reviewed decline onset, on the current fixed
event footprint. Every recurring event has its own reference. Keep the approved
short/overlap/post-event handling and reference provenance. Do not replace the
mean with a selected highest sample, require twenty clean samples or change
nominal duration to ten seconds. The ten-second candidate was not adopted.

The baseline remains event-specific in time; it is not one fixed baseline for
all events in a recording. The original spatial site-union average and global
boundary search are not restored. Formula, normalization, original amplitudes,
original outputs and explicit reviewed decisions remain preserved.

The researcher selected a **separate earlier recording-level reference** for
the above-reference flag. It is not the twenty-second local baseline that feeds
amplitude and burden. Keep both references separately named, bounded and
versioned. An above-earlier-reference flag does not reject a pocket, rescale its
local amplitude or alter burden inclusion. Its possible biological consequence
remains a hypothesis for future dual imaging.

The researcher selects the **first twenty seconds of each recording** as the
fixed comparison window, with reference-quality flags and an optional explicit
override. Use a recording-level time interval evaluated separately on each
event's current fixed footprint, as proposed, and compare that event's minimum
with its earlier-window mean. Keep interval bounds, override/source identity
and quality visible. Do not compare a local event raw value with an unrelated
whole-image mean or share one brightness value across different footprints.

A recording-start reference is descriptive, not a claim of recovered, normal
or normoxic tissue. Preserve short-window, missing-data and overlapping-native-
activity quality information. Do not search for a maximum, infer a healthy
period or move the reference merely to obtain an above-reference flag. No
additional input-CSV field is mandatory; the selected start-window default
supports the automatic batch workflow.

For an event without a temporally preceding comparison window, or without the
required comparison evidence, retain **not assessable**, not false. The optional
comparator must not itself withhold local amplitude or burden. Original local
20-second event baselines and the burden product/normalization stay unchanged.
The optional override is a separately identified recording interval, not a
silent event-by-event reference search. Implementation and verification remain
explicitly held; the selected policy has not been numerically exercised.

The two selected references and the original temporal rules are consolidated
in revision 4. Preserve existing signal/ingredient availability and explicit
review decisions in unresolved cases; no new automatic correction is assumed.
Reconcile the completed specification with the held implementation plan before
resuming. No code, numerical verification, image analysis or budget expansion
starts.

## Burden and export behavior

For newly derived outputs using the final agreed policy, select the versioned
local-decline amplitude as the primary automatic burden input. The twenty-second mean,
per-event timing and first-twenty-second recording reference are selected.
Signed-local-amplitude values remain separate from the earlier-reference flag
and are not automatically reclassified as non-pockets. Include finite signed
amplitudes and their signed products when the other required ingredients are
available. Neither quality flags nor a negative sign may convert these finite
values into NaN. Negative contributions subtract in the complete recording sum;
the finite normalized total may be positive, zero or negative. Show negative
amplitude/contribution flags, recording negative-contributor counts and total
sign separately from availability and explicit review exclusions. The shared
selector must apply the same signed choice to event, recording and window
composites when future implementation is explicitly authorized. No absolute
value, clipping or sign reversal is adopted. Identify the result as a signed
burden composite, not a guaranteed nonnegative physiological oxygen deficit.

`contribution_i = amplitude_percent_i * area_um2_i * duration_seconds_i`

`normalized_burden = sum(contribution_i) * 1e6 / recording_area_um2 * 60 / recording_duration_seconds`

All retained required contributions still need to be available. Missing area,
duration or an unusable reference keeps the recording total unavailable; no
partial sum, coverage scaling or zero filling. A numerically complete total
can include flagged references, so export its flagged-contributor counts and
`IncludesFlaggedReferences` separately from numerical completeness. Do not label
such a total as having all references independently validated.

Existing explicit reviewed references, reviewed timings/areas and not-pocket
exclusions remain authoritative within the separately identified reviewed
workflow. No saved review is revised automatically. Keep automatic and reviewed
outputs distinguishable.

The compact export remains a saved-value projection. It will expose the new
fields when present in a new statistics export; it must not recompute old
amplitudes while copying a workbook. No new mandatory input-CSV fields or
another event-by-event review gate.

## Interview decision: mean area only

The researcher defers peak area. Retain the existing per-event mean native
area, in square micrometres, as the event-size output. Peak-area calculation,
new peak columns and further area analysis are outside the current scope.
Preserve the burden formula, selected area source and normalization, with
original results intact. This does not change masks, timing or event geometry.

## Interview decision: retain duration with timing flags

The researcher selects retaining the saved numeric duration with recording-
boundary and onset/recovery flags. Do not blank a computable duration solely
because its timing is uncertain. Preserve the saved measurement window and
actual source duration, together with whether boundaries/physiological onset
or recovery are unresolved. Do not extrapolate unseen portions or present a
flagged interval as an established full pocket duration. Keep native detection
support distinct from the saved measurement interval; do not imply area was
measured beyond its native support. Missing historical timing assessment stays
not assessed, not resolved. Existing burden duration, formula, normalization
and original results remain unchanged. Implementation and verification stay
explicitly held.

## Interview decision: side-by-side burden in one workbook

The researcher selects automatic and reviewed burden side by side in one
compact workbook. Preserve automatic values and original files; identify the
reviewed result as burden with selected saved decisions applied, with review
version, retained/excluded counts and availability. Other automatic measurements
keep their own basis labels. A partially reviewed recording is not relabelled
as wholly reviewed. Copy only compatible completed source snapshots and keep
missing reviewed results explicit; no scientific recalculation inside the
compact projection.

## Interview decision: remember batch review selection

The researcher selects remembering the review revisions explicitly chosen for
each batch, showing the selected version and allowing the selection to change.
No silent switch to the newest file. Continue to require compatibility with
the exact automatic source; a remembered path does not make a stale/different
source appropriate. No new mandatory CSV field or per-event review gate.
Implementation and verification remain held; compact-export implementation is
still separately proposed.

## Interview decision: unchanged value with No manual review label

For a recording with no saved manual review decisions or corrections inside a
compatible completed reviewed snapshot, the researcher selects retaining its
unchanged saved burden with a clear **No manual review** label. Keep numerical
availability separate: an unchanged unavailable burden remains unavailable,
with its reason. This does not fill an absent compatible reviewed source or
imply manual validation. Unreviewed events retain automatic data; no decision
is not rejection and does not authorize a partial sum.

## Interview decision: single Events table and explicit identity

The researcher selects one Events table with separate automatic and reviewed
values and review flags, preserving every original detection row. Explicit
not-pocket rows remain traceable but excluded from reviewed burden. Keep
inclusion/exclusion, reasons, version, availability and corrected ingredients
visible without overwriting automatic values.

The batch combines recordings from different mice and conditions. Repeat
RecordingID, Experiment, Mouse, Condition and other available original metadata
on every data row, including site, time-series and availability tables. Join
by full recording/type/site/event identity; mouse/condition alone are not
identities. Original metadata and values remain intact, and no new mandatory
CSV fields are added. See the consolidated specification for the six-sheet
layout, source mapping and metadata requirements.

The requirements interview is consolidated; no additional layout question is
pending. The normalization/comparability source review adds session/subject
scope, per-field scaling/comparison labels, support/reference qualifications
and current aggregation provenance to the specification. It does not change
mathematics, scientific inclusion, weights, reference rules or results.
Implementation and numerical verification remain explicitly held. No source
payload, measurement, reviewed result or workbook is generated here.

## Historical bounded baseline handover and supplement

The [held delivery handover](planning/boi-reconciled-delivery-plan-20261112.json)
records the reporting requirements and current hold. The BREF-01..05 work and
limits below describe the already completed delivery under former eligibility.
They are preserved as history, not a fresh implementation authorization. The
signed-inclusion requirement is agreed but its implementation and verification
remain held; a planning continue does not lift that hold or reset spent limits.

BREF-05 was the **explicitly approved and completed supplement** for the separately agreed
first-twenty-second recording comparison and explicit optional override. It uses
the same fixed-footprint raw/saved evidence, preserves not-assessable and quality
states, and cannot change local amplitude, burden denominator or inclusion. Its
scientific/reporting meaning was agreed during the interview; its added
implementation item is made explicit here rather than backdated into the earlier
core approval. It shared the combined four-hour/twelve-scenario cap;
no new data fixture, execution count or budget is implied.

The upstream measurement/evidence layer owns this comparison. The compact
exporter must not calculate it from raw pixels or traces. If the named saved
fixture lacks the needed earlier comparison or overlap evidence, report the
missing evidence without a movie reopen or alternate example. Preserve existing
SignedTraceAUC_sec/reference fields; no new-reference AUC calculation is added.

The handover retains twelve historical baseline scenario families. They do not
verify the later signed-inclusion rule. Any future authorized checks use a frozen
constructed/table-level scope with no individual biological reviews; no existing
execution allowance resets or expands. A scope/resource boundary stops work
with a checkpoint. No implementation, test, source-payload read or numerical
check starts now.

## Completed baseline implementation: historical scope and limits

| Item; owner root | Benefit and scope | Acceptance and stopping condition |
| --- | --- | --- |
| BREF-01 | Add the versioned event-specific reference calculator and independent flags. | Twelve frozen constructed scenarios cover reference branches, sampling rate, overlap, missingness and original-column preservation. No detector/timing/area changes. |
| BREF-02 | Connect live measurement and the receipt-bound saved-evidence adapter to the same calculator. | Live/saved synthetic evidence gives identical values/flags, including when an older pre-episode field is already present. Source identity conflicts stop the operation. No raw movie reopen. |
| BREF-03 | Select the new automatic amplitude consistently for burden and expose flags/provenance in existing exports. | Event, recording and window values match the existing product/scaling with the new explicitly identified amplitude. Strict completeness, old-version reading and reviewed exclusions/references are preserved. No compact-export implementation is hidden here. |
| BREF-04 | Check compatibility, value persistence and three existing saved examples, then stop. | Targeted synthetic regression checks plus FB2412 site 1 events 1/3/4 on the already saved comparison traces; preserve all source hashes and write new evidence only. No cohort or 17-recording re-export. |
| BREF-05 (completed supplement) | Supply the agreed separate earlier-recording-reference flag and optional override upstream. | Same saved/synthetic evidence and combined limits; not assessable when no preceding/usable reference. No amplitude/eligibility/denominator change from this descriptive comparator, raw movie reopen or new-reference AUC. |

Approved limits: four active engineering hours, three sequential batches, one
routine repair, twelve new constructed scenarios with at most two executions
each (24), at most forty-eight existing synthetic regression evaluations total,
two MATLAB starts, one three-example saved-trace comparison with one repair
retry, 2 GiB worker RSS and 100 MiB new evidence. Freeze the selected existing
test names before the first numerical execution. Use the existing test/export
framework; no package installation, platform migration, GUI redesign, Git
transport, release or publication.

The sole saved-data fixture is the existing
`reference-validation/boi-amplitude-baseline-comparison-20261015/selected-saved-examples.mat`
with its original-source helper and saved arithmetic readouts. It is a finite
measurement regression, not a new biological reference annotation. Planning
does not open that MAT payload. Five reserved recordings remain untouched.
No original movie decoding, new detection, correction fit or changed spatial
support. Stop at a source/resource/effort limit with the remaining work recorded.

## Historical approval and current explicit hold

The researcher approved the bounded core on 12 November, then explicitly resumed
steps 1–4 including the recording-reference supplement on 13 November. That
baseline/reference implementation and its finite verification were completed
under the former sign rule. The subsequent revision-31 signed-inclusion contract
is agreed, while its implementation and verification are explicitly held. No
new code, fixture execution or numerical run starts from this document change.
Requirements and administrative records may be updated. Existing budgets do
not reset; new execution needs explicit applicable authorization. Do not request
repeat agreement to signed inclusion or revisit individual examples.

Keep the burden formula, normalization and original results unchanged. The
compact-workbook implementation and any batch re-export remain separately
unapproved. Record the decisions reached during the interview before coding.

Original behavior was checked directly against the supplied quantifier, which
matches the June final-version/July upstream function. The
[prior controlled comparison](BOI_AMPLITUDE_BASELINE_COMPARISON.md) already
separates baseline selection, spatial support and timing effects; no new
biological validation or complete-burden availability is claimed here.
