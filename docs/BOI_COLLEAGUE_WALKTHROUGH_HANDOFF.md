# Prepare the current download and a colleague walkthrough

14 October 2026 · Historical proposal, skipped for the current plan

**Status update, 14 October 2026:** Felix requested skipping the second user
review and moving to [batch CSV and GUI usability planning](BOI_BATCH_GUI_PLAN.md).
This colleague task, including its package/material preparation, is skipped.
No unfamiliar-user feedback or completed gate is claimed. The proposal and
unpasted execution prompt below are retained as history, not the next task.

Prepare a development download containing the accepted interface fixes and a
short session in which a scientist unfamiliar with this work can open FB2311,
find an export and reproduce one event amplitude and one recording summary.
The purpose is to check whether the software and its numbers are understandable
to someone else. Use existing saved data throughout.

Felix accepted the 3.1.0-dev.3 interface delivery on 14 October. This handoff is
prepared for a separate execution instruction; the prompt at the end authorizes
the complete preparation task, including routine repairs and focused rechecks.

Internal work item: **USER-READY-02**. Codex owns package/material preparation;
Felix arranges the human reviewer and decides release scope.

## Starting point

- Workspace: `/Users/zcm361/Documents/Github/OxygenDynamicsV2`.
- Git repository: its `existing-analysis` child.
- Branch: `development-existing-analysis-v3`.
- Current HEAD: `984288f1f16a57abb8cbc13e3a962b9ab923d624`.
- Accepted application source: `7eb3cc8f8291d0ead01f18069d9ec1b390cbf5a9`;
  the closing commit above changes documentation/status.
- Version: **3.1.0-dev.3**, build **2026-10-13 20:02:39 +02:00**.
- Portable Linux/MATLAB R2025b checks: **134/134** at `984288f`.
  Full final macOS checks remain incomplete; desktop evidence is separate.
- Previous ZIPs contain **3.1.0-dev.2**, without the new folder controls.

Read `AGENTS.md`, the active [plan](SOFTWARE_DEVELOPMENT_PLAN.md),
[status](planning/software-development-status.json),
[accepted interface delivery](BOI_USABILITY_GITHUB_DELIVERY.md),
[FB2311 test](BOI_FB2311_MANUAL_TEST_RESULT.md),
[installation instructions](../INSTALLATION.md), and
[release decisions](RELEASE_DECISION_SHEET.md).

Inspect the actual checkout/diff and preserve local work. The private
`docs/planning/felix-manual-recording-preparation.json` remains local. If the
branch has advanced, reconcile the changes before freezing package hashes.
Older cohort, protocol and recording-run walkthroughs are historical and do not
authorize those activities here.

## Prepare a verified development download

Use the existing `createOxygenReleasePackage` and explicit source policy to
create a new **3.1.0-dev.3 development test ZIP**, software folder and extracted
copy. Preserve earlier downloads. A proposed new local output packet is:

```text
/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-colleague-preparation-20261014
```

That path was absent during handoff preparation. Check it again before use; if
occupied, choose a new sibling instead of overwriting it.

Pin the actual source/policy hashes and record whether the source is committed
or has documentation changes. A base commit identifies ancestry; the manifest
identifies the exact packaged files. Check folder/ZIP/extraction agreement,
relative archive paths, required legal notices, and links needed by the reviewer.
Keep recordings, result MAT/XLSX files, private paths and bulky evidence outside
the software ZIP. Place the reviewer materials separately alongside it.

Verify version and function resolution from the extracted software, including
`createBOIExportFolderPanel`, with the development checkout excluded from the
MATLAB path. Use that extraction to open the saved FB2311 event/window views
and demonstrate the folder controls. Avoid testing with cached checkout code.
Packaging is not permission to execute a detector/statistics smoke run.

Keep the application version/build unchanged for packaging and documentation
only. Routine instruction or compatible GUI repairs may be completed within
this task; if application code actually changes, follow the existing development
version policy, record the new source and check the affected route before the
final build. Preserve scientific contract and original saved-calculator identity.

## Prepare a short session for a colleague

Provide a one-page instruction sheet and a small feedback form. Plan approximately
30–45 minutes on Felix's Mac, in ordinary MATLAB, with the existing result
available read-only. A colleague can perform both the unfamiliar-user walkthrough
and the arithmetic replay; record who did each activity and what assistance they
received. A separate remote-computer/data-portability test is outside this task.

The sheet should ask the colleague to:

1. Extract the development download, start the interface and confirm its version
   and software location.
2. Use **Open saved run → Choose BOIRun.mat** to open the existing FB2311 run.
   Confirm **328 automatic candidates** and inspect **sink site 2, event 5**.
3. Explain which trace/frames define its automatic amplitude, what its positive
   drop-oriented sign means, and why an optical percentage is not oxygen
   concentration. No new event judgment or reference is selected.
4. Export the selected event and the whole-recording sink window into new
   disposable children. Use **Open folder** and **Copy path** to find the outputs.
   Explain how the event intensity percentage differs from occupied tissue fraction.
5. Reproduce the two quantities below using a calculator, spreadsheet or their
   own small calculation from exported ingredients. Opening the existing
   assistant replay result alone does not count as the colleague's calculation.
6. Record unclear wording, assistance required, observed errors and whether they
   could understand the numbers and locate the exports.

Provide the formulas and an answer sheet, keeping the source ingredients and
units visible. No replacement GUI or calculator application is required.

## Reuse these exact results

The existing packet is:

```text
/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/felix-fb2311-manual-test-20261013
```

Run child: `BOIRun_FB2311_20261013_01/BOIRun.mat`.
Event export child: `BOIEventReview_tpbec838ab_fbe1_4c53_b6da_f6e034d0ca38/`.
Window export child: `BOIWindowReview_tp0b5173e7_04d3_4017_b0cf_ced062eada80/`.

Use the existing `SelectedEventTrace.csv`, `FixedAmplitudeFootprint.csv`,
`Frames.csv`, `Events.csv`, `Metrics.csv` and their relevant provenance/checksums.
Small copies may be placed in a separate local reviewer kit; preserve bytes and
clearly name their source export. Do not copy TIFF movies or the entire run.
The complete run remains at its existing local path for the GUI session.

**One event amplitude:** the preserved-input trace averages 250 fixed pixels.
Reference frames **479–498** give 20 samples; measurement frames **499–514**
give 16. Calculate the reference mean B and minimum event intensity Imin from
the trace, then `100 × (B − Imin) / B`. Expected B is **5637.9378**, Imin is
**5403.236** at frame **508**, and optical drop is **4.162901548860646%**.
Use the exact flags/frames and multiply a fraction by 100 once.

**One recording summary:** calculate
`100 × sum(CoveredAreaTime_um2_sec) / sum(AnalyzedTissueTime_um2_sec)` from
`Frames.csv`. The saved numerator is **5,977,355.19 µm²·s** and denominator is
approximately **1,039,822,689 µm²·s**. Expected occupied tissue fraction is
approximately **0.00574843697221921**, or **0.5748436972%**. It describes native
sink union area inside saved sink support over the modeled window, with overlaps
counted once. Preserve the 1,200-frame, 1 Hz, 2.35 µm/pixel context.

These are arithmetic/use examples. Reference suitability, correction validity,
anatomical support and physiological event identity remain separate. Preserve
missingness, sign-specific support and automatic/reviewed separation. The other
accepted numerical results and historical qualifications remain unchanged.

## Keep human feedback and release decisions separate

Complete the preparation even if no colleague has been named. Once materials
are ready, ask Felix who will try them and record the participant's actual
feedback when received. Do not contact others or send research files without
Felix's authorization. Do not substitute a Codex review or assistant-operated
check for the human walkthrough. If no human session happens, deliver the ready
kit and leave that gate pending without inventing another test phase.

Reconcile the release decision sheet with current evidence, including the
134/134 Linux result and accepted interface delivery. Give Felix a short list:
licensing coverage for new V2 contributions, intended supported environments,
development versus stable release identity, and eventual publication approval.
Retain the original MIT and dependency notices; do not choose a copyright holder,
year or new blanket grant. Packaging for this local walkthrough does not decide
distribution rights or authorize publication. Peak memory remains unmeasured;
the single FB2311 run does not establish broad recording/platform performance.

## Budget and completion

Budget: **four active engineering hours**, at most **two development-package
builds**, **two assistant-started MATLAB sessions**, **four focused verification
batches**, and **100 MiB of new artifacts**. Routine repairs/rechecks fit inside
those totals. The later human walkthrough is one planned ordinary session,
recorded separately from assistant verification. Check space and sizes before
copying. Reuse the preserved inputs; retain failed attempts and report actual use.

Deliver the verified ZIP, source/file manifest and checksum, exact opening
instructions, colleague sheet, formula/ingredient kit, feedback form, concise
release decisions and preparation receipt. Keep current plan/status truthful:
materials ready is distinct from actual colleague feedback and release acceptance.

If Felix defers the colleague session, he can continue using the accepted
checkout while the unfamiliar-user release evidence remains pending.

Check hashes of the saved run's index/status/audit/statistics and accepted exports
before/after relevant operations. Do not overwrite them. Read data as needed;
no recording, detector/statistics execution, correction refit, new scientific
boundary/reference/label, performance campaign or full historical test matrix.
VM/watchdog work stays deferred. No delegation, external messages, commit/push,
main merge, release tag or publication is included. Stop after preparation, or
after recording an actually arranged human session within this same scope.

## Prompt to paste into the implementation chat

> I approve the complete preparation task in
> `existing-analysis/docs/BOI_COLLEAGUE_WALKTHROUGH_HANDOFF.md`. Prepare a verified
> development download containing the accepted interface fixes and a short
> colleague walkthrough using the existing FB2311 result. Include clear
> ingredients/formulas for one event amplitude and one recording summary, a
> feedback form and the remaining release decisions. Routine repairs and focused
> rechecks are included within the stated budget. Preserve calculations,
> recordings, saved results and previous packages. Prepare everything before
> asking me to arrange the colleague. Claim human feedback only when received.
> No recording rerun, commit/push or publication. Deliver the ready materials
> and exact opening instructions, then stop.
