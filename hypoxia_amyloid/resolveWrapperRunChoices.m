function [AnalysisMode,strAgain,strOW] = resolveWrapperRunChoices(RunConfig)
%RESOLVEWRAPPERRUNCHOICES Resolve wrapper mode/reanalysis choices.

if RunConfig.interactive
    answerReanalyse = questdlg('Do you want to analyse data you have analysed before?', ...
        'What data', ...
        'Yes','No','No');

    switch answerReanalyse
        case 'Yes'
            strAgain = 'Y';
            answerOverwrite = questdlg('Do you want to overwrite previous analysis (if any)?','Yes','No');
            switch answerOverwrite
                case 'Yes'
                    strOW = 'Y';
                case 'No'
                    strOW = 'N';
                otherwise
                    strOW = 'N';
            end
        case 'No'
            strAgain = 'N';
            strOW = 'N';
        otherwise
            strAgain = 'N';
            strOW = 'N';
    end

    AnalysisMode = questdlg('Which wrapper mode do you want to run?', ...
        'What data', ...
        'Hypoxia-amyloid only','Preflight only','All analysis','All analysis');
else
    if RunConfig.reanalyseExisting
        strAgain = 'Y';
    else
        strAgain = 'N';
    end

    if RunConfig.overwritePreviousAnalysis
        strOW = 'Y';
    else
        strOW = 'N';
    end

    AnalysisMode = RunConfig.analysisMode;
end

AllowedModes = {'Preflight only','Only df/f tifs','Hypoxia-amyloid only','All analysis'};
if ~ismember(AnalysisMode,AllowedModes)
    error(['RunConfig.analysisMode must be "Preflight only", "Only df/f tifs", ', ...
        '"Hypoxia-amyloid only", or "All analysis".']);
end

end
