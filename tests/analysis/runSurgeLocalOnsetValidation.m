function runSurgeLocalOnsetValidation(cacheRoot,outputRoot)
% Frozen raw traces and fixed full native supports; no detector/master runs.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Results=table();Cases=table();Inputs=table();
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2312-baseline-awake","FB2411"]
 for name=["growing_clean","shrinking_clean"]
  folder=fullfile(cacheRoot,session,name);matfile=fullfile(folder,'audit-inputs.mat');
  csvfile=fullfile(folder,'support-results.csv');jsonfile=fullfile(folder,'provenance.json');
  for path=string({matfile,csvfile,jsonfile})
   Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)),'VariableNames',{'Path','SHA256'})]; %#ok<AGROW>
  end
  C=load(matfile);T=readtable(csvfile,'TextType','string');M=jsondecode(fileread(jsonfile));
  assert(M.BaselineFrames==20&&M.Frames==size(C.XTrace,2));
  T=T(T.Support=="full_event",:);local=table();
  for e=1:height(T)
   q=T(e,:);idx=q.LocalRow;native=q.StartFrame:q.EndFrame;
   px=C.Pixels{idx};blocked=false(1,M.Frames);
   for f=1:M.Frames,blocked(f)=any(ismember(px,C.AllDetectedPixels{f}));end
   oldpre=max(1,native(1)-20):native(1)-1;
   assert(isequal(oldpre(~blocked(oldpre))',C.CleanFrames{idx}(:)));
   for kind=["constructed","source"]
    trace=C.YTrace(idx,:);if kind=="source",trace=C.XTrace(idx,:);end
    R=estimateSurgeLocalOnset(trace,native,1,blocked);
    R.Session=session;R.Case=name;R.EventRow=q.EventRow;R.TraceKind=kind;
    R.LocalRow=idx;R.IsPreselectedMatch=q.IsPreselectedMatch;
    R.NativeStartFrame=native(1);R.NativeEndFrame=native(end);
    R.StoredAmplitude=q.StoredFullEventAmplitude;R.StoredBaselineStatus=q.StrictBaselineStatus;
    R.OnsetOffsetFromImposedStart=NaN;R.NativeBaselineImposedFraction=NaN;
    R.ProposedBaselineImposedFraction=NaN;R.ProposedBaselinePositiveFrames=NaN;
    R.CounterfactualPeakFraction=NaN;R.BaselineEffectPercentagePoints=NaN;
    if kind=="constructed"
     if numel(oldpre)==20
      bx=mean(C.XTrace(idx,oldpre));if bx>0,R.NativeBaselineImposedFraction=mean(trace(oldpre))/bx-1;end
     end
     if R.Status=="resolved"
      pre=R.BaselineStartFrame:R.BaselineEndFrame;bx=mean(C.XTrace(idx,pre));
      R.ProposedBaselinePositiveFrames=nnz(C.PositiveTrace(idx,pre)>0);
      if bx>0
       R.ProposedBaselineImposedFraction=mean(trace(pre))/bx-1;
       R.CounterfactualPeakFraction=max(trace(native))/bx-1;
       R.BaselineEffectPercentagePoints=100*(R.ProvisionalAmplitude-R.CounterfactualPeakFraction);
      end
      if q.IsPreselectedMatch,R.OnsetOffsetFromImposedStart=R.OnsetFrame-M.Windows(1);end
     end
    end
    local=[local;struct2table(R)]; %#ok<AGROW>
   end
  end
  Results=[Results;local]; %#ok<AGROW>
  Cases=[Cases;table(session,name,height(T),M.PreselectedEventRow, ...
   nnz(local.TraceKind=="constructed"&local.Status=="resolved"), ...
   nnz(local.TraceKind=="source"&local.Status=="resolved"), ...
   'VariableNames',{'Session','Case','Events','PreselectedEventRow','ConstructedResolved','SourceResolved'})]; %#ok<AGROW>
  fprintf('COMPLETED LOCAL ONSET %s %s\n',session,name);
 end
end
writetable(Results,fullfile(outputRoot,'onset-results.csv'));writetable(Cases,fullfile(outputRoot,'case-summary.csv'));
writetable(Inputs,fullfile(outputRoot,'input-manifest.csv'));
selected=Results(Results.IsPreselectedMatch&Results.TraceKind=="constructed",:);
writetable(selected,fullfile(outputRoot,'preselected-results.csv'));
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
writeJSON(fullfile(outputRoot,'completion.json'),struct('FrozenMovies',8,'SourceRecordings',4, ...
 'RetainedEvents',height(Results)/2,'TraceEvaluations',height(Results),'PreselectedMatches',height(selected), ...
 'CodeAndInputFreezeVerified',true,'ProductionChanged',false,'NewDetectionOrMasterRuns',0));
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);clean=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
