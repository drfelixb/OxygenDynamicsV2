function Report = runBOIWorkflowWalkthrough(SourceTiff,OutputRoot)
%RUNBOIWORKFLOWWALKTHROUGH Complete ID400 development workflow, never held-out QC.
% Fixed full recording: 512x512x600, 1 Hz, 4.75 um/pixel, archive-derived BOI.
% Run in a NEW folder. Source is copied byte-for-byte; prior outputs are untouched.
% One master, two statistics runs (only diagnostic window changes), no tuning.
setupOxygenDynamicsPath;
assert(~isfolder(OutputRoot) && ~isfile(OutputRoot),'Use a new output folder.');
expected='695f8390be5fe18d06685d718b7e99c73d08715f51ef11ec14c694b32b599a05';
assert(strcmp(oxygenFileSHA256(SourceTiff),expected),'Wrong ID400 reference TIFF.');
mkdir(OutputRoot); clockStart=tic;
Report=struct('Schema','boi-workflow-walkthrough-1','Status','started', ...
    'RecordingID','dandi000891_ID400_awake','Mouse','ID400', ...
    'AssetID','8ba82dc1-aaba-411d-a196-ff8ef0b61fc3', ...
    'SelectedSeries','/acquisition/1hz_mcor.tif','SourceSHA256',expected, ...
    'Role','previously inspected development recording; no independent evaluation', ...
    'Scope','BOI both signs; no IOSI; no biological validation or cohort eligibility decision', ...
    'MatlabVersion',version,'PipelineContract',oxygenPipelineContract(), ...
    'CreatedUTC',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ssXXX')), ...
    'Budget','One full master, two stats exports, no detector tuning; 600-second soft stage gate; 5 GiB output review target; peak memory measured externally', ...
    'ArithmeticRelativeTolerance',1e-10,'ArithmeticAbsoluteTolerance',1e-12, ...
    'OpenIssues',{{'Prior intensity preparation unknown; preserved input is not camera-raw proof', ...
    'Static tissue mask and uniform timing are working assumptions, not validated dynamic exposure', ...
    'Frame-1 detections are counted by current code; physiological onset censoring unresolved', ...
    'Local non-DANDI transfer and independent researcher GUI walkthrough still required'}});
writeJson(fullfile(OutputRoot,'walkthrough-report.json'),Report);
project=fileparts(fileparts(fileparts(mfilename('fullpath'))));
code=createOxygenRegressionCodeManifest(project);
writetable(code,fullfile(OutputRoot,'code-manifest.csv'));
[~,~,dictionarySource]=getBOIMeasurementDictionary();
Report.DictionarySHA256=oxygenFileSHA256(dictionarySource);
try
    rec=fullfile(OutputRoot,'Recording'); mkdir(rec);
    copyfile(SourceTiff,fullfile(rec,'preserved_original.tif'));
    assert(strcmp(oxygenFileSHA256(fullfile(rec,'preserved_original.tif')),expected));
    % Original metadata evidence is retained separately from the executable row.
    local=fullfile(OutputRoot,'local-only'); mkdir(local);
    writeJson(fullfile(local,'source-map.json'),struct('RecordingID',Report.RecordingID, ...
        'SourceTiff',SourceTiff,'StagedTiff',fullfile(rec,'preserved_original.tif'), ...
        'ArchiveNwbSHA256','dbdb847b52a501eaf826b191f0affb2bcfc7078c95cddf035aa785e1aac3b23f', ...
        'Evidence','docs/reference-set-phase1.json and original phase1 conversion report; no fresh archive equivalence check'));
    C=struct('SFs',1,'PiSz',4.75,'Mous','ID400','Cond','Awake_immobile', ...
        'Drug','awake','Gen','WT','Promo','GFAP.PHP','Puff',NaN,'strOW','N');
    V=validateOxygenRecording(rec,1,4.75,false,struct());
    save(fullfile(local,'input-review.mat'),'V','C');
    assert(V.IsValid,'Input review failed; inspect local-only/input-review.mat.');
    assert(V.RawTiffInfo.Frames==600 && V.RawTiffInfo.Width==512 && V.RawTiffInfo.Height==512);
    started=tic; master=runOxygenDynamicsMaster(rec,C); Report.MasterSeconds=toc(started);
    writeJson(fullfile(local,'effective-master-settings.json'),master.AnalysisInfo.AnalysisParams);
    assert(master.AnalysisInfo.NFrames==600 && master.AnalysisInfo.RecordingDurationSec==600);
    assert(toc(clockStart)<600,'Soft runtime gate exceeded after master; stop before further work.');
    Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
    Mouse={'ID400'};Genotype={'WT'};Condition={'Awake_immobile'};DrugID={'awake'};Promoter={'GFAP.PHP'};
    SampleF=1;Pixelsize=4.75;Puff_2use=NaN;RecordingID=string(Report.RecordingID);
    T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition, ...
        DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
    inputCsv=fullfile(local,'input.csv');writetable(T,inputCsv);
    config=struct('inputCsv',inputCsv,'masterFolder',OutputRoot,'outputRoot',fullfile(OutputRoot,'run-A'), ...
        'interactive',false,'imagingMode','BLI','useCuratedSinks',false,'chooseSpecificFolders',false, ...
        'sinkFolderSelection','Recent','surgeFolderSelection','Recent','behaviourFolderSelection','Recent', ...
        'analysisWindowsCsv','','baselinePairsCsv','','windowPairsCsv','');
    started=tic; a=runOxygenDynamicsStats(config);Report.StatsASeconds=toc(started);
    writeJson(fullfile(local,'stats-A-request.json'),config);
    beforeHash=oxygenFileSHA256(a.DataOutputMat);
    D=load(a.DataOutputMat);
    assert(height(D.RecordingRegistry)==1 && D.RecordingRegistry.RecordingID==RecordingID);
    audit=fullfile(OutputRoot,'portable-audit');mkdir(audit);
    writeBOIMeasurementDictionary(audit);
    Report.NumericalAudit=exportNumericalAudit(D,master,rec,audit,Report);
    writetable(D.EventMeasurementQC,fullfile(audit,'measurement-availability.csv'));
    % Diagnostic window is chosen before outcomes, not an experimental baseline.
    WindowID="diagnostic_after_30s";StartSec=30;EndSec=600;
    windows=table(RecordingID,WindowID,StartSec,EndSec);
    windowCsv=fullfile(local,'diagnostic-windows.csv');writetable(windows,windowCsv);
    assert(toc(clockStart)<600,'Soft runtime gate exceeded; stop before second stats run.');
    config.outputRoot=fullfile(OutputRoot,'run-B');config.analysisWindowsCsv=windowCsv;
    started=tic;b=runOxygenDynamicsStats(config);Report.StatsBSeconds=toc(started);
    writeJson(fullfile(local,'stats-B-request.json'),config);
    B=load(b.DataOutputMat);
    assert(strcmp(oxygenFileSHA256(a.DataOutputMat),beforeHash),'Run A changed during rerun.');
    assert(isequaln(D.Table_OxygenSinkEvents_OutCombo,B.Table_OxygenSinkEvents_OutCombo));
    assert(isequaln(D.Table_OxygenSurgeEvents_OutCombo,B.Table_OxygenSurgeEvents_OutCombo));
    assert(B.RecordingWindowMetrics.StartSec==30 && B.RecordingWindowMetrics.EndSec==600);
    changes=[D.RecordingWindowMetrics;B.RecordingWindowMetrics];
    changes.RunID=["A";"B"];writetable(changes,fullfile(audit,'window-comparison.csv'));
    decision=struct('DecisionID','R5-WALK-001','RecordingID',Report.RecordingID, ...
        'Actor','Codex development walkthrough','TimestampUTC',Report.CreatedUTC, ...
        'PreviousValue','A: whole_recording [0,600) seconds','NewValue','B: diagnostic_after_30s [30,600) seconds', ...
        'Reason','Demonstrate a recorded setting change in a separate statistics run without detector tuning', ...
        'Evidence','window-comparison.csv; identical sink and surge event tables; preserved run-A MAT checksum', ...
        'ScientificStatus','Diagnostic only; not approved experimental windows or manual curation');
    writeJson(fullfile(audit,'decision.json'),decision);
    after=createOxygenRegressionCodeManifest(project);
    assert(isequal(code(:,{'RelativePath','SHA256'}),after(:,{'RelativePath','SHA256'})),'MATLAB source changed during run.');
    assert(strcmp(Report.DictionarySHA256,oxygenFileSHA256(dictionarySource)),'Dictionary changed during run.');
    assert(ismember('BOIMeasurementDictionary',sheetnames(a.OutputXlsx)));
    exported=readtable(a.OutputXlsx,'Sheet','BOIMeasurementDictionary','TextType','string');
    definitions=getBOIMeasurementDictionary();assert(isequal(exported,definitions),'Workbook dictionary differs from source.');
    Report.Status='technical_walkthrough_passed_scientific_and_usability_gates_open';
    Report.RunADataSHA256=beforeHash;Report.RunBDataSHA256=oxygenFileSHA256(b.DataOutputMat);
    Report.PriorRunPreserved=true;Report.EventTablesIdentical=true;
    files=dir(fullfile(OutputRoot,'**','*'));Report.OutputBytes=sum([files(~[files.isdir]).bytes]);
    Report.OutputWithinReviewTarget=Report.OutputBytes<=5*1024^3;
    Report.ElapsedSeconds=toc(clockStart);
    writeJson(fullfile(OutputRoot,'walkthrough-report.json'),Report);
    writeJson(fullfile(audit,'walkthrough-report.json'),Report);
catch err
    Report.Status='failed';Report.ElapsedSeconds=toc(clockStart);
    Report.ErrorID=err.identifier;Report.ErrorMessage=err.message;
    writeJson(fullfile(OutputRoot,'walkthrough-report.json'),Report);
    rethrow(err);
end
end

function R=exportNumericalAudit(D,master,rec,out,Report)
% Reconstruct occupancy directly from exported support, independently of the
% production series/window helpers. Reconstruct amplitude from TIFF pixels.
R=struct();registry=D.RecordingRegistry;W=D.RecordingWindowMetrics;
S=D.Table_OxygenSinks_OutCombo;E=D.Table_OxygenSinkEvents_OutCombo;
n=registry.NFrames;fs=registry.SampleF;pixelSize=registry.PixelSize;
mask=false(512,512);mask(master.AnalysisInfo.SinkEligibleTissuePixels)=true;
NativeUnionPixels=zeros(n,1); EligibleUnionPixels=zeros(n,1);
for t=1:n
    unionMask=false(512,512);
    for s=1:height(S)
        pc=S.FramePixels{s};unionMask(pc{t})=true;
    end
    NativeUnionPixels(t)=nnz(unionMask);EligibleUnionPixels(t)=nnz(unionMask&mask);
end
Frame=(1:n)';StartSec=(Frame-1)/fs;EndSec=Frame/fs;
AreaUm2=EligibleUnionPixels*pixelSize^2;ValidTissueUm2=repmat(nnz(mask)*pixelSize^2,n,1);
IntervalSec=EndSec-StartSec;CoveredAreaTimeUm2Sec=AreaUm2.*IntervalSec;
ValidTissueTimeUm2Sec=ValidTissueUm2.*IntervalSec;
F=table(Frame,StartSec,EndSec,IntervalSec,NativeUnionPixels,EligibleUnionPixels,AreaUm2, ...
    ValidTissueUm2,CoveredAreaTimeUm2Sec,ValidTissueTimeUm2Sec);
writetable(F,fullfile(out,'occupancy-ingredients.csv'));
R.CoveredAreaTimeUm2Sec=sum(CoveredAreaTimeUm2Sec);R.ValidTissueTimeUm2Sec=sum(ValidTissueTimeUm2Sec);
R.ReconstructedOccupiedFraction=R.CoveredAreaTimeUm2Sec/R.ValidTissueTimeUm2Sec;
R.ExportedOccupiedFraction=W.MeanOccupiedTissueFraction;
closeEnough(R.ReconstructedOccupiedFraction,R.ExportedOccupiedFraction,Report);
R.DetectedSinkEvents=height(E);R.FiniteSinkAmplitudes=sum(isfinite(E.NormOxySinkAmp));
R.DetectedSurgeEvents=height(D.Table_OxygenSurgeEvents_OutCombo);
R.FiniteSurgeAmplitudes=sum(isfinite(D.Table_OxygenSurgeEvents_OutCombo.NormOxySurgeAmp));
R.AcquisitionStartSinkEvents=sum(E.StartFrame==1);
% Chosen deterministically: first finite sink by saved row order, not magnitude.
i=find(isfinite(E.NormOxySinkAmp),1);assert(~isempty(i),'No finite sink amplitude for this fixed walkthrough.');
e=E(i,:);s=find(S.SiteID==e.SinkID);assert(isscalar(s));
pc=S.FramePixels{s};native=e.NativeStartFrame:e.NativeEndFrame;
footprint=unique(vertcat(pc{native}));
R.EventKey=struct('RecordingID',Report.RecordingID,'Sign','sink','SiteID',e.SinkID,'EventID',e.EventID);
R.EventSelection='First finite sink amplitude in saved row order; example only, all-event availability retained';
R.EventBaselineStatus=char(e.BaselineStatus);R.EventBaselineSamples=e.BaselineValidSamples;
PixelIndex=footprint(:);writetable(table(PixelIndex),fullfile(out,'event-footprint.csv'));
ObservedMeanIntensity=zeros(n,1);tif=Tiff(fullfile(rec,'preserved_original.tif'),'r');closer=onCleanup(@()close(tif));
for t=1:n
    setDirectory(tif,t);plane=read(tif);ObservedMeanIntensity(t)=mean(double(plane(footprint)));
end
clear closer
IsBaseline=Frame>=e.BaselineStartFrame & Frame<=e.BaselineEndFrame;
IsEvent=Frame>=e.StartFrame & Frame<=e.EndFrame;
assert(nnz(IsBaseline)==e.BaselineValidSamples);
B0=mean(ObservedMeanIntensity(IsBaseline));SignedFraction=(ObservedMeanIntensity-B0)/B0;
R.ReconstructedBaseline=B0;R.ExportedBaseline=e.BaselineValue;
R.ReconstructedAmplitudeFraction=-min(SignedFraction(IsEvent));R.ExportedAmplitudeFraction=e.NormOxySinkAmp;
R.ReconstructedSignedIntegralSec=sum(SignedFraction(IsEvent))/fs;R.ExportedSignedIntegralSec=e.SignedTraceAUC_sec;
closeEnough(B0,e.BaselineValue,Report);closeEnough(R.ReconstructedAmplitudeFraction,e.NormOxySinkAmp,Report);
closeEnough(R.ReconstructedSignedIntegralSec,e.SignedTraceAUC_sec,Report);
R.EventStartFrame=e.StartFrame;R.EventEndFrame=e.EndFrame;
R.EventNativeStartFrame=e.NativeStartFrame;R.EventNativeEndFrame=e.NativeEndFrame;
writetable(table(Frame,ObservedMeanIntensity,IsBaseline,IsEvent,SignedFraction),fullfile(out,'event-trace-ingredients.csv'));
% Numeric ingredients can be replayed with no repository helper or source TIFF.
readback=readtable(fullfile(out,'occupancy-ingredients.csv'));
closeEnough(sum(readback.CoveredAreaTimeUm2Sec)/sum(readback.ValidTissueTimeUm2Sec),W.MeanOccupiedTissueFraction,Report);
trace=readtable(fullfile(out,'event-trace-ingredients.csv'));
base=mean(trace.ObservedMeanIntensity(logical(trace.IsBaseline)));
q=(trace.ObservedMeanIntensity(logical(trace.IsEvent))-base)/base;
closeEnough(-min(q),e.NormOxySinkAmp,Report);closeEnough(sum(q)/fs,e.SignedTraceAUC_sec,Report);
R.CsvReplayPassed=true;
% Refined sink timing can precede native detection; never overlay a later
% native mask on an earlier image while labelling it as same-frame evidence.
R.InspectionNativeFrame=writeBOIEventInspection(fullfile(rec,'preserved_original.tif'), ...
    pc,e,StartSec,SignedFraction,fs,fullfile(out,'event-inspection.png'));
end
function closeEnough(actual,expected,R)
assert(isfinite(actual)&&isfinite(expected)&&abs(actual-expected)<=R.ArithmeticAbsoluteTolerance+R.ArithmeticRelativeTolerance*abs(expected), ...
    'OxygenDynamics:WalkthroughArithmetic','Saved ingredients do not reproduce the reported value.');
end
function writeJson(path,value)
fid=fopen(path,'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
