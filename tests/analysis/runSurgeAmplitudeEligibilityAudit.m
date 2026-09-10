function runSurgeAmplitudeEligibilityAudit(priorRoot,outputRoot)
% Replay frozen selector decisions; no detector or onset fit is run.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
paths=[string(fullfile(priorRoot,'backgrounds.csv'));string(fullfile(priorRoot,'unseen-results.csv')); ...
 string(fullfile(priorRoot,'unseen-controls.csv'));string(fullfile(priorRoot,'resolved-measurement-review.csv'))];
Inputs=table(paths,strings(size(paths)),'VariableNames',{'Path','SHA256'});
for j=1:height(Inputs),Inputs.SHA256(j)=string(oxygenFileSHA256(paths(j)));end
B=readCSV(fullfile(priorRoot,'backgrounds.csv'));
for path=unique(B.CachePath(~ismissing(B.CachePath)&strlength(B.CachePath)>0))'
 Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)),'VariableNames',{'Path','SHA256'})]; %#ok<AGROW>
end
T=readCSV(fullfile(priorRoot,'unseen-results.csv'));T=T(T.Context=="selection",:);
C=readCSV(fullfile(priorRoot,'unseen-controls.csv'));C=C(C.Context=="selection",:);
T=[T;C];out=cell(height(T),1);lastCache="";
for b=1:height(B)
 meta=B(b,:);n=meta.Frames;native=meta.NativeStartFrame:meta.NativeEndFrame;
 blocked=false(1,n);
 if meta.Session=="flat",x=100*ones(1,n);
 else
  if meta.CachePath~=lastCache,Z=load(meta.CachePath);lastCache=meta.CachePath;end
  x=Z.XTrace(meta.LocalRow,:);px=Z.Pixels{meta.LocalRow};
  for f=max(1,native(1)-60):native(1)-1,blocked(f)=any(ismember(px,Z.AllDetectedPixels{f}));end
 end
 for j=find(T.Session==meta.Session&T.EventRow==meta.EventRow)'
  row=table2struct(T(j,:));y=x;env=zeros(size(x));constructed=row.Constructible;
  if constructed
   env=surgeUnseenEnvelope(n,row.TruthOnsetFrame,row.RiseFrames,row.Shape);
   y=x.*(1+row.AmplitudeFraction*env);
  end
  r=assessSurgeAmplitudeEligibility(y,native,1,blocked,row.OnsetFrame,row.Status);
  if row.Status=="construction_unavailable",r.AmplitudeStatus="construction_unavailable";end
  names=fieldnames(r);for name=string(names)',row.(name)=r.(name);end
  row.OracleSourceAtObservedPeak=NaN;row.OracleImposedAtObservedPeak=NaN;
  row.OracleBaselineEffect=NaN;row.OracleBaselineImposedFraction=NaN;
  row.OracleReferencePositiveFrames=NaN;row.DecompositionResidual=NaN;
  if r.ArithmeticValid
   assert(abs(r.SignedRawAmplitude-row.ProvisionalAmplitude)<1e-10);
   if constructed
    pre=r.ReferenceStartFrame:r.ReferenceEndFrame;bx=mean(x(pre));by=mean(y(pre));p=r.NativePeakFrame;
    row.OracleSourceAtObservedPeak=x(p)/bx-1;
    row.OracleImposedAtObservedPeak=(y(p)-x(p))/bx;
    row.OracleBaselineEffect=y(p)/by-y(p)/bx;
    row.OracleBaselineImposedFraction=by/bx-1;
    row.OracleReferencePositiveFrames=nnz(env(pre)>0);
    row.DecompositionResidual=r.SignedRawAmplitude-(row.OracleSourceAtObservedPeak+row.OracleImposedAtObservedPeak+row.OracleBaselineEffect);
    assert(abs(row.DecompositionResidual)<1e-10);
   end
  end
  out{j}=row;
 end
end
assert(all(~cellfun(@isempty,out)));A=struct2table(vertcat(out{:}));
writetable(A,fullfile(outputRoot,'amplitude-eligibility-results.csv'));
writetable(Inputs,fullfile(outputRoot,'input-manifest.csv'));
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
R=struct('Rows',height(A),'SourceRecordings',6,'RecordedSupports',308,'NoiselessSupports',1, ...
 'ConstructibleRecipes',nnz(A.Constructible),'SourceControls',nnz(A.Shape=="control"), ...
 'CodeAndInputFreezeVerified',true,'ProductionChanged',false,'OnsetRefits',0);
f=fopen(fullfile(outputRoot,'completion.json'),'w');fprintf(f,'%s\n',jsonencode(R,'PrettyPrint',true));fclose(f);
end
function T=readCSV(path)
T=readtable(path,'Delimiter',',','TextType','string','VariableNamingRule','preserve');
end
