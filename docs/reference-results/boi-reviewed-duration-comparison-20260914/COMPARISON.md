# Four reviewed events: duration arithmetic

At 1 Hz, endpoint span = last frame minus first frame. Inclusive count = span + 1.
The existing BOI-M04 duration uses inclusive count / Hz. Neither definition changes here.

| Saved event | Bounds used | Frames | Endpoint span (s) | Included frames | Inclusive convention (s) |
|---|---|---|---:|---:|---:|
| surge 1/4 | Automatic measurement | 540–552 | 12 | 13 | 13 |
| surge 1/4 | Native detection | 540–552 | 12 | 13 | 13 |
| surge 1/3 | Automatic measurement | 503–514 | 11 | 12 | 12 |
| surge 1/3 | Native detection | 503–514 | 11 | 12 | 12 |
| surge 5/1 | Automatic measurement | 183–193 | 10 | 11 | 11 |
| surge 5/1 | Native detection | 183–193 | 10 | 11 | 11 |
| sink 15/36 | Automatic measurement | 1156–1165 | 9 | 10 | 10 |
| sink 15/36 | Native detection | 1157–1164 | 7 | 8 | 8 |

| Saved event | Reviewed frames | Preference | Endpoint span (s) | Included frames | Inclusive convention (s) | Onset shift (frames) | Offset shift (frames) | Duration increase (s, same convention) |
|---|---|---|---:|---:|---:|---:|---:|---:|
| surge 1/4 | 536–556 | both endpoints preferred | 20 | 21 | 21 | -4 | +4 | +8 |
| surge 1/3 | 496–516 | both endpoints preferred | 20 | 21 | 21 | -7 | +2 | +9 |
| surge 5/1 | 177–195 | both endpoints preferred | 18 | 19 | 19 | -6 | +2 | +8 |
| sink 15/36 | 1149–1166 | alternative onset; offset unranked | 17 | 18 | 18 | -7 | +1 | +8 |
| sink 15/36 | 1149–1167 | alternative onset; offset unranked | 18 | 19 | 19 | -7 | +2 | +9 |
| sink 15/36 | 1153–1166 | preferred onset; offset unranked | 13 | 14 | 14 | -3 | +1 | +4 |
| sink 15/36 | 1153–1167 | preferred onset; offset unranked | 14 | 15 | 15 | -3 | +2 | +5 |

Negative onset shift means an earlier onset; positive offset shift means a later offset.
Duration differences are identical under the two conventions when the same convention is used on both sides.
For sink 15/36, all saved choices yield discrete spans {13, 14, 17, 18} s, not a continuous 13–18 s interval.
The preferred onset 1153 yields 13 or 14 s. No preferred offset or single preferred duration is invented.
1154 is preserved as an earlier review, not added to the current alternatives. All four statuses remain uncertain.
Saved surge labels are retained even where the reviewed trace is a decline. No relabelling or cohort generalization follows.
