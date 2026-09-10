function runSurgeFullMovieMeasurement(referenceRoot,outputRoot)
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Inputs=table();Summary=table();
for session=["M400-01-baseline-awake","FB2316-baseline"]
 rp=fullfile(referenceRoot,session,'reference-report.json');source=fullfile(referenceRoot,session,'Recording','archive_original.tif');
 for path=string({rp,source}),Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)),'VariableNames',{'Path','SHA256'})];end %#ok<AGROW>
 saved=jsondecode(fileread(rp));P=saved.Profile;assert(strcmp(oxygenFileSHA256(source),saved.Conversion.TiffSHA256));assert(P.SampleHz==1);
 [X,~,~]=loadtiff(source);[h,w,n]=size(X);assert(n==P.Frames);
 control=fullfile(outputRoot,session,'control');mkdir(control);copyfile(source,fullfile(control,'challenge_original.tif'));
 C=struct('SFs',P.SampleHz,'PiSz',P.PixelSize,'Mous',P.Mouse,'Cond','KnownSignal','Drug','None','Gen',P.Genotype,'Promo',P.Promoter,'Puff',NaN,'strOW','Y');
 timer=tic;runOxygenDynamicsMaster(control,C);controlSeconds=toc(timer);close all force;
 g=dir(fullfile(control,'OxygenSurges_Output','*.mat'));s=dir(fullfile(control,'OxygenSinks_Output','*Urefined*.mat'));
 G=load(fullfile(g.folder,g.name),'AnalysisInfo');S=load(fullfile(s.folder,s.name),'AnalysisInfo');eligible=false(h,w);
 eligible(intersect(G.AnalysisInfo.SurgeEligibleTissuePixels,S.AnalysisInfo.SinkEligibleTissuePixels))=true;
 [Masks,Fractions,Recipe]=createSurgeMovieRecipe(eligible,P.PixelSize,n);
 for name=["control","challenge"]
  rec=fullfile(outputRoot,session,name);seconds=controlSeconds;maxRound=0;
  if name=="challenge"
   mkdir(rec);Y=uint16(X);
   for f=1:n
    factor=ones(h,w);for q=1:6,factor(Masks(:,:,q))=factor(Masks(:,:,q))+Fractions(q,f);end
    plane=double(X(:,:,f)).*factor;assert(all(plane>=0&plane<=65535,'all'),'Synthetic input clips.');
    maxRound=max(maxRound,max(abs(plane-round(plane)),[],'all'));Y(:,:,f)=uint16(round(plane));
   end
   saveastiff(Y,fullfile(rec,'challenge_original.tif'),struct('overwrite',true));clear Y;
  end
  M=struct('SourceProfile',P,'SourceSHA256',saved.Conversion.TiffSHA256,'Case',name,'Recipe',Recipe,'MaxRoundingError',maxRound, ...
   'PipelineContract',oxygenPipelineContract(),'Placement','Control eligible tissue only; no challenge detections used.');
  f=fopen(fullfile(rec,'challenge-manifest.json'),'w');fprintf(f,'%s\n',jsonencode(M,'PrettyPrint',true));fclose(f);
  if name=="challenge",timer=tic;runOxygenDynamicsMaster(rec,C);seconds=toc(timer);close all force;end
  A=auditOxygenEventAmplitudeSource(rec);assert(all(A.MeasurementMatches));
  writetable(A,fullfile(rec,'production-amplitude-audit.csv'));
  R=auditSurgeFullMovieMeasurement(rec,source,Masks,Fractions,M,fullfile(rec,'candidate-measurement'));
  Summary=[Summary;table(session,name,R.SurgeEvents,R.SurgeSites,R.SinkEvents,R.SinkSites,seconds, ...
   'VariableNames',{'Session','Case','SurgeEvents','SurgeSites','SinkEvents','SinkSites','MasterRuntimeSec'})]; %#ok<AGROW>
  writetable(Summary,fullfile(outputRoot,'recording-summary.csv'));fprintf('COMPLETED FULL MOVIE %s %s\n',session,name);
 end
end
writetable(Inputs,fullfile(outputRoot,'input-manifest.csv'));
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
R=struct('SourceRecordings',2,'FullMasterRuns',4,'CandidateMeasurementRuns',4,'ComponentsPerMovie',6,'CodeAndInputFreezeVerified',true,'ProductionChanged',false);
f=fopen(fullfile(outputRoot,'completion.json'),'w');fprintf(f,'%s\n',jsonencode(R,'PrettyPrint',true));fclose(f);
end
