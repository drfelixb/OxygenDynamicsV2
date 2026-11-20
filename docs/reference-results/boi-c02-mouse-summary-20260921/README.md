# C02: seven-mouse descriptive overview

21 September 2026 · R4-C02-CONSOLIDATION-119 · Working results; final analysis plan remains proposed.

All seven candidate mice have paired current-method runs and accepted source-specific working tissue support. The table below brings those existing results together without rerunning detection. Each mouse is a biological unit; events are observations within its recording. These publication/development-exposed recordings are not untouched validation.

Sink occupied-tissue fraction and detected onset rate are lower in isoflurane for all seven mice. Surge coverage rises for the three FB mice and falls for the four ID mice; surge onset rate rises only for FB2312. These are descriptive directions, not significance or causal conclusions. Acquisition scale and duration also differ between the FB and ID groups, so this pattern does not establish a biological subgroup effect.

## Paired values

Each cell shows **awake → isoflurane**. Coverage is native union area-time divided by valid tissue-time, expressed as percent. Overlap counts once. Rate is saved detected onsets per mm²·min. An event present at frame 1 is currently counted, although its physiological onset may precede the recording.

### Occupied tissue (%)

| Mouse | Minutes per state | Sink | Surge |
|---|---:|---:|---:|
| FB2312 | 20 | 0.445 → 0.337 | 1.191 → 2.415 |
| FB2314 | 20 | 0.500 → 0.449 | 2.244 → 3.217 |
| FB2315 | 20 | 0.573 → 0.494 | 2.214 → 5.486 |
| ID400 | 10 | 0.610 → 0.090 | 1.104 → 0.083 |
| ID401 | 10 | 0.328 → 0.153 | 0.299 → 0.157 |
| ID402 | 10 | 0.626 → 0.026 | 3.033 → 0.017 |
| ID403 | 10 | 0.328 → 0.063 | 0.333 → 0.057 |

### Detected onsets (events/mm²/min)

| Mouse | Minutes per state | Sink | Surge |
|---|---:|---:|---:|
| FB2312 | 20 | 16.855 → 11.498 | 1.800 → 2.068 |
| FB2314 | 20 | 21.339 → 14.568 | 2.831 → 2.306 |
| FB2315 | 20 | 17.185 → 7.352 | 2.559 → 1.943 |
| ID400 | 10 | 4.740 → 2.206 | 1.244 → 0.068 |
| ID401 | 10 | 3.033 → 1.589 | 0.523 → 0.145 |
| ID402 | 10 | 3.986 → 1.059 | 2.051 → 0.060 |
| ID403 | 10 | 2.819 → 1.511 | 0.438 → 0.123 |

## Exposure and optical-measurement availability

Areas are the saved **sign-specific effective analysis areas**, not a single assumed common area. Accepted craniotomy outlines retain uncertain edges and dark interior; they are working support, not certified anatomy. The machine-readable export retains exact numerator, denominator, concurrent density, duration/area summaries, signed optical summaries, missingness reasons, boundary counts and source/run identities.

| Mouse | State | Sign | Area (mm²) | Tissue-time (mm²·min) | Events | Finite amplitudes / events | Negative finite | Frame-1 onsets |
|---|---|---|---:|---:|---:|---:|---:|---:|
| FB2312 | awake | sink | 0.9167 | 18.3333 | 309 | 157/309 | 4 | 2 |
| FB2312 | awake | surge | 0.9723 | 19.4455 | 35 | 14/35 | 0 | 1 |
| FB2312 | isoflurane | sink | 0.9523 | 19.0461 | 219 | 89/219 | 3 | 3 |
| FB2312 | isoflurane | surge | 1.0153 | 20.3056 | 42 | 17/42 | 0 | 2 |
| FB2314 | awake | sink | 0.7147 | 14.2930 | 305 | 143/305 | 1 | 3 |
| FB2314 | awake | surge | 0.7242 | 14.4839 | 41 | 10/41 | 2 | 1 |
| FB2314 | isoflurane | sink | 0.6968 | 13.9350 | 203 | 68/203 | 8 | 1 |
| FB2314 | isoflurane | surge | 0.7156 | 14.3124 | 33 | 9/33 | 0 | 2 |
| FB2315 | awake | sink | 1.0649 | 21.2977 | 366 | 190/366 | 2 | 4 |
| FB2315 | awake | surge | 1.1331 | 22.6628 | 58 | 23/58 | 3 | 1 |
| FB2315 | isoflurane | sink | 1.1017 | 22.0336 | 162 | 54/162 | 3 | 3 |
| FB2315 | isoflurane | surge | 1.1835 | 23.6704 | 46 | 16/46 | 7 | 2 |
| ID400 | awake | sink | 4.0506 | 40.5056 | 192 | 94/192 | 0 | 2 |
| ID400 | awake | surge | 4.3399 | 43.3985 | 54 | 27/54 | 0 | 0 |
| ID400 | isoflurane | sink | 4.0344 | 40.3442 | 89 | 64/89 | 0 | 0 |
| ID400 | isoflurane | surge | 4.3811 | 43.8112 | 3 | 1/3 | 0 | 0 |
| ID401 | awake | sink | 3.1652 | 31.6520 | 96 | 50/96 | 0 | 2 |
| ID401 | awake | surge | 3.2495 | 32.4947 | 17 | 12/17 | 0 | 0 |
| ID401 | isoflurane | sink | 3.3349 | 33.3494 | 53 | 37/53 | 0 | 1 |
| ID401 | isoflurane | surge | 3.4398 | 34.3977 | 5 | 1/5 | 0 | 0 |
| ID402 | awake | sink | 3.5374 | 35.3737 | 141 | 44/141 | 0 | 1 |
| ID402 | awake | surge | 3.5598 | 35.5978 | 73 | 23/73 | 1 | 1 |
| ID402 | isoflurane | sink | 3.3058 | 33.0577 | 35 | 33/35 | 0 | 0 |
| ID402 | isoflurane | surge | 3.3060 | 33.0602 | 2 | 2/2 | 0 | 0 |
| ID403 | awake | sink | 4.3639 | 43.6393 | 123 | 60/123 | 0 | 1 |
| ID403 | awake | surge | 4.5648 | 45.6475 | 20 | 11/20 | 0 | 0 |
| ID403 | isoflurane | sink | 4.5678 | 45.6785 | 69 | 52/69 | 0 | 0 |
| ID403 | isoflurane | surge | 4.8788 | 48.7876 | 6 | 5/6 | 0 | 0 |

Unavailable amplitudes remain unavailable; counts and coverage retain those events. Negative finite amplitudes are retained. Every sink amplitude–area–time composite is unavailable; the composite is not defined for surges. Finite optical subsets cannot stand in for all events or calibrated oxygen concentration.

## Interpretation and boundaries

- External exact 1 Hz governs all intervals. Frame 1 is modeled time 0 s. Camera exposure is a separate unknown.
- Each pair uses equal observation duration within mouse. FB recordings use [0,1200) s; ID recordings use [0,600) s. Full stored intervals are the working descriptive choice; final windows are not approved. Rate normalization does not establish stationarity.
- The unchanged parameter factory uses native calibration: FB 2.35 µm/pixel, ID 4.75 µm/pixel. Pixel-based settings therefore differ in physical scale. No acquisition-specific tuning was introduced.
- Awake was recorded first and isoflurane state was established before its recording. This is a state-associated comparison; it cannot isolate anesthesia from order/time effects or recover unmeasured induction kinetics.
- Original recording-specific correction and the native-screened immediate 20-sample optical reference remain unchanged. Human-reviewed event boundaries/references remain a separate branch. No universal substrate-decline model is imposed.
- This closes consolidation of C02 working outputs, not the full BOI project. Final outcome hierarchy, windows, measurement-specific admission and statistical plan still require decisions.

## Traceability and verification

The adjacent mouse-summary.json contains exact, unrounded values and checksum-linked source records. consolidate.py reproduces this overview using only Python’s standard library and existing saved exports. verification.json records arithmetic and preservation checks. Prior run audits establish numerical agreement, not biological detection accuracy. No new detector validation was performed.
