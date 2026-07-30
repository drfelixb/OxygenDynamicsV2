# Open-Source Program Application Notes

These notes separate verifiable repository facts from work that remains before
OxygenDynamicsV2 can accurately be presented as an open-source project.

## Project Summary

OxygenDynamicsV2 is a MATLAB research pipeline for analysing spatiotemporal
oxygen dynamics recorded in murine cortex with bioluminescence oxygen imaging.
It supports detection, raw-signal quantification, manual curation, verification,
hypoxic-burden analysis, regression checks, and summary exports.

The software was originally developed by Felix R. M. Beinlich and Antonios
Asiminas and builds on the analysis associated with the 2024 *Science* article
"Oxygen imaging of hypoxic pockets in the mouse cerebral cortex"
(DOI: 10.1126/science.adn1011).

## Verifiable Repository Facts

Snapshot checked on 2026-07-30:

- Repository: `drfelixb/OxygenDynamicsV2`
- Visibility: public
- Created: 2026-05-27
- Default branch: `main`
- Development branch: `development`
- Automated MATLAB checks: GitHub Actions workflow present
- Stars: 0
- Forks: 0
- Watchers: 0
- Open issues: 0

The repository is new, so adoption and community impact should not be inferred
from these metrics. Application text should focus on the scientific need,
technical capability, validation approach, and concrete plans for community
development.

## Evidence Available in the Repository

- README and user manual
- Pipeline and detection flow maps
- Synthetic smoke test
- Repository checks and GitHub Actions workflow
- Preflight verification and health checks
- Scientific acceptance and regression-baseline workflow
- Citation metadata
- Contribution, security, issue, pull request, and release guidance
- Third-party provenance and licence notices

## Blocking Decisions

1. `TODO(owner)`: Confirm ownership and permission to license the original software,
   including any University of Copenhagen obligations.
2. `TODO(owner)`: Agree on a project-level licence with both original developers.
3. `TODO(owner)`: Reconcile the existing `v3.0` tag with internal version `1.01`.
4. `TODO(owner)`: Decide which release should be presented as the first supported public
   release.
5. `TODO(owner)`: Choose and enable a private security-reporting route. GitHub
   private vulnerability reporting was disabled when these notes were prepared.

## Licence Discussion

BSD-3-Clause is a strong candidate for the project-owned code because it is
permissive, familiar in research software, and includes a non-endorsement
clause. MIT is simpler but omits that clause. Apache-2.0 adds an explicit patent
grant and more process. MPL-2.0 adds file-level copyleft, while GPL requires
derivative distributions to remain under the GPL.

The bundled dependencies use BSD-2-Clause or BSD-3-Clause-style terms, so they
are compatible with a permissive project licence when their notices are
preserved. A noncommercial or research-only restriction would not meet the
Open Source Definition.

No top-level licence should be added until ownership and the licence choice are
approved.

## Suggested Application Positioning

- **Scientific need:** reproducible analysis of transient, spatially localised
  cortical oxygen events.
- **Distinctive workflow:** denoised detection paired with raw-data amplitude
  quantification, manual curation, acceptance checks, and regression controls.
- **Public value:** a traceable MATLAB workflow linked to a peer-reviewed
  imaging method and designed for reuse by imaging laboratories.
- **Near-term goals:** settle licensing, publish a reconciled release, add
  example synthetic data and tutorials, improve automated tests, and welcome
  initial external users.
- **Community honesty:** describe the project as newly public and
  maintainer-led; do not claim an established contributor community yet.

## Responsible AI Assistance

AI assistance can support documentation, issue triage, test scaffolding,
review of repetitive refactors, dependency and licence inventories, and
reproducibility checks. Scientific definitions, thresholds, accepted outputs,
and biological interpretation must remain under domain-expert review. Any
AI-assisted scientific change should be disclosed in its pull request and
validated with synthetic tests and accepted regression evidence.

## Evidence to Gather Next

- Written approval of ownership and project licence.
- A stable release DOI, for example through Zenodo.
- CI history on `main` and `development`.
- A small public synthetic example with expected outputs.
- Installation and first-run feedback from an independent user.
- Issues or pull requests demonstrating external use.
- A short roadmap with two or three achievable milestones.
