function runSurgeSeparationValidation(referenceRoot,outputRoot)
% Development-only local partition: four sources, four imposed cases + control.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Summary=table();Scores=table();
recipes=["separate_pair","approach_pair","crossing_pair","single_expanding"];
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2312-baseline-awake","FB2411"]
 saved=jsondecode(fileread(fullfile(referenceRoot,session,'reference-report.json')));
 source=fullfile(referenceRoot,session,'Recording','archive_original.tif');
 assert(strcmp(oxygenFileSHA256(source),saved.Conversion.TiffSHA256));
 [Raw,~,~]=loadtiff(source);Raw=uint16(Raw);[H,W,N]=size(Raw);
 P=createOxygenMasterParams(saved.Profile.PixelSize,saved.Profile.SampleHz);
 assert(N==saved.Profile.Frames&&P.fs==1&&N>=180);
 O=struct('MinimumHistorySec',3,'MinimumMarkerDistanceUm',2*sqrt(P.surgeMinAreaUm2/pi),'MinimumSaddleDropFraction',.2);
 for name=["source_control" recipes]
  out=fullfile(outputRoot,session,name);mkdir(out);X=Raw;
  if name~="source_control"
   for f=101:180
    increment=surgeSeparationRecipe(H,W,f,P.PixelSize,name);
    plane=double(Raw(:,:,f)).*(1+sum(increment,3));assert(all(plane>=0&plane<=65535,'all'));
    X(:,:,f)=uint16(round(plane));
   end
   input=fullfile(out,'challenge_original.tif');saveastiff(X,input,struct('overwrite',true));
  else
   input=source;
  end
  M=struct('Session',session,'Case',name,'SourceTiff',source,'SourceSHA256',saved.Conversion.TiffSHA256, ...
   'InputTiff',input,'InputSHA256',oxygenFileSHA256(input),'SourceProfile',saved.Profile, ...
   'Height',H,'Width',W,'Frames',N,'Window',[101 180],'RecipeVersion','gaussian-contact-1', ...
   'Options',O,'PipelineContract',oxygenPipelineContract());
  writeJSON(fullfile(out,'challenge-manifest.json'),M);
  X=detrend_custom(double(X),3);
  Area=computeRecordingArea(X,P.PixelSize,P.recAreaBackgroundPercentile, ...
   'recAreaBinHalfSizeUm',P.recAreaBinHalfSizeUm,'recAreaMinCoverageFraction',P.recAreaMinCoverageFraction);
  [~,F]=preprocessDetectionStack(single(X),P.smooth);clear X;
  D=struct('percentileThreshold',P.PercentileSurgeDetectionThres,'minArea',P.ThresholdMinsize_Surges,'maxArea',Inf, ...
   'minCircularity',P.surgeCircularityThreshold,'maxOutsideFraction',P.maxOutsideRecordingAreaFraction,'frameTransform','mat2gray');
  C=detectFrameRegionCandidates(F,Area.Filter,D);
  [Separated,Decisions]=separateSurgeCandidateContacts(C,F,Area.Filter,P,O);clear F Area;
  writetable(Decisions,fullfile(out,'partition-decisions.csv'));
  save(fullfile(out,'candidate-input.mat'),'C','Separated','M','P','O','-v7.3');
  for method=["native","partition"]
   Frames=C;if method=="partition",Frames=Separated;end
   [R,Q,E]=trackSurgeCandidates(Frames,P.ThresholMinddur_Surges,P.surgeTrackingOverlapFraction, ...
    P.surgeTrackingContainmentFraction,P.surgeTrackingMaxAreaRatio);
   % Partition exposure remains explicit even when splitting removes a graph contact.
   Q.PartitionFrameCount=zeros(height(Q),1);
   if method=="partition"
    for f=1:N
     px=[];for c=1:numel(Frames{f}),if Frames{f}(c).PartitionApplied,px=[px;Frames{f}(c).PixelIdxList];end,end %#ok<AGROW>
     if isempty(px),continue;end
     for r=1:height(Q),if ~isempty(R{r,f})&&any(ismember(R{r,f},px)),Q.PartitionFrameCount(r)=Q.PartitionFrameCount(r)+1;end,end
    end
   end
   writetable(Q,fullfile(out,method+'-runs.csv'));writetable(E,fullfile(out,method+'-edges.csv'));
   save(fullfile(out,method+'-runs.mat'),'R','Q','-v7.3');
   Summary=[Summary;table(session,name,method,height(Q),sum(Q.KeptAsEvent),sum(Q.KeptAsEvent&Q.AmbiguousTracking), ...
    sum(Q.KeptAsEvent&Q.PartitionFrameCount>0),sum(Q.PartitionFrameCount(Q.KeptAsEvent)),sum(Decisions.PartitionApplied), ...
    'VariableNames',{'Session','Case','Method','CandidateRuns','RetainedRuns','ContactRetainedRuns', ...
    'PartitionExposedRetainedRuns','PartitionEventFrames','ProposedParentSplits'})]; %#ok<AGROW>
   scoreRecipes=name;if name=="source_control",scoreRecipes=recipes;end
   for recipe=scoreRecipes
    [S,Mass]=scoreRuns(R,Q,Raw,P,recipe);
    S.Session=repmat(session,height(S),1);S.Case=repmat(name,height(S),1);S.Method=repmat(method,height(S),1);S.Recipe=repmat(recipe,height(S),1);
    Scores=[Scores;S];writetable(Mass,fullfile(out,method+'-'+recipe+'-mass.csv')); %#ok<AGROW>
   end
  end
  writetable(Summary,fullfile(outputRoot,'separation-summary.csv'));writetable(Scores,fullfile(outputRoot,'recipe-scores.csv'));
  fprintf('COMPLETED SEPARATION %s %s\n',session,name);
 end
end
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
writeJSON(fullfile(outputRoot,'completion.json'),struct('SourceRecordings',4,'CompleteMovieEvaluations',20, ...
 'NewChallengeMovies',16,'Methods',2,'ScoreRows',height(Scores),'CodeFreezeVerified',true, ...
 'AllCandidatePixelsConserved',true,'ProductionDetectorChanged',false,'MasterStatisticsReruns',0, ...
 'Interpretation','Development-only candidate partition, reused reference sources, descriptive imposed-light coverage, no physiological labels or accuracy claim.'));
end
function [S,Mass]=scoreRuns(R,Q,Raw,P,recipe)
% Assign different retained runs to different imposed sources. Weight by known
% pre-rounding added light, not by arbitrary thresholded truth footprints.
[H,W,~]=size(Raw);K=2;if recipe=="single_expanding",K=1;end
ids=find(Q.KeptAsEvent);mass=zeros(numel(ids),K);total=zeros(1,K);
for f=101:180
 weights=surgeSeparationRecipe(H,W,f,P.PixelSize,recipe).*double(Raw(:,:,f));
 for k=1:K
  plane=weights(:,:,k);total(k)=total(k)+sum(plane,'all');
  for a=1:numel(ids),mass(a,k)=mass(a,k)+sum(plane(R{ids(a),f}));end
 end
end
coverage=mass./total;
% Include two zero-coverage dummy rows so unmatched sources stay unmatched.
padded=[coverage;zeros(2,K)];chosen=zeros(1,K);
if K==1
 [~,chosen(1)]=max(padded(:,1));
else
 objective=padded(:,1)+padded(:,2)';objective(1:size(objective,1)+1:end)=-Inf;
 [~,at]=max(objective(:));[chosen(1),chosen(2)]=ind2sub(size(objective),at);
end
S=table();Mass=table(ids,'VariableNames',{'CandidateRunID'});
for k=1:K
 Mass.('Recipe'+string(k)+'Mass')=mass(:,k);Mass.('Recipe'+string(k)+'Total')=repmat(total(k),numel(ids),1);
 Mass.('Recipe'+string(k)+'Coverage')=coverage(:,k);
 a=chosen(k);id=NaN;v=0;fraction=NaN;start=NaN;finish=NaN;partition=0;contact=false;
 if a<=numel(ids)&&coverage(a,k)>0
  id=ids(a);v=coverage(a,k);fraction=mass(a,k)/sum(mass(a,:));
  start=Q.NativeStartFrame(id);finish=Q.NativeEndFrame(id);partition=Q.PartitionFrameCount(id);contact=Q.AmbiguousTracking(id);
 end
 S=[S;table(k,id,v,fraction,sum(coverage(:,k)),sum(coverage(:,k)>=.1),start,finish,partition,contact, ...
  'VariableNames',{'RecipeSource','AssignedCandidateRunID','RecipeMassCoverage','RecipeContributionFraction', ...
  'AllRetainedRecipeMassCoverage','RunsCoveringAtLeastTenPercent','NativeStartFrame','NativeEndFrame','PartitionFrames','PostPartitionContact'})]; %#ok<AGROW>
end
assert(all(sum(coverage,1)<=1+1e-10));
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);clean=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
