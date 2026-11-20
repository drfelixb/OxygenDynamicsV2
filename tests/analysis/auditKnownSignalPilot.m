function auditKnownSignalPilot(root)
% Independently recompute all reported overlaps using full logical volumes.
D=load(fullfile(root,'pilot-results.mat'));R=D.Results;M=D.M;
heightPx=diff(M.SourceRows)+1;widthPx=diff(M.SourceColumns)+1;N=diff(M.SourceFrames)+1;
[y,x]=ndgrid(1:heightPx,1:widthPx);
mask=(x-M.CircleCenterXY(1)).^2+(y-M.CircleCenterXY(2)).^2<=M.CircleRadiusPixels^2;
for c=reshape(unique(R.Case,'stable'),1,[])
 for kind=["sink" "surge"]
  if kind=="sink"
   f=dir(fullfile(root,c,'OxygenSinks_Output','*Urefined*.mat'));S=load(fullfile(f.folder,f.name));
   sites=S.Table_OxygenSinks_Out;events=S.Table_OxygenSinkEvents_Out;id='SinkID';
  else
   f=dir(fullfile(root,c,'OxygenSurges_Output','*.mat'));S=load(fullfile(f.folder,f.name));
   sites=S.Table_OxygenSurges_Out;events=S.Table_OxygenSurgeEvents_Out;id='SurgeID';
  end
  for w=1:2
   truth=logical(sparse(heightPx*widthPx,N));truth(:,M.WindowsInclusive(w,1):M.WindowsInclusive(w,2))=repmat(mask(:),1,20);
   scores=zeros(height(events),1);hits=0;
   for e=1:height(events)
    pixels=sites.FramePixels{events.(id)(e)};
    active=find(~cellfun(@isempty,pixels));
    starts=active([true diff(active)>1]);ends=active([diff(active)>1 true]);
    k=events.EventID(e);volume=logical(sparse(size(truth,1),size(truth,2)));
    for t=starts(k):ends(k),volume(pixels{t},t)=true;end
    intersection=nnz(volume&truth);hits=hits+(intersection>0);
    scores(e)=intersection/nnz(volume|truth);
   end
   q=R(R.Case==c&R.DetectionSign==kind&R.Window==w,:);assert(height(q)==1);
   assert(q.TotalDetectedEvents==height(events)&&q.OverlappingEvents==hits);
   best=max([0;scores]);assert(abs(best-q.BestNativeSpacetimeIoU)<1e-12);
   if best>0,assert(q.BestEventRow==find(scores==best,1));else,assert(q.BestEventRow==0);end
  end
 end
end
A=struct('RowsIndependentlyVerified',height(R),'AllOverlapMetricsMatch',true);
f=fopen(fullfile(root,'overlap-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(A));fclose(f);
disp(A);
end
