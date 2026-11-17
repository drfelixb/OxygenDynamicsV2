# FB2311: completed manual recording test

13 October 2026 · OxygenDynamics development **3.1.0-dev.2**

Felix ran this recording in ordinary MATLAB, inspected and exported the sink
results, and reopened the completed run. He confirmed that the event count,
selected event and recording summary matched after reopening, then reported:
“ok, all matches. i think we are good”. This accepts the demonstrated workflow
for this recording.

## What worked

- A new analysis completed in **293.60 seconds** (about 4 minutes 54 seconds).
- The saved result contains **328 automatic candidates: 240 sinks and 88 surges**.
- Sink **site 2, event 5** could be inspected with its trace and source footprint,
  exported, and reopened with frames **499–514**, amplitude **4.1629%** and
  **20 clean reference frames** unchanged.
- The whole-recording sink summary could be inspected, exported and reopened
  with the same three measurements.

| Measurement checked | Result | Evidence |
|---|---:|---|
| Selected event optical drop | 4.16290155% | Independent replay of the original 250 pixels on 20 reference and 16 event frames |
| Mean occupied tissue fraction | 0.005748437, or 0.5748437% | Independent replay of 1,200 saved frame areas and the tissue-time denominator |
| Event onset rate | 13.84851490 events/mm²/min | Independent replay of 240 saved event intervals and unit conversions |
| Concurrent event density | 3.90643524 events/mm² | Independent replay of event overlap time and tissue-time |

The recording has 1,200 frames at the **1 Hz** rate confirmed by Felix; pixel
size is **2.35 µm/pixel**. Sink tissue support is 156,907 saved pixels, or
0.8665189075 mm². Reopening was confirmed by Felix's reports, rather than a
new assistant-operated MATLAB session.

## Where the result is saved

Run folder, relative to the workspace (outside Git):

```text
reference-validation/felix-fb2311-manual-test-20261013/BOIRun_FB2311_20261013_01
```

Use **Open saved run → Choose BOIRun.mat** to reopen its `BOIRun.mat`.

The containing test packet retains the input preparation record, screenshots,
event/window exports and the independent calculation scripts and results:
`independent-event-replay.json` and `independent-sink-window-replay.json`.

## Limits retained

These checks establish the selected arithmetic and saved-result workflow for
one recording. They do not establish physiological event identity, reference
suitability, correction validity or anatomical validity of the saved tissue
estimate. Native detector masks were not independently reconstructed. The sink
summary includes one acquisition-boundary candidate under the existing rule.

Peak memory was not measured and numeric resource limits were not agreed before
Run. Surge inspection, native-mask attachment and opening this run's indexed
workbook were not demonstrated. The denoised detection input differs from the
preserved amplitude input; a removed-trend comparison remains unavailable.

The initial empty-support preflight error and difficulty finding the export
path remain historical usability observations. The later 3.1.0-dev.3 interface
delivery adds actionable support guidance and persistent full export paths with
Open folder/Copy path. Its assistant checks are separate from Felix’s original
manual test; he has not reported a new independent test of those controls.
No calculations, original inputs or previous results changed. No new execution,
commit/push, packaging or release is authorized by this acceptance.

**What’s next:** keep the completed run as the named checked example. No recording
rerun follows from the interface update; release remains a separate decision.
