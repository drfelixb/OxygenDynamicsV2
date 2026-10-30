# BOI batch setup repair

14 October 2026. Felix explicitly requested the remaining setup fixes, stimulation fields as optional metadata, and unchanged original recordings. This authorizes the bounded setup task below. It does not authorize analysis execution or scientific source-identity decisions.

- **ID:** BATCH-SETUP-FIX-01.
- **User benefit:** prepare the supplied 20-row HP batch in the editor without legacy stimulation values blocking BOI preparation or moving original movies.
- **Owner:** root Codex integrates setup and UI; batch-contract Codex changes/tests metadata semantics; source-audit Codex checks exact filenames and existing evidence; separate Codex reviewer checks the finished repair.
- **Scope:** preserve stimulation columns verbatim as descriptive metadata, never forward them to the BOI engine; create separate local input folders with references to exact raw/denoised sources and relevant source declarations; retain source-identity/pairing uncertainties as explicit holds. Preserve the source CSV and recordings. Resolve editor acquisition/support setup only from the existing supplied values and researcher-selected support.
- **Acceptance checks:** focused synthetic metadata/adapter and hold checks; saved current CSV IDs/other metadata preserved; exactly one raw and at most one paired denoised file per prepared folder; original source files unmodified; reopen the prepared copy in an existing MATLAB instance; report ready/held/pending settings truthfully.
- **Budget/stop:** at most four active hours, no additional MATLAB desktop, at most one bounded synthetic MATLAB check invocation (up to two targeted repair reruns), metadata/link evidence below 10 MiB. The finite 20 source pairs may be inspected for preflight only (at most 40 GiB of OneDrive cache hydration, within the observed 317 GiB free; no separate movie copies); no movie/detector/statistics execution, correction refit, copying large movies, package, commit/push, queue implementation or publication. Stop after setup delivery; unresolved source identity remains a researcher decision.

Researcher clarification: Felix has no preset ROIs and expects the existing automatic tissue estimate. The setup uses that explicitly requested method, saved as `whole-image`, with the clearer label **Automatic tissue estimate (legacy)** in both preparation interfaces. This is a wording change; calculation and support rules are unchanged.

Status: delivered locally as **3.1.0-dev.5**, build **2026-10-14 13:02:57 +02:00**. Detailed local mapping and evidence are retained in `reference-validation/boi-batch-ready-20261014` outside the repository.


## Demonstrated result

The prepared 20-row copy is saved and open in the existing MATLAB instance as
`HP_Compartments_BOI.csv`. Native preflight reports **17 Ready** and **3 Needs
attention**: FB2416/FB2417 share identical original and denoised candidates;
FB2318 has an unverified original/denoised filename pairing. The three source
holds require acquisition evidence and were not silently resolved. Other
identity, calibration and the existing FB2420 transient warnings are retained
in the source-bound declarations and visible in selected-row details.

All original descriptive fields, row IDs, 1 Hz sampling and 2.35 micrometres/pixel
remain exact. Stimulation text is preserved and excluded from BOI requests.
`SourceFolder` and `SetupNotes` are optional provenance. Whole-image support
retains its saved identifier and scientific behavior; only its displayed
explanation changes. Every row remains Not reviewed. No old run is associated
automatically.

Four focused synthetic MATLAB cases pass, followed by one targeted GUI recheck
for the added label/identity/QC presentation. The synthetic linked-input check,
copy-to-regular-file check and source-hold rejection pass. The real-input check
prepares requests only: 17 request source sets match the independent read-only
hashes and declarations; no engine runs. Forty movie files (37,811,452,803 bytes)
were hashed, hydrating OneDrive's cache as needed without separate movie copies.
Ten available historical full hashes match; thirty have no historical baseline
and are recorded as null. Source sizes and modification times remain unchanged.
The original OneDrive CSV and previous path-corrected working copy retain their
bytes. All 544 MATLAB files outside the eight listed interface/adapter/version/
test edits match the setup-start snapshot; scientific engine files are unchanged.

Separate Codex static review found and closed two draft evidence defects before
preflight: absent historical hashes had initially been labelled as matches, and
FB2410's trigger warning had been misclassified as an identity warning. Final
receipts distinguish missing comparison evidence and preserve the actual trigger
conflict. Review then verified the normalized declarations, links and manifest;
no remaining actionable defect was reported. This is technical review, not an
independent scientist's usability acceptance or validation of source identities.

Evidence is under `reference-validation/boi-batch-ready-20261014` outside Git,
including `batch-preflight-summary.json`, `row-checks.csv`,
`delivery-verification.json`, `source-hashes.json`, `setup-integrity.json`,
`review-receipt.json` and the preserved check logs. Text/MAT evidence is below
1 MiB, within the 10 MiB limit. Existing MATLAB was reused: zero new instances,
recording/detector/statistics runs, correction refits, queue executions, builds,
commits, pushes or publication. The saved old editor was closed and replaced
with the prepared copy in that session; the other MATLAB instance was preserved.

Setup repair is complete and stopped. Felix can try the prepared editor copy;
source reconciliation remains pending for the three held rows. Sequential queue
execution/live status writeback remains the separately proposed next milestone.
