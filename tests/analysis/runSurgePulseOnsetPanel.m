function runSurgePulseOnsetPanel(cacheRoot,priorRoot,outputRoot)
% Replay the frozen recipes; replace only the available-context signal fit.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Inputs=readtable(fullfile(priorRoot,'input-manifest.csv'),'TextType','string','Delimiter',',','VariableNamingRule','preserve');
for name=["panel-results.csv","source-controls.csv","backgrounds.csv","flat-calibration.csv"]
 path=string(fullfile(priorRoot,name));Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)),'VariableNames',{'Path','SHA256'})]; %#ok<AGROW>
end
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
F=readtable(fullfile(priorRoot,'flat-calibration.csv'),'TextType','string','Delimiter',',','VariableNamingRule','preserve');F=F(F.Context=="available",:);
Y=zeros(height(F),240);for j=1:height(F),Y(j,:)=100*(1+F.AmplitudeFraction(j)*surgeTracePanelEnvelope(240,F.TruthOnsetFrame(j),F.RiseFrames(j),F.Shape(j)));end
Fit=estimateSurgePulseOnset(Y,120:180,1,false(1,240));flat=cell(height(F),1);
for j=1:height(F)
 row=replaceFit(table2struct(F(j,:)),Fit(j));row.PosthocCalibration=false;
 row.OnsetErrorSec=row.OnsetFrame-row.TruthOnsetFrame;row.WithinFiveSec=abs(row.OnsetErrorSec)<=5;flat{j}=row;
end
Flat=struct2table(vertcat(flat{:}));writetable(Flat,fullfile(outputRoot,'flat-calibration.csv'));
assert(all(Flat.Status=="resolved"&Flat.WithinFiveSec),'Noiseless gate failed; archive run not started.');
P=readtable(fullfile(priorRoot,'panel-results.csv'),'TextType','string','Delimiter',',','VariableNamingRule','preserve');P=P(P.Context=="available",:);
B=readtable(fullfile(priorRoot,'backgrounds.csv'),'TextType','string','Delimiter',',','VariableNamingRule','preserve');
C0=readtable(fullfile(priorRoot,'source-controls.csv'),'TextType','string','Delimiter',',','VariableNamingRule','preserve');C0=C0(C0.Context=="available",:);
rows=cell(height(P),1);controls=cell(height(B),1);nr=0;nc=0;
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2312-baseline-awake","FB2411"]
 C=load(fullfile(cacheRoot,session,'growing_clean','audit-inputs.mat'));
 selected=B(B.Session==session,:);
 for e=1:height(selected)
  q=selected(e,:);i=q.LocalRow;x=C.XTrace(i,:);n=numel(x);native=q.NativeStartFrame:q.NativeEndFrame;
  px=C.Pixels{i};blocked=false(1,n);
  for f=max(1,native(1)-60):native(1)-1,blocked(f)=any(ismember(px,C.AllDetectedPixels{f}));end
  T=P(P.Session==session&P.EventRow==q.EventRow,:);assert(height(T)==48);
  possible=T.TruthOnsetFrame>20&all(isfinite(x)&x>0);assert(isequal(possible,logical(T.Constructible)));
  indices=find(possible);Y=zeros(numel(indices)+1,n);Y(1,:)=x;
  for j=1:numel(indices)
   z=indices(j);Y(j+1,:)=x.*(1+T.AmplitudeFraction(z)*surgeTracePanelEnvelope(n,T.TruthOnsetFrame(z),T.RiseFrames(z),T.Shape(z)));
  end
  Fit=estimateSurgePulseOnset(Y,native,1,blocked);control=Fit(1);
  c=C0(C0.Session==session&C0.EventRow==q.EventRow,:);assert(height(c)==1);
  nc=nc+1;controls{nc}=replaceFit(table2struct(c),control);
  cursor=1;
  for j=1:height(T)
   if possible(j)
    cursor=cursor+1;R=Fit(cursor);y=Y(cursor,:);
   else
    R=control;fields=fieldnames(R);
    for k=1:numel(fields),if isnumeric(R.(fields{k})),R.(fields{k})=NaN;end,end
    R.Status="construction_unavailable";R.BaselineStatus="construction_unavailable";R.TemplateShape="unassessed";
   end
   row=replaceFit(table2struct(T(j,:)),R);
   row.ControlResolved=control.Status=="resolved";row.ControlOnsetFrame=control.OnsetFrame;
   row.OnsetErrorSec=NaN;row.WithinFiveSec=false;row.SameOnsetAsControl=false;row.ShiftFromControlSec=NaN;
   row.ProposedBaselineImposedFraction=NaN;row.BaselineEffectPP=NaN;row.PositiveBaselineFrames=NaN;row.BaselineUnderOnePercent=false;
   if R.Status=="resolved"
    row.OnsetErrorSec=R.OnsetFrame-row.TruthOnsetFrame;row.WithinFiveSec=abs(row.OnsetErrorSec)<=5;
    if row.ControlResolved,row.ShiftFromControlSec=R.OnsetFrame-control.OnsetFrame;row.SameOnsetAsControl=row.ShiftFromControlSec==0;end
    pre=R.BaselineStartFrame:R.BaselineEndFrame;bx=mean(x(pre));by=mean(y(pre));
    row.ProposedBaselineImposedFraction=by/bx-1;row.BaselineEffectPP=100*(max(y(native))/by-max(y(native))/bx);
    env=surgeTracePanelEnvelope(n,row.TruthOnsetFrame,row.RiseFrames,row.Shape);
    row.PositiveBaselineFrames=nnz(env(pre)>0);row.BaselineUnderOnePercent=row.ProposedBaselineImposedFraction<=.01;
   end
   nr=nr+1;rows{nr}=row;
  end
 end
 fprintf('COMPLETED PULSE PANEL %s\n',session);
end
Results=struct2table(vertcat(rows{:}));Controls=struct2table(vertcat(controls{:}));
assert(nr==5520&&nc==115&&nnz(Results.Constructible)==5136);
writetable(Results,fullfile(outputRoot,'panel-results.csv'));writetable(Controls,fullfile(outputRoot,'source-controls.csv'));
writetable(B,fullfile(outputRoot,'backgrounds.csv'));writetable(Inputs,fullfile(outputRoot,'input-manifest.csv'));
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
R=struct('SourceRecordings',4,'FixedSupports',115,'PlannedConstructedRows',5520,'ConstructedFits',5136, ...
 'SourceFits',115,'NoiselessFits',48,'CodeAndInputFreezeVerified',true,'ProductionChanged',false,'NewDetectionOrMasterRuns',0);
f=fopen(fullfile(outputRoot,'completion.json'),'w');assert(f>=0);cleanup=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(R,'PrettyPrint',true));
end
function row=replaceFit(row,R)
old={'BaselineSlopePerSecOverFitMedian','PostSlopePerSecOverFitMedian'};
for j=1:numel(old),if isfield(row,old{j}),row=rmfield(row,old{j});end,end
fields=fieldnames(R);for j=1:numel(fields),row.(fields{j})=R.(fields{j});end
row.Context="pulse";
end
