function Summary=auditSurgeFullMovieMeasurement(rec,source,Masks,Fractions,manifest,out)
% Measure every new native surge before any truth correspondence is selected.
mkdir(out);[X,~,~]=loadtiff(source);[Y,~,~]=loadtiff(fullfile(rec,'challenge_original.tif'));
assert(isequal(size(X),size(Y)));[h,w,n]=size(Y);X=reshape(X,[],n);Y=reshape(Y,[],n);
g=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));s=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));assert(isscalar(g)&&isscalar(s));
G=load(fullfile(g.folder,g.name));S=load(fullfile(s.folder,s.name));assert(isequaln(G.AnalysisInfo,S.AnalysisInfo));
assert(strcmp(G.AnalysisInfo.RawSHA256,oxygenFileSHA256(fullfile(rec,'challenge_original.tif'))));
assert(isequaln(G.AnalysisInfo.PipelineContract,oxygenPipelineContract()));
Meta=table('Size',[0 9],'VariableTypes',{'double','string','double','double','double','double','double','double','string'}, ...
 'VariableNames',{'EventIndex','EventType','EventRow','SiteRow','NativeStartFrame','NativeEndFrame','NativeVolume','ProductionAmplitude','ProductionBaselineStatus'});
NativePixels=cell(0,n);Pixels=cell(0,1);AllDetectedPixels=cell(1,n);
for kind=["surge","sink"]
 if kind=="surge",E=G.Table_OxygenSurgeEvents_Out;sites=G.Table_OxygenSurges_Out;id='SurgeID';amp='NormOxySurgeAmp';
 else,E=S.Table_OxygenSinkEvents_Out;sites=S.Table_OxygenSinks_Out;id='SinkID';amp='NormOxySinkAmp';end
 for e=1:height(E)
  pc=sites.FramePixels{E.(id)(e)};runs=regionprops(~cellfun(@isempty,pc),'PixelIdxList');native=runs(E.EventID(e)).PixelIdxList;
  assert(E.NativeStartFrame(e)==native(1)&&E.NativeEndFrame(e)==native(end));
  k=height(Meta)+1;NativePixels(k,native)=reshape(pc(native),1,[]);Pixels{k,1}=unique(vertcat(pc{native}));
  volume=sum(cellfun(@numel,pc(native)));
  Meta=[Meta;table(k,kind,e,E.(id)(e),native(1),native(end),volume,E.(amp)(e),string(E.BaselineStatus(e)), ...
   'VariableNames',{'EventIndex','EventType','EventRow','SiteRow','NativeStartFrame','NativeEndFrame','NativeVolume','ProductionAmplitude','ProductionBaselineStatus'})]; %#ok<AGROW>
 end
end
for f=1:n,AllDetectedPixels{f}=unique(vertcat(NativePixels{:,f}));end
TruthPixels=cell(6,1);for q=1:6,TruthPixels{q}=find(Masks(:,:,q));end
AppliedFractions=Fractions;if manifest.Case=="control",AppliedFractions(:)=0;end
XTrace=zeros(height(Meta),n);YTrace=XTrace;ComponentTrace=zeros(height(Meta),n,6);
for e=1:height(Meta)
 px=Pixels{e};XTrace(e,:)=mean(double(X(px,:)),1);YTrace(e,:)=mean(double(Y(px,:)),1);
 for q=1:6
  ip=intersect(px,TruthPixels{q});ComponentTrace(e,:,q)=sum(double(X(ip,:)),1)/numel(px).*AppliedFractions(q,:);
 end
end
EligiblePixelsSurge=G.AnalysisInfo.SurgeEligibleTissuePixels;EligiblePixelsSink=S.AnalysisInfo.SinkEligibleTissuePixels;
save(fullfile(out,'measurement-inputs.mat'),'XTrace','YTrace','ComponentTrace','Pixels','NativePixels','AllDetectedPixels', ...
 'TruthPixels','Fractions','AppliedFractions','EligiblePixelsSurge','EligiblePixelsSink','-v7.3');
writetable(Meta,fullfile(out,'events.csv'));
results=cell(nnz(Meta.EventType=="surge"),1);j=0;
for e=find(Meta.EventType=="surge")'
 native=Meta.NativeStartFrame(e):Meta.NativeEndFrame(e);blocked=false(1,n);px=Pixels{e};
 for f=max(1,native(1)-60):native(1)-1,blocked(f)=any(ismember(px,AllDetectedPixels{f}));end
 a=estimateSurgeLocalOnset(YTrace(e,:),native,1,blocked,"available");b=estimateSurgePulseOnset(YTrace(e,:),native,1,blocked);
 c=selectSurgeOnsetModel(a,b,1);r=assessSurgeExpandedPeak(YTrace(e,:),native,1,blocked,c.OnsetFrame,c.Status);
 r.EventIndex=e;r.OnsetStatus=c.Status;r.SelectedModel=c.SelectedModel;r.OnsetFrame=c.OnsetFrame;
 r.RisingScore=c.RisingScore;r.PulseScore=c.PulseScore;r.SelectedScore=c.SelectedScore;
 r.FitStartFrame=c.FitStartFrame;r.FitEndFrame=c.FitEndFrame;
 r.OraclePositiveReferenceFraction=NaN;r.OracleNegativeReferenceFraction=NaN;
 r.OracleSourceAtPeak=NaN;r.OraclePositiveAtPeak=NaN;r.OracleNegativeAtPeak=NaN;
 r.OracleRoundingAtPeak=NaN;r.OracleReferenceEffect=NaN;r.DecompositionResidual=NaN;r.StrongestPositiveComponentAtPeak=0;
 if r.ExpandedArithmeticValid&&manifest.Case~="control"
  pre=r.ReferenceStartFrame:r.ReferenceEndFrame;p=r.ExpandedPeakFrame;
  components=reshape(ComponentTrace(e,:,:),n,6);positive=sum(max(components,0),2)';negative=sum(min(components,0),2)';
  bx=mean(XTrace(e,pre));by=r.ReferenceMean;rounding=YTrace(e,p)-XTrace(e,p)-positive(p)-negative(p);
  r.OraclePositiveReferenceFraction=mean(positive(pre))/bx;r.OracleNegativeReferenceFraction=mean(negative(pre))/bx;
  r.OracleSourceAtPeak=XTrace(e,p)/bx-1;r.OraclePositiveAtPeak=positive(p)/bx;r.OracleNegativeAtPeak=negative(p)/bx;
  r.OracleRoundingAtPeak=rounding/bx;r.OracleReferenceEffect=YTrace(e,p)/by-YTrace(e,p)/bx;
  r.DecompositionResidual=r.ExpandedSignedAmplitude-r.OracleSourceAtPeak-r.OraclePositiveAtPeak-r.OracleNegativeAtPeak-r.OracleRoundingAtPeak-r.OracleReferenceEffect;
  assert(abs(r.DecompositionResidual)<1e-10);[v,q]=max(components(p,:));if v>0,r.StrongestPositiveComponentAtPeak=q;end
 end
 j=j+1;results{j}=r;
end
Measurements=table();if ~isempty(results),Measurements=struct2table(vertcat(results{:}));end
writetable(Measurements,fullfile(out,'measurements.csv'));
Pairs=table();
for e=1:height(Meta)
 for q=1:6
  frames=find(Fractions(q,:)~=0);inter=0;
  for f=frames,inter=inter+numel(intersect(NativePixels{e,f},TruthPixels{q}));end
  tv=numel(TruthPixels{q})*numel(frames);iou=inter/(Meta.NativeVolume(e)+tv-inter);
  same=(Meta.EventType(e)=="surge"&&max(Fractions(q,:))>0)||(Meta.EventType(e)=="sink"&&min(Fractions(q,:))<0);
  Pairs=[Pairs;table(e,q,same,inter,tv,iou,'VariableNames',{'EventIndex','Component','SameSign','Intersection','TruthVolume','IoU'})]; %#ok<AGROW>
 end
end
writetable(Pairs,fullfile(out,'event-component-pairs.csv'));
assigned=zeros(6,1);used=false(height(Meta),1);
if ~isempty(Pairs)
 ranked=sortrows(Pairs(Pairs.SameSign&Pairs.Intersection>0,:),{'IoU','Component','EventIndex'},{'descend','ascend','ascend'});
 for k=1:height(ranked),e=ranked.EventIndex(k);q=ranked.Component(k);if ~used(e)&&assigned(q)==0,assigned(q)=e;used(e)=true;end,end
end
Truth=table();
for q=1:6
 frames=find(Fractions(q,:)~=0);same=[];if ~isempty(Pairs),same=find(Pairs.Component==q&Pairs.SameSign&Pairs.Intersection>0);end
 eligibility=EligiblePixelsSurge;if min(Fractions(q,:))<0,eligibility=EligiblePixelsSink;end
 r=struct('Component',q,'Label',string(manifest.Recipe.Labels(q)),'Imposed',manifest.Case~="control", ...
  'TruthStartFrame',frames(1),'TruthEndFrame',frames(end),'EligibleFraction',mean(ismember(TruthPixels{q},eligibility)), ...
  'IntersectingSameSignEvents',numel(same),'AssignedEventIndex',assigned(q),'AssignedIoU',0,'AssignedEventIntersectsComponents',0, ...
  'OnsetStatus',"no_assigned_surge",'ExpandedStatus',"no_assigned_surge",'OnsetErrorSec',NaN, ...
  'NativeEnvelopeFraction',NaN,'ExpandedEnvelopeFraction',NaN,'AssignedComponentStrongestAtPeak',false);
 e=assigned(q);
 if e>0
  r.AssignedIoU=Pairs.IoU(Pairs.EventIndex==e&Pairs.Component==q);
  r.AssignedEventIntersectsComponents=nnz(Pairs.EventIndex==e&Pairs.Intersection>0);
  if Meta.EventType(e)=="surge"
   a=Measurements(Measurements.EventIndex==e,:);r.OnsetStatus=a.OnsetStatus;r.ExpandedStatus=a.ExpandedStatus;
   if r.Imposed&&a.OnsetStatus=="resolved",r.OnsetErrorSec=a.OnsetFrame-frames(1);end
   if r.Imposed&&a.ArithmeticValid,r.NativeEnvelopeFraction=abs(Fractions(q,a.NativePeakFrame))/max(abs(Fractions(q,:)));end
   if r.Imposed&&a.ExpandedArithmeticValid
    r.ExpandedEnvelopeFraction=abs(Fractions(q,a.ExpandedPeakFrame))/max(abs(Fractions(q,:)));
    r.AssignedComponentStrongestAtPeak=a.StrongestPositiveComponentAtPeak==q;
   end
  else,r.OnsetStatus="sink_measurement_not_evaluated";r.ExpandedStatus=r.OnsetStatus;end
 end
 Truth=[Truth;struct2table(r)]; %#ok<AGROW>
end
writetable(Truth,fullfile(out,'component-summary.csv'));
Summary=struct('Frames',n,'Height',h,'Width',w,'SurgeEvents',height(G.Table_OxygenSurgeEvents_Out),'SurgeSites',height(G.Table_OxygenSurges_Out), ...
 'SinkEvents',height(S.Table_OxygenSinkEvents_Out),'SinkSites',height(S.Table_OxygenSinks_Out),'CandidateMeasurements',height(Measurements), ...
 'SourceTiff',source,'SourceSHA256',oxygenFileSHA256(source),'ConstructedTiff',fullfile(rec,'challenge_original.tif'), ...
 'ConstructedSHA256',G.AnalysisInfo.RawSHA256,'SurgeMat',fullfile(g.folder,g.name),'SurgeMatSHA256',oxygenFileSHA256(fullfile(g.folder,g.name)), ...
 'SinkMat',fullfile(s.folder,s.name),'SinkMatSHA256',oxygenFileSHA256(fullfile(s.folder,s.name)), ...
 'MeasurementCacheSHA256',oxygenFileSHA256(fullfile(out,'measurement-inputs.mat')),'PipelineContract',oxygenPipelineContract());
f=fopen(fullfile(out,'provenance.json'),'w');fprintf(f,'%s\n',jsonencode(Summary,'PrettyPrint',true));fclose(f);
end
