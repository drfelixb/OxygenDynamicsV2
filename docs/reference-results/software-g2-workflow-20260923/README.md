# G2 compact evidence

See [G2 delivery](../../SOFTWARE_G2_WORKFLOW.md) for scope, results and limits.
Local evidence is MATLAB R2025a on macOS ARM; hosted R2025b/Linux CI is not run.
The full gate passed 129 tests; ten final focused tests passed (nine repeated,
one added). Exactly two ID400 executions produced 148 passing exact comparisons.

MATLAB recipes use `.m.txt` so this archive does not enter the runtime code
inventory. Run outputs, raw copies, full logs and before-code snapshots stay
outside the repository in `reference-validation/software-g2-workflow-20260923`.
The artifact record uses workspace-relative paths and SHA256; its G1 chain
verification identifies preserved bytes for earlier files updated during G2.
