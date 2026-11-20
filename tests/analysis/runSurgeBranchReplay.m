function runSurgeBranchReplay(priorRoot,shapeRoot,outputRoot)
% Six complete frozen movies, four sources. Changes candidate linking only.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Old=readtable(fullfile(priorRoot,'code-manifest.csv'),'TextType','string');
for j=1:height(Old)
 if ~startsWith(Old.RelativePath(j),'tests/')
  assert(strcmp(oxygenFileSHA256(Old.RelativePath(j)),Old.SHA256(j)),'Production source differs from archived runs.');
 end
end
specs={priorRoot,'M401-01-baseline-awake','smooth_pairs';priorRoot,'M400-01-baseline-awake','moving_clean'; ...
 shapeRoot,'FB2312-baseline-awake','growing_clean';shapeRoot,'FB2312-baseline-awake','shrinking_clean'; ...
 shapeRoot,'FB2411','growing_clean';shapeRoot,'FB2411','shrinking_clean'};
Summary=table();Scores=table();
for k=1:size(specs,1)
 rec=fullfile(specs{k,:});session=string(specs{k,2});name=string(specs{k,3});
 M=jsondecode(fileread(fullfile(rec,'challenge-manifest.json')));M.Windows=reshape(M.Windows,[],2);
 assert(isequaln(M.PipelineContract,oxygenPipelineContract()));
 P=createOxygenMasterParams(M.SourceProfile.PixelSize,M.SampleHz);
 [X,~,~]=loadtiff(fullfile(rec,'challenge_original.tif'));X=detrend_custom(X,3);
 Area=computeRecordingArea(X,P.PixelSize,P.recAreaBackgroundPercentile, ...
  'recAreaBinHalfSizeUm',P.recAreaBinHalfSizeUm,'recAreaMinCoverageFraction',P.recAreaMinCoverageFraction);
 [~,F]=preprocessDetectionStack(single(X),P.smooth);clear X;
 D=struct('percentileThreshold',P.PercentileSurgeDetectionThres,'minArea',P.ThresholdMinsize_Surges,'maxArea',Inf, ...
  'minCircularity',P.surgeCircularityThreshold,'maxOutsideFraction',P.maxOutsideRecordingAreaFraction,'frameTransform','mat2gray');
 C=detectFrameRegionCandidates(F,Area.Filter,D);clear F Area;
 [Expected,I]=trackSurgeCandidates(C,P.ThresholMinddur_Surges,P.surgeTrackingOverlapFraction,P.surgeTrackingContainmentFraction,P.surgeTrackingMaxAreaRatio);
 [Sites,~,~,Q,G]=buildTrackedOxygenSurgeSites(C,P);
 file=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));assert(isscalar(file));U=load(fullfile(file.folder,file.name));
 assert(strcmp(U.AnalysisInfo.RawSHA256,oxygenFileSHA256(fullfile(rec,'challenge_original.tif'))));
 assert(strcmp(M.SourceSHA256,oxygenFileSHA256(M.SourceTiff)));
 assert(isequaln(Q,U.SurgeCandidateRunQC(:,Q.Properties.VariableNames)));
 assert(isequaln(G,U.SurgeGapReview(:,G.Properties.VariableNames)));
 assert(size(Sites,1)==height(U.Table_OxygenSurges_Out));
 for s=1:size(Sites,1),assert(isequal(Sites(s,:),U.Table_OxygenSurges_Out.FramePixels{s}));end
 clear Sites Q G U;
 out=fullfile(outputRoot,session,name);mkdir(out);
 % Candidate input is cached for inexpensive independent follow-up replay.
 save(fullfile(out,'candidate-input.mat'),'C','M','P','-v7.3');
 for policy=["isolated_shape","majority_shape","split_only","segment_contacts"]
  [R,Q,E]=compareSurgeBranchPolicy(C,P,policy);
  if policy=="isolated_shape"
   assert(isequal(R,Expected));assert(isequal(Q.AmbiguousTracking,I.AmbiguousTracking));
   assert(isequal(Q.KeptAsEvent,I.KeptAsEvent));BaseEdges=E;
  else
   assert(isequal(E(:,{'FromFrame','ToFrame','SharedPixels','PreviousPixels','NextPixels'}), ...
    BaseEdges(:,{'FromFrame','ToFrame','SharedPixels','PreviousPixels','NextPixels'})));
  end
  gained=0;lost=0;
  for f=1:M.Frames
   base=vertcat(Expected{I.KeptAsEvent,f});now=vertcat(R{Q.KeptAsEvent,f});
   gained=gained+numel(setdiff(now,base));lost=lost+numel(setdiff(base,now));
  end
  Summary=[Summary;table(session,name,policy,height(Q),sum(Q.KeptAsEvent),sum(Q.AmbiguousTracking & Q.KeptAsEvent), ...
   sum(E.Contact),sum(E.Linked & E.Contact),sum(E.Linked & ~BaseEdges.Linked),sum(~E.Linked & BaseEdges.Linked),gained,lost, ...
   'VariableNames',{'Session','Case','Policy','CandidateRuns','RetainedRuns','AmbiguousRetainedRuns','ContactEdges', ...
   'LinkedContactEdges','AddedLinks','RemovedLinks','GainedRetainedPixelFrames','LostRetainedPixelFrames'})]; %#ok<AGROW>
  for q=reshape(M.EvaluatedTruthRows,1,[])
   truth=cell(1,M.Frames);
   for f=M.Windows(q,1):M.Windows(q,2),truth{f}=find(surgeEvidenceTruthMask(M,2,q,f));end
   volume=sum(cellfun(@numel,truth));best=0;bestID=NaN;start=NaN;finish=NaN;touch=false(1,M.Frames);
   for r=find(Q.KeptAsEvent)'
    intersection=0;rv=0;
    for f=Q.NativeStartFrame(r):Q.NativeEndFrame(r)
     n=numel(intersect(R{r,f},truth{f}));intersection=intersection+n;rv=rv+numel(R{r,f});touch(f)=touch(f)||n>0;
    end
    iou=intersection/(volume+rv-intersection);
    if iou>best,best=iou;bestID=r;start=Q.NativeStartFrame(r);finish=Q.NativeEndFrame(r);end
   end
   Scores=[Scores;table(session,name,policy,q,best,bestID,start,finish,sum(touch), ...
    'VariableNames',{'Session','Case','Policy','TruthRow','BestNativeSpacetimeIoU','BestCandidateRunID','NativeStartFrame','NativeEndFrame','RetainedTruthFrames'})]; %#ok<AGROW>
  end
  writetable(Q,fullfile(out,policy+'-runs.csv'));writetable(E,fullfile(out,policy+'-edges.csv'));
 end
 Provenance=struct('InputRecording',rec,'InputSHA256',oxygenFileSHA256(fullfile(rec,'challenge_original.tif')), ...
  'SourceSHA256',M.SourceSHA256,'SourceProfile',M.SourceProfile,'PipelineContract',oxygenPipelineContract(), ...
  'ProductionMasksAndCandidateLedgersReproduced',true,'AllCandidatePixelsConserved',true,'NoGapFilling',true, ...
  'Parameters',P,'AmplitudeRecomputed',false);
 writeJSON(fullfile(out,'provenance.json'),Provenance);
 writetable(Summary,fullfile(outputRoot,'policy-summary.csv'));writetable(Scores,fullfile(outputRoot,'support-scores.csv'));
 fprintf('COMPLETED BRANCH REPLAY %s %s\n',session,name);
end
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
writeJSON(fullfile(outputRoot,'completion.json'),struct('CompleteMovieReplays',size(specs,1),'SourceRecordings',4, ...
 'Policies',4,'SupportScoreRows',height(Scores),'ProductionSourceUnchanged',true,'CodeFreezeVerified',true, ...
 'ProductionMasksAndCandidateLedgersReproduced',true,'AllCandidatePixelsConserved',true,'NoGapFilling',true, ...
 'Interpretation','Link-policy comparison on reused development recordings. No new master/statistics runs, amplitude recalculation, or biological accuracy estimate.'));
disp(Summary);disp(Scores);
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);clean=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
