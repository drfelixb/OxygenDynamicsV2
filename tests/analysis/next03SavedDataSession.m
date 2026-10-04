function next03SavedDataSession(Root,StartJob)
% Bounded saved ingredients/calculations only; no analysis or stats pipeline.
addpath(fullfile(Root,'existing-analysis'));setupOxygenDynamicsPath;
folder=fullfile(Root,'reference-validation','software-next03-calculations-20261004');
if nargin<2,StartJob=1;end
cleanup=onCleanup(@()finish(folder,StartJob));started=tic;job=StartJob;
while toc(started)<10800 && job<=7
    if isfile(fullfile(folder,'close-session')),break;end
    path=fullfile(folder,sprintf('command-%02d.json',job));if ~isfile(path),pause(.5);continue;end
    c=jsondecode(fileread(path));
    try
        clear next03Inventory runNext03CalculationChecks createOxygenExportProvenance writeOxygenAnalysisManifest exportBOIWindowReview exportBOIEventReview getOxygenPipelineVersion;
        rehash;
        if strcmp(c.Action,'inventory'),next03Inventory(Root);else,runNext03CalculationChecks(Root,c.Batch);end
        receipt=struct('Job',job,'Status','returned');
    catch err
        receipt=struct('Job',job,'Status','failed','Message',getReport(err,'extended','hyperlinks','off'));
    end
    writeJSON(fullfile(folder,sprintf('command-%02d-finished.json',job)),receipt);job=job+1;
end
end
function finish(folder,StartJob)
writeJSON(fullfile(folder,sprintf('session-job%02d-ended.json',StartJob)),struct('EndedUTC',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ssXXX'))));
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
