function T=runSurgeContinuitySweep(outputRoot)
% Prescribed candidate geometry; does not test image preprocessing or biology.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);T=table();
cases=["stationary","smooth_growth","smooth_shrink","rapid_growth","rapid_shrink", ...
 "pulsating","extreme_growth","neighbor_merge","neighbor_split", ...
 "single_with_dropout","true_pair","short_fragments","long_gap"];
for px=[2.35 4.75 6.75]
 for fs=[.5 1 2]
  P=createOxygenMasterParams(px,fs);N=round(24*fs);H=ceil(600/px);[y,x]=ndgrid(1:H,1:H);cx=round(H/2);cy=cx;
  for name=cases
   radius=60*ones(1,N);Frames=cell(1,N);
   if name=="smooth_growth",radius=linspace(60,120,N);end
   if name=="smooth_shrink",radius=linspace(120,60,N);end
   if name=="rapid_growth",radius(N/2+1:end)=82;end
   if name=="rapid_shrink",radius(1:N/2)=82;end
   if name=="extreme_growth",radius(N/2+1:end)=120;end
   if name=="pulsating",radius(mod(floor((0:N-1)/(2*fs)),2)==1)=82;end
   for t=1:N,Frames{t}=regionprops((x-cx).^2+(y-cy).^2<=(radius(t)/px)^2,'PixelIdxList');end
   if any(name==["neighbor_merge","neighbor_split"])
    side=ceil(sqrt(P.ThresholdMinsize_Surges));left=false(H);right=left;merged=left;
    left(1:side,1:side)=true;right(1:side,side+2:2*side+1)=true;merged(1:side,1:2*side)=true;
    two=regionprops(left|right,'PixelIdxList');one=regionprops(merged,'PixelIdxList');
    Frames(1:N/2)={two};Frames(N/2+1:end)={one};
    if name=="neighbor_split",Frames=fliplr(Frames);end
   end
   if any(name==["single_with_dropout","true_pair","short_fragments","long_gap"])
    d=round(12*fs);gap=1;
    if name=="short_fragments",d=round(6*fs);end
    if name=="long_gap",gap=ceil(3*fs);end
    region=Frames{1};Frames=cell(1,2*d+gap);Frames(1:d)={region};Frames(d+gap+1:end)={region};
   end
   % Prescribed candidates must pass the real physical-area admission rule.
   for t=1:numel(Frames)
    if isempty(Frames{t}),continue;end
    Frames{t}=Frames{t}(arrayfun(@(r)numel(r.PixelIdxList)>=P.ThresholdMinsize_Surges,Frames{t}));
   end
   for method=["mutual_only","isolated_shape"]
    R=P;if method=="mutual_only",R.surgeTrackingMaxAreaRatio=1;end
    [Sites,~,Map,Q,G]=buildTrackedOxygenSurgeSites(Frames,R);
    for t=1:numel(Frames)
     v=[];for site=1:size(Sites,1),v=[v;Sites{site,t}];end %#ok<AGROW>
     assert(numel(v)==numel(unique(v)),'Duplicated candidate ownership.');
    end
    assert(height(Map)==sum(Q.KeptAsEvent));
    if any(name==["single_with_dropout","true_pair"]),assert(height(Map)==2&&height(G)==1);end
    if name=="short_fragments",assert(isempty(Map)&&height(Q)==2&&height(G)==1);end
    if name=="long_gap",assert(height(Map)==2&&isempty(G));end
    if any(name==["neighbor_merge","neighbor_split"]),assert(height(Map)==3&&sum(Q.ShapeChangeLinkCount)==0);end
    if method=="isolated_shape"&&any(name==["stationary","smooth_growth","smooth_shrink","rapid_growth","rapid_shrink","pulsating"])
     assert(height(Map)==1&&max(Q.DurationSec)==24);
    end
    T=[T;table(px,fs,name,method,height(Q),height(Map),size(Sites,1),sum(~Q.KeptAsEvent), ...
     max([0;Q.DurationSec(Q.KeptAsEvent)]),sum(Q.ShapeChangeLinkCount),height(G),sum(Q.AmbiguousTracking), ...
     'VariableNames',{'PixelSizeUm','SampleHz','Case','Method','CandidateRuns','RetainedEvents','RecurringSites', ...
     'RejectedCandidateRuns','LongestRetainedSec','ShapeChangeLinks','GapReviewPairs','AmbiguousCandidateRuns'})]; %#ok<AGROW>
   end
  end
 end
end
writetable(T,fullfile(outputRoot,'continuity-sweep.csv'));
Report=struct('PrescribedCases',height(T)/2,'MethodsCompared',2,'CandidateOwnershipVerified',true, ...
 'NoGapBridging',true,'ShortFragmentsRemainRejected',true,'NeighborContactsCannotUseFallback',true, ...
 'AllBoundedGrowthAndContractionCasesContinuous',true,'Interpretation','Prescribed masks only. Dropout and true-pair cases deliberately have identical masks. No biological sensitivity or specificity estimate.');
f=fopen(fullfile(outputRoot,'sweep-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(Report,'PrettyPrint',true));fclose(f);disp(Report);
end
