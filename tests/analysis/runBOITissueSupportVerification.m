function Report=runBOITissueSupportVerification(OutputRoot)
%RUNBOITISSUESUPPORTVERIFICATION Synthetic end-to-end support transport only.
% One reviewed-mask master/stats run plus the existing default-mask integration.
% No biological source selection, mask review, detector tuning or cohort claims.
setupOxygenDynamicsPath;
OutputRoot=char(java.io.File(OutputRoot).getCanonicalPath());
assert(~isfolder(OutputRoot),'Preserve previous verification folders.');mkdir(OutputRoot);started=tic;
project=fileparts(fileparts(fileparts(mfilename('fullpath'))));
code=createOxygenRegressionCodeManifest(project);writetable(code,fullfile(OutputRoot,'code-manifest.csv'));
Report=struct('Schema','boi-tissue-support-verification-1','Status','started', ...
    'ScientificScope','synthetic transport and arithmetic; biological support remains unresolved', ...
    'MatlabVersion',version,'CreatedUTC',char(datetime('now','TimeZone','UTC')));
try
    rec=fullfile(OutputRoot,'Recording');mkdir(rec);rng(71);
    X=uint16(1000+10*randn(96,96,100));
    X(35:55,35:55,40:48)=X(35:55,35:55,40:48)-250;
    X(60:80,60:80,65:76)=X(60:80,60:80,65:76)+250;
    source=fullfile(rec,'synthetic_original.tif');saveastiff(X,source);
    Mask=false(96);Mask(12:84,32:85)=true;Mask(40:45,45:50)=false;
    proposal=fullfile(OutputRoot,'proposal');reviewBOITissueSupport(rec,Mask,proposal);
    assert(~isfile(fullfile(rec,'BOITissueSupport.json')));
    decision=struct('DecisionID','SYNTHETIC-TISSUE-001','Actor','automated verification fixture', ...
        'Reason','Verify explicit static support reaches master and export without replacing prior evidence', ...
        'Evidence','Known rectangle and hole generated for a synthetic test; no biological anatomical review', ...
        'AlignmentEvidence','Logical mask constructed in the decoded source row/column grid; no registration');
    snapshot=writeBOITissueSupport(rec,proposal,decision);
    Review=reviewBOIRecordingInput(rec,2,2.5);assert(any(Review.QC.IssueID=="R1-REVIEWED-TISSUE"));
    save(fullfile(OutputRoot,'preflight.mat'),'Review');
    if isempty(gcp('nocreate')),parpool('Processes',2);end
    context=struct('SFs',2,'PiSz',2.5,'Mous','synthetic','Cond','Unknown','Drug','Unknown', ...
        'Gen','Unknown','Promo','Unknown','Puff',NaN,'strOW','N');
    t=tic;master=runOxygenDynamicsMaster(rec,context);Report.ReviewedMasterSeconds=toc(t);I=master.AnalysisInfo;
    sink=false(96);sink(21:76,21:76)=Mask(21:76,21:76);
    assert(isequal(I.SinkEligibleTissuePixels,find(sink))&&isequal(I.SurgeEligibleTissuePixels,find(Mask)));
    assert(I.RecordingAreaUm2==nnz(sink)*2.5^2&&I.SurgeRecordingAreaUm2==nnz(Mask)*2.5^2);
    assert(isequal(I.BOITissueSupport,snapshot));
    % loadtiff supplies single pixels to the master. Preserve that numerical
    % input type when replaying its automatic support; double is not identical.
    auto=computeRecordingArea(detrend_custom(single(X),3),2.5,30);
    assert(isequal(I.TissueSupportAudit.AutomaticTissuePixels,find(auto.Mask)));
    assert(isequal(I.TissueSupportAudit.AddedPixels,find(Mask & ~auto.Mask)));
    assert(isequal(I.TissueSupportAudit.RemovedPixels,find(~Mask & auto.Mask)));
    Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
    Mouse={'synthetic'};Genotype={'Unknown'};Condition={'Unknown'};DrugID={'Unknown'};Promoter={'Unknown'};
    SampleF=2;Pixelsize=2.5;Puff_2use=NaN;RecordingID="SYNTHETIC-TISSUE-001";
    T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
    csv=fullfile(OutputRoot,'input.csv');writetable(T,csv);
    t=tic;result=runOxygenDynamicsStats(struct('inputCsv',csv,'masterFolder',OutputRoot, ...
        'outputRoot',fullfile(OutputRoot,'stats'),'interactive',false));Report.ReviewedStatsSeconds=toc(t);
    D=load(result.DataOutputMat);contract=D.BOIInputContracts{1};
    assert(isequal(contract.TissueSnapshot,snapshot)&&isequal(contract.TissueSupportAudit,I.TissueSupportAudit));
    assert(strcmp(contract.TissueDecision.DecisionID,decision.DecisionID));
    assert(strcmp(contract.ScientificEligibility,'not_established_by_input_contract'));
    assert(contains(D.RecordingRegistry.TissueValidityStatus,'reviewed_static_support_declared'));
    assert(all(D.RecordingFrameExposure.SinkAnalyzedArea_um2==nnz(sink)*2.5^2));
    assert(all(D.RecordingFrameExposure.SurgeAnalyzedArea_um2==nnz(Mask)*2.5^2));
    ingredients=readtable(fullfile(fileparts(result.DataOutputMat),'WindowFrameIngredients.csv'));
    denominator=sum(ingredients.AnalyzedTissueTime_um2_sec);
    assert(denominator==nnz(sink)*2.5^2*50);
    assert(abs(sum(ingredients.CoveredAreaTime_um2_sec)/denominator-D.RecordingWindowMetrics.MeanOccupiedTissueFraction)<1e-12);
    json=jsondecode(fileread(fullfile(fileparts(result.DataOutputMat),'RecordingInputContracts.json')));
    assert(isequal(json.TissueDecision.MaskPixels,find(Mask))&&isequal(json.TissueSupportAudit.RemovedPixels,I.TissueSupportAudit.RemovedPixels));
    acceptance=readtable(result.OutputXlsx,'Sheet','StatsAcceptance','TextType','string');
    assert(any(contains(acceptance.Item,"R1-REVIEWED-TISSUE") & acceptance.Status=="REVIEW"));
    Report.AutomaticPixels=nnz(auto.Mask);Report.ReviewedPixels=nnz(Mask);Report.SinkPixels=nnz(sink);
    Report.AddedPixels=numel(I.TissueSupportAudit.AddedPixels);Report.RemovedPixels=numel(I.TissueSupportAudit.RemovedPixels);
    Report.AnalyzedTissueTime_um2_sec=denominator;Report.CsvReplayPassed=true;
    Report.DataOutput=result.DataOutputMat;Report.DataOutputSHA256=oxygenFileSHA256(result.DataOutputMat);
    t=tic;defaultResult=runExistingAnalysisIntegration();Report.DefaultIntegrationSeconds=toc(t);
    save(fullfile(OutputRoot,'default-integration.mat'),'defaultResult');
    Report.DefaultIntegrationPassed=true;
    after=createOxygenRegressionCodeManifest(project);
    assert(isequal(code(:,{'RelativePath','SHA256'}),after(:,{'RelativePath','SHA256'})),'Code changed during verification.');
    Report.Status='technical_checks_passed_biological_support_unresolved';
catch err
    Report.Status='failed';Report.ErrorID=err.identifier;Report.Error=err.message;
    Report.ElapsedSeconds=toc(started);writeReport(OutputRoot,Report);rethrow(err);
end
Report.ElapsedSeconds=toc(started);writeReport(OutputRoot,Report);
end
function writeReport(folder,Report)
fid=fopen(fullfile(folder,'verification-report.json'),'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(Report,'PrettyPrint',true));
end
