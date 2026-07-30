function printWrapperConfiguration(WrapperName,RunConfig,AnalysisMode)
%PRINTWRAPPERCONFIGURATION Print resolved wrapper settings.

fprintf('\n%s configuration\n',WrapperName);
fprintf('Input CSV: %s\n',RunConfig.inputCsv);
fprintf('Analysis mode: %s\n',AnalysisMode);
fprintf('Reanalyse existing outputs: %s\n',string(RunConfig.reanalyseExisting));
fprintf('Overwrite previous analysis: %s\n',string(RunConfig.overwritePreviousAnalysis));

if isfield(RunConfig,'runRawDenoisedQC')
    fprintf('Raw/denoised QC after run: %s\n',string(RunConfig.runRawDenoisedQC));
end
if isfield(RunConfig,'runHypoxiaAmyloidAnalysis')
    fprintf('Hypoxia-amyloid analysis: %s\n',string(RunConfig.runHypoxiaAmyloidAnalysis));
    fprintf('Hypoxia-amyloid primary near threshold: %g um\n', ...
        RunConfig.hypoxiaAmyloidNearThresholdMicrometers);
end

fprintf('Email alerts enabled: %s\n\n',string(RunConfig.sendEmailAlerts));

end
