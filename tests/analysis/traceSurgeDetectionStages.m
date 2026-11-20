function Summary=traceSurgeDetectionStages(root,session,name,outputRoot)
% Reconstruct production stages to localize losses, not an independent detector.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
rec=fullfile(root,session,name);M=jsondecode(fileread(fullfile(rec,'challenge-manifest.json')));
assert(isequaln(M.PipelineContract,oxygenPipelineContract()));P=createOxygenMasterParams(M.SourceProfile.PixelSize,M.SampleHz);
[I,~]=loadOxygenMasterInputs(rec,P);assert(isempty(I.IM_NoNoise));
X=detrend_custom(I.IM_Raw,3);clear I;
Area=computeRecordingArea(X,P.PixelSize,P.recAreaBackgroundPercentile, ...
 'recAreaBinHalfSizeUm',P.recAreaBinHalfSizeUm,'recAreaMinCoverageFraction',P.recAreaMinCoverageFraction);
[~,F]=preprocessDetectionStack(single(X),P.smooth);clear X;
N=size(F,3);[y,x]=ndgrid(1:size(F,1),1:size(F,2));masks=cell(numel(M.EvaluatedTruthRows),N);
for w=1:numel(M.EvaluatedTruthRows)
 q=M.EvaluatedTruthRows(w);
 for t=M.Windows(q,1):M.Windows(q,2)
  cx=M.CentersXY(2,1);if q==8,cx=round(cx+M.MotionUmPerSec*(t-101)/P.PixelSize);end
  masks{w,t}=(x-cx).^2+(y-M.CentersXY(2,2)).^2<=M.RadiusPixels^2;
 end
end
D=struct('percentileThreshold',P.PercentileSurgeDetectionThres,'minArea',P.ThresholdMinsize_Surges, ...
 'maxArea',Inf,'minCircularity',P.surgeCircularityThreshold,'maxOutsideFraction',P.maxOutsideRecordingAreaFraction,'frameTransform','mat2gray');
C=detectFrameRegionCandidates(F,Area.Filter,D);threshold=cell(1,N);areaOnly=cell(1,N);accepted=cell(1,N);
for t=1:N
 frame=safeMat2Gray(F(:,:,t));BW=frame>prctile(frame(:),P.PercentileSurgeDetectionThres);
 threshold{t}=find(BW);BW=filterRegionCandidates(BW,true(size(BW)),P.ThresholdMinsize_Surges,Inf,-Inf,1,[]);areaOnly{t}=find(BW);
 if ~isempty(C{t}),accepted{t}=vertcat(C{t}.PixelIdxList);end
end
clear F;
Summary=[summarize(threshold,"percentile_only",masks,M);summarize(areaOnly,"physical_area_only",masks,M);summarize(accepted,"candidate_geometry_tissue",masks,M)];
[R,Info]=trackSurgeCandidates(C,P.ThresholMinddur_Surges,P.surgeTrackingOverlapFraction,P.surgeTrackingContainmentFraction,P.surgeTrackingMaxAreaRatio);
Summary=[Summary;summarize(R,"adjacent_tracks_before_duration",masks,M)];
keep=Info.NativeEndFrame-Info.NativeStartFrame+1>=ceil(P.ThresholMinddur_Surges);R=R(keep,:);
Summary=[Summary;summarize(R,"ten_second_duration",masks,M)];
[Sites,~]=groupSurgeRunsIntoSites(R,P.surgeSiteOverlapFraction);
Summary=[Summary;summarize(Sites,"recurring_sites",masks,M)];
f=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));assert(numel(f)==1);S=load(fullfile(f.folder,f.name),'Table_OxygenSurges_Out');
assert(height(S.Table_OxygenSurges_Out)==size(Sites,1));
for s=1:size(Sites,1),assert(isequal(Sites(s,:),S.Table_OxygenSurges_Out.FramePixels{s}),'Reconstructed final surge masks differ.');end
writetable(Summary,fullfile(outputRoot,'surge-stage-trace.csv'));
report=struct('Session',session,'Case',name,'InputSHA256',oxygenFileSHA256(fullfile(rec,'challenge_original.tif')), ...
 'FinalSavedMasksExactlyMatch',true,'ProductionPreprocessingReused',true,'AnalysisParams',P);
f=fopen(fullfile(outputRoot,'trace-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(report,'PrettyPrint',true));fclose(f);disp(Summary);
end
function T=summarize(P,stage,masks,M)
T=table();
for w=1:numel(M.EvaluatedTruthRows)
 q=M.EvaluatedTruthRows(w);a=M.Windows(q,1);b=M.Windows(q,2);coverage=0;volume=0;seen=false(1,b-a+1);longest=0;hits=0;bounds="";
 for s=1:size(P,1)
  active=find(~cellfun(@isempty,P(s,:)));if isempty(active),continue;end
  starts=active([true diff(active)>1]);ends=active([diff(active)>1 true]);
  for j=1:numel(starts)
   overlap=false(1,b-a+1);
   for t=max(a,starts(j)):min(b,ends(j)),overlap(t-a+1)=any(masks{w,t}(P{s,t}));end
   if any(overlap)
    hits=hits+1;bounds=bounds+sprintf('%d:%d-%d;',s,starts(j),ends(j));
    runs=regionprops(overlap,'Area');longest=max(longest,max([runs.Area]));
   end
  end
 end
 for t=a:b
  px=unique(vertcat(P{:,t}));n=nnz(masks{w,t}(px));seen(t-a+1)=n>0;coverage=coverage+n;volume=volume+nnz(masks{w,t});
 end
 T=[T;table(stage,q,nnz(seen),coverage/volume,hits,longest,bounds, ...
 'VariableNames',{'Stage','TruthRow','FramesWithIntersection','InjectedVolumeCoverage','IntersectingRuns','LongestConsecutiveIntersectionFrames','RowAndNativeBounds'})]; %#ok<AGROW>
end
end
