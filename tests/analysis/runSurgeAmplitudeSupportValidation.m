function runSurgeAmplitudeSupportValidation(priorRoot,outputRoot)
% Eight frozen master outputs; paired source arithmetic, no new detection runs.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Results=table();OriginalAudit=table();Summary=table();
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2312-baseline-awake","FB2411"]
 for name=["growing_clean","shrinking_clean"]
  rec=fullfile(priorRoot,session,name);out=fullfile(outputRoot,session,name);mkdir(out);
  M=jsondecode(fileread(fullfile(rec,'challenge-manifest.json')));M.Windows=reshape(M.Windows,[],2);
  assert(isequal(M.Windows,[101 160])&&isequal(M.EvaluatedTruthRows,1));
  gf=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));sf=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));
  assert(isscalar(gf)&&isscalar(sf));
  G=load(fullfile(gf.folder,gf.name),'Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out','AnalysisInfo');
  S=load(fullfile(sf.folder,sf.name),'Table_OxygenSinks_Out','AnalysisInfo');assert(isequaln(G.AnalysisInfo,S.AnalysisInfo));
  source=M.SourceTiff;input=fullfile(rec,'challenge_original.tif');
  assert(strcmp(oxygenFileSHA256(source),M.SourceSHA256)&&strcmp(oxygenFileSHA256(input),G.AnalysisInfo.RawSHA256));
  [X,~,~]=loadtiff(source);[Y,~,~]=loadtiff(input);assert(isequal(size(X),size(Y),[M.Height M.Width M.Frames]));
  E=G.Table_OxygenSurgeEvents_Out;sites=G.Table_OxygenSurges_Out;N=M.Frames;
  P=G.AnalysisInfo.AnalysisParams;required=round(P.surgeBaselineWindowSec*P.fs);assert(required==20&&P.fs==1);
  [A,FullTraces]=auditOxygenEventFootprints(sites,E,S.Table_OxygenSinks_Out,Y,required,'surge');assert(all(A.MeasurementMatches));
  A.Session=repmat(session,height(A),1);A.Case=repmat(name,height(A),1);OriginalAudit=[OriginalAudit;A]; %#ok<AGROW>
  matched=readtable(fullfile(priorRoot,'evidence',session,name,'matched-surge-signal-audit.csv'));
  assert(height(matched)==1);bestRow=matched.BestEventRow;
  NativePixels=cell(height(E),N);AllDetectedPixels=cell(1,N);
  for e=1:height(E)
   c=sites.FramePixels{E.SurgeID(e)};native=FullTraces{e}.DetectedFrames;
   assert(isequal(native(:)',E.StartFrame(e):E.EndFrame(e)),'Surge timing is no longer native.');
   NativePixels(e,native)=c(native);
  end
  for f=1:N
   px=[];
   for s=1:height(sites),c=sites.FramePixels{s};px=[px;c{f}(:)];end %#ok<AGROW>
   for s=1:height(S.Table_OxygenSinks_Out),c=S.Table_OxygenSinks_Out.FramePixels{s};px=[px;c{f}(:)];end %#ok<AGROW>
   AllDetectedPixels{f}=unique(px);
  end
  window=M.Windows(1,1):M.Windows(1,2);common=true(M.Height,M.Width);
  for f=window,common=common & surgeEvidenceTruthMask(M,2,1,f);end
  oracle=find(common);assert(~isempty(oracle));
  % Recheck the previous choice using native spacetime overlap, not amplitudes.
  best=0;chosen=0;volume=0;
  for f=window,volume=volume+nnz(surgeEvidenceTruthMask(M,2,1,f));end
  for e=1:height(E)
   shared=0;v=0;
   for f=E.StartFrame(e):E.EndFrame(e)
    px=NativePixels{e,f};v=v+numel(px);truth=surgeEvidenceTruthMask(M,2,1,f);shared=shared+nnz(truth(px));
   end
   iou=shared/(volume+v-shared);if iou>best,best=iou;chosen=e;end
  end
  assert(chosen==bestRow&&abs(best-matched.BestNativeSpacetimeIoU)<1e-12);
  X=reshape(X,[],N);Y=reshape(Y,[],N);nrows=3*height(E)+1;
  Pixels=cell(nrows,1);CleanFrames=cell(nrows,1);XTrace=nan(nrows,N);YTrace=XTrace;PositiveTrace=XTrace;NegativeTrace=XTrace;
  local=table();ridx=0;
  for e=0:height(E)
   thresholds=[0 .5 .75];if e==0,thresholds=NaN;end
   for fraction=thresholds
    ridx=ridx+1;support="full_event";
    if e==0
     px=oracle;event=window;support="recipe_common_core_oracle";pre=max(1,event(1)-required):event(1)-1;
     clean=pre;for f=pre,if any(ismember(px,AllDetectedPixels{f})),clean(clean==f)=[];end,end
     recorded=NaN;isMatch=false;
    else
     event=E.StartFrame(e):E.EndFrame(e);pre=max(1,event(1)-required):event(1)-1;
     px=surgePersistentSupport(NativePixels(e,:),event,fraction);clean=FullTraces{e}.CleanBaselineFrames;
     recorded=E.NormOxySurgeAmp(e);isMatch=e==bestRow;
     if fraction>0,support="persistent_"+string(round(100*fraction));end
    end
    Pixels{ridx}=px;CleanFrames{ridx}=clean;status="available";
    if isempty(px)
     status="empty_support";z=zeros(1,N);R=analyzeSurgeAmplitudeCounterfactual(z,z,z,z,event,pre,clean,window,required);
     fields=fieldnames(R);for j=1:numel(fields),if isnumeric(R.(fields{j})),R.(fields{j})=NaN;end,end
     R.StrictBaselineStatus="empty_support";
    else
     xx=double(X(px,:));delta=double(Y(px,:))-xx;
     XTrace(ridx,:)=mean(xx,1);YTrace(ridx,:)=mean(double(Y(px,:)),1);
     PositiveTrace(ridx,:)=mean(max(delta,0),1);NegativeTrace(ridx,:)=mean(min(delta,0),1);
     R=analyzeSurgeAmplitudeCounterfactual(XTrace(ridx,:),YTrace(ridx,:),PositiveTrace(ridx,:),NegativeTrace(ridx,:),event,pre,clean,window,required);
     if e>0&&fraction==0
      assert(isequal(px,FullTraces{e}.Footprint));
      assert((isnan(recorded)&&isnan(R.StrictMeasuredPeakFraction))||abs(recorded-R.StrictMeasuredPeakFraction)<1e-10);
      assert(R.StrictBaselineStatus==string(E.BaselineStatus(e)));
     end
    end
    R.Session=session;R.Case=name;R.EventRow=e;R.Support=support;R.SupportStatus=status;R.SupportPixels=numel(px);
    R.SupportAreaUm2=numel(px)*P.PixelSize^2;R.OccupancyFraction=fraction;R.IsPreselectedMatch=isMatch;
    R.StartFrame=event(1);R.EndFrame=event(end);R.SharedCleanBaselineFrames=numel(clean);R.StoredFullEventAmplitude=recorded;
    R.EligibleSupportFraction=NaN;if ~isempty(px),R.EligibleSupportFraction=mean(ismember(px,G.AnalysisInfo.SurgeEligibleTissuePixels));end
    R.LocalRow=ridx;local=[local;struct2table(R)]; %#ok<AGROW>
   end
  end
  assert(ridx==nrows);Results=[Results;local]; %#ok<AGROW>
  save(fullfile(out,'audit-inputs.mat'),'Pixels','CleanFrames','NativePixels','AllDetectedPixels','XTrace','YTrace','PositiveTrace','NegativeTrace','-v7.3');
  writetable(local,fullfile(out,'support-results.csv'));
  M.InputTiff=input;M.InputSHA256=G.AnalysisInfo.RawSHA256;M.SavedSurgeMat=fullfile(gf.folder,gf.name);M.SavedSurgeMatSHA256=oxygenFileSHA256(M.SavedSurgeMat);
  M.SavedSinkMat=fullfile(sf.folder,sf.name);M.SavedSinkMatSHA256=oxygenFileSHA256(M.SavedSinkMat);
  M.BaselineFrames=required;M.OccupancyFractions=[0 .5 .75];M.PreselectedEventRow=bestRow;
  M.CurrentPipelineContract=oxygenPipelineContract();M.Scope='Read-only measurement comparison of frozen historical outputs. No contract upgrade or pooling.';
  writeJSON(fullfile(out,'provenance.json'),M);
  Summary=[Summary;table(session,name,height(E),height(local),bestRow,nnz(A.StoredStatus=="valid"),nnz(local.SupportStatus=="empty_support"), ...
   'VariableNames',{'Session','Case','RetainedSurgeEvents','SupportRowsIncludingOracle','PreselectedEventRow','StoredValidAmplitudes','EmptySupports'})]; %#ok<AGROW>
  writetable(Results,fullfile(outputRoot,'support-results.csv'));writetable(OriginalAudit,fullfile(outputRoot,'original-amplitude-audit.csv'));writetable(Summary,fullfile(outputRoot,'case-summary.csv'));
  clear X Y xx delta G S FullTraces;fprintf('COMPLETED AMPLITUDE SUPPORT %s %s\n',session,name);
 end
end
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
writeJSON(fullfile(outputRoot,'completion.json'),struct('SourceRecordings',4,'FrozenMoviesAudited',8, ...
 'RetainedSurgeEventsAudited',height(OriginalAudit),'SupportRowsIncludingOracles',height(Results),'OriginalAmplitudeMismatches',nnz(~OriginalAudit.MeasurementMatches), ...
 'CodeFreezeVerified',true,'NewDetectionRuns',0,'NewMasterStatisticsRuns',0,'ProductionMeasurementChanged',false));
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);clean=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
