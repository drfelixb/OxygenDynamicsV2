function Report=auditSurgeCandidateEvidence(rec,outputRoot)
% Explain existing detections against prescribed signal support; no retuning.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
M=jsondecode(fileread(fullfile(rec,'challenge-manifest.json')));assert(isequaln(M.PipelineContract,oxygenPipelineContract()));
M.Windows=reshape(M.Windows,[],2);
P=createOxygenMasterParams(M.SourceProfile.PixelSize,M.SampleHz);
[Y,~,~]=loadtiff(fullfile(rec,'challenge_original.tif'));[Source,~,~]=loadtiff(M.SourceTiff);
assert(isequal(size(Y),size(Source))&&strcmp(oxygenFileSHA256(M.SourceTiff),M.SourceSHA256));
X=detrend_custom(Y,3);Area=computeRecordingArea(X,P.PixelSize,P.recAreaBackgroundPercentile, ...
 'recAreaBinHalfSizeUm',P.recAreaBinHalfSizeUm,'recAreaMinCoverageFraction',P.recAreaMinCoverageFraction);
[Spatial,Temporal]=normalizeToZStat(single(X));[Check,F]=preprocessDetectionStack(single(X),P.smooth);assert(isequal(Temporal,Check));clear Check;
D=struct('percentileThreshold',P.PercentileSurgeDetectionThres,'minArea',P.ThresholdMinsize_Surges,'maxArea',Inf, ...
 'minCircularity',P.surgeCircularityThreshold,'maxOutsideFraction',P.maxOutsideRecordingAreaFraction,'frameTransform','mat2gray');
C=detectFrameRegionCandidates(F,Area.Filter,D);
[Sites,~,~,Q,G]=buildTrackedOxygenSurgeSites(C,P);[Runs,~]=trackSurgeCandidates(C,P.ThresholMinddur_Surges, ...
 P.surgeTrackingOverlapFraction,P.surgeTrackingContainmentFraction,P.surgeTrackingMaxAreaRatio);
f=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));assert(isscalar(f));U=load(fullfile(f.folder,f.name));
assert(strcmp(U.AnalysisInfo.RawSHA256,oxygenFileSHA256(fullfile(rec,'challenge_original.tif'))));
assert(height(U.Table_OxygenSurges_Out)==size(Sites,1));
for s=1:size(Sites,1),assert(isequal(Sites(s,:),U.Table_OxygenSurges_Out.FramePixels{s}));end
assert(isequaln(Q,U.SurgeCandidateRunQC(:,Q.Properties.VariableNames)));
assert(isequaln(G,U.SurgeGapReview(:,G.Properties.VariableNames)));
N=M.Frames;frameMean=mean(reshape(double(Y),[],N),1)';frameSD=std(reshape(double(Y),[],N),0,1)';
Trace=table();Transitions=table();Matches=table();
Regions=table('Size',[0 11],'VariableTypes',[repmat({'double'},1,7) repmat({'logical'},1,4)], ...
 'VariableNames',{'TruthRow','Frame','ThresholdRegionIndex','AreaUm2','Circularity','OutsideTissueFraction','TruthPixels', ...
 'BelowMinimumArea','BelowCircularity','ExcessOutsideTissue','Accepted'});
for q=reshape(M.EvaluatedTruthRows,1,[])
 a=M.Windows(q,1);b=M.Windows(q,2);truth=cell(1,N);
 for t=a:b,truth{t}=find(surgeEvidenceTruthMask(M,2,q,t));end
 footprint=unique(vertcat(truth{:}));raw=roiTrace(Y,footprint);source=roiTrace(Source,footprint);det=roiTrace(X,footprint);
 spatial=roiTrace(Spatial,footprint);temporal=roiTrace(Temporal,footprint);smooth=roiTrace(F,footprint);
 ntruth=zeros(N,1);selected=ntruth;accepted=ntruth;kept=ntruth;eligible=ntruth;threshold=nan(N,1);
 for t=a:b
  ntruth(t)=numel(truth{t});eligible(t)=nnz(Area.Filter(truth{t}));frame=safeMat2Gray(F(:,:,t));cut=prctile(frame(:),P.PercentileSurgeDetectionThres);BW=frame>cut;
  values=double(F(:,:,t));threshold(t)=min(values(:))+cut*(max(values(:))-min(values(:)));
  selected(t)=nnz(BW(truth{t}));regs=regionprops(BW,'Area','Circularity','PixelIdxList');
  reconstructed=false(M.Height,M.Width);
  for j=1:numel(regs)
   px=regs(j).PixelIdxList;outside=nnz(~Area.Filter(px))/numel(px);small=regs(j).Area<P.ThresholdMinsize_Surges;
   irregular=regs(j).Circularity<P.surgeCircularityThreshold;off=outside>P.maxOutsideRecordingAreaFraction;keep=~(small||irregular||off);
   if keep,reconstructed(px)=true;end
   hits=numel(intersect(px,truth{t}));if hits==0,continue;end
   Regions=[Regions;table(q,t,j,numel(px)*P.PixelSize^2,regs(j).Circularity,outside,hits,small,irregular,off,keep, ...
    'VariableNames',{'TruthRow','Frame','ThresholdRegionIndex','AreaUm2','Circularity','OutsideTissueFraction','TruthPixels', ...
    'BelowMinimumArea','BelowCircularity','ExcessOutsideTissue','Accepted'})]; %#ok<AGROW>
  end
  candidatePixels=[];if ~isempty(C{t}),candidatePixels=vertcat(C{t}.PixelIdxList);end
  assert(isequal(find(reconstructed),sort(candidatePixels(:))),'Filter reconstruction differs.');
  accepted(t)=nnz(reconstructed(truth{t}));kept(t)=numel(intersect(unique(vertcat(Sites{:,t})),truth{t}));
 end
 anchor=max(1,min(M.Windows(M.EvaluatedTruthRows,1))-round(P.quantBaselineWindowSec*P.fs)):min(M.Windows(M.EvaluatedTruthRows,1))-1;
 assert(~isempty(anchor));base=mean(raw(anchor));
 T=table(repmat(q,N,1),(1:N)',(0:N-1)'/P.fs,raw,source,(raw-base)/base, ...
 (raw-source)./source,det,spatial,temporal,smooth,threshold,frameMean,frameSD,ntruth,selected,accepted,kept,eligible, ...
 'VariableNames',{'TruthRow','Frame','TimeSec','RawFixedUnionMean','SourceFixedUnionMean','RawChangeFromPreFirstInjection', ...
 'AppliedChangeVsSourceSameFrame','DetrendedFixedUnionMean','SpatialZFixedUnionMean','TemporalZFixedUnionMean','SmoothedZFixedUnionMean', ...
 'SurgeThresholdZ','FullFrameRawMean','FullFrameRawSD','TruthPixels','SelectedTruthPixels','AcceptedTruthPixels','RetainedTruthPixels','EligibleTruthPixels'});
 Trace=[Trace;T]; %#ok<AGROW>
 V=summarizeSurgeCandidateTransitions(Runs,truth,P);V.TruthRow=repmat(q,height(V),1);Transitions=[Transitions;V]; %#ok<AGROW>
 E=U.Table_OxygenSurgeEvents_Out;best=0;row=0;volume=sum(ntruth);
 for e=1:height(E)
  cells=U.Table_OxygenSurges_Out.FramePixels{E.SurgeID(e)};frames=E.NativeStartFrame(e):E.NativeEndFrame(e);n=0;v=0;
  for t=frames,n=n+numel(intersect(cells{t},truth{t}));v=v+numel(cells{t});end
  iou=n/(volume+v-n);if iou>best,best=iou;row=e;end
 end
 first=NaN;last=NaN;amplitude=NaN;status="no_intersection";uplift=NaN;preFraction=NaN;anchorPeak=NaN;appliedPeak=NaN;contaminatedFrames=NaN;
 if row>0
  first=E.NativeStartFrame(row);last=E.NativeEndFrame(row);amplitude=E.NormOxySurgeAmp(row);status=string(E.BaselineStatus(row));
  cells=U.Table_OxygenSurges_Out.FramePixels{E.SurgeID(row)};px=unique(vertcat(cells{first:last}));yr=roiTrace(Y,px);xr=roiTrace(Source,px);
  pre=max(1,first-round(P.quantBaselineWindowSec*P.fs)):first-1;
  uplift=mean(yr(pre)-xr(pre))/mean(xr(pre));preFraction=mean(yr(pre))/mean(yr(anchor))-1;
  anchorPeak=max(yr(a:b)/mean(yr(anchor))-1);appliedPeak=max((yr(a:b)-xr(a:b))./xr(a:b));
  contaminatedFrames=0;
  for t=reshape(pre,1,[])
   injected=[];
   for qq=reshape(M.EvaluatedTruthRows,1,[])
    if M.FractionBySignAndFrame(2,t)>0,injected=union(injected,find(surgeEvidenceTruthMask(M,2,qq,t)));end
   end
   contaminatedFrames=contaminatedFrames+~isempty(intersect(px,injected));
  end
 end
 Matches=[Matches;table(q,a,b,best,row,first,last,amplitude,status,uplift,preFraction,anchorPeak,appliedPeak,contaminatedFrames, ...
 'VariableNames',{'TruthRow','TruthStartFrame','TruthEndFrame','BestNativeSpacetimeIoU','BestEventRow','NativeStartFrame','NativeEndFrame', ...
 'ReportedAmplitudeFraction','BaselineStatus','AppliedChangeInNativePrebaselineFraction','NativePrebaselineChangeFromAnchorFraction', ...
 'FullSupportPeakFromAnchorFraction','PeakAppliedChangeOnEventFootprint','NativePrebaselineFramesTouchingKnownSurge'})]; %#ok<AGROW>
end
writetable(Trace,fullfile(outputRoot,'fixed-support-stage-traces.csv'));writetable(Regions,fullfile(outputRoot,'threshold-region-decisions.csv'));
writetable(Transitions,fullfile(outputRoot,'candidate-transition-evidence.csv'));writetable(Matches,fullfile(outputRoot,'matched-surge-signal-audit.csv'));
Report=struct('Session',M.SourceProfile.Session,'Case',M.Case,'InputSHA256',U.AnalysisInfo.RawSHA256, ...
 'PipelineContract',oxygenPipelineContract(),'AnalysisParams',P,'SavedMasksAndCandidateLedgersReproduced',true,'FilteringReconstructed',true, ...
 'DefaultTrackingLinksIndependentlyVerified',true,'AmplitudeDefinitionChanged',false, ...
 'TraceSupport','Fixed union of imposed surge support for each truth window; columns have distinct intensity/z-score units.', ...
 'BaselineInterpretation','Anchor precedes the first imposed signal. Counterfactual source comparison isolates applied change on the same pixels; it is not an observable biological ground truth for natural events. Native prebaseline diagnostics do not remove excluded frames and do not replace the production measurement.', ...
 'ProductionPreprocessingReused',true,'Matches',table2struct(Matches));
fid=fopen(fullfile(outputRoot,'evidence-verification.json'),'w');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(Report,'PrettyPrint',true));fclose(fid);
% Export one focused scientific plot with separate axes for distinct units.
q=M.EvaluatedTruthRows(1);T=Trace(Trace.TruthRow==q,:);a=M.Windows(q,1);b=M.Windows(q,2);range=max(1,a-15):min(N,b+10);
h=figure('Visible','off','Position',[100 100 1050 800]);tiledlayout(3,1,'TileSpacing','compact');
nexttile;plot(T.TimeSec(range),100*T.RawChangeFromPreFirstInjection(range),'LineWidth',1.4);hold on;
plot(T.TimeSec(range),100*T.AppliedChangeVsSourceSameFrame(range),'LineWidth',1.4);ylabel('Intensity change (%)');legend('Recorded + imposed, vs pre-injection anchor','Applied increment vs source, same frame','Location','best');
title(string(M.SourceProfile.Session)+" / "+string(M.Case)+" / fixed imposed-union support",'Interpreter','none');
nexttile;plot(T.TimeSec(range),[T.SpatialZFixedUnionMean(range) T.TemporalZFixedUnionMean(range) T.SmoothedZFixedUnionMean(range)],'LineWidth',1.2);ylabel('Stage z-score mean');legend('Spatial normalization','Temporal normalization','After smoothing','Location','best');
nexttile;plot(T.TimeSec(range),[T.SelectedTruthPixels(range) T.AcceptedTruthPixels(range) T.RetainedTruthPixels(range)]./T.TruthPixels(range),'LineWidth',1.4);ylabel('Fraction of imposed pixels');ylim([0 1]);xlabel('Recording time (s)');legend('Percentile selected','After region filters','Retained events','Location','best');
exportgraphics(h,fullfile(outputRoot,'stage-evidence.png'),'Resolution',150);close(h);disp(Matches);
end
function t=roiTrace(X,px)
flat=reshape(X,[],size(X,3));t=mean(double(flat(px,:)),1)';
end
