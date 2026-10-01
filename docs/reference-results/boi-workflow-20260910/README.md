# ID400 BOI workflow evidence — 10 September 2026

One complete, previously inspected development recording passed master analysis,
two statistics exports and independent saved-ingredient arithmetic replay under
MATLAB R2025a. No detector or scientific measurement rule was changed. The
[workflow protocol and limitations](../../BOI_REPRESENTATIVE_WORKFLOW.md) define
this bounded pass. [Machine-readable report](walkthrough-report.json) contains
source, contract, dictionary and run-output hashes and numerical evidence.

Full local evidence is in the sibling workspace folder
`reference-validation/boi-workflow-20260910/`. It includes the staged TIFF,
source mapping, input review, effective master settings, statistics requests,
MATLAB code manifest, complete automatic outputs, both statistics runs and a
`portable-audit/` with calculation ingredients, guide and inspection panel.
Private technical paths stay outside this compact report. The dictionary version
is `0.1.0-draft`; outcome tiers remain proposed.

## Numerical findings, conditional on the current detector

| Check | Observed result |
|---|---|
| Complete recording | 512 × 512 × 600; 1 Hz; 4.75 µm/pixel; no added denoising |
| Sink availability | 196 detected events; 102 finite amplitudes; 94 unavailable |
| Surge availability | 50 detected events; 28 finite amplitudes; 22 unavailable |
| Covered native sink area-time | 13,329,135.3125 µm²·s |
| Static eligible tissue-time | 2,147,981,587.5 µm²·s |
| Reconstructed mean occupied tissue fraction | 0.0062054234496551524, approximately 0.6205% |
| Selected event | Recording `dandi000891_ID400_awake`, sink site 1, event 2; first finite sink in saved row order |
| Baseline | 20 samples; preserved-input mean 90.994496268656718 |
| Relative sink amplitude | 0.0526120470218696, approximately 5.2612% |
| Signed trace integral | −0.65706061031655838 fraction·s |
| Numerical acceptance | Baseline, amplitude, signed integral and occupancy passed 1e-12 + 1e-10 × absolute reported value; CSV roundtrip also passed |
| Separate run | A [0,600) s; B diagnostic [30,600) s; identical sink/surge event tables; original A MAT checksum preserved |

No acquisition-start sink events occurred in this example; this does not resolve
the general frame-1 onset-censoring issue. Finite amplitudes are not independently
validated physiological amplitudes. The example intentionally retains the
complete trace, including wider intensity changes; it is not evidence that the
local baseline or timing is scientifically optimal.

The selected event has native frames 436–440 and refined frames 431–457.
That difference illustrates why native coverage, refined duration and fixed
union amplitude support must remain separately inspectable. Positive-event
classification, recurrence/recovery and onset independence were not established.

## Resources and review

Recorded function time: 169.75 seconds, including an 88.95-second master and
32.13/27.32-second statistics runs. External wall time including MATLAB startup
and shutdown was 178.86 seconds. Output measured before final report copies:
1,717,129,117 bytes (about 1.60 GiB), below the 5 GiB review target.

MATLAB automatically started 14 process workers during the full-recording run.
macOS `/usr/bin/time -l` reported maximum resident set size 8,858,501,120 bytes
(about 8.25 GiB) and peak memory footprint 10,918,471,040 bytes (about 10.17 GiB).
These process-accounting figures are not a sampled simultaneous sum of all
parallel workers and must not be advertised as total machine memory demand.
A process-list snapshot was unavailable inside the sandbox. Total worker peak
memory and human manual-review effort remain unmeasured. A bounded two-worker
configuration should be assessed before extrapolating cohort feasibility.

## Presentation correction and final-code verification

Visual review caught the first figure overlaying the mask from native frame 436
on image frame 431, the refined start. The numerical calculation was unaffected.
The corrected renderer uses native frame 436 for both image and mask. The old
figure and executed runner/definition-writer source are preserved under
`local-only/`; `presentation-correction.json` in the portable audit records the
before/after image hashes and reason. This is a presentation correction, not a
new detection experiment.

The full-recording code manifest describes the code executed at that time.
Afterward, the dictionary hook was moved to the BOI-only branch of the statistics
exporter and the renderer was corrected. Final verification uses the existing
known-event/zero-event BOI integration test, extended to verify the exported
shared dictionary and readable/JSON sidecars, plus same-frame rendering of this
actual event. The final renderer/integration result is recorded in the current
status document; the full biological detector was not rerun for these export
and presentation changes.

## Gates remaining open

This is technical development evidence. Independent researcher GUI use, a second
person's numerical replay, non-DANDI local transfer, biological accuracy,
acquisition/exposure validity, independent evaluation roles, scientific outcome
selection and final cohort eligibility remain open. One event inspection and
one recording do not cover weak/strong, brief/sustained, irregular, recurrent,
overlapping and spatially changing biological signals across animals and
acquisition strata. Prior holds and source corrections remain unchanged.
