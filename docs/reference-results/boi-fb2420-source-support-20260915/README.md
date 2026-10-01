# FB2420 source and reference assessment

R1-FB2420-SOURCE-SUPPORT-071 · 15 September 2026 · source assessment complete

[Report](report.md) gives the findings and limitations. Start with the
[reference/source comparison](run-01/reference-source-comparison.png), then the
[six fixed frames](run-01/source-six-frames.png) and
[whole-field QC](run-01/whole-field-qc.png). Three figures were visually inspected.
No ROI, registration, frame exclusion, correction or biological admission was adopted.

- [Prespecification](prespecification.json): case, frozen frames/windows, criteria,
  stopping point and feasibility budget before image access.
- [Source QC](run-01/source-qc.json) and [all-frame values](run-01/frame-qc.csv).
- [Triggered addendum](spike-inspection-addendum.json) and
  [exact three-frame patches](run-01/spike-inspection.json).
- [Visual review](visual-review.json), [verification](verification.json),
  [input bindings](inputs.json), and [preservation](preservation.json).

`inspect_source.py` streams the original TIFF using bundled Python, NumPy and
Pillow. `inspection-arrays.npz` retains the native reference, full temporal mean,
three window means and six source snapshots. `display-arrays.bin` is a little-
endian float64 C-order transport; `display-layout.json` records its 11-plane
layout. Exact numeric equality of that transport and the NPZ was verified.
`plotSourceInspection.m` reads it in MATLAB R2025a and renders scientific figures
without a spatial transform. The portable MATLAB snapshot uses `.m.txt`.
`inspect_spike.py` reads the same three selected frames and records an 11x11
native patch around the frame-17 maximum. Source values are unchanged.

The initial Python plotting dependency failure occurred before source reading.
It is retained in `run-01.log` with the earlier script in `before/`. Successful
streaming is `run-02.log`. A later NumPy integer serialization failure in the
patch export is retained in `spike-inspection.log`, with its initial script;
`spike-inspection-02.log` records the corrected same-case run. No failed result
was replaced by another recording or a changed scientific selection.

The full streaming scan took 3.27 seconds excluding plotting/startup. The source
budget remained bounded; the addendum added two technical read attempts on the
same three frames. No detector, old output inspection, fit or production-code
change occurred. All 485 existing MATLAB files and 53 prior sealed artifacts
are preserved. The source and reference hashes were checked before/after;
phase-070 acquisition declarations remain unchanged despite new exposure evidence.

Preserve this evidence directory. A later replay must use a new output location;
the source runner rejects an existing `run-01` folder. Original movies remain
on the connected drive. Exact source paths/hashes are in the prespecification.
`artifact-record.json` seals local, portable and current repository artifacts;
`completion.json` records its checksum. Their own files are outside the seal.

Next is a provisional outline for researcher review. Visible vessels support
coarse correspondence; dark internal regions and boundary uncertainty remain
explicit. Localized high-value transients remain unresolved before biological
event interpretation. This is descriptive source assessment, not independent
validation or acceptance of physiological measurements.
