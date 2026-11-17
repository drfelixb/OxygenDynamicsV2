# Reading automatic optical amplitudes and their summaries

Automatic amplitude describes preserved-input optical intensity change. It is
not oxygen concentration, absolute oxygen pressure or measured oxygen debt.
The original TIFF may already contain acquisition/preprocessing transformations;
“preserved input” does not establish camera-raw counts.

## Event measurements

Intensity is averaged over the fixed union of pixels detected during the event.
The reference is the mean of the requested immediately preceding window before
the saved measurement start, normally 20 seconds. Every requested sample must
be finite and free of overlapping native sink or surge detections, and the mean
must be positive. Missing context remains unavailable: no shortened window,
earlier search, post-event reference or zero substitution is used. “Clean” only
means free of detected overlap; it does not establish physiological suitability.

| Existing identifier | Meaning | Units and sign |
|---|---|---|
| `NormOxySinkAmp` | (reference − lowest event intensity) / reference | Fraction; positive optical drop |
| `NormOxySinkAmpPercent` | 100 × the sink fraction | Percent; same sign |
| `NormOxySurgeAmp` | (highest event intensity − reference) / reference | Fraction; positive optical increase |
| `NormOxySurgeAmpPercent` | 100 × the surge fraction | Percent; same sign |
| `DetectionOxySinkAmp` | Distance between processed site-trace and fitted-trend minima under the existing diagnostic formula | Processed detection units; not an intensity percentage |

A fraction of 0.05 is 5%. A negative sink amplitude means its event minimum is
above the reference; a negative surge amplitude means its maximum is below it.
Those values are retained. Older explicit `negative_drop_percent` provenance
reverses the sink sign; only burden inputs convert that sign. The new reporting
never rewrites older values.

Sink measurement intervals use saved refined bounds; surge intervals use native
bounds. This export fits no new correction. The reviewed-pocket primary measure
uses corrected intensity and makes a downward excursion negative. It remains a
separate result and does not replace automatic statistics.

## Summaries describe different populations

| Summary | Actual contributors | Total count and weighting |
|---|---|---|
| Site amplitude mean (`MeanOxySinkEvent_NormAmp`, surge equivalent) | Finite event fractions, including negatives | Events at that site; every contributing event equal |
| Recording mean burden amplitude (`MeanBurdenAmplitudePercent`) | Non-NaN nonnegative drop-oriented percentages; zero included | Sink events in that recording; each contributing event equal |
| Recording mean area or duration | Non-NaN inputs for that variable | All recording sink events; may include unavailable amplitudes |
| Recording mean/median event composite, including normalized variants | Non-NaN contributions for the specific variant | All recording sink events; normalization can change availability |
| Within-mouse recording mean | Requires every recording value in that mouse/group | Recordings, equally weighted; one NaN leaves the mouse mean unavailable |
| Group mean (`*_Mean`) | Finite within-mouse means | Mice, equally weighted; event/recording counts do not weight the mice |

Grouped site metric sheets put site values under mouse headings; they do not
calculate a mouse mean. Recording burden means and mouse/group means must not
be substituted for site means. Group SEM uses the same contributing mice and
requires at least two. Recording composite totals retain their strict missingness
rule: an unavailable required contribution prevents a complete total. Zero
contributing events gives an unavailable event mean, not a mean of zero.

## Companion exports

`AutomaticAverageCounts` (workbook and CSV) gives the existing metric identifier,
value, contributing count, total count, observation unit, summary level and
recording/mouse/site/group identity. Counts follow the actual arithmetic:
finite-only for site means, non-NaN for existing event means/medians, strict means
within mouse and finite-only at group level. A partial within-mouse input count
is explanatory; it does not turn a missing mouse mean into a partial average.

`AutomaticAmplitudeAvailability` separates:

- Unavailable event amplitudes.
- Negative finite event amplitudes.
- Negative drop-oriented amplitudes excluded from the sink burden input.
- Events whose unnormalized amplitude–area–duration composite is unavailable.

These are overlapping categories, not a partition. Missing/excluded amplitudes
also prevent their composite; an available amplitude may have a missing
composite because event area or duration is unavailable. Normalized composite
means have their own counts. Blank availability counts mean not assessed or not
defined (surges have no composite), not zero. Events remain in detection counts
and coverage even when amplitude or composite is unavailable.

`AutomaticAmplitudeGuide` and `AutomaticAmplitudeDefinitions.csv` explain source,
reference, formula, sign, units and limits. `AutomaticAmplitudeGuide.md` is the
readable report. `AutomaticAmplitudeExport.mat` and the additive
`AutomaticAmplitudeExport` field in `DataOutput.mat` preserve these companions.
Existing result columns remain unchanged. Previously saved exports are not
rewritten; generating a new companion export uses a new output folder.

For deterministic MATLAB CSV import, use:

```matlab
counts = readtable('AutomaticAverageCounts.csv', ...
    'Delimiter',',','NumHeaderLines',0,'ReadVariableNames',true, ...
    'VariableNamingRule','preserve','TextType','string');
```

Numerical consistency does not settle reference suitability, validity of a
background correction, pocket geometry or biological interpretation.
