function Summary=compareLocalTimingReference(oldRoot,newRoot,predictionRoot)
P=jsondecode(fileread(fullfile(newRoot,'reference-set-profile.json')));Summary=table();Events=table();Audits=table();
Pred=readtable(fullfile(predictionRoot,'default-timing-prediction.csv'),'TextType','string');
for i=1:numel(P.Records)
 R=P.Records(i);a=load(fullfile(oldRoot,R.Session,'reference-report.mat'));b=load(fullfile(newRoot,R.Session,'reference-report.mat'));
 assert(strcmp(a.report.Status,'passed')&&strcmp(b.report.Status,'passed'));
 oldFolder=fileparts(a.report.StatsOutput);newFolder=fileparts(b.report.StatsOutput);
 for kind=["Sink","Surge"]
  S=readOne(fullfile(oldFolder,char(kind+"Table4LME.mat")));U=readOne(fullfile(newFolder,char(kind+"Table4LME.mat")));
  assert(isequaln(S.FramePixels,U.FramePixels),'Native masks changed.');
  E=readOne(fullfile(oldFolder,char(kind+"EventTable.mat")));F=readOne(fullfile(newFolder,char(kind+"EventTable.mat")));
  id=char(kind+"ID");amp=char("NormOxy"+kind+"Amp");
  assert(isequal(E(:,{id,'EventID'}),F(:,{id,'EventID'})),'Event identities changed.');
  if kind=="Surge"
   cols={'StartFrame','EndFrame','DurationSec','BaselineValue','BaselineStatus','BaselineValidSamples','EventArea_um2',amp};
   assert(isequaln(E(:,cols),F(:,cols)),'Surge measurements changed.');
  else
   D=Pred(Pred.Session==string(R.Session),:);
   assert(isequal(F.SinkID,D.SiteID)&&isequal(F.EventID,D.EventID));
   assert(isequal(F.StartFrame,D.StartFrame)&&isequal(F.EndFrame,D.EndFrame),'Full rerun differs from fixed-trace prediction.');
   assert(isequal(logical(F.TimingResolved),logical(D.TimingResolved)));
   F.Session=repmat(string(R.Session),height(F),1);Events=[Events;F]; %#ok<AGROW>
   overlap=0;
   for s=reshape(unique(F.SinkID),1,[])
    T=sortrows(F(F.SinkID==s,:),'StartFrame');overlap=overlap+sum(T.EndFrame(1:end-1)>=T.StartFrame(2:end));
   end
   oldFinite=isfinite(E.(amp));newFinite=isfinite(F.(amp));
   row=table(string(R.Session),string(R.Role),height(F),sum(F.TimingResolved),sum(~F.TimingResolved), ...
    sum(oldFinite),sum(newFinite),sum(oldFinite&E.(amp)<0),sum(newFinite&F.(amp)<0),overlap, ...
    max([0;F.NativeStartFrame-F.StartFrame])/R.SampleHz,max([0;F.EndFrame-F.NativeEndFrame])/R.SampleHz, ...
    'VariableNames',{'Session','Role','SinkEvents','TimingResolved','TimingUnresolved','OldFiniteAmplitudes','NewFiniteAmplitudes', ...
    'OldWrongDirection','NewWrongDirection','SameSiteOverlappingPairs','MaxStartExtensionSec','MaxEndExtensionSec'});
   Summary=[Summary;row]; %#ok<AGROW>
  end
 end
 Audit=auditOxygenEventAmplitudeSource(fullfile(newRoot,R.Session,'Recording'));
 assert(all(Audit.MeasurementMatches),'Independent measurement audit failed.');
 Audit.Session=repmat(string(R.Session),height(Audit),1);Audits=[Audits;Audit]; %#ok<AGROW>
end
writetable(Summary,fullfile(newRoot,'timing-comparison-summary.csv'));
writetable(Events,fullfile(newRoot,'sink-event-timing-results.csv'));
writetable(Audits,fullfile(newRoot,'independent-amplitude-audit.csv'));
C=table(true,true,true,true,'VariableNames',{'ExactNativeMasksAllRecordings','ExactEventIdentitiesAllRecordings','ExactSurgeMeasurementsAllRecordings','ExactDefaultTimingPredictionAllRecordings'});
writetable(C,fullfile(newRoot,'comparison-invariants.csv'));disp(Summary);
end
function T=readOne(file)
S=load(file);names=fieldnames(S);T=S.(names{1});
end
