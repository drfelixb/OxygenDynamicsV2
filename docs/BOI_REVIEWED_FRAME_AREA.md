# Reviewing the area of the extended FB2412 pocket

This bounded feature adds **Reviewed frame areas** to the existing event
reviewer for FB2412 sink site 1/event 2. The accepted event is frames 651–693,
with its own reference at 631–650, 6.942974529% raw drop and 43 inclusive
seconds. Its trace uses the accepted 718-pixel footprint. The separate event 1
and event 3 exclusions remain in their saved boundary revision.

## Scientist workflow

Select the frame with Prev/Next, the frame selector or a table row. Switch
between the original raw image and the saved denoised input. Their grayscale
display limits are fixed across the prepared interval. The right image shows
per-pixel percentage change from the accepted reference mean for the chosen
source; it is display context, not another correction or a segmentation rule.

- Cyan is the accepted quantitative footprint.
- Magenta is a saved automatic mask, initially an unaccepted suggestion.
- Green is the current drawn, edited or accepted area.

Use **Accept saved mask** when the suggestion is suitable. To change it, use
**Use saved as draft**, then **Add region**, **Erase region / hole** or
**Draw / replace**. Drag an outline on the left image and release to finish;
then choose **Accept drawn area**. Drawing/erasing stores exact pixel sets and
resets that frame to unreviewed until it is explicitly accepted. Separate
components and holes are retained. **Cancel drawing** leaves the frame
unchanged. An invalid or outside-image outline is discarded, never clipped.

Choose **No pocket area** only for a frame judged to have zero area.
**Uncertain** withholds quantification. An absent automatic mask alone is
neither an accepted zero nor a missing source file. Acceptance, explicit empty
and uncertainty advance to the next frame. **Undo frame change** acts on the
currently displayed frame; use Prev first if the preceding decision advanced
the display. **Next unreviewed** returns to an outstanding frame.

**Save revision** retains progress in a new folder, including incomplete
progress. Reopen revision validates its source and parent. The panel opens the
latest saved revision when available; earlier revisions remain intact. Closing
with unsaved changes offers keep reviewing, save, or discard draft changes.

## Baseline comparison and playback

**Compare / playback** opens the companion **Baseline and playback** tab.
It shows the accepted reference mean, selected cached frame and the existing
percentage-change map together. Baseline and current grayscale panels use
identical, fixed limits for the selected raw or denoised source. Blue in the
change map means lower intensity than the reference; red means higher.

**Play span** plays the episode, reference, recovered context or complete
already-cached interval once. The speed selector controls display speed;
the acquisition frequency is shown separately. **Stop** holds the current
frame. **Flicker reference** alternates the selected frame with its baseline
at the same contrast for up to 20 seconds; Stop restores the selected frame.
Switching away from this tab also stops playback.

**Show current outlines** toggles overlays without changing any mask. Cyan is
the accepted footprint; magenta and green on current/change images refer to
the selected frame's automatic suggestion and current review/draft area.
The baseline panel carries only the footprint. **Review this frame** returns
to the area editor at an episode frame. Context-only frames cannot enter
the event's area decisions.

The comparison tab has no acceptance, drawing or scientific save action.
It reads the live area draft and cached crops; opening it preserves unsaved
decisions and does not read source images again. A clearer display can help
judgment, while indistinct boundaries can still remain uncertain.

## Area and burden

All 43 frames require an accepted nonempty mask or an explicit empty judgment.
An unreviewed or uncertain frame withholds the whole mean and event burden.
A mask extending outside cyan flags a spatial mismatch and also withholds
quantification: resolve its association with the accepted trace/amplitude
explicitly, without silently trimming or enlarging the footprint.

For a complete review:

```
mean area_um2 = mean(all 43 reviewed pixel counts) * 2.35^2
event burden = approved raw drop_percent * mean area_um2 * 43
normalized contribution = event burden * (1e6 / saved FOV area_um2)
                                      * (60 / saved recording duration_sec)
```

This reviewed mean over the full interval is versioned separately from the
original detector-positive-frame mean. There is no interpolation, gap filling,
fixed 718-pixel area or partial sum. Software checks establish arithmetic and
traceability; the frame judgments establish the researcher's area selection.

## Saved files and existing export integration

Each revision contains exact masks/decisions in `AreaReview.json`, a 43-row
`AreaFrames.csv`, `ReviewedEventBurden.json/.mat/.csv`, status and checksums.
The JSON uses null for unavailable area/product; CSV and MAT preserve NaN.
`Status=complete` means the artifact finished writing; inspect `AreaStatus`
and `BurdenAvailable` to distinguish incomplete biological review.

The artifact identifies the raw and denoised sources, native master, audit,
accepted measurement/reference/boundary, clock, pixel size, footprint and
saved recording exposure. Every accepted/empty frame carries its reviewer and
decision time. Derived values are recomputed and checked when loaded.

The existing reviewed burden exporter accepts this folder through its existing
`ReviewedEventFolders` input. Schema `boi-reviewed-single-event-burden-2`
permits complete or explicitly unavailable reviewed area. Missing area replaces
the old automatic event contribution with unavailable; it cannot fall back to
that value. Strict recording completeness still applies. The automatic area
is retained as `AutomaticBurdenArea_um2`; reviewed status/frame count are
additional columns. Legacy schema 1 and the earlier site 20 result retain their
behavior. Existing export files/formats and the burden formula are preserved.

`AreaRevisions/LatestRevision.json` is a mutable pointer to immutable history.
For a future export, resolve that pointer, load/validate its event artifact and
use exactly one area revision for this event. The next-export manifest is a
snapshot, not an instruction to run a combined export or an automatically
updated selection. No 17-recording workbook is rebuilt by this feature.

## Delivery checks

Work item FB2412-S1-REVIEWED-AREA-01; owner root, no delegation. Six focused area
checks and 12 existing reviewed-burden cases pass. Native incomplete-area and
legacy site 20 loaders pass, along with immutable save/reopen, changed-parent
and wrong-source rejection. The GUI preparation reads 83 frames per source
once (166 image planes), caches only display crops and reuses them during
display repairs. Original recordings, automatic outputs, earlier reviews and
the combined workbook are preserved.

Evidence and the exact current saved revision are in
`reference-validation/boi-fb2412-area-review-20261026/`. Researcher frame review
remains pending; engineering delivery does not accept any of the 43 frames.
