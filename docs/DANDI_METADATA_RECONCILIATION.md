# DANDI metadata reconciliation — 9 September 2026

Release: DANDI `000891/0.240215.0831`. This audit read API metadata and remote NWB acquisition/subject headers for **all 87 assets**. It did not run event detection on those 87 recordings. The earlier 137 sink / 40 surge event counts concern **only ID400, M400_01_baseline_awake**, analyzed at 1 Hz and 4.75 µm/pixel.

## Source mapping and verification

The user supplied `DataDescription.xlsx` and `PooledData2.csv`. The workbook's `PooledData_annotated` sheet contains 83 recording rows. All 83 map uniquely to archive session names after removing punctuation and case differences; no normalized-name collisions were found. For those matched records, the selected image series' pixel size, rate, condition, DrugID, promoter and subject genotype agree with the workbook. Subject IDs agree after punctuation normalization. Other subject/session fields are retained in the manifest but were not all subjected to equivalence rules.

The CSV contains 67 rows: 39 match archive sessions directly, eight are candidate-only links to four animals, and 20 have no matching session in this release. Original labels remain preserved. Record-specific mappings reconcile `GFAP` with `GFAP.PHP`, `Ctrl` with `awake`, and six stimulation-condition labels against the matched workbook records. These are not global replacement rules for all experiments.

## Resolved image-series selection

Six assets contain two image series. Select the unique explicitly named BLI series:

| Asset session | Selected series | Other channel |
|---|---|---|
| FB2352 | `01_FB2352_BLI.tif` | Microspheres |
| FB2353 | `01_FB2353_BLI.tif` | Microspheres |
| FB2354 | `01_FB2354_BLI.tif` | Microspheres |
| FB2355 | `01_FB2355_BLI.tif` | Microspheres |
| FB2364 | `02_FB2364_BLI.tif` | Microspheres |
| nm200420-A1 | `BLI.tif` | mNeongreen |

FB2411 is a separate mNeonGreen fluorescence-control recording and is explicitly classified as such. Metadata consistency does not authorize pooling that control as a BOI experiment. The other conditions likewise remain separate experimental strata.

## Unresolved mappings

F120, F134, F136 and M189 each have one image series in the archive. Their candidate CSV rows separately name baseline and whisker sessions. Image filenames indicate baseline or no stimulation; no NWB interval table establishes a split. Analog acquisition channels exist, but their labels alone do not identify stimulation timing. No segment boundaries or one-to-two recording mappings have been created.

All four NWBs specify **1.54 µm/pixel**; their candidate CSV rows specify **1.55 µm/pixel**. Exact session correspondence and calibration must be resolved before using those CSV rows to define analyses. The manifest leaves canonical values unavailable for these four records rather than silently selecting a source.

The other 20 unmatched CSV rows comprise six ID32/34/38/52/54/60 recordings, eight M400–M403 whisker sessions, and six FB2312/14/15 whisker sessions. They must not be substituted with another recording from the same animal.

## Manifest contract and limits

The local deliverable has one record per archive asset, a separate mapping for every CSV row, source-file hashes, original source rows, API metadata, NWB headers, explicit image-series selection and published archive SHA-256 values. No implicit timing bounds are assigned. `MetadataResolved` describes metadata/series selection only; it is not signal QC, detector accuracy or suitability for a particular biological comparison.

The metadata audit did not download and hash every complete NWB movie. Archive digests are recorded as published values; full-file checksum verification and pixel roundtrip validation have so far been performed only for the ID400 reference. Stored HDF5 dimensions are retained without assuming a universal time-axis convention.

The ID400 reference harness now records WT genotype, consistent with both supplied files and the NWB subject description. Earlier saved reference outputs retain their historical unspecified-genotype label. No numerical detector setting changed in this correction.

## Next step

Resolve the four calibration/session conflicts using acquisition records or an explicit source correction. The 83 resolved assets can support a stratified reference-selection plan now; choose multiple animals and acquisition scales while keeping baseline, stimulation, calibration and fluorescence-control strata distinct. Do not treat all 83 as an interchangeable pooled cohort.
