function assertNoBlockedVerificationRows(VerificationReport,nextStepName)
%ASSERTNOBLOCKEDVERIFICATIONROWS Stop gated scripts when verification failed.

if nargin<2 || isempty(nextStepName)
    nextStepName = 'the next step';
end

BlockedRows = VerificationReport.SummaryTable(VerificationReport.SummaryTable.Status=="Blocked",:);
if ~isempty(BlockedRows)
    error('Verification found %d blocked recording(s). Fix these before running %s. See %s', ...
        height(BlockedRows),nextStepName,VerificationReport.OutputFiles.Xlsx);
end

end
