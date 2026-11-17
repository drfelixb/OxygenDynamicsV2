function automaticAmplitudeSavedDataSession(Root)
% Bounded saved-table export session; no detector, movie or statistics pipeline.
addpath(fullfile(Root,'existing-analysis'));setupOxygenDynamicsPath;
folder=fullfile(Root,'reference-validation','automatic-amplitude-exports-20261001');
started=tic;job=1;
while toc(started)<3600 && job<=4
    if isfile(fullfile(folder,'close-session')),break;end
    command=fullfile(folder,sprintf('command-%02d.json',job));
    if ~isfile(command),pause(.25);continue;end
    c=jsondecode(fileread(command));
    try
        clear runAutomaticAmplitudeExportChecks createAutomaticAmplitudeExportData writeAutomaticAmplitudeExport exportStatsResults;
        rehash;
        runAutomaticAmplitudeExportChecks(Root,c.Batch);
        status=struct('Job',job,'Status','returned');
    catch err
        status=struct('Job',job,'Status','failed','Message',getReport(err,'extended','hyperlinks','off'));
    end
    f=fopen(fullfile(folder,sprintf('command-%02d-finished.json',job)),'w');fprintf(f,'%s\n',jsonencode(status,'PrettyPrint',true));fclose(f);
    job=job+1;
end
end
