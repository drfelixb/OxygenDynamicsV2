# Reviewed static tissue support verification

Decision R1-TISSUE-004 adds the [MATLAB reviewed-support workflow](../../BOI_REVIEWED_TISSUE_SUPPORT.md).
This is synthetic implementation evidence. No HP anatomical mask was created or
adopted, and no biological detector run, tuning or cohort inclusion occurred.

## Completed checks

- **52 targeted MATLAB tests passed:** ten tissue-support checks plus the 42
  existing acquisition/input, calculation, pipeline and availability checks.
  They cover source/shape identity, invalid masks, declaration mutation,
  pre-master adoption, default calculation equivalence, bins, candidate overlap
  and tissue-intersected occupancy.
- **One complete reviewed-support master/statistics verification passed** on
  a 96 × 96 × 100 synthetic recording at 2 Hz and 2.5 µm/pixel. The mask is an
  explicitly synthetic rectangle with a hole, not a biological annotation.
  Automatic support: 5,994 pixels; supplied support: 3,906; added: 1,431;
  removed: 3,519. Sink border exclusion leaves 2,484 pixels.
- Both sign masks and areas, the original JSON snapshot, review decision and
  automatic-mask ledger survived master and normal CSV/JSON/MAT/workbook export.
  Sink tissue-time replay: **2,484 × 2.5² × 50 = 776,250 µm²·s**.
- This reviewed-mask full run retained zero events in both signs. Its zero
  occupied-area numerator is not detector sensitivity evidence. A separate
  nonzero overlap fixture verifies union/intersection: 4 µm²·s covered / 16
  µm²·s tissue-time = **0.25**, with outside-support pixels excluded once.
- The existing complete **default-mask known-event/zero-event integration**
  passed, including two injected known sink amplitudes (25% and 40%), successful
  zero-event handling, recording identity, dictionary and QC exports. Injected
  events test measurement/export rather than detector recovery.
- The proposal PNG was visually inspected: source frames 1/50/100, matching
  native coordinates, included rectangle, excluded hole and clear unadopted
  status. Three frames do not establish dynamic observability or anatomy.

MATLAB R2025a used two process workers. Reviewed master: 4.07 s; reviewed stats:
5.32 s; default integration: 8.88 s. Verification function elapsed time: 32.19 s,
including pool startup. This small fixture is not a new full-recording HP
resource benchmark. Original automatic computation is retained for comparison.

## Preserved verification corrections

The initial unit occupancy fixture omitted the existing site Start/Duration
fields and failed before calculation. Adding those fixture fields produced the
52-test pass; the initial log remains available.

The first integration comparison reconstructed automatic support from **double**
pixels, while `loadtiff` supplies **single** pixels to the master. Its mask
comparison failed. The replay was corrected to use the actual input type; no
production numerical rule changed. The next attempt passed that check but
stopped at a relative-path CSV manifest. Canonical absolute paths corrected the
verification harness. The final run completed both integrations. Earlier folders,
failed reports, logs and runner snapshots remain intact.

## Evidence locations

The portable [verification report](verification-report.json) and
[artifact record](artifact-record.json) bind these claims to retained files.
Full generated synthetic inputs/outputs and logs are under workspace
`reference-validation/boi-tissue-support-20260910-complete/`.
Earlier attempts remain under `boi-tissue-support-20260910/` and
`boi-tissue-support-20260910-verified/` in the same directory. The default
integration's original temporary directory is recorded in the local result;
its complete files are also copied into the final evidence folder.

Source TIFFs and the prior HP workflow and review artifacts were checked against
their recorded hashes. Updated code/docs are additive worktree changes; earlier
unrelated edits remain uncommitted and preserved.

## Scientific limits

The supplied mask is a recorded review declaration, not independent validation.
Candidate outside-support filtering, untrimmed event footprints, whole-image
normalization, static validity assumptions and provisional physical calibration
retain their existing implications. The HP finding about dark peripheral support
and the negative source amplitude remains open for biological interpretation.
Confirmed external 1 Hz timing remains authoritative for HP; no new timestamp
hold was introduced. Next work is to inspect available HP reference images for
evidence of observable tissue and alignment before adopting a real mask.
