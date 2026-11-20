# Two calculations from exported saved ingredients

5 October 2026 · reader/exporter 3.1.0-dev.2

The assistant independently replayed these CSV ingredients using Python
arithmetic, without MATLAB calculation helpers. This is a separate arithmetic
implementation, not independent scientist review or physiological validation.
The actual numerical inputs below make these worked examples readable without
the local research workspace. Full sample/event tables and demonstration receipts
are separate saved ingredients, not included in the software ZIP. Researcher
acceptance of the demonstrated scope does not establish an independent walkthrough.

## One reviewed event

Historical ID400, saved sink site 11/event 1 (audit row 41). Both intensity
vectors average the **same 1,100 saved pixels**. Reference frames **73–81** give
**9 samples**; the observation interval **82–98** gives **17 samples**. Both
minima occur at frame **88**. No correction was fitted during review.

| Ingredient | Value (arbitrary intensity units) |
|---|---:|
| Mean raw reference, B | 76.3808080808081 |
| Mean saved corrected reference, C | 0.8618334124530063 |
| Minimum raw intensity in observation interval | 73.0745454545455 |
| Minimum saved corrected intensity in observation interval | −2.99718514102405 |

Corrected signed trough:

`100 × (−2.99718514102405 − 0.8618334124530063) / 76.3808080808081`
`= −5.05234056884336%`

Raw companion:

`100 × (73.0745454545455 − 76.3808080808081) / 76.3808080808081`
`= −4.32865625454589%`

Both denominators are the **positive raw reference mean**, not the near-zero
corrected reference. The units are percent of raw reference intensity. A negative
value means a downward optical excursion. CSV rounding changes the independent
replay by at most 5.6 × 10⁻¹⁴ percentage points from the accepted values; no
scientific output was changed. Percent fields already contain percentages.

The reference is recorded as accepted local state and recovery observed, but
the measure remains exploratory. The observation end is not a newly confirmed
pocket duration. Its saved footprint does not independently establish pocket
extent. The original automatic amplitude remains **−0.349679595615087%**, with
its original definition; it is not replaced by either reviewed value.

Use `ReviewedPocketSamples.csv` in a separately supplied reviewed export
for exact samples and `ReviewedPocketMeasures.csv`
for the stored values and qualifications.

## One automatic recording summary

This is the **G2 ID400 saved recording**, a different analysis from the event
above. The metric is **MeanBurdenAmplitudePercent**, the existing mean of
nonnegative automatic sink drop-oriented percentages. Each automatic amplitude
has its own saved pre-event reference; the current documented rule requests
the immediately preceding clean finite window, normally 20 seconds, with a
positive raw intensity mean. No common recording reference or new fit is used.

The demonstrated `RecordingSummaryIngredients.csv`, supplied separately,
contains **192 events**, of which **94 contribute**. Their values sum to
**837.3494506029256 percentage points**:

`mean = sum(non-NaN saved BurdenAmplitudePercent) / contributor count`
`= 837.3494506029256 / 94 = 8.90797287875453%`

The **98 unavailable amplitudes** remain unavailable; they are not zeros and
are not included in the denominator. This packet has zero negative amplitudes
and zero negative exclusions. The result is one recording mean, not a pooled
mouse/group mean. Its subset must not be reused for area, duration or composite
metrics. Reviewed values do not contribute; strict totals can remain unavailable
even when a finite event mean is available.

The selected mean/counts agree in CSV, workbook and MAT. Historical calculation
software is **unknown**; saved contract `3.1-roi-dev` is not a software release
version. Current reader/exporter is **3.1.0-dev.2**, without a statistics rerun.

C02 conditional reference, FB2312 unresolved recovery and saved-footprint
qualifications remain. Optical arithmetic does not establish oxygen concentration,
pressure, correction validity or reference suitability.

For the installation and export steps, see the
[saved-result walkthrough](BOI_ORDINARY_MATLAB_WALKTHROUGH.md). For definitions
and missingness at other summary levels, see
[automatic amplitude exports](AUTOMATIC_AMPLITUDE_EXPORTS.md).
