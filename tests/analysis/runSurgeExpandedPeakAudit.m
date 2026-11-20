function runSurgeExpandedPeakAudit(selectorRoot,eligibilityRoot,outputRoot)
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
paths=[string(fullfile(selectorRoot,'backgrounds.csv'));string(fullfile(eligibilityRoot,'amplitude-eligibility-results.csv'))];
Inputs=table(paths,strings(size(paths)),'VariableNames',{'Path','SHA256'});
for j=1:height(Inputs),Inputs.SHA256(j)=string(oxygenFileSHA256(paths(j)));end
B=readCSV(paths(1));T=readCSV(paths(2));
for path=unique(B.CachePath(~ismissing(B.CachePath)&strlength(B.CachePath)>0))'
 Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)),'VariableNames',{'Path','SHA256'})]; %#ok<AGROW>
end
out=cell(height(T),1);lastCache="";
for b=1:height(B)
 meta=B(b,:);n=meta.Frames;native=meta.NativeStartFrame:meta.NativeEndFrame;blocked=false(1,n);
 if meta.Session=="flat",x=100*ones(1,n);
 else
  if meta.CachePath~=lastCache,Z=load(meta.CachePath);lastCache=meta.CachePath;end
  x=Z.XTrace(meta.LocalRow,:);px=Z.Pixels{meta.LocalRow};
  for f=max(1,native(1)-60):native(1)-1,blocked(f)=any(ismember(px,Z.AllDetectedPixels{f}));end
 end
 for j=find(T.Session==meta.Session&T.EventRow==meta.EventRow)'
  row=table2struct(T(j,:));env=zeros(size(x));
  if row.Constructible,env=surgeUnseenEnvelope(n,row.TruthOnsetFrame,row.RiseFrames,row.Shape);end
  y=x.*(1+row.AmplitudeFraction*env);
  r=assessSurgeExpandedPeak(y,native,1,blocked,row.OnsetFrame,row.Status);
  if row.Status=="construction_unavailable",r.AmplitudeStatus="construction_unavailable";r.ExpandedStatus="construction_unavailable";end
  if r.ArithmeticValid,assert(abs(r.SignedRawAmplitude-row.SignedRawAmplitude)<1e-10);end
  for name=string(fieldnames(r))',row.(name)=r.(name);end
  row.NativeEnvelopeFraction=NaN;row.ExpandedEnvelopeFraction=NaN;
  row.ExpandedOracleSource=NaN;row.ExpandedOracleImposed=NaN;
  row.ExpandedOracleReferenceEffect=NaN;row.ExpandedDecompositionResidual=NaN;
  row.OracleSourceOnlyWindowGain=NaN;
  if row.Constructible&&r.ArithmeticValid
   row.NativeEnvelopeFraction=env(r.NativePeakFrame)/max(env);
   if r.ExpandedArithmeticValid
    p=r.ExpandedPeakFrame;pre=r.ReferenceStartFrame:r.ReferenceEndFrame;bx=mean(x(pre));by=r.ReferenceMean;
    row.ExpandedEnvelopeFraction=env(p)/max(env);
    row.ExpandedOracleSource=x(p)/bx-1;row.ExpandedOracleImposed=(y(p)-x(p))/bx;
    row.ExpandedOracleReferenceEffect=y(p)/by-y(p)/bx;
    row.ExpandedDecompositionResidual=r.ExpandedSignedAmplitude-row.ExpandedOracleSource-row.ExpandedOracleImposed-row.ExpandedOracleReferenceEffect;
    row.OracleSourceOnlyWindowGain=(max(x(row.OnsetFrame:native(end)))-max(x(native)))/bx;
    assert(abs(row.ExpandedDecompositionResidual)<1e-10);
   end
  end
  out{j}=row;
 end
end
assert(all(~cellfun(@isempty,out)));A=struct2table(vertcat(out{:}));writetable(A,fullfile(outputRoot,'expanded-peak-results.csv'));
writeChallenges(outputRoot);
writetable(Inputs,fullfile(outputRoot,'input-manifest.csv'));
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
R=struct('Rows',height(A),'SourceRecordings',6,'RecordedSupports',308,'NoiselessSupports',1, ...
 'ConstructibleRecipes',nnz(A.Constructible),'SourceControls',nnz(A.Shape=="control"),'FixedOnsetChallenges',8, ...
 'CodeAndInputFreezeVerified',true,'ProductionChanged',false,'OnsetRefits',0);
f=fopen(fullfile(outputRoot,'completion.json'),'w');fprintf(f,'%s\n',jsonencode(R,'PrettyPrint',true));fclose(f);
end
function writeChallenges(outputRoot)
n=160;target=zeros(1,n);target(75:85)=((75:85)-74)/11;target(86:110)=(111-(86:110))/26;
names=["clean","detected_surge","detected_sink","undetected_surge","undetected_sink", ...
 "reference_neighbor","before_reference_neighbor","nonfinite_added"];
out=cell(8,1);traces=cell(8,1);
for j=1:8
 source=100*ones(1,n);blocked=false(1,n);
 if ismember(j,[2 4]),source(91:93)=150;end
 if ismember(j,[3 5]),source(91:93)=70;end
 if ismember(j,[2 3]),blocked(91:93)=true;end
 if j==6,source(65:67)=150;blocked(65:67)=true;end
 if j==7,source(45:47)=150;blocked(45:47)=true;end
 y=source+20*target;if j==8,y(80)=NaN;end
 r=assessSurgeExpandedPeak(y,100:120,1,blocked,75,"resolved");r.Challenge=names(j);
 r.TargetFractionAtExpandedPeak=NaN;
 if r.ExpandedArithmeticValid,r.TargetFractionAtExpandedPeak=target(r.ExpandedPeakFrame);end
 out{j}=r;
 traces{j}=table(repmat(names(j),n,1),(1:n)',source',y',blocked',target', ...
  'VariableNames',{'Challenge','Frame','Source','Observed','Blocked','TargetEnvelope'});
end
writetable(struct2table(vertcat(out{:})),fullfile(outputRoot,'neighbor-challenges.csv'));
writetable(vertcat(traces{:}),fullfile(outputRoot,'neighbor-challenge-traces.csv'));
end
function T=readCSV(path)
T=readtable(path,'Delimiter',',','TextType','string','VariableNamingRule','preserve');
end
