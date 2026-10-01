# Restricted ROI implementation evidence

Decision **R1-C02-STRICT-032**, 12 September 2026. Implementation phase complete;
scientific validation remains open. No biological recording was processed by
the new method in this phase. The default whole-image method and prior outputs
remain available. [Researcher workflow](../../BOI_STRICT_ROI_WORKFLOW.md).

## Verified behavior

- **53 distinct tests passed**, combining the complete 52-test run and the
  subsequently added spatial-bin test; 12 affected tests were rerun after that
  correction. [Named results](unit-results.csv) retain the latest successful
  result per test; all execution logs and result MAT files remain local.
- Two synthetic 192×192×240, 1 Hz recordings have identical interior data and
  strong, different finite exterior signals. Each produces **10 sinks and
  4 surges**. All final native footprints and event measurements match exactly,
  as do spatial-bin traces. Counts are implementation observations, not detector
  sensitivity or biological acceptance targets.
- **28/28** independent preserved-source event audits agree, with reconstruction
  of ROI normalization and detection traces. Every final native footprint is
  exactly inside its sign support. Constant input produces **zero events**.
- Explicit arithmetic tests cover ROI sample standardization and included-neighbor
  averaging; fixtures cover weak/strong, recurrent/sustained and boundary-crossing
  signals for both signs. Empty/invalid support fails explicitly.
- Statistics preserve the effective profile in registry, MAT, JSON and readable
  review. Source-bound mask/weight validation and mixed-method rejection pass.
  Exported occupied-fraction ingredients independently reproduce the summary.
- The existing full legacy integration passed, including known-event measurement
  and zero-event export. Runtime: **8.62 s**.

The final strict synthetic workflow took **26.78 s**,
including three masters, detection reconstruction/source audits and one statistics
export. Master times were 3.45, 2.77, 1.41 s;
statistics took 9.57 s, using two thread workers in MATLAB
R2025a. These small-fixture times are not full-recording resource estimates.
[Structured result](synthetic-verification.json).

## Method and retained corrections

`craniotomy-roi-1` / `3.1-roi-dev` restricts spatial normalization, weighted
smoothing, percentile support, components and final native support. Spatial-bin
means use included observations only. Baseline, signed source measurements and
dictionary 0.3.0-draft formulas remain unchanged. ROI-only normalization can
suppress shared responses; native source interpretation remains necessary.

Initial `integration-01` passed event and source checks but preceded the final
spatial-bin correction. Inspection found that partly covered bins could average
exterior computational zeros. The optional included-pixel mean was added with
its own arithmetic test and saved policy. `integration-02` is the final complete
workflow evidence; earlier outputs are retained and are not final method inputs.
An initial final-verification dispatcher failed before testing because MATLAB
`run` changed its directory; the corrected dispatcher resolves the repository
explicitly. This was not a biological analysis retry. The first unit run opened
MATLAB's default 14-process pool; subsequent checks explicitly used two threads.

## Reproducibility and limits

Local evidence root: `workspace/reference-validation/boi-strict-roi-implementation-20260912`.
It contains both synthetic attempts, source TIFFs and declarations, complete
master/stats outputs, source audits, test MAT/CSV/logs, prior edited-file copies,
a complete final MATLAB source snapshot and a change patch.
[Final code hashes](code-manifest.csv), [existing-file changes](changed-existing-files.json)
and [preservation checks](preservation.json) identify the final implementation.
181 immutable 031 artifacts, the original FB2314 source and its three
legacy outputs are unchanged. Updated standing documents are separately recorded;
their previous contents remain in the local `before` snapshot.

Implementation checks do not settle uncertain boundaries, physiological event
identity, baseline meaning, global optical changes, dynamic tissue validity,
camera exposure, biological transfer or independent researcher usability.
The opt-in selector is currently a MATLAB context field. No GUI profile selector
or release acceptance is claimed.

## Next bounded comparison

[Prespecification](next-comparison-prespecification.json): one FB2314 awake
candidate run against the saved 031 support-only arm, with exactly the same full
source and working ROI. Compare native support, availability, original traces
and feasibility, without a count or treatment-effect target. Other animals and
states remain outside this experiment.
