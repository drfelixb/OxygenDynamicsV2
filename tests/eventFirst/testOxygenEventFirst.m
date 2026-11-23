function Report = testOxygenEventFirst()
% Offline deterministic numerical/structural acceptance checks.
setupOxygenDynamicsPath(); addpath(fileparts(mfilename('fullpath')));
tests={@zeroCases,@inputValidation,@signedNoisyEvents,@exactQuantification,@laterEventInvariant, ...
    @topologyAndRecovery,@boundaryAndMissing,@windowConservation,@physicalSampling,@globalStep, ...
    @denoisedQuantitativeSource,@roundTrip,@siteChaining,@matchingAndLeakage,@batchFailures,@nwbAxes,@singlePixelAndSingleton,@defaultLegacy};
rows=struct('Test',{},'Passed',{},'Detail',{});
for k=1:numel(tests)
    name=string(func2str(tests{k}));
    try, tests{k}(); passed=true; detail="ok";
    catch ME, passed=false; detail=string(getReport(ME,'extended','hyperlinks','off')); end
    fprintf('%s: %d\n',name,passed);
    rows(end+1)=struct('Test',name,'Passed',passed,'Detail',detail); %#ok<AGROW>
end
Report=struct2table(rows); disp(Report(:,1:2));
if any(~Report.Passed), disp(Report.Detail(~Report.Passed)); end
end
function zeroCases()
[R,C]=makeEventFirstFixture;
for value=[0 100 NaN]
    R.Intensity(:)=value; X=runOxygenEventFirst(R,C); assert(isempty(X.Events));
    if isnan(value), assert(all(isnan(X.RecordingWindowMetrics.OccupiedTissueFraction)));
    elseif value>0, assert(all(X.RecordingWindowMetrics.OccupiedTissueFraction==0)); end
end
R.Intensity(:)=100; R.ValidMask(:)=false; X=runOxygenEventFirst(R,C); assert(X.RecordingQC.ValidSeconds==0);
end
function inputValidation()
[R,C]=makeEventFirstFixture;
Q=R; Q.AxisOrder="TXY"; mustFail(@()runOxygenEventFirst(Q,C),'eventFirst:Axes');
Q=R; Q.FrameTimestampsSec=(0:R.NFrames-1)/R.fs; Q.FrameTimestampsSec(10)=4.6;
mustFail(@()runOxygenEventFirst(Q,C),'eventFirst:Timing');
Q=R; Q.PixelSizeUm=[NaN NaN]; X=runOxygenEventFirst(Q,C); assert(all(isnan(X.Events.MeanAreaUm2)));
assert(all(isnan(X.RecordingWindowMetrics.OnsetsPerMm2Min)));
Q=R; Q.NFrames=3; mustFail(@()runOxygenEventFirst(Q,C),'eventFirst:Input');
end
function signedNoisyEvents()
[R,C]=makeEventFirstFixture; X=runOxygenEventFirst(R,C);
assert(height(X.Events)==2); assert(all(abs(X.Events.PeakRelativeBLI-[.2;.3])<.04));
assert(all(X.Events.ObservedDurationSec==3)); assert(X.Events.MeanSignedRelativeBLI(1)<0 && X.Events.MeanSignedRelativeBLI(2)>0);
assert(all(X.RecordingWindowMetrics.OccupiedTissueFraction>=0 & X.RecordingWindowMetrics.OccupiedTissueFraction<=1));
end
function exactQuantification()
[R,C]=makeEventFirstFixture; R.Intensity(:)=100; R.Intensity(4:6,5:7,31:36)=80; R.Intensity(8:10,9:11,71:76)=130;
S=zeros(size(R.Intensity)); S(4:6,5:7,31:36)=-8; S(8:10,9:11,71:76)=8;
[R,raw,V]=validateOxygenEventRecording(R); M=extractOxygenEventComponents(S,V,R,C); [E,~,~]=quantifyOxygenEventFirst(M,raw,V,R,C);
assert(max(abs(E.PeakRelativeBLI-[.2;.3]))<1e-12); assert(max(abs(E.SignedRelativeBLIAUC_sec-[-.6;.9]))<1e-12);
% A zero baseline is missing, not epsilon and not a post-event fallback.
raw(:,:,1:30)=0; [E,~,~]=quantifyOxygenEventFirst(M,raw,V,R,C); assert(isnan(E.PeakRelativeBLI(1))&&E.BaselineStatus(1)=="nonpositive baseline");
end
function laterEventInvariant()
[R,C]=makeEventFirstFixture; A=runOxygenEventFirst(R,C);
R.Intensity(3:7,4:8,101:106)=R.Intensity(3:7,4:8,101:106)-20; B=runOxygenEventFirst(R,C);
assert(A.Events.PeakRelativeBLI(1)==B.Events.PeakRelativeBLI(1));
assert(isequal(A.EventTraces{1}.Footprint,B.EventTraces{1}.Footprint));
Q=R; Q.RecordingID="other-recording"; Q.Condition="changed"; D=runOxygenEventFirst(Q,C);
assert(~any(ismember(B.Events.EventID,D.Events.EventID))); assert(B.Events.PeakRelativeBLI(1)==D.Events.PeakRelativeBLI(1));
end
function topologyAndRecovery()
[R,C]=makeEventFirstFixture; S=zeros(size(R.Intensity)); V=true(size(S));
S(3,3,20:30)=-7; S(3,7,20:30)=-7; S(3,4:6,25)=-3;
M=extractOxygenEventComponents(S,V,R,C); assert(numel(M)==1&&M.Ambiguous);
S(:)=0; S(3,3,20:24)=-7; S(3,3,26:30)=-7; S(3,4,20:24)=7;
M=extractOxygenEventComponents(S,V,R,C); assert(numel(M)==3);
for k=1:numel(M), assert(~ismember(25,M(k).Frames)); end
end
function boundaryAndMissing()
[R,C]=makeEventFirstFixture; S=zeros(size(R.Intensity)); V=true(size(S));
S(3,3,1:4)=-7; S(4,4,119:120)=7;
M=extractOxygenEventComponents(S,V,R,C); assert(numel(M)==2&&all([M.BoundaryTruncated]));
[R,raw]=validateOxygenEventRecording(R); [E,~,~]=quantifyOxygenEventFirst(M,raw,V,R,C);
assert(isnan(E.PeakRelativeBLI(1))); assert(E.IntervalEndSec(2)==R.NFrames/R.fs);
S(:)=0; S(3,3,20:30)=-7; V(:,:,25)=false;
M=extractOxygenEventComponents(S,V,R,C); assert(numel(M)==2&&all([M.AdjacentUnknown]));
assert(sum(arrayfun(@(m)numel(m.Frames),M))==10);
end
function windowConservation()
[R,C]=makeEventFirstFixture; R.Windows=table(["a";"b"],[0;16.25],[16.25;60],'VariableNames',{'WindowID','StartSec','EndSec'});
R.Contrasts=table("a","b",'VariableNames',{'BaselineWindowID','ComparisonWindowID'});
X=runOxygenEventFirst(R,C); W=X.RecordingWindowMetrics;
assert(abs(sum(W.ActiveEventSeconds)-sum(X.Events.ObservedDurationSec))<1e-12);
assert(abs(sum(W.OccupiedPixelSeconds)-sum(X.TimeSeries.SinkOccupiedPixels+X.TimeSeries.SurgeOccupiedPixels)/R.fs)<1e-12);
R.ValidMask=repmat(R.ValidMask,1,1,R.NFrames); R.ValidMask(:,:,1:10)=false;
X=runOxygenEventFirst(R,C); assert(X.RecordingQC.ValidSeconds==55);
end
function physicalSampling()
[R,C]=makeEventFirstFixture; R.Intensity(:)=100;
S=zeros(size(R.Intensity)); S(4:6,5:7,31:36)=-8; V=true(size(S));
[R,raw]=validateOxygenEventRecording(R); raw(4:6,5:7,31:36)=80;
M=extractOxygenEventComponents(S,V,R,C); [A,~,~]=quantifyOxygenEventFirst(M,raw,V,R,C);
Q=R; Q.Intensity=repelem(raw,2,2,2); Q.PixelSizeUm=R.PixelSizeUm/2; Q.fs=R.fs*2; Q.NFrames=R.NFrames*2;
SS=repelem(S,2,2,2); VV=true(size(SS)); M=extractOxygenEventComponents(SS,VV,Q,C); [B,~,~]=quantifyOxygenEventFirst(M,Q.Intensity,VV,Q,C);
assert(abs(A.MeanAreaUm2-B.MeanAreaUm2)<1e-12&&abs(A.ObservedDurationSec-B.ObservedDurationSec)<1e-12);
assert(abs(A.PeakRelativeBLI-B.PeakRelativeBLI)<1e-12);
end
function globalStep()
[R,C]=makeEventFirstFixture; R.Intensity(:)=100; R.Intensity(:,:,61:end)=80;
R.Windows=table(["control";"step"],[0;30],[30;60],'VariableNames',{'WindowID','StartSec','EndSec'});
R.Contrasts=table("control","step",'VariableNames',{'BaselineWindowID','ComparisonWindowID'});
X=runOxygenEventFirst(R,C); q=X.BaselineContrasts.Metric=="GlobalPreservedBLIMean";
assert(all(abs(X.BaselineContrasts.PercentChange(q)+20)<1e-10)); assert(X.TimeSeries.GlobalPreservedBLI(61)==80);
end
function denoisedQuantitativeSource()
[R,C]=makeEventFirstFixture; A=runOxygenEventFirst(R,C); R.DenoisedIntensity=R.Intensity*3;
R.DenoisedProvenance="test scale transform for source isolation"; C.DetectionSource="denoised"; B=runOxygenEventFirst(R,C);
assert(max(abs(A.Events.PeakRelativeBLI-B.Events.PeakRelativeBLI))<1e-10);
assert(all(B.Events.QuantificationSource=="PreservedInputIntensity"));
end
function roundTrip()
[R,C]=makeEventFirstFixture; C.AnalysisRunID="roundtrip"; A=runOxygenEventFirst(R,C); B=runOxygenEventFirst(R,C);
assert(isequaln(A.Events,B.Events)&&isequaln(A.EventFrameMasks,B.EventFrameMasks));
folder=tempname; mkdir(folder); clean=onCleanup(@()rmdir(folder,'s'));
f=saveOxygenEventFirst(A,folder); x=load(fullfile(f,'EventFirstResult.mat'));
assert(isequaln(x.Result.EventFrameMasks,A.EventFrameMasks));
end
function siteChaining()
[R,C]=makeEventFirstFixture; X=runOxygenEventFirst(R,C); E=X.Events([1 1 1],:); C.SiteMinIoU=.3;
M=struct('Footprint',{uint32(1:4),uint32(3:6),uint32(5:8)});
[E,S]=assignOxygenEventSites(E,M,R,C); assert(height(S)==2 && E.SiteID(1)~=E.SiteID(3));
end
function matchingAndLeakage()
[R,C]=makeEventFirstFixture; X=runOxygenEventFirst(R,C); m=matchOxygenEventMasks(X,X,.5); assert(m.Precision==1&&m.Recall==1);
Z=X; Z.Events=X.Events([],:); Z.EventFrameMasks=X.EventFrameMasks([],:);
m=matchOxygenEventMasks(Z,X,.5); assert(m.FalsePositives==height(X.Events)&&isnan(m.Recall));
m=matchOxygenEventMasks(Z,Z,.5); assert(m.FalsePositives==0&&isnan(m.Precision));
M=struct('Recording',{R,R},'Partition',{'development','heldout'});
mustFail(@()runOxygenDetectionBenchmark(M,{C}),'eventFirst:Leakage');
M(2).Recording.MouseID="another-mouse"; M(2).Recording.RecordingID="another-recording";
B=runOxygenDetectionBenchmark(M(:),{C}); assert(height(B.Metrics)==6);
end
function batchFailures()
[R,C]=makeEventFirstFixture; Q=R; Q.RecordingID="bad"; Q.NFrames=1;
folder=tempname; clean=onCleanup(@()rmdir(folder,'s'));
B=runOxygenEventFirstBatch({R,Q},C,folder); assert(height(B.RecordingQC)==2&&B.RecordingQC.Status(2)=="failed");
end
function nwbAxes()
folder=tempname; mkdir(folder); clean=onCleanup(@()rmdir(folder,'s')); file=fullfile(folder,'fixture.nwb');
raw=reshape(uint16(1:84),[4 7 3]); source=permute(raw,[3 2 1]);
h5create(file,'/series/data',size(source),'Datatype','uint16'); h5write(file,'/series/data',source);
h5create(file,'/series/starting_time',1); h5write(file,'/series/starting_time',12); h5writeatt(file,'/series/starting_time','rate',2);
metadata=struct('RecordingID',"axes",'MouseID',"axes",'PixelSizeUm',[2 3],'ValidMask',true(4,7));
layout=struct('MATLABAxisOrder',"TXY",'ExpectedSHA256',oxygenEventFirstSHA256(file));
R=loadOxygenEventFirstNWB(file,'/series',metadata,layout); assert(isequal(R.Intensity,raw)&&R.fs==2&&R.FrameTimestampsSec(1)==12);
layout.ExpectedSHA256="incorrect"; mustFail(@()loadOxygenEventFirstNWB(file,'/series',metadata,layout),'eventFirst:Checksum');
end
function singlePixelAndSingleton()
[R,C]=makeEventFirstFixture; C.MinDurationSec=0; S=zeros(size(R.Intensity)); V=true(size(S)); S(3,4,21)=-8;
M=extractOxygenEventComponents(S,V,R,C); assert(numel(M)==1&&numel(M.Footprint)==1);
[R,raw]=validateOxygenEventRecording(R); [E,~,F]=quantifyOxygenEventFirst(M,raw,V,R,C); [~,Sites]=assignOxygenEventSites(E,M,R,C);
assert(height(E)==1&&height(F)==1&&iscell(F.PixelIdxList)&&height(Sites)==1);
end
function defaultLegacy()
C=OxygenDynamics_Config; assert(strcmp(C.OxygenWrapper.DetectorMode,'legacy'));
mustFail(@()runOxygenDynamicsStats(struct('DetectorMode','eventFirst')),'eventFirst:StatsSchema');
end
function mustFail(f,id)
try, f(); catch ME, assert(strcmp(ME.identifier,id),'Unexpected error: %s',ME.message); return; end
error('Expected failure %s',id);
end
