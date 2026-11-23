function runEventFirstExamples(OutputRoot,PublicNWB)
% Reproducible synthetic benchmark and optional verified local public prefix.
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); addpath(root); setupOxygenDynamicsPath; addpath(fullfile(root,'tests','eventFirst'));
if nargin<1, OutputRoot=fullfile(root,'examples','eventFirst','results'); end
if ~isfolder(OutputRoot), mkdir(OutputRoot); end
[R,C]=makeEventFirstFixture; C.AnalysisRunID="synthetic-example";
X=runOxygenEventFirst(R,C); saveOxygenEventFirst(X,OutputRoot); renderOxygenEventFirstReview(R,X,fullfile(OutputRoot,'synthetic-review.png'));
% Known injection support defines synthetic truth, independently of detection.
A=struct(); A.Provenance="synthetic injection schedule seed17; no manual biological labels";
A.Events=table(["truth-sink";"truth-surge"],["sink";"surge"],[15;35],[18;38],[.2;.3],[54;54],[3;3], ...
    'VariableNames',{'EventID','EventType','IntervalStartSec','IntervalEndSec','PeakRelativeBLI','MeanAreaUm2','ObservedDurationSec'});
ids=strings(12,1); frames=zeros(12,1); pixels=cell(12,1);
for k=1:2
    plane=false(12,14);
    if k==1, plane(4:6,5:7)=true; active=31:36; else, plane(8:10,9:11)=true; active=71:76; end
    for j=1:6, q=(k-1)*6+j; ids(q)=A.Events.EventID(k); frames(q)=active(j); pixels{q}=uint32(find(plane)); end
end
A.EventFrameMasks=table(ids,frames,pixels,'VariableNames',{'EventID','Frame','PixelIdxList'});
Null=R; Null.RecordingID="synthetic-null"; Null.MouseID="null-mouse";
rng(18); Null.Intensity=100+.4*randn(size(R.Intensity)); NA=A; NA.Events=A.Events([],:); NA.EventFrameMasks=A.EventFrameMasks([],:);
M=struct('Recording',{R,Null},'Partition',{'development','heldout'},'Annotation',{A,NA});
configs={};
for window=[20 30 45]
    for seed=[4 5 6]
        configs{end+1}=oxygenEventFirstConfig(struct('SpatialScalesUm',0,'BaselineWindowSec',window,'SeedSD',seed,'MinDurationSec',1)); %#ok<AGROW>
    end
end
B=runOxygenDetectionBenchmark(M,configs); writetable(B.Metrics,fullfile(OutputRoot,'synthetic-benchmark.csv'));
save(fullfile(OutputRoot,'synthetic-benchmark.mat'),'B','M','-v7.3');
if nargin>=2 && strlength(string(PublicNWB))>0
    metadata=struct('RecordingID',"DANDI-000891-ID400-awake-prefix120",'MouseID',"ID400", ...
        'PixelSizeUm',[4.75 4.75],'ValidMask',true(512), ...
        'Condition',"awake immobile (series metadata)",'Promoter',"GFAP.PHP", ...
        'MotionProvenance',"series name 1hz_mcor.tif suggests prior correction; transforms unavailable", ...
        'ExclusionReasons',"registration support unverified; estimated tissue exported for review");
    layout=struct('MATLABAxisOrder',"TXY",'FrameCount',120, ...
        'ExpectedSHA256',"dbdb847b52a501eaf826b191f0affb2bcfc7078c95cddf035aa785e1aac3b23f");
    P=loadOxygenEventFirstNWB(PublicNWB,'/acquisition/1hz_mcor.tif',metadata,layout);
    PC=oxygenEventFirstConfig(struct('AnalysisRunID',"public-verified120"));
    tic; PX=runOxygenEventFirst(P,PC); fprintf('PUBLIC detection %.2f sec, %d events\n',toc,height(PX.Events));
    memory=whos('P','PX'); disp(struct2table(memory));
    saveOxygenEventFirst(PX,OutputRoot); renderOxygenEventFirstReview(P,PX,fullfile(OutputRoot,'public-review.png'));
end
end
