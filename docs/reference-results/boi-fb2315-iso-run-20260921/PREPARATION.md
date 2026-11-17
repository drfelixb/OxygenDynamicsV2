# FB2315 isoflurane run preparation

The existing source, native mask and displayed five-frame outline are bound in
prespecification.json. The source identity and original filename discrepancy were
resolved previously. Settings, external 1 Hz timing and original correction are
unchanged. This preparation does not adopt the outline or approve final windows.

The researcher judgment on this isoflurane outline remains pending. runWorkflow.m
checks for its separate accepted decision before creating any analysis output.
The awake acceptance is not transferred. After the judgment, save its exact text
and source/preview identities in researcher-support-decision.json, write the
matching BOIInputMetadata.json, and execute the prepared current-method workflow.
Then use auditWorkflow.m and verify.py for the established numerical checks.

Original inputs and all prior outputs remain unchanged. No movie was decoded,
detector executed, threshold tuned or physiological claim added in preparation.
