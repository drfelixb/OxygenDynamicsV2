# Prepare Felix's recording test in ordinary MATLAB

5 October 2026 · Planning handoff · Owner: implementation Codex chat;
Felix selects the input and performs the manual test.

The next useful check is for Felix to use the current development download on
one recording and inspect its analysis outputs. Keep this personal test on the
[project agenda](SOFTWARE_NEXT_STEPS.md#next-on-felixs-agenda) until he reports its
outcome. Preparing instructions does not authorize Codex to start a recording.

## Starting point

- Repository: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/existing-analysis`.
- Branch: `development-existing-analysis-v3`; recorded HEAD 029c989.
- Version: **3.1.0-dev.2**, unchanged software build.
- [Accepted development-download delivery](SOFTWARE_LICENSING_DISTRIBUTION_DELIVERY.md):
  source 44f3031, candidate03, 448 matching package files. Preserve all candidates.
- Read the workspace/repository instructions,
  [development plan](SOFTWARE_DEVELOPMENT_PLAN.md) and
  [current status](planning/software-development-status.json).
- Preserve the current uncommitted agenda/status updates. No package rebuild or
  push is needed to prepare this walkthrough.

## Prepare one short manual walkthrough

1. Ask Felix which **one BOI recording** he wants to use. If its location is
   unknown, request it rather than selecting an unrelated recording. Read
   existing metadata only as needed to prepare the instructions.
2. Confirm the selected recording's timing authority, pixel calibration, tissue
   support and intended existing analysis settings. Do not assume that every
   recording is externally triggered at 1 Hz. Leave unsupported or unknown
   values explicit for the preflight decision.
3. Name a new unused output folder and agree practical time, storage and memory
   limits before the test. Explain the ordinary MATLAB stop procedure and that
   an interrupted run remains incomplete. Sampled memory is an observation,
   not a guaranteed hard limit.
4. Give Felix numbered instructions for installation, import, Review settings,
   starting analysis manually, inspecting sink/surge results, closing/reopening
   the completed result and exporting it. Use existing supported controls. State
   what he should see at each step in plain language.
5. Prepare a small results form: recording/settings/software identity, completed
   or failed stage, output path, start/end time, any available sampled peak memory,
   confusing controls and questionable values. Missing measurements remain
   unknown. Include the exact error and retained folder if the run fails.
6. Identify one event measurement and one recording summary to inspect after the
   manual run: trace, footprint, reference and event frames, source, formula,
   sign/units, unavailable values and contributor counts. Keep automatic and
   reviewed measurements distinct. Any subsequent numerical replay should be
   scoped to those two examples once their saved ingredients are available.

Preparation budget: 45 active minutes and 2 MiB of new textual documents, using
the existing installation/workflow guides. No application repair, numerical
suite, MATLAB launch, recording execution, build, commit/push or publication is
included. Deliver the short guide and stop for Felix's selected inputs or test.
Routine wording corrections stay within this preparation task.

Keep accepted formulas, references, footprints and scientific qualifications.
Custom containment, VM/watchdog work and worker qualification remain deferred
to a possible v4. Licensing and release decisions remain separate. A completed
manual workflow is evidence for that recording; it does not establish biological
validity or performance for all recordings.

## Copy into the next Codex chat

> The corrected licensing documents and development ZIP are accepted within
> their demonstrated scope. Read the current plan/status and preserve the local
> agenda changes. Prepare one short, scientist-readable walkthrough for **me to
> test one recording in ordinary MATLAB** using version 3.1.0-dev.2. Follow
> `docs/SOFTWARE_RESEARCHER_RECORDING_TEST_HANDOFF.md` within its 45-minute,
> 2-MiB preparation budget. Ask which recording I want to use, confirm its timing,
> calibration and existing settings, and agree a new output folder and practical
> resource limits. Explain import, preflight, run, inspection, reopen and export,
> with expected results and a simple feedback form. Include how to inspect one
> event calculation and one recording summary. Keep **Felix must run the recording
> test** pending on the agenda until I report its result. I will start the run
> manually when ready. Prepare instructions only; preserve calculations and
> original results, keep VM/watchdog work deferred, and start no MATLAB session,
> recording, diagnostic campaign, build, commit/push or publication. Deliver the
> walkthrough and stop.
