# Contributing to OxygenDynamicsV2

Thank you for helping improve OxygenDynamicsV2. Contributions that make the
pipeline easier to validate, reproduce, understand, or reuse are welcome.

## Before Opening an Issue

- Search existing issues for the same problem or proposal.
- Run `setupOxygenDynamicsPath` and open the recording workflow with `openBOIBatchEditor`.
- For code problems, report the result of `runBOISoftwareChecks('portable','results-portable')` from the source checkout.
- Remove personal, animal, experimental, institutional, and local filesystem
  information from logs and examples.

Use the issue form that best matches the request. A minimal synthetic example
is strongly preferred to experimental data.

Software failures, crashes, incorrect file handling, and reproducible output
defects belong in the bug form. Questions about biological interpretation or
whether a result supports a scientific conclusion are not software bugs; frame
those as a discussion with the relevant scientific context and without
confidential data.

## Development Workflow

1. Create a branch from `main`.
2. Keep each change focused and avoid unrelated formatting or refactoring.
3. Do not commit raw recordings, generated outputs, secrets, or local paths.
4. Add or update tests and documentation for changed behaviour.
5. Run the checks listed below.
6. Open a pull request into `main`.

## Validation

The repository is tested with MATLAB R2025b. Core imaging work requires Image
Processing Toolbox; some optional analyses require Statistics and Machine
Learning Toolbox. Earlier MATLAB releases have not been formally verified.

In a fresh MATLAB session, run these commands in order from the repository root:

```matlab
setupOxygenDynamicsPath
runRepositoryChecks
runBOISoftwareChecks('portable','results-portable')
runBOISoftwareChecks('desktop','results-desktop')
```

For changes that affect experimental results, document the numerical differences on a synthetic
fixture or a recording approved for that comparison.

## Scientific Changes

A pull request that changes detection, tracking, curation, quantification,
normalisation, filtering, or statistical definitions must:

- explain the scientific rationale;
- identify affected outputs, columns, and saved variables;
- state whether results remain comparable with earlier versions;
- include a synthetic test or a reviewed regression comparison;
- update metric definitions, the affected guides, and compatibility notes as needed.

## Code Style

- Follow the existing MATLAB naming and file-layout conventions.
- Prefer small functions with explicit inputs and outputs.
- Keep scripts that exist for compatibility thin.
- Add comments for scientific assumptions or non-obvious constraints, not for
  self-explanatory operations.
- Keep platform-specific behaviour optional and clearly guarded.

## Third-Party Code

Do not add copied or adapted code without recording its author, source URL,
version or retrieval date, licence, and any modifications. Preserve required
notices and update `THIRD_PARTY_NOTICES.md`.

## Pull Requests

Complete the pull request template and disclose any generated or AI-assisted
changes that require extra review. A maintainer may ask for a smaller change,
additional validation, or provenance information before merging.

Before requesting review, confirm that the scope is explained, scientific
changes are identified, the BOI checks pass, regression testing was run where
needed, documentation is current, and no generated or confidential files are
included.

By contributing, you confirm that you have the right to submit the material
and that it can be distributed under the repository's eventual project
licence. The project-level licence is currently under review, so maintainers
may defer substantive external contributions until that decision is complete.
