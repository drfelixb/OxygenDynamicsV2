function Summary=runDandiSignalAudit(referenceRoot,outputRoot)
% Audit frozen reference measurements; no detections or amplitudes are changed.
setupOxygenDynamicsPath;
assert(~isfolder(outputRoot),'Use a new signal-audit output root.');mkdir(outputRoot);
P=jsondecode(fileread(fullfile(referenceRoot,'reference-set-profile.json')));
CodeManifest=createOxygenRegressionCodeManifest(fileparts(fileparts(fileparts(mfilename('fullpath')))));
writetable(CodeManifest,fullfile(outputRoot,'audit-code-manifest.csv'));
copyfile(fullfile(referenceRoot,'reference-set-profile.json'),fullfile(outputRoot,'reference-set-profile.json'));
Summary=table();AllEvents=table();
for i=1:numel(P.Records)
    R=P.Records(i);fprintf('\nSIGNAL AUDIT %d/%d: %s\n',i,numel(P.Records),R.Session);started=tic;
    status="failed";message="";n=NaN;mismatch=NaN;wrong=NaN;
    try
        report=load(fullfile(referenceRoot,R.Session,'reference-report.mat'));
        assert(strcmp(report.report.Status,'passed'),'Reference recording did not pass.');
        A=auditOxygenEventAmplitudeSource(fullfile(referenceRoot,R.Session,'Recording'), ...
            'reconstructDetection',true,'outputFolder',fullfile(outputRoot,R.Session));
        n=height(A);mismatch=sum(~A.MeasurementMatches);wrong=sum(A.WrongDirection);
        A.Session=repmat(string(R.Session),height(A),1);A.Role=repmat(string(R.Role),height(A),1);
        AllEvents=[AllEvents;A]; %#ok<AGROW>
        assert(mismatch==0,'OxygenDynamics:AuditMismatch','Saved measurements differ from independent reconstruction.');
        status="passed";
    catch ex
        message=string(getReport(ex,'extended','hyperlinks','off'));fprintf('%s\n',message);
    end
    row=table(string(R.Session),string(R.Role),status,n,mismatch,wrong,toc(started),message, ...
        'VariableNames',{'Session','Role','Status','Events','MeasurementMismatches','WrongDirectionEvents','ElapsedSeconds','Error'});
    Summary=[Summary;row]; %#ok<AGROW>
    writetable(Summary,fullfile(outputRoot,'signal-audit-summary.csv'));
    writetable(AllEvents,fullfile(outputRoot,'all-event-signal-audit.csv'));
    save(fullfile(outputRoot,'signal-audit-summary.mat'),'Summary');
    fprintf('SIGNAL AUDIT RESULT: %s %s\n',R.Session,status);
end
Final=createOxygenRegressionCodeManifest(fileparts(fileparts(fileparts(mfilename('fullpath')))));
assert(isequal(CodeManifest(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})), ...
    'OxygenDynamics:AuditCodeChanged','MATLAB source changed during audit.');
end
