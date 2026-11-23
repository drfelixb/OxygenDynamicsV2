function runBOIEventBaselineFlagsSession(out)
% One MATLAB process can perform the initial pass and one authorized repair.
try
    runBOIEventBaselineFlagsChecks(out,'initial');
catch problem
    checkpoint=struct('Status','awaiting_one_repair','Message',getReport(problem,'extended','hyperlinks','off'));
    path=fullfile(out,'verification-checkpoint.json');write(path,checkpoint);
    disp(checkpoint.Message);
    fprintf('CHECKPOINT: initial verification stopped; awaiting the one bounded repair.\n');
    timer=tic;
    signal=fullfile(out,'run-one-repair.json');
    while ~isfile(signal)&&toc(timer)<3600,pause(1);end
    assert(isfile(signal),'OxygenDynamics:RepairWaitExpired','No repair signal; preserved checkpoint.');
    scope=jsondecode(fileread(fullfile(out,'scope.json')));
    assert(scope.Counters.Repairs==1,'OxygenDynamics:RepairBudget','Only one recorded repair is allowed.');
    clear functions
    rehash;
    mode='initial';if isfile(fullfile(out,'initial-test-results.json')),mode='repair';end
    runBOIEventBaselineFlagsChecks(out,mode);
end
write(fullfile(out,'verification-complete.json'),struct('Status','passed'));
end
function write(path,data)
fid=fopen(path,'w');assert(fid>=0);c=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(data,'PrettyPrint',true));
end
