function runSurgeModelSelectionValidation(cacheRoot,priorRoot,pulseRoot,referenceRoot,outputRoot)
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Inputs=table();paths=[string(fullfile(priorRoot,'panel-results.csv'));string(fullfile(pulseRoot,'panel-results.csv')); ...
 string(fullfile(priorRoot,'source-controls.csv'));string(fullfile(pulseRoot,'source-controls.csv'));string(fullfile(priorRoot,'backgrounds.csv'))];
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2312-baseline-awake","FB2411"]
 paths(end+1)=fullfile(cacheRoot,session,'growing_clean','audit-inputs.mat');
end
for session=["ID13-20200917","FB2316-baseline"]
 base=fullfile(referenceRoot,session);
 paths=[paths;string(fullfile(base,'reference-report.json'));string(fullfile(base,'Recording','archive_original.tif')); ...
  string(fullfile(base,'Recording','OxygenSurges_Output','OxygenSurgesRecording.mat')); ...
  string(fullfile(base,'Recording','OxygenSinks_Output','OxygenSinks_UrefinedRecording.mat'))]; %#ok<AGROW>
end
for path=paths',Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)),'VariableNames',{'Path','SHA256'})];end %#ok<AGROW>

% Frozen component replay; no component refits in this stage.
A=readCSV(fullfile(priorRoot,'panel-results.csv'));A=A(A.Context=="available",:);
P=readCSV(fullfile(pulseRoot,'panel-results.csv'));C=readCSV(fullfile(priorRoot,'source-controls.csv'));C=C(C.Context=="available",:);
D=readCSV(fullfile(pulseRoot,'source-controls.csv'));keys={'Session','EventRow','AmplitudeFraction','RiseFrames','Shape','DelayFrames'};
assert(isequal(A(:,keys),P(:,keys))&&isequal(C(:,{'Session','EventRow'}),D(:,{'Session','EventRow'})));
ctrl=cell(height(C),1);
for j=1:height(C)
 r=selectSurgeOnsetModel(table2struct(C(j,:)),table2struct(D(j,:)),1);r.Session=C.Session(j);r.EventRow=C.EventRow(j);ctrl{j}=r;
end
Controls=struct2table(vertcat(ctrl{:}));writetable(Controls,fullfile(outputRoot,'cached-selection-controls.csv'));
replay=cell(height(A),1);
for j=1:height(A)
 a=table2struct(A(j,:));p=table2struct(P(j,:));r=selectSurgeOnsetModel(a,p,1);
 for name=string(keys),r.(name)=a.(name);end
 r.Constructible=a.Constructible;r.OnsetErrorSec=NaN;r.WithinFiveSec=false;r.ProposedBaselineImposedFraction=NaN;
 r.BaselineEffectPP=NaN;r.BaselineUnderOnePercent=false;r.SameOnsetAsControl=false;
 if r.Status=="resolved"
  chosen=a;if r.SelectedModel=="pulse",chosen=p;end
  for name=["OnsetErrorSec","WithinFiveSec","ProposedBaselineImposedFraction","BaselineEffectPP","BaselineUnderOnePercent"],r.(name)=chosen.(name);end
  c=Controls(Controls.Session==a.Session&Controls.EventRow==a.EventRow,:);assert(height(c)==1);
  r.SameOnsetAsControl=c.Status=="resolved"&&r.OnsetFrame==c.OnsetFrame;
 end
 replay{j}=r;
end
writetable(struct2table(vertcat(replay{:})),fullfile(outputRoot,'cached-selection-results.csv'));
B=readCSV(fullfile(priorRoot,'backgrounds.csv'));B.Cohort=repmat("development",height(B),1);B.CachePath=strings(height(B),1);
for j=1:height(B),B.CachePath(j)=fullfile(cacheRoot,B.Session(j),'growing_clean','audit-inputs.mat');end
B=B(:,{'Session','EventRow','LocalRow','CachePath','NativeStartFrame','NativeEndFrame','Frames','Cohort'});
Extra=prepareAdditionalOnsetBackgrounds(referenceRoot,fullfile(outputRoot,'additional-backgrounds'));B=[B;Extra];
B=[B;table("flat",1,1,"",120,180,240,"noiseless",'VariableNames',B.Properties.VariableNames)];
writetable(B,fullfile(outputRoot,'backgrounds.csv'));
for path=unique(B.CachePath(B.CachePath~=""))'
 if ~ismember(path,Inputs.Path),Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)),'VariableNames',{'Path','SHA256'})];end %#ok<AGROW>
end
records=cell(height(B)*36*3,1);sourceRecords=cell(height(B)*3,1);nr=0;nc=0;lastCache="";
for b=1:height(B)
 meta=table2struct(B(b,:));n=meta.Frames;native=meta.NativeStartFrame:meta.NativeEndFrame;
 if meta.Cohort=="noiseless",x=100*ones(1,n);blocked=false(1,n);
 else
  if meta.CachePath~=lastCache,Z=load(meta.CachePath);lastCache=meta.CachePath;end
  x=Z.XTrace(meta.LocalRow,:);px=Z.Pixels{meta.LocalRow};blocked=false(1,n);
  for f=max(1,native(1)-60):native(1)-1,blocked(f)=any(ismember(px,Z.AllDetectedPixels{f}));end
 end
 cases=struct([]);Y=x;
 for amp=[.02 .1 .2],for rise=[7 23],for shape=["gamma","exponential","quadratic"],for delay=[10 25]
  k=native(1)-delay;possible=k>20&&all(isfinite(x)&x>0);
  c=struct('AmplitudeFraction',amp,'RiseFrames',rise,'Shape',shape,'DelayFrames',delay,'TruthOnsetFrame',k, ...
   'Constructible',possible,'PulseTruncated',false,'TraceIndex',NaN);
  if possible
   [env,last]=surgeUnseenEnvelope(n,k,rise,shape);Y(end+1,:)=x.*(1+amp*env);c.TraceIndex=size(Y,1);c.PulseTruncated=last>n; %#ok<AGROW>
  end
  cases=[cases;c]; %#ok<AGROW>
 end,end,end,end
 Pulse=estimateSurgePulseOnset(Y,native,1,blocked);Rising=cell(size(Y,1),1);Selected=Rising;
 for j=1:size(Y,1)
  Rising{j}=estimateSurgeLocalOnset(Y(j,:),native,1,blocked,"available");Selected{j}=selectSurgeOnsetModel(Rising{j},Pulse(j),1);
 end
 control={Rising{1},Pulse(1),Selected{1}};names=["rising","pulse","selection"];
 for method=1:3
  nc=nc+1;sourceRecords{nc}=makeRow(control{method},Selected{1},meta,names(method),[],[],[],[],native,control{method});
 end
 for j=1:numel(cases)
  c=cases(j);env=[];y=[];
  if c.Constructible
   idx=c.TraceIndex;fits={Rising{idx},Pulse(idx),Selected{idx}};y=Y(idx,:);env=surgeUnseenEnvelope(n,c.TruthOnsetFrame,c.RiseFrames,c.Shape);
  else
   fits=cell(1,3);
   for method=1:2
    f=control{method};fields=fieldnames(f);
    for field=string(fields)',if isnumeric(f.(field)),f.(field)=NaN;end,end
    f.Status="construction_unavailable";f.BaselineStatus="construction_unavailable";fits{method}=f;
   end
   fits{3}=selectSurgeOnsetModel(fits{1},fits{2},1);
  end
  for method=1:3
   nr=nr+1;records{nr}=makeRow(fits{method},fits{3},meta,names(method),c,x,y,env,native,control{method});
  end
 end
 if b==height(B)||B.Session(b)~=B.Session(b+1),fprintf('COMPLETED UNSEEN PANEL %s\n',meta.Session);end
end
T=struct2table(vertcat(records{:}));writetable(T,fullfile(outputRoot,'unseen-results.csv'));
writetable(struct2table(vertcat(sourceRecords{:})),fullfile(outputRoot,'unseen-controls.csv'));
writetable(Inputs,fullfile(outputRoot,'input-manifest.csv'));
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
R=struct('SourceRecordings',6,'DevelopmentSupports',115,'AdditionalSupports',height(Extra),'NoiselessSupports',1, ...
 'RecipesPerSupport',36,'PlannedUnseenRows',height(T),'ConstructibleCasesIncludingNoiseless',nnz(T.Constructible)/3, ...
 'SourceControlRowsIncludingNoiseless',nc,'CachedSelectorRows',height(A),'CachedSelectorControls',height(C), ...
 'CodeAndInputFreezeVerified',true,'ProductionChanged',false,'NewDetectorOrMasterRuns',0);
f=fopen(fullfile(outputRoot,'completion.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(R,'PrettyPrint',true));fclose(f);
end
function R=makeRow(f,selection,meta,kind,c,x,y,env,native,control)
R=struct('Session',meta.Session,'EventRow',meta.EventRow,'Cohort',meta.Cohort,'Context',kind, ...
 'NativeStartFrame',native(1),'NativeEndFrame',native(end),'Status',string(f.Status), ...
 'OnsetFrame',f.OnsetFrame,'FitStartFrame',f.FitStartFrame,'FitEndFrame',f.FitEndFrame, ...
 'BaselineStartFrame',f.BaselineStartFrame,'BaselineEndFrame',f.BaselineEndFrame,'BaselineMean',f.BaselineMean, ...
 'ProvisionalAmplitude',f.ProvisionalAmplitude,'BaselineStatus',string(f.BaselineStatus), ...
 'RisingScore',selection.RisingScore,'PulseScore',selection.PulseScore,'SelectedScore',selection.SelectedScore, ...
 'SelectedModel',selection.SelectedModel,'SelectorStatus',selection.Status,'ModelGapSec',selection.ModelGapSec, ...
 'CombinedProfileSpanSec',selection.CombinedProfileSpanSec,'PlausibleModels',selection.PlausibleModels, ...
 'AmplitudeFraction',0,'RiseFrames',0,'Shape',"control",'DelayFrames',0,'TruthOnsetFrame',NaN,'Constructible',false, ...
 'PulseTruncated',false,'OnsetErrorSec',NaN,'WithinFiveSec',false,'NativeBaselineImposedFraction',NaN, ...
 'NativeBaselineEffectPP',NaN,'ProposedBaselineImposedFraction',NaN,'BaselineEffectPP',NaN,'PositiveBaselineFrames',NaN, ...
 'BaselineUnderOnePercent',false,'ControlResolved',control.Status=="resolved",'SameOnsetAsControl',false,'ShiftFromControlSec',NaN);
if isempty(c),return;end
for name=["AmplitudeFraction","RiseFrames","Shape","DelayFrames","TruthOnsetFrame","Constructible","PulseTruncated"],R.(name)=c.(name);end
if ~c.Constructible,return;end
pre=native(1)-20:native(1)-1;bx=mean(x(pre));by=mean(y(pre));peak=max(y(native));
R.NativeBaselineImposedFraction=by/bx-1;R.NativeBaselineEffectPP=100*(peak/by-peak/bx);
if R.Status~="resolved",return;end
R.OnsetErrorSec=R.OnsetFrame-c.TruthOnsetFrame;R.WithinFiveSec=abs(R.OnsetErrorSec)<=5;
pre=R.BaselineStartFrame:R.BaselineEndFrame;bx=mean(x(pre));by=mean(y(pre));
R.ProposedBaselineImposedFraction=by/bx-1;R.BaselineEffectPP=100*(peak/by-peak/bx);R.PositiveBaselineFrames=nnz(env(pre)>0);
R.BaselineUnderOnePercent=R.ProposedBaselineImposedFraction<=.01;
if R.ControlResolved,R.ShiftFromControlSec=R.OnsetFrame-control.OnsetFrame;R.SameOnsetAsControl=R.ShiftFromControlSec==0;end
end
function T=readCSV(path)
T=readtable(path,'TextType','string','Delimiter',',','VariableNamingRule','preserve');
end
