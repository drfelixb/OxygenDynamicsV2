function runSurgeShapeEvidenceValidation(referenceRoot,priorRoot,outputRoot)
% Full-image expansion/contraction, fixed before inspecting recovery scores.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
% The preceding controls are reusable only if all production MATLAB files match.
Old=readtable(fullfile(priorRoot,'code-manifest.csv'),'TextType','string');
for j=1:height(Old)
 if startsWith(Old.RelativePath(j),'tests/'),continue;end
 assert(strcmp(oxygenFileSHA256(Old.RelativePath(j)),Old.SHA256(j)),'Production code differs from source control runs.');
end
Results=table();Audits=table();QC=table();
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2411","FB2312-baseline-awake"]
 saved=jsondecode(fileread(fullfile(referenceRoot,session,'reference-report.json')));P=saved.Profile;
 source=fullfile(referenceRoot,session,'Recording','archive_original.tif');assert(strcmp(oxygenFileSHA256(source),saved.Conversion.TiffSHA256));
 [X,~,~]=loadtiff(source);X=uint16(X);[H,W,N]=size(X);assert(N==P.Frames&&P.SampleHz==1&&N>=160);
 [yy,xx]=ndgrid(1:H,1:W);centers=[round(.33*W) round(.5*H);round(.67*W) round(.5*H)];
 for name=["growing_clean","shrinking_clean"]
  radii=60*ones(1,N);radii(101:160)=linspace(60,120,60);if name=="shrinking_clean",radii(101:160)=linspace(120,60,60);end
  fractions=zeros(2,N);fractions(:,101:160)=[-1;1]*(.2*sin(pi*(1:60)/61).^2);Y=X;
  assert(all(centers(:,1)-120/P.PixelSize>=1&centers(:,1)+120/P.PixelSize<=W));
  assert(all(centers(:,2)-120/P.PixelSize>=1&centers(:,2)+120/P.PixelSize<=H));
  for t=101:160
   factor=ones(H,W);occupied=false(H,W);
   for k=1:2
    mask=(xx-centers(k,1)).^2+(yy-centers(k,2)).^2<=(radii(t)/P.PixelSize)^2;
    assert(~any(occupied&mask,'all'));occupied=occupied|mask;factor(mask)=1+fractions(k,t);
   end
   plane=double(X(:,:,t)).*factor;assert(all(plane>=0&plane<=65535,'all'));Y(:,:,t)=uint16(round(plane));
  end
  rec=fullfile(outputRoot,session,name);mkdir(rec);saveastiff(Y,fullfile(rec,'challenge_original.tif'),struct('overwrite',true));clear Y;
  M=struct('SourceTiff',source,'SourceSHA256',saved.Conversion.TiffSHA256,'SourceProfile',P,'Case',char(name),'Frames',N, ...
   'Height',H,'Width',W,'CentersXY',centers,'RadiusUmByFrame',radii,'SampleHz',1,'Windows',[101 160],'EvaluatedTruthRows',1, ...
   'FractionBySignAndFrame',fractions,'PipelineContract',oxygenPipelineContract(), ...
   'Interpretation','Separate sink and surge patches; radius changes linearly between 60 and 120 um over 60 frames. Local intensity changes follow +/-0.2*sin(pi*j/61)^2. These prescribed signals are not physiological labels.');
  f=fopen(fullfile(rec,'challenge-manifest.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(M,'PrettyPrint',true));fclose(f);
  Config=struct('SFs',P.SampleHz,'PiSz',P.PixelSize,'Mous',P.Mouse,'Cond','KnownSignal','Drug','None','Gen',P.Genotype,'Promo',P.Promoter,'Puff',NaN,'strOW','Y');
  runOxygenDynamicsMaster(rec,Config);
  A=auditOxygenEventAmplitudeSource(rec);assert(all(A.MeasurementMatches));A.Session=repmat(session,height(A),1);A.Case=repmat(name,height(A),1);Audits=[Audits;A]; %#ok<AGROW>
  R=scoreSurgeShapeSupport(rec,M,name);Control=scoreSurgeShapeSupport(fullfile(priorRoot,session,'control'),M,"control_for_"+name);Results=[Results;R;Control]; %#ok<AGROW>
  sf=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));uf=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));S=load(fullfile(sf.folder,sf.name));U=load(fullfile(uf.folder,uf.name));
  Q=createOxygenMeasurementQC(table(string(S.AnalysisInfo.RecordingID),'VariableNames',{'RecordingID'}),S.Table_OxygenSinkEvents_Out,U.Table_OxygenSurgeEvents_Out);
  Q.Session=repmat(session,height(Q),1);Q.Case=repmat(name,height(Q),1);QC=[QC;Q]; %#ok<AGROW>
  auditSurgeCandidateEvidence(rec,fullfile(outputRoot,'evidence',session,name));
  writetable(Results,fullfile(outputRoot,'shape-support-results.csv'));writetable(Audits,fullfile(outputRoot,'independent-amplitude-audit.csv'));writetable(QC,fullfile(outputRoot,'recording-qc.csv'));
  close all force;fprintf('COMPLETED SHAPE %s %s\n',session,name);
 end
end
for spec={ {'M400-01-baseline-awake','smooth_pairs'}, {'M401-01-baseline-awake','smooth_pairs'}, {'M400-01-baseline-awake','moving_clean'} }
 pair=spec{1};auditSurgeCandidateEvidence(fullfile(priorRoot,pair{1},pair{2}),fullfile(outputRoot,'prior-evidence',pair{1},pair{2}));
end
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})),'MATLAB source changed during validation.');
f=fopen(fullfile(outputRoot,'completion.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(struct('NewFullMovieRuns',8,'SourceRecordings',4,'PriorControlsRescored',4,'PriorCasesTraced',3,'ProductionSourceUnchanged',true,'CodeFreezeVerified',true),'PrettyPrint',true));fclose(f);
end
