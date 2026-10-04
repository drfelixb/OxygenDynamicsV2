function tests=testBOIPortableDurationRates
% Portable frozen independent arithmetic; synthetic saved ingredients only.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testSingleFrame(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(1,C.Cases(1),target);
end
function testNativeVsMeasurement(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(2,C.Cases(2),target);
end
function testOverlappingPixels(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(3,C.Cases(3),target);
end
function testPartialExposure(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(4,C.Cases(4),target);
end
function testUnequalTissue(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(5,C.Cases(5),target);
end
function testZeroEvents(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(6,C.Cases(6),target);
end
function testMissingPixelScale(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(7,C.Cases(7),target);
end
function testInvalidClock(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step2-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(8,C.Cases(8),target);
end
function checkFixture(k,C,target)
[P,SB,UB]=next02FixtureInputs(k);n=C.NFrames;fs=C.SampleHz;px=C.PixelSizeUm;if isempty(px),px=NaN;end
R=table("R","M","fixture","none","none","none",false,n,fs,n/fs,numel(C.SinkSupport)*px^2,px,"loaded","fixture-hash", ...
    'VariableNames',{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim','NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','PixelSize','AnalysisStatus','RawSHA256'});
contract=struct('Schema','boi-recording-input-1','RecordingID','R','RawSHA256','fixture-hash','NFrames',n,'SampleHz',fs, ...
    'PixelSizeUm',px,'FrameSize',[3 4],'SinkEligibleTissuePixels',C.SinkSupport(:),'SurgeEligibleTissuePixels',C.SurgeSupport(:), ...
    'FrameTimingStatus','uniform_assumed_from_sampling_rate','TissueValidityStatus','synthetic_not_biological_evidence');
X=table("R","fixture",C.Window(1),C.Window(2),'VariableNames',{'RecordingID','WindowID','StartSec','EndSec'});
output=struct;
for kind=["sink","surge"]
    bounds=SB;if kind=="surge",bounds=UB;end
    if isempty(bounds),bounds=zeros(0,2);end
    [S,E]=tables(P,bounds,fs,px,n,kind,C);
    beforeS=S;beforeE=E;
    if k==8
        expectError(@()finalizeOxygenEventMeasurements(S,E,P,100*ones(3,4,n),fs,px,0,'R',char(kind),1),'OxygenDynamics:InvalidQuantificationScale');
        if kind=="sink",expectError(@()createOxygenAnalysisWindows(R,S,E,X),'OxygenDynamics:InvalidExposure');
        else,expectError(@()createBOISurgeAnalysisWindows(R,{contract},S,E,X),'OxygenDynamics:InvalidExposure');end
        continue
    end
    exp=C.Expected.(char(kind));
    if k==7
        expectError(@()finalizeOxygenEventMeasurements(S,E,P,100*ones(3,4,n),fs,px,0,'R',char(kind),1),'OxygenDynamics:InvalidQuantificationScale');
    else
        [S,E]=finalizeOxygenEventMeasurements(S,E,P,100*ones(3,4,n),fs,px,0,'R',char(kind),1);
    end
    equal(E.DurationSec,exp.EventDurationSec,'inclusive duration');
    if k==7,assert(all(isnan(E.EventArea_um2)));else,equal(E.EventArea_um2,exp.EventAreaUm2,'native mean event area');end
    equal(E.StartFrame,bounds(:,1),'measurement start retained');equal(E.EndFrame,bounds(:,2),'measurement end retained');
    assert(isequal(E.NativeStartFrame,beforeE.NativeStartFrame)&&isequal(E.NativeEndFrame,beforeE.NativeEndFrame));
    originalR=R;originalS=S;originalE=E;
    if kind=="sink",[W,F]=createOxygenAnalysisWindows(R,S,E,X);series=computeOngoingSinkTimeSeries(S,n,px);
    else
        if k==7
            expectError(@()createBOISurgeAnalysisWindows(R,{contract},S,E,X),'OxygenDynamics:InputContractIdentity');
            [W,F]=createOxygenAnalysisWindows(R,S,E,X,'surge'); % primitive unavailable output; wrapper blocks first
        else,[W,F]=createBOISurgeAnalysisWindows(R,{contract},S,E,X);end
        series=computeOngoingSurgeTimeSeries(S,n,px);
    end
    assert(isequaln(R,originalR)&&isequaln(S,originalS)&&isequaln(E,originalE),'Calculation mutated input values.');
    equal(series.Count,exp.CountSeries,'concurrent event series');
    equal(series.AreaUm,nanValue(exp.OccupiedAreaUm2,n),'union native area series');
    checkWindow(W,F,exp,n);
    if ~isempty(S)&&k~=7
        if kind=="sink",A=createAdditionalOxygenSinkMetrics(S);duration=A.MeanOxySinkEvent_Duration;rate=A.SinkSiteEventRate_per_min;
        else,A=createAdditionalOxygenSurgeMetrics(S);duration=A.MeanOxySurgeEvent_Duration;rate=A.SurgeSiteEventRate_per_min;end
        equal(duration,exp.EventDurationSec,'site duration converted to seconds');
        equal(rate,ones(height(S),1)*60/(n/fs),'site rate per minute, without tissue denominator');
    end
    writetable(E,fullfile(target,char(kind)+"-events.csv"));
    output.(char(kind))=struct('S',S,'E',E,'W',W,'F',F);
end
if k==8,return;end
writeStatsEventTables(fullfile(target,'Events.xlsx'),output.sink.E,output.surge.E);
if k~=6
    for kind=["sink","surge"]
        T=readtable(fullfile(target,'Events.xlsx'),'Sheet',['Oxy' titleKind(kind) 'Events'],'VariableNamingRule','preserve');
        equal(T.DurationSec,output.(char(kind)).E.DurationSec,'event workbook duration');
        equal(T.EventArea_um2,output.(char(kind)).E.EventArea_um2,'event workbook area');
    end
end
RecordingRegistry=R;BOIInputContracts={contract}; %#ok<NASGU>
RecordingWindowMetrics=output.sink.W;WindowFrameIngredients=output.sink.F; %#ok<NASGU>
SurgeRecordingWindowMetrics=output.surge.W;SurgeWindowFrameIngredients=output.surge.F; %#ok<NASGU>
Table_OxygenSinkEvents_OutCombo=output.sink.E;Table_OxygenSurgeEvents_OutCombo=output.surge.E; %#ok<NASGU>
RecordingInputQC=table("R","fixture","Synthetic support only","No biological acceptance",'VariableNames',{'RecordingID','IssueID','Message','Action'}); %#ok<NASGU>
RecordingFrameExposure=table(repmat("R",n,1),(1:n)',nan(n,1),'VariableNames',{'RecordingID','Frame','CameraExposureSec'}); %#ok<NASGU>
p=fullfile(target,'Fixture.mat');save(p,'RecordingRegistry','BOIInputContracts','RecordingWindowMetrics','WindowFrameIngredients', ...
    'SurgeRecordingWindowMetrics','SurgeWindowFrameIngredients','Table_OxygenSinkEvents_OutCombo','Table_OxygenSurgeEvents_OutCombo','RecordingInputQC','RecordingFrameExposure');
if k==7,expectError(@()loadBOIWindowReview(p),'OxygenDynamics:InvalidWindowReview');return;end
Review=loadBOIWindowReview(p);
for kind=["sink","surge"]
    D=buildBOIWindowReviewData(Review,1,char(kind));assert(all(D.Checks.Status=="match"));
    exp=C.Expected.(char(kind));equal(D.Metrics.Replayed,[exp.Occupancy;exp.OnsetRate;exp.ConcurrentDensity],'reader replay');
    dest=fullfile(target,[char(kind) '-window']);exportBOIWindowReview(Review,1,dest,'',char(kind));checkExport(dest,exp);
end
end
function [S,E]=tables(P,bounds,fs,px,n,kind,C)
if isempty(bounds),bounds=zeros(0,2);end
ns=size(P,1);support=C.SinkSupport;if kind=="surge",support=C.SurgeSupport;end
S=table(repmat("R",ns,1),(1:ns)',mat2cell(bounds(:,1),ones(ns,1),1),mat2cell(bounds(:,2)-bounds(:,1)+1,ones(ns,1),1), ...
    repmat({numel(support)*px^2},ns,1),mat2cell(P,ones(ns,1),n),repmat({support(:)},ns,1),repmat({NaN},ns,1), ...
    'VariableNames',{'RecordingID','SiteID','Start','Duration','RecAreaSize','FramePixels','EligibleTissuePixels','NormOxySinkAmp'});
S.SampleF=repmat(fs,ns,1);S.RecDuration=repmat({n/fs},ns,1);S.NumOxySinkEvents=ones(ns,1);S.Size_modulation=repmat({0},ns,1);
S.MeanOxySinkArea_um=zeros(ns,1);S.MeanOxySinkFilledArea_um=zeros(ns,1);
if kind=="surge"
    old={'Start','Duration','RecAreaSize','NormOxySinkAmp','RecDuration','NumOxySinkEvents','Size_modulation','MeanOxySinkArea_um','MeanOxySinkFilledArea_um'};
    new={'Start_Surge','Duration_Surge','RecAreaSize_Surge','NormOxySurgeAmp','RecDuration_Surge','NumOxySurgeEvents','Size_Surge_modulation','MeanOxySurgeArea_um','MeanOxySurgeFilledArea_um'};
    for k=1:numel(old),S.Properties.VariableNames{strcmp(S.Properties.VariableNames,old{k})}=new{k};end
end
id='SinkID';prefix='MeanOxySink';amp='NormOxySinkAmp';if kind=="surge",id='SurgeID';prefix='MeanOxySurge';amp='NormOxySurgeAmp';end
E=table(repmat("R",ns,1),(1:ns)',ones(ns,1),bounds(:,1),bounds(:,2),(bounds(:,1)-1)/fs,bounds(:,2)/fs, ...
    bounds(:,2)-bounds(:,1)+1,(bounds(:,2)-bounds(:,1)+1)/fs,nan(ns,1),nan(ns,1),nan(ns,1), ...
    'VariableNames',{'RecordingID',id,'EventID','StartFrame','EndFrame','StartSec','EndSec','DurationFrames','DurationSec',amp,[amp 'Percent'],'EventArea_um2'});
E.NativeStartFrame=zeros(ns,1);E.NativeEndFrame=zeros(ns,1);
for s=1:ns,f=find(~cellfun(@isempty,P(s,:)));E.NativeStartFrame(s)=f(1);E.NativeEndFrame(s)=f(end);end
for field={'Area_um','FilledArea_um','Diameter_um','Perimeter_um'},E.([prefix field{1}])=zeros(ns,1);end
end
function checkWindow(W,F,exp,n)
equal(W.AreaUm2,nanValue(exp.AreaUm2,1),'selected sign tissue area');
equal(W.EventOnsets,exp.EventOnsets,'onset count');equal(W.ActiveEventSeconds,exp.ActiveEventSeconds,'clipped event time');
equal(W.MeanOccupiedTissueFraction,nanValue(exp.Occupancy,1),'occupied fraction');
equal(W.EventOnsetRate_per_mm2_per_min,nanValue(exp.OnsetRate,1),'onset rate');
equal(W.MeanConcurrentEvents_per_mm2,nanValue(exp.ConcurrentDensity,1),'concurrent density');
equal(W.CoveredAreaTime_um2_sec,nanValue(exp.CoveredAreaTime,1),'covered area-time');
equal(W.AnalyzedTissueTime_um2_sec,nanValue(exp.TissueTime,1),'tissue-time denominator');
if isfield(exp,'AcquisitionStartOnsetsCounted'),equal(W.AcquisitionStartOnsetsCounted,exp.AcquisitionStartOnsetsCounted,'boundary onset policy');end
if isfield(exp,'OngoingAtWindowStart'),equal(W.OngoingAtWindowStart,exp.OngoingAtWindowStart,'ongoing at window start');end
if isfield(exp,'WindowOverlapSec'),dt=exp.WindowOverlapSec(:);equal(F.WindowOverlapSec,dt(dt>0),'fractional frame overlap');end
assert(n>=1);
end
function checkExport(dest,exp)
F=readtable(fullfile(dest,'Frames.csv'));E=readtable(fullfile(dest,'Events.csv'));M=readtable(fullfile(dest,'Metrics.csv'));
den=sum(F.AnalyzedTissueTime_um2_sec);
values=[sum(F.CoveredAreaTime_um2_sec)/den;sum(E.OnsetInWindow)*60e6/den;sum(E.OverlapSec)*1e6/den];
equal(values,[exp.Occupancy;exp.OnsetRate;exp.ConcurrentDensity],'CSV independent replay');equal(M.Saved,values,'metric CSV values');
L=load(fullfile(dest,'SelectedWindowReview.mat'));equal(L.D.Metrics.Saved,values,'selected-window MAT values');
assert(strcmp(L.Receipt.ScientificStatus,'not_established'));
end
function v=nanValue(v,n)
if isempty(v),v=nan(n,1);end
end
function equal(actual,expected,label)
a=double(actual(:));b=double(expected(:));
assert(numel(a)==numel(b),'OxygenDynamics:Next02Mismatch','%s size mismatch (%d vs %d)',label,numel(a),numel(b));
assert(all((isnan(a)&isnan(b))|(isfinite(a)&isfinite(b)&abs(a-b)<=1e-10*max(1,abs(b)))), ...
    'OxygenDynamics:Next02Mismatch','%s differs from frozen independent answer.',label);
end
function expectError(fun,id)
try,fun();catch err,assert(strcmp(err.identifier,id),'Expected %s, got %s: %s',id,err.identifier,err.message);return;end
error('OxygenDynamics:Next02MissingGuard','Expected %s; function returned a value.',id);
end
function text=titleKind(kind)
if kind=="sink",text='Sink';else,text='Surge';end
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
