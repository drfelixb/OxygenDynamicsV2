function Results=auditSurgePhysicalTracking(outputRoot)
% Prescribed circular regions: physical area, motion, frame rate and overlap sweep.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);Results=table();
for px=[2.35 4.75 6.75]
 for fs=[.5 1 2]
  P=createOxygenMasterParams(px,fs);N=round(12*fs);
  for radius=[45 60 85.5 120]
   for speed=[0 4.75 9.5 19 38]
    H=ceil(2*(radius+15)/px);W=ceil((2*(radius+15)+speed*12)/px);[y,x]=ndgrid(1:H,1:W);
    F=cell(N,1);Old=cell(N,1);areas=zeros(N,1);
    for f=1:N
     cx=round((radius+15+speed*(f-1)/fs)/px);cy=round((radius+15)/px);
     mask=(x-cx).^2+(y-cy).^2<=(radius/px)^2;areas(f)=nnz(mask);
     if areas(f)>=P.ThresholdMinsize_Surges,F{f}=struct('PixelIdxList',find(mask));end
     if areas(f)>=400,Old{f}=struct('PixelIdxList',find(mask));end
    end
    old=trackiOSSurgeCandidates(Old,P.ThresholMinddur_Surges,390);
    [~,oldL]=refineTrackedSurgeCandidates(old,P.ThresholMinddur_Surges);oldCount=countTrackedEvents(oldL);
    for fraction=[.5 .6 .7 .8]
     P.surgeTrackingOverlapFraction=fraction;
     [~,L,M]=buildTrackedOxygenSurgeSites(F,P);longest=0;
     if ~isempty(M),longest=max(M.NativeEndFrame-M.NativeStartFrame+1);end
     Results=[Results;table(px,fs,radius,speed,fraction,P.surgeMinAreaUm2,P.ThresholdMinsize_Surges, ...
      min(areas),N,nnz(~cellfun(@isempty,F)),height(M),size(L,1),longest,oldCount, ...
      'VariableNames',{'PixelSizeUm','SampleHz','RadiusUm','SpeedUmPerSec','TrackingOverlapFraction', ...
      'MinAreaUm2','MinAreaPixels','CandidateAreaPixels','InputFrames','AreaQualifiedFrames','RetainedRuns','Sites','LongestRunFrames','PreviousRuleRuns'})]; %#ok<AGROW>
    end
   end
  end
 end
end
assert(height(Results)==720);writetable(Results,fullfile(outputRoot,'physical-tracking-sweep.csv'));
writetable(createOxygenRegressionCodeManifest(),fullfile(outputRoot,'code-manifest.csv'));disp(Results(Results.TrackingOverlapFraction==.6 & Results.SpeedUmPerSec==4.75,:));
end
