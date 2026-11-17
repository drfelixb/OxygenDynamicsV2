# Portable BOI checks and desktop evidence

Run `runBOISoftwareChecks('portable','ci-results')` for the portable automated
gate. It selects calculation, saved-result, rejection and export checks using
small fixtures; no local research folders or supplied recordings are needed.

The new independent arithmetic JSON fixtures carry named inputs and answers
frozen during the accepted Step 2/3 work. Unit suites protect duration/native
area/occupancy/rates, signed integrals and units, composites, strict missingness,
unequal mouse weighting, zeros, sign conventions, contributor counts, workbook/
CSV/MAT export and original/current provenance. Reviewed-pocket scalar traces
protect −20% raw/−25% saved corrected examples, conditional surge footprints,
unresolved recovery, missing correction/clock/reference and immutable round
trips. Supported saved audit dimensions require source-matched metadata;
failed/incomplete and unsupported artifacts are rejected. Existing BOI indexed
run schema and source/artifact integrity checks stay included.

`runBOISoftwareChecks('desktop')` selects explicitly listed programmatic GUI
checks; `'all'` combines both. No automated result establishes human usability
or native chooser behavior. The accepted Step 4 installation demonstration and
earlier native-chooser evidence remain separate records.

The default gate is portable. JSON and JUnit reports include MATLAB release,
computer, selected test names/counts and GitHub SHA. CI uses Linux R2025b and
Image Processing/Statistics and Machine Learning toolboxes, with a 30-minute
job timeout. GitHub Actions details: [MATLAB command action](https://github.com/matlab-actions/run-command),
[artifact uploader](https://github.com/actions/upload-artifact). Actual named
support and results are recorded in the Step 5 delivery, not inferred from CI
configuration. Windows/other releases and new recordings remain untested here.
