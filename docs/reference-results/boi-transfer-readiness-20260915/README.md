# Additional local BOI transfer readiness

R3-TRANSFER-READINESS-070 · 15 September 2026 · preparation/import check complete

[Report](report.md) explains the four metadata-selected cases and limitations.
[Prespecification](prespecification.json) freezes selection, roles, denominator,
criteria, budget and stopping rule before new source access. No event outcomes
were inspected or detection run. This is not independent validation.

[Source readiness](source-readiness.json) records full source hashes, original
inventory entries, fresh header evidence, reference candidates and staged links.
[MATLAB results](matlab-01/readiness.json) retain per-recording acquisition/QC;
the adjacent individual QC tables and [log](matlab-01.log) preserve every notice.
[Verification](verification.json) and [preservation](preservation.json) check
all four imports, 485 unchanged MATLAB files, 36 prior sealed artifacts and
source/declaration integrity. Import elapsed times exclude MATLAB startup.

The original source drive is read only. Local `staged/` contains one exact
source symlink per candidate plus a separate acquisition declaration. The
portable packet contains the declarations, not the TIFF links or MAT binaries.
Full local MAT import results are sealed locally. `source-readiness.json`
binds the linked payloads; source TIFFs are not duplicated into the evidence
seal. No denoised or legacy output file is substituted for the selected source.
Current checksums are first-recorded hashes where no prior whole-source hash
existed; old size/dimension matches do not prove historical pixel equality.

`prepare_sources.py` applies the frozen plan and checks source/reference files.
`checkMatlabReadiness.m` calls the unchanged production import review; its
portable snapshot has `.m.txt` extension. These scripts reject existing stage
or result directories. For a repeat, preserve this phase and create a new
run-specific preparation and output path before executing; do not rerun into
this sealed directory. Pinned inputs are in `inputs.json`, and source selection
is additionally bound by `SelectionSHA256` in the readiness result.

The checks ran in bundled Python and MATLAB R2025a. No production code changed,
so no unrelated regression suite was rerun. All four retain scientific-review
status. The 1 Hz researcher confirmation overrides unreliable source clocks;
FB2410's contradictory tag stays visible. Physical calibration, tissue,
preparation, label meaning, historical tuning and frame validity remain open.

`artifact-record.json` binds local/portable/current repository artifacts;
`completion.json` records its checksum. Their own files are outside that seal.
Next: source/tissue and preparation assessment beginning with FB2420, before
freezing any event-review queue or computing new reviewed optical quantities.
