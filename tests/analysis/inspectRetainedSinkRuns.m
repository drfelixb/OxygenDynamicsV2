function QC=inspectRetainedSinkRuns(root,previousRoot,outputRoot)
% Independently check event flags against saved native masks, plus surge identity.
setupOxygenDynamicsPath;
assert(~isfolder(outputRoot),'Use a new inspection output folder.');mkdir(outputRoot);
M=jsondecode(fileread(fullfile(root,'manifest.json')));QC=table();surgeIdentical=true;
for k=1:numel(M.Cases)
 name=string(M.Cases(k).Case);
 f=dir(fullfile(root,name,'OxygenSinks_Output','*Urefined*.mat'));assert(numel(f)==1);
 S=load(fullfile(f.folder,f.name));E=S.Table_OxygenSinkEvents_Out;sites=S.Table_OxygenSinks_Out;
 assert(isequaln(S.AnalysisInfo.PipelineContract,oxygenPipelineContract()));
 for s=1:height(sites)
  runs=regionprops(~cellfun(@isempty,sites.FramePixels{s}),'PixelIdxList');
  for e=reshape(find(E.SinkID==s),1,[])
   j=E.EventID(e);native=runs(j).PixelIdxList;before=NaN;after=NaN;
   assert(E.NativeStartFrame(e)==native(1)&&E.NativeEndFrame(e)==native(end));
   if j>1,before=(native(1)-runs(j-1).PixelIdxList(end)-1)/M.SampleHz;end
   if j<numel(runs),after=(runs(j+1).PixelIdxList(1)-native(end)-1)/M.SampleHz;end
   assert(isequaln(E.PreviousNativeGapSec(e),before)&&isequaln(E.NextNativeGapSec(e),after));
   expected=any([before after]<S.AnalysisInfo.AnalysisParams.sinkCloseNativeGapSec);
   assert(E.CloseNativeRun(e)==expected);
   assert((E.RecurrenceStatus(e)=="close_native_runs_review")==expected);
  end
 end
 for s=1:height(sites)
  A=sortrows(E(E.SinkID==s,:),'NativeStartFrame');
  assert(all(A.EndFrame(1:end-1)<A.StartFrame(2:end)),'Same-site measurement windows overlap.');
 end
 f=dir(fullfile(root,name,'OxygenSurges_Output','*.mat'));assert(numel(f)==1);
 U=load(fullfile(f.folder,f.name));
 f=dir(fullfile(previousRoot,name,'OxygenSurges_Output','*.mat'));assert(numel(f)==1);
 Old=load(fullfile(f.folder,f.name));
 assert(isequaln(U.Table_OxygenSurges_Out.FramePixels,Old.Table_OxygenSurges_Out.FramePixels));
 cols={'SurgeID','EventID','StartFrame','EndFrame'};
 assert(isequaln(U.Table_OxygenSurgeEvents_Out(:,cols),Old.Table_OxygenSurgeEvents_Out(:,cols)));
 R=table(string(S.AnalysisInfo.RecordingID),'VariableNames',{'RecordingID'});
 Q=createOxygenMeasurementQC(R,E,U.Table_OxygenSurgeEvents_Out);
 Q.Case=repmat(name,height(Q),1);QC=[QC;Q]; %#ok<AGROW>
end
writetable(QC,fullfile(outputRoot,'recording-recurrence-qc.csv'));
R=readtable(fullfile(root,'pilot-results.csv'),'TextType','string');
a=R(R.Case=="sink20"&R.DetectionSign=="sink",:);
assert(height(a)==2&&all(a.BestNativeSpacetimeIoU>0)&&all(a.CloseNativeRun==1));
assert(all(a.MeasuredOnsetErrorSec==0&a.MeasuredOffsetErrorSec==0));
Report=struct('AllSavedNativeGapsAndFlagsVerified',true,'SurgeNativeMasksAndEventIdentitiesUnchanged',surgeIdentical, ...
 'BothStrongSinksRetainedAndFlagged',true,'SameSiteMeasurementWindowsNonoverlapping',true,'Cases',numel(M.Cases));
f=fopen(fullfile(outputRoot,'recurrence-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(Report,'PrettyPrint',true));fclose(f);
disp(QC(:,{'Case','EventType','DetectedEvents','CloseNativeRunEvents','FiniteAmplitudeEvents','TimingUnresolvedEvents'}));
end
