function R=runBOIHPWorkflow(SourceTiff,MetadataFile,OutputRoot)
%RUNBOIHPWORKFLOW Fixed R1-HP-CLOCK-002 descriptive development transfer.
% Exactly one full source master, two diagnostic stats exports, no tuning.
setupOxygenDynamicsPath;
assert(~isfolder(OutputRoot),'Preserve prior runs; use a new output folder.');
expected='3d903105aa450da0348d6aa4ddb4b23145099534d5817a826461bb5ff2132e73';
assert(strcmp(oxygenFileSHA256(SourceTiff),expected),'Wrong fixed HP source.');
mkdir(OutputRoot);started=tic;
R=struct('DecisionID','R1-HP-CLOCK-002','Status','started','RecordingID','HP_ECS_CSV2_identity_pending', ...
    'Role','development_transfer_not_biological_evaluation','SourceSHA256',expected, ...
    'SourceTiff',SourceTiff,'MetadataSHA256',oxygenFileSHA256(MetadataFile), ...
    'MatlabVersion',version,'CreatedUTC',char(datetime('now','TimeZone','UTC')), ...
    'ConfirmedSampleHz',1,'ProvisionalPixelSizeUm',2.35,'BiologicalEligibility','not_established');
writeJson(fullfile(OutputRoot,'workflow-report.json'),R);
project=fileparts(fileparts(fileparts(mfilename('fullpath'))));
code=createOxygenRegressionCodeManifest(project);writetable(code,fullfile(OutputRoot,'code-manifest.csv'));
try
    rec=fullfile(OutputRoot,'Recording');mkdir(rec);
    source=fullfile(rec,'preserved_original.tif');copyfile(SourceTiff,source);
    copyfile(MetadataFile,fullfile(rec,'BOIInputMetadata.json'));
    Review=reviewBOIRecordingInput(rec,1,2.35);save(fullfile(OutputRoot,'InputReview.mat'),'Review');
    writetable(Review.QC,fullfile(OutputRoot,'InputQC.csv'));
    assert(Review.Files.IsValid&&Review.Acquisition.InputCompatible);
    assert(Review.Files.RawTiffInfo.Frames==1200);
    assert(strcmp(Review.Acquisition.FrameTimingStatus,'uniform_confirmed_from_acquisition_evidence'));
    assert(strcmp(Review.Acquisition.SourceClockStatus,'known_unreliable'));
    assert(all(isnan(Review.Acquisition.DeclaredFrameTimesSec)));
    C=struct('SFs',1,'PiSz',2.35,'Mous',R.RecordingID,'Cond','Unknown','Drug','Unknown', ...
        'Gen','Unknown','Promo','Unknown','Puff',NaN,'strOW','N');
    t=tic;master=runOxygenDynamicsMaster(rec,C);R.MasterSeconds=toc(t);
    assert(master.AnalysisInfo.NFrames==1200&&master.AnalysisInfo.RecordingDurationSec==1200);
    writeJson(fullfile(OutputRoot,'effective-master-settings.json'),master.AnalysisInfo.AnalysisParams);
    assert(toc(started)<900,'Soft time budget reached after master.');
    Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
    Mouse={R.RecordingID};Genotype={'Unknown'};Condition={'Unknown'};DrugID={'Unknown'};Promoter={'Unknown'};
    SampleF=1;Pixelsize=2.35;Puff_2use=NaN;RecordingID=string(R.RecordingID);
    T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
    inputCsv=fullfile(OutputRoot,'development-input.csv');writetable(T,inputCsv);
    config=struct('inputCsv',inputCsv,'masterFolder',OutputRoot,'outputRoot',fullfile(OutputRoot,'run-A'), ...
        'interactive',false,'imagingMode','BLI','useCuratedSinks',false,'chooseSpecificFolders',false, ...
        'sinkFolderSelection','Recent','surgeFolderSelection','Recent','behaviourFolderSelection','Recent', ...
        'analysisWindowsCsv','','baselinePairsCsv','','windowPairsCsv','');
    t=tic;a=runOxygenDynamicsStats(config);R.StatsASeconds=toc(t);
    R.RunAData=a.DataOutputMat;R.RunADataSHA256=oxygenFileSHA256(a.DataOutputMat);D=load(a.DataOutputMat);
    F=D.RecordingFrameExposure;
    assert(isequal(F.ModeledStartSec,(0:1199)')&&all(F.FrameIntervalSec==1));
    assert(isequal(F.SourceClockTimeSec,Review.Acquisition.SourceClockTimesSec));
    assert(all(isnan(F.DeclaredFrameTimeSec))&&all(isnan(F.DeclaredFrameValid))&&all(F.CameraExposureSec==.96));
    assert(any(D.RecordingInputQC.IssueID=="SOURCE-IDENTITY")&&any(D.RecordingInputQC.IssueID=="SOURCE-CALIBRATION"));
    assert(~any(D.RecordingInputQC.IssueID=="R1-TIMING"|D.RecordingInputQC.IssueID=="R1-TIMING-UNKNOWN"));
    acceptance=readtable(a.OutputXlsx,'Sheet','StatsAcceptance','TextType','string');
    assert(any(contains(acceptance.Item,"SOURCE-IDENTITY")&acceptance.Status=="REVIEW"));
    dictionary=readtable(a.OutputXlsx,'Sheet','BOIMeasurementDictionary','TextType','string');
    assert(isequal(dictionary,getBOIMeasurementDictionary()));
    ingredients=readtable(fullfile(fileparts(a.DataOutputMat),'WindowFrameIngredients.csv'));
    R.ReplayedOccupancy=sum(ingredients.CoveredAreaTime_um2_sec)/sum(ingredients.AnalyzedTissueTime_um2_sec);
    closeEnough(R.ReplayedOccupancy,D.RecordingWindowMetrics.MeanOccupiedTissueFraction);
    assert(toc(started)<900,'Soft time budget reached before audit.');
    t=tic;[Audit,Traces]=auditOxygenEventAmplitudeSource(rec,'outputFolder',fullfile(OutputRoot,'event-audit'));
    R.AuditSeconds=toc(t);R.AuditedEvents=height(Audit);R.MeasurementMismatches=sum(~Audit.MeasurementMatches);
    assert(R.MeasurementMismatches==0,'Independent source amplitude audit disagrees.');
    R.DetectedSinks=height(D.Table_OxygenSinkEvents_OutCombo);R.DetectedSurges=height(D.Table_OxygenSurgeEvents_OutCombo);
    R.FiniteSinkAmplitudes=sum(isfinite(D.Table_OxygenSinkEvents_OutCombo.NormOxySinkAmp));
    R.FiniteSurgeAmplitudes=sum(isfinite(D.Table_OxygenSurgeEvents_OutCombo.NormOxySurgeAmp));
    i=find(Audit.EventType=="sink"&isfinite(Audit.RecomputedAmplitude),1);
    R.ExampleStatus='no_finite_sink_amplitude';
    if ~isempty(i)
        e=D.Table_OxygenSinkEvents_OutCombo(Audit.EventRow(i),:);trace=Traces{i};
        Frame=(1:1200)';ObservedMeanIntensity=trace.Raw(:);
        IsBaseline=ismember(Frame,trace.CleanBaselineFrames);IsEvent=Frame>=e.StartFrame&Frame<=e.EndFrame;
        baseline=mean(ObservedMeanIntensity(IsBaseline));SignedFraction=(ObservedMeanIntensity-baseline)/baseline;
        csv=fullfile(OutputRoot,'event-trace-ingredients.csv');
        writetable(table(Frame,ObservedMeanIntensity,IsBaseline,IsEvent,SignedFraction),csv);
        back=readtable(csv);b=mean(back.ObservedMeanIntensity(logical(back.IsBaseline)));
        q=(back.ObservedMeanIntensity(logical(back.IsEvent))-b)/b;
        closeEnough(b,e.BaselineValue);closeEnough(-min(q),e.NormOxySinkAmp);closeEnough(sum(q),e.SignedTraceAUC_sec);
        PixelIndex=trace.Footprint(:);writetable(table(PixelIndex),fullfile(OutputRoot,'event-footprint.csv'));
        R.ExampleNativeFrame=writeBOIEventInspection(source,D.Table_OxygenSinks_OutCombo.FramePixels{e.SinkID}, ...
            e,(0:1199)',SignedFraction,1,fullfile(OutputRoot,'event-inspection.png'));
        R.ExampleStatus='first_finite_sink_replayed';R.ExampleSiteID=e.SinkID;R.ExampleEventID=e.EventID;
        R.ExampleBaseline=b;R.ExampleAmplitude=-min(q);R.ExampleSignedIntegralSec=sum(q);
    end
    assert(toc(started)<900,'Soft time budget reached before diagnostic export.');
    WindowID="diagnostic_after_30s";StartSec=30;EndSec=1200;windows=table(RecordingID,WindowID,StartSec,EndSec);
    windowCsv=fullfile(OutputRoot,'diagnostic-windows.csv');writetable(windows,windowCsv);
    config.outputRoot=fullfile(OutputRoot,'run-B');config.analysisWindowsCsv=windowCsv;
    t=tic;b=runOxygenDynamicsStats(config);R.StatsBSeconds=toc(t);B=load(b.DataOutputMat);
    assert(isequaln(D.Table_OxygenSinkEvents_OutCombo,B.Table_OxygenSinkEvents_OutCombo));
    assert(isequaln(D.Table_OxygenSurgeEvents_OutCombo,B.Table_OxygenSurgeEvents_OutCombo));
    assert(strcmp(oxygenFileSHA256(a.DataOutputMat),R.RunADataSHA256),'Original stats run changed.');
    assert(B.RecordingWindowMetrics.StartSec==30&&B.RecordingWindowMetrics.EndSec==1200);
    comparison=[D.RecordingWindowMetrics;B.RecordingWindowMetrics];comparison.RunID=["A";"B"];
    writetable(comparison,fullfile(OutputRoot,'window-comparison.csv'));
    after=createOxygenRegressionCodeManifest(project);
    assert(isequal(code(:,{'RelativePath','SHA256'}),after(:,{'RelativePath','SHA256'})),'Source changed during run.');
    assert(strcmp(oxygenFileSHA256(SourceTiff),expected)&&strcmp(oxygenFileSHA256(source),expected));
    R.RunBData=b.DataOutputMat;R.RunBDataSHA256=oxygenFileSHA256(b.DataOutputMat);
    R.EventTablesIdentical=true;R.PriorStatsPreserved=true;R.ElapsedSeconds=toc(started);
    files=dir(fullfile(OutputRoot,'**','*'));R.OutputBytes=sum([files(~[files.isdir]).bytes]);
    R.OutputWithinReviewTarget=R.OutputBytes<=5*1024^3;
    R.Status='technical_workflow_passed_scientific_eligibility_open';
catch err
    R.Status='failed';R.ErrorID=err.identifier;R.ErrorMessage=err.message;R.ElapsedSeconds=toc(started);
    writeJson(fullfile(OutputRoot,'workflow-report.json'),R);rethrow(err);
end
writeJson(fullfile(OutputRoot,'workflow-report.json'),R);
end
function closeEnough(actual,expected)
assert(isfinite(actual)&&isfinite(expected)&&abs(actual-expected)<=1e-12+1e-10*abs(expected), ...
    'OxygenDynamics:WalkthroughArithmetic','Exported ingredients do not reproduce the value.');
end
function writeJson(path,value)
fid=fopen(path,'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
