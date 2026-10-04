function next02SavedDataSession(Root)
% One bounded saved-data-only session. No engine, movie, detector or stats run.
addpath(fullfile(Root,'existing-analysis'));setupOxygenDynamicsPath;
folder=fullfile(Root,'reference-validation','software-next02-calculations-20261004');
cleanup=onCleanup(@()writeStatus(fullfile(folder,'session-ended.json'),struct('EndedUTC',char(datetime('now','TimeZone','UTC')))));
started=tic;job=1;
while toc(started)<7200 && job<=5
    if isfile(fullfile(folder,'close-session')),break;end
    command=fullfile(folder,sprintf('command-%02d.json',job));
    if ~isfile(command),pause(.5);continue;end
    c=jsondecode(fileread(command));
    try
        clear runNext02CalculationChecks next02Inventory;
        rehash;
        if strcmp(c.Action,'inventory'),next02Inventory(Root);
        else,runNext02CalculationChecks(Root,c.Batch);end
        status=struct('Job',job,'Status','returned');
    catch err
        status=struct('Job',job,'Status','failed','Message',getReport(err,'extended','hyperlinks','off'));
    end
    writeStatus(fullfile(folder,sprintf('command-%02d-finished.json',job)),status);job=job+1;
end
end
function writeStatus(path,value)
f=fopen(path,'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
