function auditSurgeTrackingOutputs(root,outputRoot)
% Independently compare flattened space-time index sets against every score.
assert(~isfolder(outputRoot));mkdir(outputRoot);R=readtable(fullfile(root,'tracking-signal-results.csv'),'TextType','string');
for session=reshape(unique(R.Session,'stable'),1,[])
 for name=reshape(unique(R.Case(R.Session==session),'stable'),1,[])
  rec=fullfile(root,session,name);M=jsondecode(fileread(fullfile(rec,'challenge-manifest.json')));
  [y,x]=ndgrid(1:M.Height,1:M.Width);npx=M.Height*M.Width;
  for k=1:2
   kind="sink";folder='OxygenSinks_Output';pattern='*Urefined*.mat';
   if k==2,kind="surge";folder='OxygenSurges_Output';pattern='*.mat';end
   f=dir(fullfile(rec,folder,pattern));assert(numel(f)==1);D=load(fullfile(f.folder,f.name));
   if k==1,S=D.Table_OxygenSinks_Out;E=D.Table_OxygenSinkEvents_Out;id='SinkID';
   else,S=D.Table_OxygenSurges_Out;E=D.Table_OxygenSurgeEvents_Out;id='SurgeID';
    assert(all(E.NativeStartFrame==E.StartFrame&E.NativeEndFrame==E.EndFrame));
    assert(all(E.TouchesRecordingStart==(E.StartFrame==1)&E.TouchesRecordingEnd==(E.EndFrame==M.Frames)));
    assert(all(E.TimingMethod=="native_mask_bounds_not_refined"));
   end
   if k==2
    P=D.AnalysisInfo.AnalysisParams;
    for site=1:height(S)
     pc=S.FramePixels{site};occupied=find(~cellfun(@isempty,pc));starts=occupied([true diff(occupied)>1]);ends=occupied([diff(occupied)>1 true]);
     anchor=unique(vertcat(pc{starts(1):ends(1)}));
     for j=1:numel(starts)
      footprint=unique(vertcat(pc{starts(j):ends(j)}));
      assert(numel(intersect(footprint,anchor))/max(numel(footprint),numel(anchor))>=P.surgeSiteOverlapFraction-1e-12);
      assert(ends(j)-starts(j)+1>=ceil(P.ThresholMinddur_Surges));
      for t=starts(j):ends(j)
       assert(numel(pc{t})>=P.ThresholdMinsize_Surges);
       if t>starts(j),assert(numel(intersect(pc{t-1},pc{t}))/max(numel(pc{t-1}),numel(pc{t}))>=P.surgeTrackingOverlapFraction-1e-12);end
      end
     end
    end
    for t=1:M.Frames
     px=[];for site=1:height(S),pc=S.FramePixels{site};px=[px;pc{t}];end %#ok<AGROW>
     assert(numel(unique(px))==numel(px),'Duplicate surge pixel ownership.');
    end
    assert(all(E.TrackingMethod=="adjacent_frame_mutual_overlap"));
    assert(all(ismember(E.AmbiguousTracking,[0 1]))&&all(ismember(E.SiteAssignmentAmbiguous,[0 1])));
   end
   assert(~ismember('SiteTraceAmplitude',E.Properties.VariableNames));
   volumes=cell(height(E),1);
   for e=1:height(E)
    pc=S.FramePixels{E.(id)(e)};frames=find(~cellfun(@isempty,pc));
    starts=frames([true diff(frames)>1]);ends=frames([diff(frames)>1 true]);j=E.EventID(e);
    v=[];
    for t=starts(j):ends(j),v=[v;pc{t}(:)+npx*(t-1)];end %#ok<AGROW>
    volumes{e}=unique(v);
    previous=NaN;next=NaN;
    if j>1,previous=(starts(j)-ends(j-1)-1)/M.SampleHz;end
    if j<numel(starts),next=(starts(j+1)-ends(j)-1)/M.SampleHz;end
    assert(isequaln(previous,E.PreviousNativeGapSec(e))&&isequaln(next,E.NextNativeGapSec(e)));
    assert(E.CloseNativeRun(e)==any([previous next]<E.CloseNativeGapThresholdSec(e)));
   end

   rows=find(R.Session==session&R.Case==name&R.EventType==kind);
   for q=reshape(rows,1,[])
    truth=[];
    for t=R.TruthStartFrame(q):R.TruthEndFrame(q)
     cx=M.CentersXY(k,1);if R.TruthRow(q)==8,cx=round(cx+M.MotionUmPerSec*(t-101)/M.SampleHz/M.SourceProfile.PixelSize);end
     mask=find((x-cx).^2+(y-M.CentersXY(k,2)).^2<=M.RadiusPixels^2);
     truth=[truth;mask+npx*(t-1)]; %#ok<AGROW>
    end
    scores=zeros(height(E),1);hits=0;
    for e=1:height(E)
     overlap=numel(intersect(truth,volumes{e}));hits=hits+(overlap>0);
     scores(e)=overlap/numel(union(truth,volumes{e}));
    end
    best=max([0;scores]);assert(abs(best-R.BestNativeSpacetimeIoU(q))<1e-12&&hits==R.OverlappingRuns(q));
    if best>0,assert(R.BestEventRow(q)==find(scores==best,1));else,assert(R.BestEventRow(q)==0);end
   end
  end
 end
end
Report=struct('RowsIndependentlyVerified',height(R),'AllOverlapScoresMatch',true, ...
 'NativeGapsAndFlagsMatchMasks',true,'SurgeNativeTimingMetadataMatches',true,'NoObsoleteSiteAmplitudeExport',true,'SurgeAdjacentCoverageAndPhysicalAreaVerified',true,'FixedSiteAnchorCoverageVerified',true,'NoDuplicateSurgePixelOwnership',true,'RejectedCandidateAmbiguityReconstructed',false);
f=fopen(fullfile(outputRoot,'overlap-and-metadata-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(Report,'PrettyPrint',true));fclose(f);disp(Report);
end
