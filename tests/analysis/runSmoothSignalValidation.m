function Results=runSmoothSignalValidation(referenceRoot,outputRoot)
% Full-input, paired-background challenges; no natural-event accuracy labels.
setupOxygenDynamicsPath;
assert(~isfolder(outputRoot),'Use a new validation root.');mkdir(outputRoot);
Sessions=["M400-01-baseline-awake","M401-01-baseline-awake","FB2411"];
Cases=["control","smooth_pairs","single_clean","single_noise"];
Windows=[41 60;66 85;111 130;146 165;196 215;246 265;101 160];
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Results=table();QCAll=table();Audits=table();
for r=1:numel(Sessions)
 saved=jsondecode(fileread(fullfile(referenceRoot,Sessions(r),'reference-report.json')));P=saved.Profile;
 source=fullfile(referenceRoot,Sessions(r),'Recording','archive_original.tif');
 assert(strcmp(oxygenFileSHA256(source),saved.Conversion.TiffSHA256),'Source checksum differs.');
 assert(P.SampleHz==1&&P.Frames>=265,'Fixed challenge windows require 1 Hz and >=265 frames.');
 [X,~,~]=loadtiff(source);X=uint16(X);[H,W,N]=size(X);
 assert(N==P.Frames);[yy,xx]=ndgrid(1:H,1:W);
 centers=[round(.33*W) round(.5*H);round(.67*W) round(.5*H)];radius=85.5/P.PixelSize;
 masks=false(H,W,2);
 for k=1:2,masks(:,:,k)=(xx-centers(k,1)).^2+(yy-centers(k,2)).^2<=radius^2;end
 assert(~any(masks(:,:,1)&masks(:,:,2),'all'));
 rng(90209+r);noise=.08*randn(2,N); % Correlated within a patch, independent across signs/time.
 for ci=1:numel(Cases)
  name=Cases(ci);fraction=zeros(2,N);truth=1:7;
  if name=="smooth_pairs",truth=1:6;elseif name~="control",truth=7;end
  if name~="control"
   for k=1:2
    polarity=2*k-3;
    for q=truth
     t=Windows(q,1):Windows(q,2);pulse=sin(pi*(1:numel(t))/(numel(t)+1)).^2;
     fraction(k,t)=polarity*.2*pulse;
     if name=="single_noise",fraction(k,t)=fraction(k,t)+noise(k,t);end
    end
   end
  end
  rec=fullfile(outputRoot,Sessions(r),name);mkdir(rec);
  % Promote the synthetic TIFF container to uint16 without changing source values.
  Y=X;maxRound=0;
  for t=1:N
   plane=double(X(:,:,t));factor=ones(H,W);
   for k=1:2,factor(masks(:,:,k))=1+fraction(k,t);end
   plane=plane.*factor;assert(all(plane(:)>=0&plane(:)<=65535),'Synthetic input would clip.');
   maxRound=max(maxRound,max(abs(plane(:)-round(plane(:)))));Y(:,:,t)=uint16(round(plane));
  end
  saveastiff(Y,fullfile(rec,'challenge_original.tif'),struct('overwrite',true));clear Y;
  M=struct('SourceTiff',source,'SourceSHA256',saved.Conversion.TiffSHA256,'SourceProfile',P, ...
   'Case',char(name),'Frames',N,'Height',H,'Width',W,'CentersXY',centers,'RadiusUm',85.5, ...
   'RadiusPixels',radius,'SampleHz',P.SampleHz,'Windows',Windows,'EvaluatedTruthRows',truth, ...
   'FractionBySignAndFrame',fraction,'PeakLatentFraction',.2,'NoiseFractionSD',.08, ...
   'NoiseSeed',90209+r,'MaxRoundingError',maxRound,'PipelineContract',oxygenPipelineContract(), ...
   'Interpretation','Both signs injected at separate fixed sites. Control has no injections. Single-noise adds temporally independent, within-patch correlated Gaussian intensity perturbations to the latent pulse; not a photon-noise model.');
  fid=fopen(fullfile(rec,'challenge-manifest.json'),'w');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(M,'PrettyPrint',true));fclose(fid);
  C=struct('SFs',P.SampleHz,'PiSz',P.PixelSize,'Mous',P.Mouse,'Cond','KnownSignal', ...
   'Drug','None','Gen',P.Genotype,'Promo',P.Promoter,'Puff',NaN,'strOW','Y');
  runOxygenDynamicsMaster(rec,C);
  f=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));assert(numel(f)==1);S=load(fullfile(f.folder,f.name));
  f=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));assert(numel(f)==1);U=load(fullfile(f.folder,f.name));
  A=auditOxygenEventAmplitudeSource(rec);assert(all(A.MeasurementMatches),'Independent amplitude audit failed.');
  A.Session=repmat(Sessions(r),height(A),1);A.Case=repmat(name,height(A),1);A.Role=repmat(string(P.Role),height(A),1);Audits=[Audits;A]; %#ok<AGROW>
  Q=createOxygenMeasurementQC(table(string(S.AnalysisInfo.RecordingID),'VariableNames',{'RecordingID'}), ...
   S.Table_OxygenSinkEvents_Out,U.Table_OxygenSurgeEvents_Out);
  Q.Session=repmat(Sessions(r),height(Q),1);Q.Case=repmat(name,height(Q),1);Q.Role=repmat(string(P.Role),height(Q),1);QCAll=[QCAll;Q]; %#ok<AGROW>
  for k=1:2
   kind="sink";sites=S.Table_OxygenSinks_Out;E=S.Table_OxygenSinkEvents_Out;id='SinkID';amp='NormOxySinkAmp';
   if k==2,kind="surge";sites=U.Table_OxygenSurges_Out;E=U.Table_OxygenSurgeEvents_Out;id='SurgeID';amp='NormOxySurgeAmp';end
   assert(~ismember('SiteTraceAmplitude',E.Properties.VariableNames));
   mask=masks(:,:,k);
   for q=truth
    a=Windows(q,1);b=Windows(q,2);best=0;row=0;hits=0;nativeA=NaN;nativeB=NaN;
    for e=1:height(E)
     pc=sites.FramePixels{E.(id)(e)};runs=regionprops(~cellfun(@isempty,pc),'PixelIdxList');frames=runs(E.EventID(e)).PixelIdxList;
     intersection=0;volume=0;
     for t=reshape(frames,1,[])
      volume=volume+numel(pc{t});if t>=a&&t<=b,intersection=intersection+nnz(mask(pc{t}));end
     end
     hits=hits+(intersection>0);iou=intersection/(volume+nnz(mask)*(b-a+1)-intersection);
     if iou>best,best=iou;row=e;nativeA=frames(1);nativeB=frames(end);end
    end
    onset=NaN;offset=NaN;amplitude=NaN;flag=NaN;status="no_intersection";resolved=NaN;
    if row>0
     onset=E.StartFrame(row)-a;offset=E.EndFrame(row)-b;amplitude=E.(amp)(row);flag=double(E.CloseNativeRun(row));status=string(E.BaselineStatus(row));
     if ismember('TimingResolved',E.Properties.VariableNames),resolved=double(E.TimingResolved(row));end
    end
    R=table(Sessions(r),string(P.Role),name,kind,q,a,b,hits,best,row,nativeA,nativeB,onset,offset,amplitude,flag,status,resolved, ...
     'VariableNames',{'Session','Role','Case','EventType','TruthRow','TruthStartFrame','TruthEndFrame','OverlappingRuns','BestNativeSpacetimeIoU','BestEventRow', ...
     'NativeStartFrame','NativeEndFrame','MeasuredOnsetErrorSec','MeasuredOffsetErrorSec','MeasuredAmplitudeFraction','CloseNativeRun','BaselineStatus','TimingResolved'});
    Results=[Results;R]; %#ok<AGROW>
   end
  end
  writetable(Results,fullfile(outputRoot,'smooth-signal-results.csv'));writetable(QCAll,fullfile(outputRoot,'recording-qc.csv'));
  writetable(Audits,fullfile(outputRoot,'independent-amplitude-audit.csv'));
  close all force;fprintf('COMPLETED %s %s: %d amplitudes audited\n',Sessions(r),name,height(A));
 end
end
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})),'MATLAB source changed during validation.');
save(fullfile(outputRoot,'smooth-validation.mat'),'Results','QCAll','Audits');
end
