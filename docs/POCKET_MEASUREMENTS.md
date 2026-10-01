# Understanding a reviewed pocket measurement

This guide explains the measurement you can make after inspecting a saved
event. The aim is to make the calculation, reference choice and exported
result understandable.

## First, distinguish finding an event from measuring it

The detector finds candidate sinks and surges using normalized signal contrast.
That score can behave differently from the original intensity trace. A high
score is therefore not, by itself, a large percentage intensity change or a
confirmed physiological event.

In the reviewed workflow, you decide whether a trace contains a pocket and
choose the interval to measure. A saved candidate labelled as a surge can
still contain a downward excursion you want to review. The original label is
retained alongside your interpretation.

## Choose the interval and reference explicitly

- **Pocket interval:** the frames covering the decline and the part of the
  recovery you are observing.
- **Reference:** the exact frames before onset that represent the local state
  you want to compare against. Ordinary fluctuations are allowed.
- **Reference suitability:** your assessment of whether that comparison is
  appropriate. A provisional reference produces a conditional result.
- **Recovery status:** whether recovery was observed, remains unresolved, or
  was cut off by the end of the recording.

The reference must precede onset. The software does not silently shorten it,
remove inconvenient samples or replace it with another interval. A preceding
surge or an already-started decline can make a reference unsuitable even when
the arithmetic is correct.

The current reviewed workflow supports the established external 1 Hz timing
of the supplied examples. Confirm that timing only when it is known for the
recording. File timestamps alone do not establish the acquisition timing.
Enter your name and reason so that another reader can understand the choice.

A selected observation end is not automatically a confirmed recovery time.
This reviewed feature does not establish a new pocket-duration measurement.

## What is calculated

Both intensity traces are averaged over the same saved image region. Both
measurements use exactly the same reference frames and pocket interval.

**Corrected decrease — the main reviewed measurement**

1. Average the corrected intensity over the reference frames.
2. Find the lowest corrected intensity inside the chosen pocket interval.
3. Subtract the corrected reference average from that lowest intensity.
4. Divide by the average **uncorrected** reference intensity and multiply by 100.

**Raw decrease — the accompanying measurement**

Repeat the comparison using the uncorrected intensity trace. Divide by the
same uncorrected reference average and multiply by 100.

The corrected measurement uses the correction already saved with the analysis.
It does not fit a new trend during review. The corrected reference can be close
to zero, which is why it is not used as the denominator. The uncorrected
reference must be finite and positive.

Negative means a downward optical change. A value of −5% means a decrease
equal to 5% of the uncorrected reference intensity. **This is not an oxygen
concentration or an absolute oxygen-pressure measurement.**

The correction can change the apparent decrease. Whether it removes unwanted
background variation or part of a biological signal remains a scientific
question; the software cannot settle that from arithmetic alone.

## The three checked examples

Values below are rounded for readability. Full precision and exact selected
samples are retained in the saved results.

| Example | Pocket frames | Reference frames | Corrected decrease | Raw decrease | Important qualification |
|---|---|---|---:|---:|---|
| ID400 | 82–98 | 73–81 | −5.052% | −4.329% | Nine reference samples; measured on the saved sink region. |
| FB2312 | 398–417 | 378–397 | −8.363% | −8.139% | Recovery unresolved. Frame 417 is the observation end. |
| C02 | 177–195 | 165–170 | −12.384% | −11.105% | Conditional result from a provisional six-frame reference. |

FB2312 and C02 use the image regions from their saved surge candidates. Their
decreases are measured over those regions; the spatial outlines of the pockets
have not been established independently. The corrected and raw minima occur
at the same frames in these examples, but they can differ in other traces.

These examples check the chosen formula and preservation of its results.
They do not validate every possible reference, correction or recording.

## How to read the labels

| Label you may see | Meaning |
|---|---|
| Computed / `computed_exploratory` | The calculation is available using a reference recorded as suitable. Biological interpretation still requires review. |
| Conditional / `conditional_exploratory` | A value was calculated, but its reference remains provisional. Keep that qualification with the number. |
| Recovery unresolved | The full recovery endpoint is unknown. The selected end only bounds the observation. |
| Unavailable / NaN / null | A required input or suitability condition is missing. This is not a zero decrease. |
| Saved surge footprint | The pixels come from the original surge candidate. They are not a newly drawn pocket outline. |

If matching correction data are missing, the corrected result is unavailable.
A raw result may still be shown separately when its inputs are valid.

## What saving and exporting preserve

Use **Preview draft** after changing a choice, then **Save NEW revision**.
Saving creates a new folder and keeps earlier revisions. Reopening displays
the saved values; it does not recalculate them automatically.

**Export SAVED revision** exports the selected saved result. An unsaved edit
does not replace it. The export contains:

- `Evidence.md`: the readable explanation, values and qualifications.
- `ReviewedPocketMeasures.csv`: the measurement summary.
- `ReviewedPocketSamples.csv`: exact frames and intensity samples.
- `ReviewedPocketFootprint.csv`: the saved pixels used for both measurements.
- MATLAB and JSON records of the values, choices, source analysis and correction.

The reviewed CSV fields with `Percent` in their names already contain
percentages. Do not multiply those values by 100 again. Some older automatic
amplitude columns contain fractions instead, so check the column definition
before combining outputs.

Original automatic measurements remain separate. Their reference intervals,
measurement intervals and sign conventions can differ from your reviewed
choice. Reviewed values do not automatically replace amplitudes in the
recording-level statistics.

For the step-by-step interface route, see the [main guide](../README.md).
The [full manual](../USER_MANUAL.md) also covers older and optional analyses.
