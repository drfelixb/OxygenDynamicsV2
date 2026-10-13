# Clear support choices and accessible export folders

13 October 2026 · Development **3.1.0-dev.3** · No new package or release

The approved interface task fixes the observed missing-choice message and makes
the last completed event/window export easy to locate. **Detection support** still
starts unselected. Missing support now names the two choices and directs the
researcher back to **Review settings**. Required ROI evidence and explicit
confirmation remain; changing support invalidates confirmation. No calculation,
detector/correction parameter or scientific contract changes.

Both viewers keep a full read-only/selectable path under **Last completed export
folder**, with **Open folder** and **Copy path**. Row/frame interactions do not
erase it. Cancellation/failure preserves the previous successful destination;
an incomplete export is not advertised as completed. The file-manager command
receives separate arguments rather than a shell-interpolated path. Formats,
provenance and new-child/no-overwrite behavior remain.

## Identity and opening the software

- Version/build: **3.1.0-dev.3**, **2026-10-13 20:02:39 +02:00**.
- Branch: `development-existing-analysis-v3`; starting commit `029c989`.
- Exact source commit: recorded in the closing delivery-record update before push.
- Final branch, normal-push and single CI execution identities/outcome: reported
  in the final GitHub handoff and local transport receipt.
- All prior ZIPs remain **3.1.0-dev.2**. None contains these new controls; this
  task builds no replacement ZIP. Original inputs and results remain unchanged.

Follow [installation](../INSTALLATION.md). On Felix's current machine, start a
fresh ordinary MATLAB desktop, close older BOI viewers, and run:

```matlab
cd('/Users/zcm361/Documents/Github/OxygenDynamicsV2/existing-analysis');
addpath(pwd,'-begin');
setupOxygenDynamicsPath;
getOxygenPipelineVersion
which openBOIRecordingWorkflow -all
which createBOIExportFolderPanel -all
openBOIRecordingWorkflow
```

Expected: version/build above, with functions from that checkout and `helpers`.
Use **Open saved run → Choose BOIRun.mat** to select the completed FB2311 run
under workspace `reference-validation/felix-fb2311-manual-test-20261013/`.
Opening it performs no recording rerun. Inspect/export, then use **Open folder**
or **Copy path** beside the full completed destination.

## What was checked

The initial focused batch passed **9/13** and exposed four checks reading an empty
folder getter after success. A nested getter now reads the shared current
destination; the four affected checks then passed **4/4**. That gives **13 unique
final passing cases**, with the initial failure retained. Checks cover actionable
missing support, explicit whole-image/ROI behavior, confirmation invalidation,
disabled initial controls, copying, cancel/no-write, failure/incomplete destination,
previous-success retention, no overwrite and event/window selection persistence.
These are focused programmatic checks, not a full local scientific gate.

The named saved **FB2311** run reopened with **328 candidates**, unchanged settings
and the selected sink site 2/event 5. Whole-image preflight read the existing input
and matched saved effective parameters; missing ROI evidence was blocked. No
preflight output was staged. The new event/window exports match the accepted
trace/metrics/frame/event/check CSV data. Their four numerical values are unchanged:

| Quantity | Accepted export → new export | Reference/contributors |
|---|---:|---|
| Sink site 2/event 5 amplitude | 4.16290155% → 4.16290155% | 250 fixed pixels; 20 reference frames 479–498; measurement frames 499–514 |
| Whole-recording sink occupied fraction | 0.00574843697221921 → same | 1,200 modeled frame intervals; saved union area-time / sink tissue-time |
| Sink onset rate | 13.8485148981 → same events/mm²/min | 240 onsets, including one acquisition-boundary candidate; 0.8665189075 mm² × 20 min |
| Sink concurrent density | 3.9064352442 → same events/mm² | 4,062 event-seconds / (0.8665189075 mm² × 1,200 s) |

The original event calculator software remains **unknown**. Saved statistics retain
**3.1.0-dev.2**, build **2026-10-04 21:37:28 +02:00**; current receipts separately
identify reader/exporter **3.1.0-dev.3**. Existing source/contract/provenance fields
and unavailable values are preserved. No new physiological reference or mask is chosen.

Folder-opening and clipboard handlers used exact long paths containing spaces
and quotes. Both resulting folders were observed in Finder with the expected
export files and full path. Captures at **1280 × 900** and **1120 × 800** show
readable full destinations and Open/Copy controls. Event plot labels are crowded
at the smaller size; no broad viewer-layout claim is made. Chooser cancellation
was checked through the shared continuation given cancel result `0`, with no
writer call or new child. No new native-chooser mouse sequence or independent
researcher retest of the repaired controls is claimed.

Felix's existing MATLAB app appeared blank through desktop access; one call
timed out and another took 1,633.48 s to return. His session was preserved.
Two separate ordinary saved-only verification starts were used. The first test
failure was retained and its idle task-owned engine closed with SIGTERM after
checking its exact command; the repaired session exited normally. Both launch
wrappers returned code 0. No whole-process-tree cleanup/containment claim follows.

## Documentation, preservation and limits

README, installation/manual/walkthroughs, distribution/support/release wording,
plan, agenda, status and changelog now record the actual
[FB2311 manual-test result](BOI_FB2311_MANUAL_TEST_RESULT.md): Felix completed it
in **293.60 s** using 3.1.0-dev.2, inspected/exported the sink results and accepted
matching values after reopening. Assistant repairs/checks remain separate from
his feedback and from an unfamiliar scientist's independent walkthrough.
Numeric limits were not agreed before that run; **peak memory was not measured**.
Felix did not demonstrate surge inspection, native-mask attachment or that run's
indexed-workbook launch. Broader recording/platform support remains open.

Final static checks cover unchanged original/source copies, saved index/status/
audit/statistics/workbook and accepted exports, all three previous ZIPs and the
72 existing planning/definition JSON files. Only approved UI/request/version/test
MATLAB files change; calculation and export-writer source files retain their hashes.
The explicit future package policy includes the new presentation helper and the
necessary FB2311 reader record. Private preparation maps, movies, MAT/XLSX data,
screenshots and generated evidence stay outside the intended Git commits.

The historical Linux/R2025b gate remains **133/133 at 5c23b02**; the macOS/R2025a
full gate remains **132/133 followed by three targeted passes**, with no final
full rerun. One existing portable CI execution may be triggered by the delivery
push; its exact outcome/pending state is reported separately. No Linux desktop,
Windows or whole-application support is inferred from it.

Keep C02's conditional reference, FB2312's unresolved recovery, fixed-footprint
qualifications, automatic/reviewed separation and unknown historical calculator
versions. Optical percentages do not establish oxygen concentration or physiological
validity. Original MIT/dependency notices remain exact; licensing of new V2
contributions, declared support/publication and any new package remain decisions.
VM/watchdog/custom containment and worker qualification stay deferred to possible v4.

Used **two MATLAB starts**, **four focused validation batches**, approximately
**13 MiB** of local evidence/exports before closing receipts, and no recording,
detector/statistics run, refit or package build. Budget allows four active hours,
100 MiB, two commits and one successful normal push; all limits remain. One static
link check ran before this delivery file existed; the completed-document recheck
is retained with the preservation receipt. Stop after verified branch delivery:
no automatic further test, recording, diagnostic, merge/tag or public release.
