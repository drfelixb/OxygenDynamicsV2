# FB2420 first run with accepted working support

15 September 2026 · R3-FB2420-FIRST-ROI-RUN-074

**One full master/statistics run and its source replay are complete.** All 330
events passed automatic amplitude/baseline/status and signed integral/mean replay.
Native masks are contained in their sign-specific support. These are technical
checks, not acceptance of biological event identity or physiological measurements.

## Method fixed before new event results

The prespecification selected the accepted 161,039-pixel mask and existing
`craniotomy-roi-1` profile, with unchanged default detection/measurement settings
and original recording-specific correction. Detection and amplitude use the
preserved original source; no denoised or legacy output was substituted. One
byte-identical source copy keeps the fresh run usable after drive disconnection.
Earlier sources, input stages, ROI proposal and acceptance remain unchanged.

The existing 20-pixel sink image-border rule gives 158,712 sink-eligible pixels;
surge support retains all 161,039 ROI pixels. This distinction is separate from
the accepted anatomical outline. No pixel/frame artifact exclusion was added.

The fresh acquisition declaration adds the phase-071 evidence of a 960 ms
camera setting in all 1,200 frame tags and a visible source-transient QC item.
The earlier declaration remains intact. Sampling is still exactly external
1 Hz, with frame 1 at modeled time 0 and 1,200 seconds of inclusive modeled
exposure. Camera exposure remains a declared setting, not measured shutter time.
Frame validity is unknown, with modeled inclusion explicitly retained.

CSV values `FB2420`, `baseline` and repeated `GFAP-ECS` labels are retained as
recorded. They do not resolve genotype, drug or KX-state semantics. The 2.35
µm/pixel value is provisional; matching default area parameters does not validate
physical calibration or detection sensitivity. This is descriptive transfer
development, not a cohort comparison or independent evaluation.

## Complete event and missingness denominators

| Saved sign | Events | Finite automatic amplitude | Unavailable amplitude | Negative finite saved-sign amplitude |
|---|---:|---:|---:|---:|
| Sink | 278 | 167 | 111 | 5 |
| Surge | 52 | 17 | 35 | 3 |
| Total | 330 | 184 | 146 | 8 |

Negative saved-sign amplitudes remain unchanged. They indicate disagreement
between that source-baseline measurement and the saved detection sign, not an
automatic sign repair or biological classification. Unavailable values remain
missing; neither event counts nor source arithmetic establish biological truth.

All-event native union occupancy is 0.4148% of modeled sink tissue-time and
4.2562% of modeled surge tissue-time. Events with unavailable amplitudes account
for 50.10% and 62.44% of their respective covered native area-time. These values
demonstrate why a finite-amplitude-only interpretation would omit substantial
detected support. They are conditional detected-support descriptions under this
working ROI and modeled frame inclusion, not calibrated physiological coverage.

For sinks, 216 events have measured time outside their native runs, totaling
1,768 sample-seconds across events. Surge measurement bounds equal the native
runs in this output. Native and measured duration remain distinct; no reviewed
onset/recovery or manual reference was transferred from FB2314.

## Inspected transient context

The frozen ledger checks the known center (row 330, column 432) and its 11 × 11
patch (rows 325–335, columns 427–437) at frame 17 against every event. It retains
fixed-footprint contact separately from native support, measured bounds and
retained clean prebaseline membership.

No event had native patch contact at frame 17, fixed-patch/measurement contact
at that frame, or fixed-patch contact with frame 17 in its retained baseline.
Thus the four sign-specific transient review slots are absent and were not
replaced. **This is not evidence that the spike is harmless:** correction and
ROI-wide normalization can couple pixels, and other source spikes have not
been traced individually. No causal effect, false-positive label, spike filter
or clipping rule was inferred.

## Frozen review queue

For each sign, the rule selected the first finite amplitude, first unavailable
amplitude, shortest/longest native duration and closest same-site recurrence,
plus the two transient-contact slots when present. Ties use native start,
site, event and audit row. Duplicate cases retain both reasons without replacement.
Fourteen slots yield ten filled slots and **nine unique cases**:

| Queue | Saved sign/site/event | Native frames | Selection reason |
|---|---|---|---|
| 1 | Sink 6/1 | 27–30 | First finite amplitude |
| 2 | Sink 1/1 | 1–44 | First unavailable amplitude |
| 3 | Sink 3/1 | 2–4 | Shortest native duration |
| 4 | Sink 17/1 | 101–160 | Longest native duration |
| 5 | Sink 5/2 | 18–22 | Closest recurrence |
| 6 | Surge 3/1 | 134–144 | First finite amplitude |
| 7 | Surge 1/1 | 1–10 | First unavailable; shortest duration |
| 8 | Surge 11/5 | 971–1034 | Longest duration |
| 9 | Surge 2/4 | 105–126 | Closest recurrence |

This is a purposive technical review queue, not a population sample. An
independent Python implementation reproduced all 14 slot dispositions, selected
row order/reasons, 330 recurrence gaps and 330 contact-logic records. That is
independent arithmetic implementation, not independent biological validation.

The first case is audit row 34, saved sink site 6/event 1. Its native bounds
are 27–30 and measured bounds 25–31. It has a finite **−7.0058% saved sink
amplitude**, so “finite” does not imply sign agreement or a recognized pocket.
The researcher subsequently answered **“I do not see a pocket”** for this case.
This is saved separately as `not_recognized`, with no onset/recovery frames,
in `researcher-review/BOI-researcher-review-01.json`. The exact question and
reply are retained in `feedback-01.json`. This recognition judgment does not
establish false-positive ground truth or alter any automatic output.

![First selected timing view](reference-results/boi-fb2420-first-roi-run-20260915/review-02/first-review-timing.png)

Open the live MATLAB view with:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-first-roi-run-20260915');
[Fig,UI] = openFB2420Review(1);
```

Use queue positions 1–9 for the other cases. The launcher checks the audit,
masters, statistics, selection and queue hashes, attaches both native sources
and opens the timing tab. The upper corrected-intensity plot is primary; the
lower filtered score supports inspection. Raw/correction QA is available through
its checkbox. Automatic bounds are not physiological annotations.

## Verification and feasibility

The master took 69.68 seconds, statistics 62.60 seconds and reconstructed-source
audit 58.57 seconds. Total execution was 210.73 seconds inside MATLAB, or
217.83 seconds including process/startup according to `/usr/bin/time`. Output
was 3.33 GB (3.10 GiB), within the frozen 5 GiB budget. With two thread workers,
the OS reported 12.40 GB maximum resident size and 19.11 GB peak memory footprint;
these are distinct OS metrics and matter for transfer to other computers.

The initial support-queue check failed because it passed the registry ID to
a helper expecting the master's recording-folder identity. The correction uses
the saved folder ID; the stable registry ID remains separately recorded. The
failed check, original script and initial bindings are preserved. The full
pipeline was not rerun. The final support check also matched native union
occupancy to statistics, and all signed integrals/means to the saved master fields.
The first live review launcher was exercised in a temporary MATLAB figure and
its exported screenshot visually inspected. This is developer verification,
not an independent researcher usability test.

The [evidence packet](reference-results/boi-fb2420-first-roi-run-20260915/README.md)
retains source/method bindings, all results and missingness, exact queue rules,
transient ledger, selected traces, resource evidence and preservation. All phase-073 artifacts and the pre-change MATLAB sources are preserved.
After the run, saving the first nonrecognition exposed an empty-boundary display
bug: MATLAB `unique([])` produces a column-shaped empty value, which the plotting
loop treated as one empty coordinate. `createBOITimingPanel` now normalizes the
manual bounds to a row before iterating; the passing event-review suite includes a regression test that loads a recognized
revision followed by a no-boundary revision, checks removal of purple marks,
retention of automatic bounds and unchanged measurements. Only this viewer helper
and its test file changed among the 485 MATLAB files. No detector or measurement
code changed, and the pipeline was not rerun. The saved judgment and failed
rendering log are retained; rendering is retried from the same immutable revision. No global
scientific policy was adopted.

Next is researcher recognition/timing/reference review of the frozen cases,
continuing with queue entry 2 (sink site 1/event 1). That case begins at
acquisition: native frames 1–44, measured frames 1–48, with unavailable automatic
amplitude because a sufficient clean prebaseline cannot be established.
An unobserved onset or pre-recording baseline must remain unresolved. Biological variability, physiological relevance,
feasibility, usability, traceability and BOI-only scope remain standing
requirements. Exact anatomy, frame validity, preparation/calibration, transient
effects, reference precision, physiological interpretation and evaluation
independence remain unresolved. Later detector/timing changes still require
the existing 48-event challenge and a separate decision.
