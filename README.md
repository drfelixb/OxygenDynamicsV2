> Development snapshot: **3.1.0-dev.2**, build `2026-10-04 21:37:28 +02:00`.
> This is not a release; prior saved-run metadata remains unchanged.

# OxygenDynamicsV2

MATLAB software for analysing bioluminescence oxygen-imaging recordings and
reviewing local decreases in signal, often called oxygen pockets.

**Our current priority is correct analysis calculations and clear outputs.**
Detection identifies candidate events. You can inspect those candidates and
make your own measurement choices before interpreting the results.

## What you can do now

- Reopen an existing analysis and inspect its event traces and saved image regions.
- Mark an interval as a pocket and choose the exact frames before it to use as a reference.
- Measure the deepest decrease in the corrected signal, with the uncorrected measurement alongside it.
- Record an uncertain reference or an unresolved recovery explicitly.
- Save your choices, reopen the same measurements and export the values and calculation inputs.

The recent work made this reviewed-measurement workflow usable from the MATLAB
interface, including folder selection, cancellation and a readable saved-result
viewer. Original automatic results remain available separately.

## What the numbers mean

| Number | Meaning |
|---|---|
| Detection score | A normalized signal used to find candidates. It is not a percentage intensity change. |
| Automatic amplitude | Preserved-input intensity relative to its own pre-event reference: a positive drop for sinks or positive increase for surges. Stored fractions and explicitly named percentage columns are separate. |
| Reviewed raw decrease | The lowest uncorrected intensity in your chosen interval, compared with your chosen reference mean. |
| Reviewed corrected decrease | The lowest corrected intensity in your chosen interval, compared with the corrected reference mean and scaled by the uncorrected reference mean. |

For a reviewed pocket, the main measurement is:

```text
100 × (lowest corrected intensity − mean corrected reference intensity)
      / mean uncorrected reference intensity
```

A negative value means a downward optical change. For example, −5% means a
corrected decrease equal to 5% of the uncorrected reference intensity.
**It does not mean a 5% decrease in oxygen concentration.**

Both reviewed measurements use the same selected frames and saved image region.
The reference intensity must be finite and positive. Missing required inputs
produce an unavailable result, rather than a replacement reference or a zero.

[Read the short measurement guide](docs/POCKET_MEASUREMENTS.md) for examples,
reference selection, units and the meaning of uncertainty labels.

## Understand automatic summary exports

New BOI statistics exports include an `AutomaticAmplitudeGuide.md` report,
companion definition/count/availability sheets in the workbook, and CSV/MAT
copies. Existing columns and values retain their identifiers and definitions.
Site means include negative finite amplitudes. Recording burden-amplitude means
exclude negative drop-oriented amplitudes. Composite means additionally require
available event area and duration. Mouse means require every recording value;
group means weight contributing mice equally. Each affected average has its own
contributing count, total count and observation unit.

[Read the automatic amplitude guide](docs/AUTOMATIC_AMPLITUDE_EXPORTS.md) before
comparing site, recording or mouse summaries. Existing saved outputs are not
rewritten automatically.

## Start with a saved result

Follow the [portable saved-result walkthrough](docs/BOI_ORDINARY_MATLAB_WALKTHROUGH.md)
and [two worked calculations](docs/BOI_SAVED_CALCULATION_WORKED_EXAMPLES.md).
The software candidate excludes recordings and example results; supply saved
ingredients separately. [Distribution limits](DISTRIBUTION_STATUS.md) distinguish
complete Linux calculation evidence, partial final macOS gate evidence and
assistant-operated saved workflows from independent researcher feedback.

Open MATLAB in the installation folder and run:

```matlab
setupOxygenDynamicsPath
Start_OxygenPipeline
```

1. Open **BOI recording workflow**, then **Reopen saved run**.
2. Choose a completed analysis folder and open **Inspect event traces**.
3. Select an event. In **Reviewed optical → Reviewed pocket**, enter your pocket
   interval, reference frames, reference suitability, recovery status, reviewer
   and reason. Confirm the established timing of that recording.
4. Click **Preview draft** and inspect the values and qualifications.
5. Click **Save NEW revision**. Choose a parent folder; the software creates a
   new folder inside it and displays its path.
6. Use **Reopen saved revision** to choose that saved folder itself, or
   **Export SAVED revision** to create a separate export.

You can also run `openBOIReviewedPocketEvidence` to choose and view a saved
reviewed measurement directly. Reopening displays the saved values. Arithmetic
recalculation is a separate, explicit action.

A draft is excluded from export until saved. Earlier revisions and automatic
results are preserved. The main window's **Export selected evidence** includes
both the original event information and the saved reviewed measurement.

## What you receive

Each reviewed export contains:

- A readable report explaining the measurement and its limitations.
- CSV tables of the measurements, exact reference/event samples and saved pixels.
- MATLAB and JSON files containing the saved values, choices and calculation inputs.
- Records identifying the source analysis, saved correction and review revision.

You can reopen the reviewed export without rerunning a recording. Reviewed
measurements are exported separately; they do not automatically replace
amplitudes in recording-wide statistics.

For a fresh recording, the recording workflow provides input review, analysis
and statistics. See the [user manual](USER_MANUAL.md) for those routes and their
input requirements.

## What has been checked, and what remains uncertain

The reviewed calculation and save/reopen/export workflow were checked on three
saved examples: ID400, FB2312 and C02. Their exact measurements and uncertainty
labels were preserved. Folder selection and cancellation were exercised.
The saved-result viewer was checked at 1120 × 800 and 900 × 650 on MATLAB R2025a
and macOS.

These checks establish that the selected calculation is implemented and its
results are preserved for those examples. They do not establish that every
chosen reference or background correction is biologically appropriate.

- C02's short reference remains provisional, so its measurement is conditional.
- FB2312's recovery remains unresolved; its selected end is an observation end.
- The saved image region may come from a surge candidate. Measuring a decrease
  there does not establish the spatial outline of a pocket.
- Automatic measurements retain their existing definitions. Agreement with
  arithmetic alone does not settle their biological interpretation.

Broader testing of fresh recordings, resource use and platform compatibility
remains incomplete. The
current repository is a development version, rather than a finished general
release. Local recordings and generated research results are maintained
separately from the source repository.

## Requirements and further reading

The imaging pipeline uses MATLAB and Image Processing Toolbox. Some analyses
also use Statistics and Machine Learning Toolbox. See the manual for details.

- [Pocket measurements: a short guide](docs/POCKET_MEASUREMENTS.md)
- [Full user manual, including older and optional tools](USER_MANUAL.md)
- Detailed development history (repository record: `DEVELOPMENT_NOTES.md`)
- Calculation and workflow verification records (repository record: `docs/SOFTWARE_CC_02_COMPLETION_DELIVERY.md`)
- Viewer and folder-selection verification records (repository record: `docs/SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md`)
- [Citation information](CITATION.cff)
- [Software licensing and contributor credits](LICENSING.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)

The original Science_2024 software was released under
[MIT](licenses/Science_2024-MIT.txt); retain its copyright and permission notice
when sharing inherited code. Licensing of new V2 contributions remains
unconfirmed; [the licensing guide](LICENSING.md) explains that remaining decision
and records contributor roles. [The dependency notice review](docs/LICENCE_NOTICE_RECONCILIATION.md)
records the helpers' own terms and remaining provenance limits. This candidate
includes those documents; earlier ZIPs are preserved. The software builds on the analysis
associated with [the 2024 Science paper](https://doi.org/10.1126/science.adn1011).
When comparing results with earlier software versions, check the calculation
and units: some measurement definitions have changed.
