# Reading event duration, area and recording event rates

Checked on 4 October 2026 using the saved G2 ID400 result and eight small
calculation fixtures. These are descriptive optical-event measurements. Arithmetic
agreement does not establish physiological onset, tissue validity or detector accuracy.

| Measurement | Calculation | Meaning and units |
|---|---|---|
| Event duration | (last frame − first frame + 1) / sampling rate | Seconds of modeled frame intervals; one frame at 2 Hz is 0.5 s |
| Native mean event area | mean(native event pixels per detected frame) × pixel size² | µm²; uses native detected masks, even when sink timing is refined |
| Mean occupied tissue fraction | sum(union occupied area × clipped frame time) / (selected tissue area × window duration) | Fraction; multiply by 100 for percent. A pixel shared by sites counts once |
| Event onset rate | onsets in the window × 60 × 10⁶ / (tissue area in µm² × window duration in seconds) | Events/mm²/min; counts beginnings, not ongoing events |
| Mean concurrent event density | sum(event time overlapping window) × 10⁶ / (tissue area in µm² × window duration in seconds) | Events/mm²; overlapping events each contribute their time |

Sink and surge results use their own saved tissue support and never cancel.
The recording registry's area is the sink area; the surge window uses saved surge
support. Neither area is automatically the full image rectangle. Native masks are
intersected with the selected support for tissue occupancy. Native event mean
area is a separate measurement of the detected footprint across its native frames.

An event whose first and last saved frames are 82 and 91 at 1 Hz lasts 10 s under
the inclusive rule, rather than the 9 s between those frame indices. The modeled
interval is [81,91) s. This does not prove a continuous physiological episode or
supply the camera integration exposure. The supplied ID400 acquisition clock is
1 Hz; that authority must not be assumed for other recordings.

Sink event duration uses its saved measurement bounds, which may be refined.
Native area and occupied tissue use detected masks. In the checked small example,
native frames 1–2 contain two pixels each at 2 µm/pixel: native mean area is
8 µm². Extending the saved sink measurement interval through frame 3 gives a
3 s duration, while its native area remains 8 µm². The surge's native interval
remains 2 s. This difference is preserved and should remain visible in event tables.

For tissue occupancy, suppose the native union areas over four 1 Hz frames are
8, 12, 0 and 0 µm², with 16 µm² of sink tissue. The whole-window occupied fraction
is (8 + 12) / (16 × 4) = 0.3125, or 31.25%. A shared pixel was counted once.
In window [0.5,2.5) s, frame overlaps are 0.5, 1 and 0.5 s: covered area-time
is 8 × 0.5 + 12 × 1 + 0 × 0.5 = 16 µm²·s. Occupancy is 16 / 32 = 50%.

In that partial window, one event begins inside the window and 2.5 event-seconds
are active, including an event already ongoing at its start. Onset rate is
1 × 60 × 10⁶ / 32 = 1,875,000 events/mm²/min; concurrent density is
2.5 × 10⁶ / 32 = 78,125 events/mm². The large values reflect this deliberately
tiny synthetic tissue area, not a biological example. With 32 µm² of surge
support, those normalized rates and the occupied fraction are halved.

Windows include their start and exclude their end. An event beginning at the
window end has no onset or active-time contribution inside that window. An event
already ongoing contributes only its overlapping time. Events starting at frame 1
remain counted by the current descriptive policy; they do not establish a new
physiological onset. Unknown biological timing remains unknown.

## Worked saved ID400 example

The saved recording contains 600 modeled seconds at 1 Hz and a scale of
4.75 µm/pixel. Its original results are preserved.

| Ingredient / result | Sink | Surge |
|---|---:|---:|
| Selected tissue area (µm²) | 4,050,555.375 | 4,339,851.75 |
| Event onsets | 192 | 54 |
| Active event time (event-seconds) | 2,501 | 781 |
| Covered union area-time (µm²·s) | 14,815,462.5625 | 28,751,664.5 |
| Mean occupied tissue (%) | 0.609606 | 1.104172 |
| Onset rate (events/mm²/min) | 4.740091 | 1.244282 |
| Concurrent density (events/mm²) | 1.029077 | 0.299933 |

For example, sink density is 2,501 / (4.050555375 × 600) = 1.029077 events/mm².
Sink onset rate is 192 / (4.050555375 × 10 minutes) = 4.740091 events/mm²/min.
Two sink onsets occur at the acquisition boundary and are included descriptively.
No surge onset occurs there. The first saved sink event is frames 1–3: 3 s and
5,475.166667 µm² native mean area. The first surge is frames 3–14: 12 s and
17,051.609375 µm² native mean area.

`OxySinkEvents` and `OxySurgeEvents` contain event duration and native area.
`RecordingWindowMetrics` and `SurgeRecordingWindowMetrics` contain the three
window measures. Their separate frame ledgers retain union areas, tissue areas
and clipped time. Selected-window exports provide `Frames.csv`, `Events.csv`,
`Metrics.csv` and MAT evidence for arithmetic replay. Site event rates are
**events/minute at a site**, without tissue normalization; grouped site columns
are not mouse means. They must not be substituted for recording onset density.

A genuinely analyzed empty recording with valid support has zero count, active
time, occupancy and rates. Missing calibration or denominator gives unavailable
normalized measurements or blocks the source-bound reader. Invalid timing is
blocked. Missing native mask ingredients do not become valid zero occupancy.
Unavailable amplitudes do not remove detections from these counts or coverage.

These checks preserve automatic/reviewed separation, correction and footprint
rules. Camera integration exposure remains unknown in this saved example; static
tissue support does not establish dynamic physiological validity. C02's conditional
reference, FB2312's unresolved recovery and saved-footprint qualifications remain.
No inference about those other recordings was made here. See the
[bounded check report](SOFTWARE_NEXT_02_DELIVERY.md) for exact evidence and limits.
