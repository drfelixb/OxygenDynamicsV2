function Report=runBOIInputContractVerification(PreviousWalkthroughRoot,OutputRoot,CompletedRunRoot)
%RUNBOIINPUTCONTRACTVERIFICATION Bounded R1 export/entry verification on ID400.
% One existing full-recording master is read; no detector rerun or tuning.
setupOxygenDynamicsPath;
if nargin<3,CompletedRunRoot='';end
assert(~isfolder(OutputRoot)&&~isfile(OutputRoot),'Choose a new verification output root.');
mkdir(OutputRoot);started=tic;
project=fileparts(fileparts(fileparts(mfilename('fullpath'))));
code=createOxygenRegressionCodeManifest(project);writetable(code,fullfile(OutputRoot,'code-manifest.csv'));
Report=struct('Schema','boi-input-contract-verification-1','Status','started', ...
    'RecordingID','dandi000891_ID400_awake','Role','previously inspected ID400 development recording', ...
    'Scope','BOI only; input/export consistency, not biological validation', ...
    'InputContract','boi-recording-input-1','WindowAudit','boi-window-exposure-1', ...
    'Budget','One known-event/zero-event integration, one ID400 stats export; no full detector rerun; ten-minute soft completion review', ...
    'CreatedUTC',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ssXXX')));
writeJson(fullfile(OutputRoot,'verification-report.json'),Report);
try
    rec=fullfile(PreviousWalkthroughRoot,'Recording');
    oldFiles=dir(fullfile(PreviousWalkthroughRoot,'run-A','**','DataOutput.mat'));assert(isscalar(oldFiles));
    oldFile=fullfile(oldFiles.folder,oldFiles.name);oldHash=oxygenFileSHA256(oldFile);old=load(oldFile);
    assert(height(old.RecordingRegistry)==1 && old.RecordingRegistry.RecordingID==string(Report.RecordingID));
    expected='695f8390be5fe18d06685d718b7e99c73d08715f51ef11ec14c694b32b599a05';
    assert(strcmp(oxygenFileSHA256(fullfile(rec,'preserved_original.tif')),expected));
    Report.SourceSHA256=expected;
    % Preflight reads present source declarations. Stats separately reads only
    % the declaration snapshot saved with the selected historical master.
    review=reviewBOIRecordingInput(rec,1,4.75);save(fullfile(OutputRoot,'input-review.mat'),'review');
    assert(strcmp(review.Status,'descriptive_input_requires_scientific_review'));
    if isempty(CompletedRunRoot)
    if isempty(gcp('nocreate')),parpool('Processes',2);end
    t=tic;integration=runExistingAnalysisIntegration();Report.IntegrationSeconds=toc(t);
    save(fullfile(OutputRoot,'integration-result.mat'),'integration');
    inputCsv=fullfile(PreviousWalkthroughRoot,'local-only','input.csv');
    config=struct('inputCsv',inputCsv,'masterFolder',PreviousWalkthroughRoot,'outputRoot',fullfile(OutputRoot,'stats'), ...
        'interactive',false,'imagingMode','BLI','useCuratedSinks',false,'chooseSpecificFolders',false, ...
        'sinkFolderSelection','Recent','surgeFolderSelection','Recent','behaviourFolderSelection','Recent', ...
        'analysisWindowsCsv','','baselinePairsCsv','','windowPairsCsv','');
    t=tic;result=runOxygenDynamicsStats(config);Report.StatsSeconds=toc(t);
    else
        % A failed comparison does not require another export. Preserve that
        % report and independently verify its already completed result.
        previousReport=fullfile(CompletedRunRoot,'verification-report.json');
        previous=jsondecode(fileread(previousReport));
        assert(isfield(previous,'IntegrationSeconds')&&isfield(previous,'StatsSeconds'));
        Report.IntegrationSeconds=previous.IntegrationSeconds;Report.StatsSeconds=previous.StatsSeconds;
        Report.VerificationMode='read_only_replay_of_completed_export';
        Report.CompletedRunReportSHA256=oxygenFileSHA256(previousReport);
        files=dir(fullfile(CompletedRunRoot,'stats','**','DataOutput.mat'));assert(isscalar(files));
        books=dir(fullfile(files.folder,'FilteredData_*.xlsx'));assert(isscalar(books));
        result=struct('DataOutputMat',fullfile(files.folder,files.name),'OutputXlsx',fullfile(books.folder,books.name));
    end
    D=load(result.DataOutputMat);
    assert(strcmp(oxygenFileSHA256(oldFile),oldHash),'Prior stats result changed.');
    assert(isequaln(D.Table_OxygenSinkEvents_OutCombo,old.Table_OxygenSinkEvents_OutCombo));
    assert(isequaln(D.Table_OxygenSurgeEvents_OutCombo,old.Table_OxygenSurgeEvents_OutCombo));
    fields=fieldnames(old.HypoxicBurden);
    for field=reshape(fields,1,[])
        original=old.HypoxicBurden.(field{1});current=D.HypoxicBurden.(field{1});
        if istable(original)
            current=current(:,original.Properties.VariableNames);
        end
        assert(isequaln(current,original),'Original burden field changed: %s',field{1});
    end
    oldNames=old.RecordingWindowMetrics.Properties.VariableNames;
    oldNumeric=varfun(@isnumeric,old.RecordingWindowMetrics,'OutputFormat','uniform');
    for name=oldNames(oldNumeric)
        x=D.RecordingWindowMetrics.(name{1});y=old.RecordingWindowMetrics.(name{1});
        assert(all((isnan(x)&isnan(y))|abs(x-y)<=1e-12+1e-10*abs(y)),'Existing window result changed: %s',name{1});
    end
    W=D.RecordingWindowMetrics;F=D.WindowFrameIngredients;
    assert(height(F)==600 && height(D.RecordingFrameExposure)==600);
    numerator=sum(F.CoveredAreaTime_um2_sec);denominator=sum(F.AnalyzedTissueTime_um2_sec);
    assert(abs(numerator/denominator-W.MeanOccupiedTissueFraction)<=1e-12);
    assert(numerator==W.CoveredAreaTime_um2_sec && denominator==W.AnalyzedTissueTime_um2_sec);
    assert(all(isnan(D.RecordingFrameExposure.CameraExposureSec)));
    assert(all(isnan(D.RecordingFrameExposure.DeclaredFrameValid)));
    assert(all(D.RecordingFrameExposure.ModeledFrameIncluded));
    assert(all(isnan(D.RecordingFrameExposure.DeclaredFrameTimeSec)));
    assert(D.RecordingRegistry.AcquisitionMetadataState=="not_recorded_at_master");
    assert(any(D.RecordingInputQC.IssueID=="R1-EXPOSURE-UNKNOWN"));
    assert(W.EventOnsets==W.OnsetsAfterAcquisitionStart+W.AcquisitionStartOnsetsCounted);
    folder=fileparts(result.OutputXlsx);
    assert(isfile(fullfile(folder,'RecordingInputReview.md')));
    csv=readtable(fullfile(folder,'WindowFrameIngredients.csv'));
    assert(abs(sum(csv.CoveredAreaTime_um2_sec)/sum(csv.AnalyzedTissueTime_um2_sec)-W.MeanOccupiedTissueFraction)<=1e-12);
    exported=jsondecode(fileread(fullfile(folder,'RecordingInputContracts.json')));
    % jsondecode represents JSON null (unknown NaN) differently; verify exact
    % identifiers, original tissue indices and timing/model statements.
    assert(strcmp(exported.RecordingID,D.BOIInputContracts{1}.RecordingID));
    assert(isequal(exported.SinkEligibleTissuePixels,D.BOIInputContracts{1}.SinkEligibleTissuePixels));
    assert(strcmp(exported.FrameTimingStatus,'uniform_assumed_from_sampling_rate'));
    acceptance=readtable(result.OutputXlsx,'Sheet','StatsAcceptance','TextType','string');
    assert(any(contains(acceptance.Item,'R1-STATIC-TISSUE') & acceptance.Status=="REVIEW"));
    finalCode=createOxygenRegressionCodeManifest(project);
    assert(isequal(code(:,{'RelativePath','SHA256'}),finalCode(:,{'RelativePath','SHA256'})),'Code changed during verification.');
    Report.Status='technical_checks_passed_scientific_eligibility_open';
    Report.OldDataSHA256=oldHash;Report.NewDataSHA256=oxygenFileSHA256(result.DataOutputMat);
    Report.OriginalResultPreserved=true;Report.EventTablesUnchanged=true;Report.BurdenNumericalResultsUnchanged=true;
    Report.CoveredAreaTime_um2_sec=numerator;Report.AnalyzedTissueTime_um2_sec=denominator;
    Report.MeanOccupiedTissueFraction=W.MeanOccupiedTissueFraction;
    Report.EventOnsets=W.EventOnsets;Report.AcquisitionStartOnsetsCounted=W.AcquisitionStartOnsetsCounted;
    Report.InputReviewIssues=height(D.RecordingInputQC);Report.FrameRows=height(F);
    Report.CameraExposureKnown=false;Report.MeasuredFrameTimestampsKnown=false;
    Report.DeclaredFrameValidityKnown=false;Report.ModeledFramesIncluded=height(D.RecordingFrameExposure);
    Report.CsvReplayPassed=true;Report.ElapsedSeconds=toc(started);
    files=dir(fullfile(OutputRoot,'**','*'));Report.OutputBytes=sum([files(~[files.isdir]).bytes]);
    writeJson(fullfile(OutputRoot,'verification-report.json'),Report);
    save(fullfile(OutputRoot,'verification-result.mat'),'result','Report');
catch err
    Report.Status='failed';Report.ErrorID=err.identifier;Report.Error=err.message;Report.ElapsedSeconds=toc(started);
    writeJson(fullfile(OutputRoot,'verification-report.json'),Report);rethrow(err);
end
end
function writeJson(path,value)
fid=fopen(path,'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
