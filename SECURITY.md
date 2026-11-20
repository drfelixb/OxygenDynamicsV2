# Security Policy

## Supported Versions

Security fixes are currently made on the latest code on `development` and are
included in the next promotion to `main`. Historical snapshots and tags are not
separately supported.

## Reporting a Vulnerability

Do not open a public issue for a suspected vulnerability or for a report that
contains sensitive paths, credentials, personal information, or research data.

Use GitHub private vulnerability reporting from the repository's **Security**
tab when that option is available. Otherwise, contact a maintainer privately
through their institutional contact details and include:

- a concise description of the issue and impact;
- the affected commit, branch, or version metadata;
- minimal reproduction steps using synthetic data;
- any suggested mitigation;
- whether disclosure is time-sensitive.

Please allow the maintainers time to confirm the report and coordinate a fix
before public disclosure. This policy covers software security; questions about
scientific validity should use the normal issue templates without sharing
sensitive data.

## Research Data Handling

The pipeline reads and writes local research files. Users are responsible for
appropriate filesystem permissions, institutional access controls, secure
storage, backups, and review of exported logs and workbooks before sharing.

OxygenDynamicsV2 does not claim compliance with clinical, diagnostic, medical
device, or regulated-data standards. Do not use the public issue tracker to
share unpublished datasets, credentials, animal identifiers, personal data, or
protected network locations.
