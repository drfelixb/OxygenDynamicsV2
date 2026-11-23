function recordBOICompactBatchWrite(scopePath)
% Count before every native writer dispatch, including failed attempts.
s=jsondecode(fileread(scopePath));assert(s.ExecutionApproved&&s.Counters.WriterDispatches<s.Limits.WriterDispatches,'OxygenDynamics:CompactBudget','Workbook dispatch limit reached.');
s.Counters.WriterDispatches=s.Counters.WriterDispatches+1;writeBOIRunJSON(scopePath,s);
end
