# Release candidate package contents

The source policy also lists paired recording setup, analysis, inspection, export and the multichannel guide for a future package. [Multichannel guide](docs/BOI_MULTICHANNEL.md)

Open the Batch Editor with `openBOIBatchEditor`. From a source checkout, start the editor or run `setupOxygenDynamicsPath` before calling `runBOISoftwareChecks` in portable or desktop mode.

The ZIP contains the MATLAB code and support files on the explicit source list, plus the [one-page Batch Editor guide](docs/BOI_BATCH_QUICK_START.pdf), [installation instructions](INSTALLATION.md), [historical RC1 notes](docs/RELEASE_NOTES_3.1.0_RC1.md), source notices and required reader documentation. See the [licensing guide](LICENSING.md), [original MIT notice](licenses/Science_2024-MIT.txt) and [third-party notices](THIRD_PARTY_NOTICES.md).

`RELEASE_MANIFEST.txt` identifies the source snapshot, lists relative paths and records per-file SHA-256 values. The ZIP inventory is derived from `OxygenReleaseSourcePolicy.json`. Research recordings, generated results, machine-specific inputs, development evidence and unadopted prototypes are excluded. Saved recording and export folders are supplied separately by the user.

The release workflow calls `createOxygenReleasePackage` on the selected commit. Verification reads the finished ZIP and compares every source path and SHA-256 with `getOxygenReleaseSourceList(pwd,true)`. The sole additional file is the generated `RELEASE_MANIFEST.txt`, whose source hashes are also checked.

A dry-run artifact contains `OxygenDynamicsV2-X.zip` and `SHA256SUMS`. For an approved tag, the draft also carries `RELEASE_NOTES_X.md` from the tagged commit as both an attachment and the release body. The checksum file covers the ZIP and any attached notes. The researcher decides when to publish. [Release runbook](RELEASING.md)
