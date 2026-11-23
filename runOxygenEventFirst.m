function Result = runOxygenEventFirst(Recording,DetectorConfig)
%RUNOXYGENEVENTFIRST Standalone opt-in BLI prototype. See docs/EVENT_FIRST.md.
started=tic;
if nargin<2, DetectorConfig=struct(); end
C=oxygenEventFirstConfig(DetectorConfig);
if strlength(C.AnalysisRunID)==0, C.AnalysisRunID=string(char(java.util.UUID.randomUUID)); end
[R,Raw,Valid,dt,PixelArea]=validateOxygenEventRecording(Recording);
D=Raw;
if string(C.DetectionSource)=="denoised"
    assert(isfield(R,'DenoisedIntensity')&&isequal(size(R.DenoisedIntensity),size(Raw))&&isfield(R,'DenoisedProvenance'), ...
        'eventFirst:Source','Denoised source requires matching YXT stack and provenance.');
    D=double(R.DenoisedIntensity);
    assert(all(isfinite(D(Valid))),'eventFirst:Source','Denoised data are invalid within quantitative support; prescribe a common ValidMask.');
    if isfield(R,'DarkOffset'), D=D-R.DarkOffset; end
end
if C.Verbose, fprintf('eventFirst: validated %d x %d x %d; scoring\n',size(Raw)); end
[Score,ScoreQC,Diagnostics]=scoreOxygenEventFirst(D,Valid,R,C);
if C.Verbose, fprintf('eventFirst: scores ready at %.2f s; components\n',toc(started)); end
Masks=extractOxygenEventComponents(Score,Valid,R,C);
if C.Verbose, fprintf('eventFirst: %d components at %.2f s; quantifying\n',numel(Masks),toc(started)); end
[Events,Traces,FrameMasks]=quantifyOxygenEventFirst(Masks,Raw,Valid,R,C);
if C.Verbose, fprintf('eventFirst: quantified at %.2f s; sites\n',toc(started)); end
[Events,Sites]=assignOxygenEventSites(Events,Masks,R,C);
if C.Verbose, fprintf('eventFirst: sites ready at %.2f s; windows\n',toc(started)); end
[Windows,Contrasts,TimeSeries]=measureOxygenEventWindows(Events,Masks,Raw,Valid,R,C);
area=TimeSeries.ValidAreaPixels; status="completed";
Sites.RecurrencePerValidMinute=60*Sites.EventCount/(nnz(area>0)*dt);
if ~any(area>0), status="no observable exposure";
elseif isempty(Masks), status="completed: zero events"; end
qc=struct('RecordingID',R.RecordingID,'MouseID',R.MouseID,'AnalysisRunID',C.AnalysisRunID, ...
    'Detector',"eventFirst",'DetectorVersion',C.Version,'Condition',R.Condition,'Genotype',R.Genotype,'Promoter',R.Promoter, ...
    'SourceIdentity',R.SourceIdentity,'SignalProvenance',R.SignalProvenance,'SourceScaling',R.SourceScaling, ...
    'NFrames',R.NFrames,'fs',R.fs,'TimeOriginSec',R.TimeOriginSec,'PixelSizeYUm',R.PixelSizeUm(1),'PixelSizeXUm',R.PixelSizeUm(2), ...
    'ValidSeconds',nnz(area>0)*dt,'ValidPixelSeconds',sum(area)*dt,'ValidAreaUm2Seconds',sum(area)*dt*PixelArea, ...
    'MeanValidAreaPixels',mean(area),'ExcludedFrames',nnz(area==0),'ExclusionReasons',R.ExclusionReasons, ...
    'NonfiniteVoxelCount',R.NonfiniteVoxelCount,'SaturatedVoxelCount',R.SaturatedVoxelCount,'TissueMaskSource',R.TissueMaskSource, ...
    'DarkOffsetStatus',R.DarkOffsetStatus,'MotionProvenance',R.MotionProvenance, ...
    'BaselineUnidentified',ScoreQC.BaselineUnidentified,'Status',status,'EventCount',height(Events));
Result=struct('SchemaVersion',"oxygen-event-first/1",'RecordingQC',struct2table(qc),'Events',Events, ...
    'EventFrameMasks',FrameMasks,'Sites',Sites,'RecordingWindowMetrics',Windows,'BaselineContrasts',Contrasts, ...
    'EventTraces',{Traces},'TimeSeries',TimeSeries,'TissueMask',R.TissueMask,'ValidMask',Valid, ...
    'FrameSize',[size(Raw,1) size(Raw,2)],'ScoreQC',ScoreQC,'Diagnostics',{Diagnostics});
metadata=rmfield(R,intersect(fieldnames(R),{'Intensity','DenoisedIntensity','ValidMask','TissueMask'}));
root=fileparts(mfilename('fullpath'));
[~,commit]=system(sprintf('git -C "%s" rev-parse HEAD',root));
[~,diff]=system(sprintf('git -C "%s" status --porcelain',root));
Result.RunManifest=struct('Detector',"eventFirst",'DetectorVersion',C.Version,'SchemaVersion',Result.SchemaVersion, ...
    'AnalysisRunID',C.AnalysisRunID,'Configuration',C,'RecordingMetadata',metadata,'CodeCommit',strtrim(string(commit)), ...
    'WorkingTreeStatus',string(diff),'PinnedLegacyCommit',"8cf3f036b41e16b2c472bcee7e5cfaeab41433eb", ...
    'Randomness',"none in detector; run ID is UUID unless supplied",'Dependencies',{ver}, ...
    'CreatedUTC',string(datetime('now','TimeZone','UTC')),'RuntimeSec',toc(started), ...
    'ContrastStatus',"not specified",'ValidationStatus',"exploratory; biological superiority unvalidated");
Result.RunManifest.QuantitativeInputSHA256=oxygenEventFirstArraySHA256(Raw);
Result.RunManifest.ValidMaskSHA256=oxygenEventFirstArraySHA256(Valid);
Result.RunManifest.SourceCodeSHA256=oxygenEventFirstCodeIdentity(root);
if ~isempty(Contrasts), Result.RunManifest.ContrastStatus="explicit windows"; end
end
