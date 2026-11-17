# Pre-episode baseline implementation

16 October 2026. AMP-EPISODE-01; owner root Codex, no delegation.
Felix explicitly approves the pre-episode reference and withholding references
more than 20 seconds older than the event's usual baseline. Original automatic
measurements and files, burden formula, area/time normalization, detector,
event boundaries and footprints remain.

## Bounded items and acceptance

- AMP-EPISODE-01A: shared versioned reference. Link consecutive native sink runs
  at the same site only when their gap is less than 20 seconds and their fixed
  event footprints intersect. Carry the first event's existing baseline interval;
  measure it on each event's own footprint. This is a numerical recurrence rule,
  not proof of physiological recovery. Require the full original baseline length,
  finite samples, positive mean and no native overlap of either sign. Withhold
  when the interval shift exceeds 20 seconds; do not search for another interval.
  Acquisition-start series remain unresolved; no post-recovery fallback.
- AMP-EPISODE-01B: integrate saved-run stats and future measurements through the
  same service. Read saved audited traces and receipt-bound native masters;
  never rewrite them. Append derived reference fields beside original fields.
  Burden uses the derived amplitude including explicit missingness; no fallback
  to the contaminated original when a derived reference is withheld.
- AMP-EPISODE-01C: export within the existing workbook/MAT formats and sheets,
  with original/derived amplitudes, reference interval, source/version, review
  status and recording-level missingness. Preserve strict unavailable totals.
- AMP-EPISODE-01D: synthetic reference, identity, missingness, clock, export and
  normalization checks; the named FB2412 examples must reproduce 7.465059534%,
  6.012181174% and unresolved recording-start amplitude, and event 3's normalized
  contribution 2608.970112849447. Protect earlier master/audit/workbook hashes.

Stop after these checks and local delivery. No all-17 re-export, new detector
run, manual event-by-event review requirement, packaging, commit/push or release.
Limits: four active hours, six focused five-minute MATLAB invocations plus two
targeted repairs, 100 MiB evidence, 200 MiB synthetic output.


## Local delivery and verification

Delivered local **3.1.0-dev.9**, 16 October 2026. All four bounded items are
complete. [User guide](BOI_PRE_EPISODE_BASELINE.md). Implementation is stopped.
No new milestone, supplied detector run, package or publication is inferred.

- 129 distinct focused cases pass across the final reports. The final
  reference suite is 15/15, including the real existing stats loader with a
  tiny disposable source/receipt/master fixture. Broader compatibility is
  102/102. Earlier focused checks are 59/59; overlapping cases are counted once.
  Dictionary versions and distribution source paths validate. Code Analyzer
  reports style/performance suggestions, no parse errors. Expected warnings
  from rejection fixtures remain.
- FB2412 event 3 uses 639–658, mean 822.6566909975669, amplitude
  6.012181174339028%, contribution 42299.692661956 and unchanged normalized
  event contribution 2608.970112849447. Event 2 retains its own original value;
  isolated event 4 is unchanged; acquisition-start event 1 stays unavailable.
- All original saved event columns remain identical. Nine protected historical
  hashes (masters, audit, earlier evidence and combined workbook) are unchanged.
  Independent Python arithmetic checks reference means, amplitudes, products
  and exposure scaling; workbook readback verifies original/derived columns
  and blank missing values. The selected-example workbook excludes recording
  and group totals and time series so a subset cannot masquerade as a full run.
- Six headless MATLAB starts total 236.99 seconds. Retained initial
  failures: a missing fixture registry field, report concatenation, an excluded
  development test in the distribution list, and a fixture-only empty struct
  initialization. Their bounded repairs pass. Evidence before closeout is
  384,774 bytes. No supplied movies are read; synthetic sources are used only
  for software checks. No detector run, 17-recording export or original overwrite.

The original pipeline contract describes the unchanged original measurements.
The additional `boi-pre-episode-1` version is stored separately in event rows,
source AnalysisInfo, StatsInfo and the workbook policy sheet. Saved detector
outputs are not falsely invalidated. Legacy tables without derived fields
retain their prior burden behavior; new BOI stats explicitly withhold derived
measurements when saved evidence is absent. Original automatic QC and derived
reference QC remain distinct.

Evidence: workspace-root `reference-validation/boi-pre-episode-implementation-20261016/`,
including final verification, final test CSVs, independent arithmetic and
`FB2412_selected_examples_only.xlsx`. This is a software regression, not proof
of physiological recovery or a complete recording burden. The original combined
17-recording export remains unchanged. A fresh combined export will use the new
reference; any unresolved required contribution still prevents a complete
recording total. No partial-burden endpoint is introduced.
