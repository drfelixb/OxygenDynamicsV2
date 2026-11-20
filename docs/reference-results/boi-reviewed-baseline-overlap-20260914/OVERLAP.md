# Saved baseline versus reviewed intervals

| Saved event | Reviewed frames | Retained / required samples | Retained samples inside reviewed interval | Count | Retained samples before reviewed onset | Existing baseline status |
|---|---|---:|---|---:|---:|---|
| surge 1/4 | 536–556 | 20/20 | 536, 537, 538, 539 | 4 | 16 | valid |
| surge 1/3 | 496–516 | 20/20 | 496, 497, 498, 499, 500, 501, 502 | 7 | 13 | valid |
| surge 5/1 | 177–195 | 0/20 | None — retained list empty | 0 | 0 | insufficient_clean_prebaseline |
| sink 15/36 | 1149–1166 | 14/20 | 1154, 1155 | 2 | 12 | insufficient_clean_prebaseline |
| sink 15/36 | 1149–1167 | 14/20 | 1154, 1155 | 2 | 12 | insufficient_clean_prebaseline |
| sink 15/36 | 1153–1166 | 14/20 | 1154, 1155 | 2 | 12 | insufficient_clean_prebaseline |
| sink 15/36 | 1153–1167 | 14/20 | 1154, 1155 | 2 | 12 | insufficient_clean_prebaseline |

All seven alternatives are listed; duplicate sink overlap results are intentional.
After removing only overlapping retained samples, the remaining counts are 16, 13, 0 and 12—each below the existing requirement of 20.
These are membership counts, not recalculated baseline values or amplitudes.
The two finite saved baselines remain valid computations for their original automatic windows, but their samples overlap the reviewed intervals.
An already unavailable reference stays unavailable. Native-support “clean” does not establish physiological baseline.
