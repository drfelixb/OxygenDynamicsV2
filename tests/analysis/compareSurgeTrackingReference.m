function T=compareSurgeTrackingReference(previousRoot,newRoot,fbPreviousRoot,outputRoot)
% Same-input comparison: require unchanged sink native masks and timing.
assert(~isfolder(outputRoot));mkdir(outputRoot);T=table();
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2411","FB2312-baseline-awake"]
 cases=["control","smooth_pairs","single_clean","single_noise"];
 if session=="FB2312-baseline-awake",cases="control";end
 for name=cases
  old=fullfile(previousRoot,session,name);if session=="FB2312-baseline-awake",old=fullfile(fbPreviousRoot,'Recording');end
  rec=fullfile(newRoot,session,name);
  [oldS,oldU]=readOutputs(old);[newS,newU]=readOutputs(rec);
  assert(isequal(oldS.Table_OxygenSinks_Out.FramePixels,newS.Table_OxygenSinks_Out.FramePixels),'Sink native masks changed.');
  columns={'NativeStartFrame','NativeEndFrame','StartFrame','EndFrame','SinkID','EventID'};
  assert(isequal(oldS.Table_OxygenSinkEvents_Out(:,columns),newS.Table_OxygenSinkEvents_Out(:,columns)),'Sink timing/identity changed.');
  for k=1:2
   a=oldS.Table_OxygenSinkEvents_Out;b=newS.Table_OxygenSinkEvents_Out;kind="sink";amp='NormOxySinkAmp';oldSites=height(oldS.Table_OxygenSinks_Out);newSites=height(newS.Table_OxygenSinks_Out);
   if k==2,a=oldU.Table_OxygenSurgeEvents_Out;b=newU.Table_OxygenSurgeEvents_Out;kind="surge";amp='NormOxySurgeAmp';oldSites=height(oldU.Table_OxygenSurges_Out);newSites=height(newU.Table_OxygenSurges_Out);end
   T=[T;table(session,name,kind,height(a),height(b),oldSites,newSites,sum(isfinite(a.(amp))),sum(isfinite(b.(amp))),sum(a.CloseNativeRun),sum(b.CloseNativeRun), ...
    'VariableNames',{'Session','Case','EventType','PreviousRuns','CurrentRuns','PreviousSites','CurrentSites','PreviousFiniteAmplitudes','CurrentFiniteAmplitudes','PreviousCloseRuns','CurrentCloseRuns'})]; %#ok<AGROW>
  end
 end
end
writetable(T,fullfile(outputRoot,'same-input-comparison.csv'));
f=fopen(fullfile(outputRoot,'comparison-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(struct('SameInputCases',13,'SinkNativeMasksUnchanged',true,'SinkTimingAndIdentitiesUnchanged',true,'SinkAmplitudeMayChangeThroughCrossSignBaselineExclusion',true),'PrettyPrint',true));fclose(f);
end
function [S,U]=readOutputs(root)
f=dir(fullfile(root,'OxygenSinks_Output','*Urefined*.mat'));assert(numel(f)==1);S=load(fullfile(f.folder,f.name));
f=dir(fullfile(root,'OxygenSurges_Output','*.mat'));assert(numel(f)==1);U=load(fullfile(f.folder,f.name));
end
