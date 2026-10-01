function cc02SavedDataSession(Root)
%CC02SAVEDDATASESSION One ordinary saved-data test session, bounded idle lifetime.
addpath(fullfile(Root,'existing-analysis'));setupOxygenDynamicsPath;
packet=fullfile(Root,'reference-validation','cc-02-integration-20260930');
started=tic;job=1;
while toc(started)<3600
    command=fullfile(packet,sprintf('command-%02d.json',job));
    if isfile(fullfile(packet,'close-session')),break;end
    if ~isfile(command),pause(.25);continue;end
    c=jsondecode(fileread(command));
    try
        runCC02Integration(Root,c.Cases,c.Batch);
        status=struct('Job',job,'Status','returned');
    catch err
        status=struct('Job',job,'Status','stopped','ErrorID',err.identifier,'Message',getReport(err,'extended','hyperlinks','off'));
    end
    fid=fopen(fullfile(packet,sprintf('command-%02d-finished.json',job)),'w');fprintf(fid,'%s',jsonencode(status,'PrettyPrint',true));fclose(fid);
    job=job+1;
end
exit;
end
