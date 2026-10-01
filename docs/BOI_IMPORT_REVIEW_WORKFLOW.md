# BOI input review in MATLAB

11 September 2026. The GUI and batch verification now share the BOI acquisition
and tissue preflight checks. This adds review visibility and input compatibility
gating; it does not establish scientific eligibility or change detection rules.

## Researcher steps

1. Open `OxygenDynamics_GUI`, choose the intended metadata CSV, then select
   **1. Run Verification**. To preselect a CSV from MATLAB, call
   `OxygenDynamics_GUI(inputCsv)`. Preselection does not run analysis.
2. Verification opens **BOI Input Review**. Select a recording to see its source,
   sampling evidence, exposure, calibration evidence, intensity/motion history,
   tissue support and unresolved issues. The lower panel scrolls; **Open full
   review** opens a larger reading window. Each issue states its affected
   measurements, evidence and required action.
3. Distinguish **Import failed**, **Held: unsupported input**, and **Readable;
   review open**. Import failures and unsupported declarations block the gated
   wrapper/statistics steps. Review warnings remain visible without an added
   approval dialog. A readable input can support conditional descriptive work;
   it is not scientific acceptance.
4. Correct input problems or record supported decisions with the existing
   source-bound declaration tools, preserving earlier sources and results.
   Run verification again after a change. A newly selected CSV or failed
   verification clears the displayed/current review rather than leaving an old
   successful review active.
5. Use the verification workbook's **BOIInputReview** sheet for issue details.
   The verification MAT retains `BOIImportReviews` and `BOIInputIssues`; the
   adjacent `_BOIInputReview.json` retains the reviews and exact captured
   acquisition/tissue declarations. These are local research exports and may
   contain private paths or source declarations.

The original **Verification** tab's Ready/Partial/Blocked column is explicitly
labelled **Technical status**. Ready describes file/output readiness; the BOI
panel separately states **Scientific eligibility: Not established**. The
workbook's NeedsReview sheet includes scientific-review warnings even for
technically Ready rows. Existing output folders alone do not establish matching
sources, modern calculation versions or scientific acceptance; statistics still
performs its separate saved-source/settings checks.

## Evidence handling

`createBOIImportReview` reuses the file validation already performed by
verification, then hashes the preserved TIFF and resolves the acquisition and
tissue declarations through the same helpers used by the master/input contract.
`reviewBOIRecordingInput` calls the same builder for individual MATLAB preflight.
Malformed or source-mismatched declarations become an actionable import-failure
review, including the declaration-file checksum when readable. Batch verification
can therefore retain the failed recording's issue alongside other recordings.
The master retains its own strict input guards.

The panel distinguishes camera exposure from frame spacing, and confirmed
uniform sampling from an assumed uniform grid. HP's user-confirmed **external
1 Hz** timing is displayed as confirmed; its incorrect embedded timestamps
remain provenance only. The captured 0.96-second exposure is separately shown.
Neither measured absolute timestamps nor verified dynamic frame validity are
invented.

A supplied static mask is labelled **Reviewed mask declared**. Its actor,
alignment evidence and limitations remain visible. Without one, the panel says
**Automatic estimate; unreviewed** and explains the implications for tissue
occupancy, area-normalized measurements and candidate support. This is a general
input review, not an automatic search for references or a tissue-mask editor.

The researcher clarified that the AQuA2 files are exploratory detection outputs.
They are not acquisition references or reviewed anatomical masks. Historical
outputs remain intact; no filename is promoted to anatomical evidence. See the
[HP source review](BOI_HP_LOCAL_INPUT_REVIEW.md) for the selected case's unresolved
reference, identity and calibration questions.

## Verification and limits

[Execution evidence](reference-results/boi-import-review-20260911/README.md)
covers readable inputs, confirmed sampling with unreliable metadata clocks,
source-review issues, unsupported timing, malformed declarations, explicit mask
declarations, report export and GUI recording selection. The actual GUI is also
exercised on the preserved staged HP recording using its verification callback,
without running detection or statistics.

This developer check does not replace the independent researcher usability
walkthrough, scientific review, a final cohort freeze or evidence for a real
anatomical mask. The existing full master and measurement results remain intact.
