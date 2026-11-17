# Complete burden in the stats preview and exports

29 October 2026. Work item BURDEN-COMPLETENESS-01; owner root, no delegation.
Felix's continuation authorizes the directly proposed strict-completeness check.

An unresolved included event withholds the recording's complete burden and
every normalized version. Available event counts describe missingness; they
are not burden coverage and cannot justify scaling a partial sum. Explicit
saved recognition decisions can exclude a detection in reviewed exports.
Uncertain or unreviewed detections remain included.

The recording and reviewed-export calculators already enforce this rule.
The stats GUI preview did not: its display helpers used omit-missing sums,
means and maxima. A synthetic pair with contributions 80 and unavailable
could therefore display an event sum of 80; entirely missing inputs could
display a sum of zero. The saved recording totals remained unavailable.

The preview now displays `Unavailable` and unresolved-input counts for these
burden summaries. It also shows available event-contribution counts and complete
normalized recording counts, explicitly labeled as counts. Complete and known
zero-event values retain their existing arithmetic. This change is in the
preview-row builder; the native panel has not been reopened during this check,
to preserve the live unsaved area review.

The existing exported group summary averages complete mouse summaries and
reports each metric's `NValidMice`. A missing recording still withholds its
mouse's mean. Those calculations and counts are unchanged. The GUI no longer
presents an aggregate over only available mice as a complete summary: it shows
the number of unresolved mouse summaries instead. Event means/medians and the
other existing descriptive measures retain their distinct definitions.

Workbook basis notes now explicitly describe strict missingness and warn that
integrating only finite portions of a gapped time trace does not produce a
complete recording burden. Workbook names, sheets, columns, CSV formats,
amplitude × mean area × inclusive duration, and recording area/time normalization
are unchanged. Historical workbooks are preserved.

The preserved reviewed export from 26 October contains 17 recordings, 5,404
retained detections, 3,257 available contributions and 2,147 unavailable
contributions after three explicit rejections. All 17 complete recording
burdens and every normalized variant remain unavailable. This read-only check
does not incorporate the live FB2412 area draft or create a fresh cohort export.

Verification: MATLAB R2025a passes 25 focused synthetic tests with no failures
or incomplete tests. They cover each missing event ingredient, registry and
fallback aggregation, all normalized totals, complete and zero-event values,
GUI sums/means/maxima, incomplete mouse summaries, reviewed exclusions/imports,
uncertain or spatially mismatched areas, and XLSX/CSV numeric readback. All six
changed MATLAB files have empty Code Analyzer reports. The three suites are
included in the existing software-check runner. This is software verification,
not validation of a biological boundary or a new area method.

Thirty-nine protected code/result artifacts match their pre-work checksums.
The only change inside the burden calculator is the two workbook-note strings.
No source images, scientific judgments, original results, area rule, correction,
baseline, formula or normalization changed. Tests used one headless MATLAB
start; the existing desktop session and draft were untouched. Evidence:
`reference-validation/boi-burden-completeness-20261029/verification.json`.

The work item is complete and stopped. The extended FB2412 pocket's area and
burden remain unresolved; the experimental area rule is not adopted. A future
area-measurement decision is separate from this completeness fix.
