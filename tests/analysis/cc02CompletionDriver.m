% CC02COMPLETIONDRIVER Disposable saved-data session; no engine or movie route.
% Script runs in base workspace so each completed job can clear cached functions.
cc02Root='/Users/zcm361/Documents/Github/OxygenDynamicsV2';
cc02Packet=fullfile(cc02Root,'reference-validation','cc-02-completion-extension-20260930');
addpath(fullfile(cc02Root,'existing-analysis'),fullfile(cc02Root,'existing-analysis','tests','analysis'));
cc02Started=tic;cc02Job=1;
while toc(cc02Started)<14400
    if isfile(fullfile(cc02Packet,'close-session')),break;end
    cc02Command=fullfile(cc02Packet,sprintf('command-%02d.json',cc02Job));
    if ~isfile(cc02Command),pause(.25);continue;end
    cc02Config=jsondecode(fileread(cc02Command));
    % No job function remains active here. Refresh the disposable process only.
    clear functions;
    rehash;
    cc02Loaded=inmem('-completenames');
    assert(~any(contains(string(cc02Loaded),["runCC02Integration.m","createBOIReviewedPocketPanel.m","buildBOIReviewedPocketEvidence.m"])), ...
        'CC02:Cache','Test/application functions remained cached before the job.');
    try
        runCC02Integration(cc02Root,cc02Config.Cases,cc02Config.Batch,cc02Packet);
        cc02Status=struct('Job',cc02Job,'Status','returned','CacheRefresh','clear_functions_rehash_before_job', ...
            'Cases',cc02Config.Cases(:)','DriverSHA256',oxygenFileSHA256(mfilename('fullpath')+".m"));
    catch cc02Error
        cc02Status=struct('Job',cc02Job,'Status','stopped','ErrorID',cc02Error.identifier, ...
            'Message',getReport(cc02Error,'extended','hyperlinks','off'));
    end
    cc02File=fopen(fullfile(cc02Packet,sprintf('command-%02d-finished.json',cc02Job)),'w');
    fprintf(cc02File,'%s',jsonencode(cc02Status,'PrettyPrint',true));fclose(cc02File);
    cc02Job=cc02Job+1;
end
exit;
