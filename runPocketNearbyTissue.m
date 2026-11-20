function resultFolder = runPocketNearbyTissue(inputFolder, outputParent, options)
%RUNPOCKETNEARBYTISSUE Export automatic pocket and nearby-tissue traces.
% With no arguments, choose a completed automatic export and review the
% sources. In scripts, supply one decision row per movie needing a mouse ID
% or relocated TIFF. See docs/POCKET_TRACES.md.
arguments
    inputFolder (1,1) string = ""
    outputParent (1,1) string = ""
    options.Decisions table = table()
    options.ConfirmedOmissions string = strings(0,1)
    options.MakeFigures (1,1) logical = true
end
setupOxygenDynamicsPath;
resultFolder = "";
if inputFolder==""
    folder = uigetdir(pwd,'Choose a completed automatic export');
    if isequal(folder,0), return; end
    openPocketTracePreview(folder);
    return
end
if outputParent=="", outputParent=inputFolder; end
plan = preparePocketNearbyTissue(inputFolder,outputParent);
resultFolder = exportAutomaticPocketTraces(plan,outputParent,options.Decisions,options.ConfirmedOmissions,options.MakeFigures);
end
