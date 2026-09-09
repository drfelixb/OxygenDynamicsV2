function T=auditSurgeTrackingMotion(outputRoot)
% Isolate tracker behavior with prescribed, duration-qualified region masks.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
P=createOxygenMasterParams(4.75,1);T=table();
for shift=[0 1]
 F=cell(12,1);
 for t=1:12
  mask=false(20,40);left=1+(t-1)*shift;mask(:,left:left+19)=true;
  F{t}=struct('PixelIdxList',find(mask));
 end
 % Historical fixed-seed diagnostic, not the current BOI detector.
 surge=trackiOSSurgeCandidates(F,P.ThresholMinddur_Surges,390);
 [~,surgeMask]=refineTrackedSurgeCandidates(surge,P.ThresholMinddur_Surges);
 sink=trackSinkCandidates(F,P.ThresholMinddur,.6);[~,sinkMask]=filterSinkRunsByDuration(sink,P.ThresholMinddur,P.ThresholMaxddur);
 surgeEvents=0;sinkEvents=0;
 for s=1:size(surgeMask,1),surgeEvents=surgeEvents+numel(regionprops(surgeMask(s,:),'PixelIdxList'));end
 for s=1:size(sinkMask,1),sinkEvents=sinkEvents+numel(regionprops(sinkMask(s,:),'PixelIdxList'));end
 T=[T;table(shift,400,12,390,numel(intersect(F{1}.PixelIdxList,F{2}.PixelIdxList)),surgeEvents,sinkEvents, ...
  'VariableNames',{'ShiftPixelsPerFrame','AreaPixels','Frames','StrictSurgeOverlapThresholdPixels','AdjacentOverlapPixels','RetainedSurgeRuns','RetainedSinkRuns'})]; %#ok<AGROW>
end
writetable(T,fullfile(outputRoot,'tracker-motion-diagnostic.csv'));disp(T);
end
