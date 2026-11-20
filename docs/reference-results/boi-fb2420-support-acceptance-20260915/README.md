# FB2420 working ROI acceptance

R1-FB2420-SUPPORT-ACCEPTANCE-073 · 15 September 2026 · acceptance recorded and verified

The researcher replied **“I accept”** to the exact phase-072 outline.
[Acceptance record](researcher-acceptance.json) retains that reply and its scope.
[Working-support report](report.md) explains what is accepted and still unresolved.

- [Writer decision](writer-decision.json) binds the actual acceptance, proposal,
  mask and overlay to the source.
- [Fresh-stage manifest](stage-manifest.json) locates the source link and unchanged
  acquisition declaration. The new [tissue declaration](staged/FB2420/BOITissueSupport.json)
  records exact native indices and provenance.
- [MATLAB verification](verification-matlab.json), [complete verification](verification.json),
  [input QC](accepted-input-qc.csv), [preservation](preservation.json) and
  [log](matlab-01.log) retain the outcome and all unresolved review issues.

The local `recordAcceptedSupport.m` calls the existing `writeBOITissueSupport`
then `reviewBOIRecordingInput`. Its portable snapshot has `.m.txt` extension.
The local `accepted-input-review.mat` retains full Review and Snapshot objects.
The portable packet omits the source symlink and MAT binary; it includes the
exact acquisition/tissue JSON. The source link is bound by the stage manifest.
No source movie is copied, altered or inserted into the evidence seal.

The 161039 mask pixels exactly match the accepted proposal. The earlier
acquisition declaration and source are unchanged; the previous stage still
has no tissue declaration. All 485 MATLAB files and 43 prior sealed artifacts
are preserved. Original pending-review status remains dated history.
The new input review reports reviewed static support and scientific review
still required. No detector run, sign change or implicit method selection occurs.

Preserve this directory and the accepted declaration. The writer refuses an
existing declaration or earlier master outputs. Future mask revisions require
fresh proposals and stages. `artifact-record.json` seals local, portable and
current repository artifacts; `completion.json` records its hash. Their own
files are outside the seal. Source payload hashes are bound separately.

Next: prepare the first source-bound run and event-review plan using the accepted
working ROI, with an explicit method profile and no silent treatment of localized
transients as biology. Registration, dynamic validity, calibration, preparation,
physiology, evaluation independence and cohort eligibility remain unresolved.
