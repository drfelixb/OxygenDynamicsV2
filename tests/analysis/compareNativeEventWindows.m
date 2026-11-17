function Summary=compareNativeEventWindows(referenceRoot,outputFolder)
% Counterfactual only: do not overwrite or replace the saved event measurements.
setupOxygenDynamicsPath;
P=jsondecode(fileread(fullfile(referenceRoot,'reference-set-profile.json')));Summary=table();Details=table();
for i=1:numel(P.Records)
 R=P.Records(i);folder=fullfile(referenceRoot,R.Session,'Recording');
 f=dir(fullfile(folder,'OxygenSinks_Output','OxygenSinks_Urefined*.mat'));S=load(fullfile(f.folder,f.name));
 f=dir(fullfile(folder,'OxygenSurges_Output','OxygenSurges*.mat'));G=load(fullfile(f.folder,f.name));
 I=S.AnalysisInfo;assert(strcmp(oxygenFileSHA256(I.RawFile),I.RawSHA256));[Raw,~,~]=loadtiff(I.RawFile);
 for kind=["sink","surge"]
  if kind=="sink",E=S.Table_OxygenSinkEvents_Out;sites=S.Table_OxygenSinks_Out;other=G.Table_OxygenSurges_Out;col='SinkID';amp='NormOxySinkAmp';window=I.AnalysisParams.quantBaselineWindowSec;
  else,E=G.Table_OxygenSurgeEvents_Out;sites=G.Table_OxygenSurges_Out;other=S.Table_OxygenSinks_Out;col='SurgeID';amp='NormOxySurgeAmp';window=I.AnalysisParams.surgeBaselineWindowSec;end
  Native=E;
  for e=1:height(E)
   c=sites.FramePixels{E.(col)(e)};runs=regionprops(~cellfun(@isempty,c),'PixelIdxList');d=runs(E.EventID(e)).PixelIdxList;
   Native.StartFrame(e)=d(1);Native.EndFrame(e)=d(end);
  end
  A=auditOxygenEventFootprints(sites,Native,other,Raw,round(window*I.AnalysisParams.fs),kind);
  if kind=="surge"
   assert(all(A.MeasurementMatches),'OxygenDynamics:NativeSurgeMismatch','Unchanged surge bounds must reproduce the current measurements.');
  end
  shift=(Native.StartFrame-E.StartFrame)/I.AnalysisParams.fs;
  oldFinite=isfinite(E.(amp));newFinite=isfinite(A.RecomputedAmplitude);oldWrong=oldFinite&E.(amp)<0;newWrong=newFinite&A.RecomputedAmplitude<0;
  changed=sum(E.StartFrame~=Native.StartFrame|E.EndFrame~=Native.EndFrame);
  row=table(string(R.Session),kind,height(E),changed,max([0;shift]),sum(shift>20),sum(oldFinite),sum(newFinite),sum(oldWrong),sum(newWrong),sum(oldWrong&newFinite&~newWrong), ...
    'VariableNames',{'Session','Kind','Events','ChangedTimingEvents','MaxEarlierStartSec','StartsOver20SecEarlier','CurrentFinite','NativeFinite','CurrentWrongDirection','NativeWrongDirection','FlaggedNowNonnegative'});
  Summary=[Summary;row]; %#ok<AGROW>
  rows=table(repmat(string(R.Session),height(E),1),repmat(kind,height(E),1),(1:height(E))',E.StartFrame,E.EndFrame,Native.StartFrame,Native.EndFrame,E.(amp),A.RecomputedAmplitude,string(E.BaselineStatus),A.RecomputedStatus, ...
    'VariableNames',{'Session','Kind','EventRow','CurrentStart','CurrentEnd','NativeStart','NativeEnd','CurrentAmplitude','NativeWindowAmplitude','CurrentStatus','NativeWindowStatus'});
  Details=[Details;rows]; %#ok<AGROW>
 end
end
writetable(Summary,fullfile(outputFolder,'native-window-counterfactual-summary.csv'));
writetable(Details,fullfile(outputFolder,'native-window-counterfactual-events.csv'));disp(Summary);
end
