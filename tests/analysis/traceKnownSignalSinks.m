function Summary=traceKnownSignalSinks(pilotRoot,caseName,outputRoot)
% Reconstruct production sink stages and verify exact final saved geometry.
setupOxygenDynamicsPath;
assert(~isfolder(outputRoot),'Use a fresh trace output folder.');mkdir(outputRoot);
M=jsondecode(fileread(fullfile(pilotRoot,'manifest.json')));
assert(isequaln(M.PipelineContract,oxygenPipelineContract()),'Trace requires current-contract outputs.');
rec=fullfile(pilotRoot,caseName);[P,~]=createOxygenMasterParams(M.PixelSizeUm,M.SampleHz);
[Input,~]=loadOxygenMasterInputs(rec,P);
assert(isempty(Input.IM_NoNoise),'Pilot must use original input only.');
X=detrend_custom(Input.IM_Raw,3);
Area=computeRecordingArea(X,M.PixelSizeUm,P.recAreaBackgroundPercentile, ...
 'recAreaBinHalfSizeUm',P.recAreaBinHalfSizeUm,'recAreaMinCoverageFraction',P.recAreaMinCoverageFraction);
[Z,F]=preprocessDetectionStack(single(X),P.smooth);clear X Input;
border=P.Pixel_frame;frameSize=[size(Z,1) size(Z,2)];N=size(Z,3);
[y,x]=ndgrid(1:frameSize(1),1:frameSize(2));mask=(x-M.CircleCenterXY(1)).^2+(y-M.CircleCenterXY(2)).^2<=M.CircleRadiusPixels^2;
mask=mask(border+1:end-border,border+1:end-border);
clip=F(border+1:end-border,border+1:end-border,:);support=Area.Filter(border+1:end-border,border+1:end-border);
A=struct('percentileThreshold',P.PercentileDetectionThres,'minArea',P.ThresholdMinsize, ...
 'maxArea',P.ThresholdMaxsize,'minCircularity',P.CircularityThres,'maxOutsideFraction',P.maxOutsideRecordingAreaFraction,'frameTransform','invert');
Candidates=detectFrameRegionCandidates(clip,support,A);
% Threshold-only masks separate percentile selection from shape/tissue rejection.
threshold=cell(1,N);accepted=cell(1,N);
for t=1:N
 im=imcomplement(clip(:,:,t));threshold{t}=find(im>prctile(im(:),P.PercentileDetectionThres));
 if ~isempty(Candidates{t}),accepted{t}=vertcat(Candidates{t}.PixelIdxList);end
end
clear clip;
Summary=[summarize(threshold,"percentile",mask,M);summarize(accepted,"candidate_geometry_tissue",mask,M)];
Tracked=trackSinkCandidates(Candidates,P.ThresholMinddur,.6);clear Candidates;
Summary=[Summary;summarize(Tracked,"tracking",mask,M)];
[Tracked,Logical]=filterSinkRunsByDuration(Tracked,P.ThresholMinddur,P.ThresholMaxddur);
Summary=[Summary;summarize(Tracked,"duration_filter_retain_close",mask,M)];
for pass=1:3
 [~,trace]=extractSinkTraces(Tracked,Logical,Z,F,[],border);
 trace=detrend_custom(trace,2);
 [Tracked,Logical]=refineSinkRegionsByTraceCorrelation(Tracked,Logical,trace,P.sinkTraceCorrelationThreshold,P.sinkNoiseCorrelationPercentile,.7);
 Summary=[Summary;summarize(Tracked,"correlation_"+pass,mask,M)]; %#ok<AGROW>
end
f=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));assert(numel(f)==1);
Saved=load(fullfile(f.folder,f.name),'Table_OxygenSinks_Out');sites=Saved.Table_OxygenSinks_Out;
assert(height(sites)==size(Tracked,1),'Reconstructed site count differs.');
for s=1:height(sites)
 pc=sites.FramePixels{s};
 for t=1:N
  [yy,xx]=ind2sub(frameSize-2*border,Tracked{s,t});
  px=sub2ind(frameSize,yy+border,xx+border);
  assert(isequal(sort(px(:)),sort(pc{t}(:))),'Reconstructed masks differ from production.');
 end
end
writetable(Summary,fullfile(outputRoot,'sink-stage-trace.csv'));
Report=struct('Case',caseName,'SourcePilot',pilotRoot,'InputSHA256',oxygenFileSHA256(fullfile(rec,'pilot_original.tif')), ...
 'FinalSavedMasksExactlyMatch',true,'AnalysisParams',P);
f=fopen(fullfile(outputRoot,'trace-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(Report,'PrettyPrint',true));fclose(f);
writetable(createOxygenRegressionCodeManifest(),fullfile(outputRoot,'code-manifest.csv'));
disp(Summary);
end
function S=summarize(pixels,stage,mask,M)
S=table();
for w=1:size(M.WindowsInclusive,1)
 a=M.WindowsInclusive(w,1);b=M.WindowsInclusive(w,2);counts=zeros(1,b-a+1);hits=0;bounds="";
 for s=1:size(pixels,1)
  active=find(~cellfun(@isempty,pixels(s,:)));
  if isempty(active),continue;end
  starts=active([true diff(active)>1]);ends=active([diff(active)>1 true]);
  for k=1:numel(starts)
   overlap=0;
   for t=max(a,starts(k)):min(b,ends(k))
    overlap=overlap+nnz(mask(pixels{s,t}));
   end
   if overlap>0,hits=hits+1;bounds=bounds+sprintf('%d:%d-%d;',s,starts(k),ends(k));end
  end
 end
 for t=a:b
  px=unique(vertcat(pixels{:,t}));counts(t-a+1)=nnz(mask(px));
 end
 S=[S;table(stage,w,nnz(counts),sum(counts)/(nnz(mask)*(b-a+1)),hits,bounds, ...
  'VariableNames',{'Stage','Window','FramesWithIntersection','InjectedVolumeCoverage','IntersectingRuns','RowAndNativeBounds'})]; %#ok<AGROW>
end
end
