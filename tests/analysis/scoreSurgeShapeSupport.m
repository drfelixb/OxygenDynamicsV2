function T=scoreSurgeShapeSupport(rec,M,caseLabel)
% Full space-time support scores; compare source controls using identical masks.
T=table();
for k=1:2
 folder='OxygenSinks_Output';pattern='*Urefined*.mat';kind="sink";id='SinkID';amp='NormOxySinkAmp';
 if k==2,folder='OxygenSurges_Output';pattern='*.mat';kind="surge";id='SurgeID';amp='NormOxySurgeAmp';end
 f=dir(fullfile(rec,folder,pattern));assert(isscalar(f));D=load(fullfile(f.folder,f.name));
 if k==1,S=D.Table_OxygenSinks_Out;E=D.Table_OxygenSinkEvents_Out;px=D.AnalysisInfo.SinkEligibleTissuePixels;
 else,S=D.Table_OxygenSurges_Out;E=D.Table_OxygenSurgeEvents_Out;px=D.AnalysisInfo.SurgeEligibleTissuePixels;end
 eligible=false(M.Height,M.Width);eligible(px)=true;truth=cell(1,M.Frames);volume=0;eligibleVolume=0;
 for t=M.Windows(1,1):M.Windows(1,2)
  truth{t}=find(surgeEvidenceTruthMask(M,k,1,t));volume=volume+numel(truth{t});eligibleVolume=eligibleVolume+nnz(eligible(truth{t}));
 end
 best=0;row=0;hits=0;na=NaN;nb=NaN;
 for e=1:height(E)
  pc=S.FramePixels{E.(id)(e)};r=regionprops(~cellfun(@isempty,pc),'PixelIdxList');frames=r(E.EventID(e)).PixelIdxList;
  v=0;n=0;
  for t=reshape(frames,1,[]),v=v+numel(pc{t});n=n+numel(intersect(pc{t},truth{t}));end
  hits=hits+(n>0);iou=n/(v+volume-n);
  if iou>best,best=iou;row=e;na=frames(1);nb=frames(end);end
 end
 value=NaN;status="no_intersection";if row>0,value=E.(amp)(row);status=string(E.BaselineStatus(row));end
 T=[T;table(string(M.SourceProfile.Session),string(M.SourceProfile.Role),string(caseLabel),kind,height(E),height(S), ...
  hits,best,row,na,nb,value,status,eligibleVolume/volume, ...
  'VariableNames',{'Session','Role','Case','EventType','TotalRetainedEvents','TotalRecurringSites','IntersectingEvents','BestNativeSpacetimeIoU','BestEventRow', ...
  'NativeStartFrame','NativeEndFrame','MeasuredAmplitudeFraction','BaselineStatus','TruthEligibleFraction'})]; %#ok<AGROW>
end
end
