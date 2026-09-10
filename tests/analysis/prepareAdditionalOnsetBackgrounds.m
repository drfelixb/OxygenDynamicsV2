function B=prepareAdditionalOnsetBackgrounds(referenceRoot,outputRoot)
% Read historical supports; keep their contract and raw TIFF provenance explicit.
assert(~isfolder(outputRoot));mkdir(outputRoot);B=table();
for session=["ID13-20200917","FB2316-baseline"]
 src=fullfile(referenceRoot,session);out=fullfile(outputRoot,session);mkdir(out);
 gf=fullfile(src,'Recording','OxygenSurges_Output','OxygenSurgesRecording.mat');
 sf=fullfile(src,'Recording','OxygenSinks_Output','OxygenSinks_UrefinedRecording.mat');
 rf=fullfile(src,'reference-report.json');M=jsondecode(fileread(rf));
 G=load(gf,'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
 S=load(sf,'AnalysisInfo','Table_OxygenSinks_Out');assert(isequaln(G.AnalysisInfo,S.AnalysisInfo));
 raw=G.AnalysisInfo.RawFile;assert(strcmp(oxygenFileSHA256(raw),G.AnalysisInfo.RawSHA256));
 assert(strcmp(G.AnalysisInfo.RawSHA256,M.Conversion.TiffSHA256));assert(M.SampleHz==1&&G.AnalysisInfo.AnalysisParams.fs==1);
 [X,~,~]=loadtiff(raw);N=size(X,3);assert(N==M.Frames);heightPx=size(X,1);widthPx=size(X,2);X=reshape(X,[],N);
 E=G.Table_OxygenSurgeEvents_Out;sites=G.Table_OxygenSurges_Out;
 Pixels=cell(height(E),1);NativePixels=cell(height(E),N);AllDetectedPixels=cell(1,N);XTrace=zeros(height(E),N);
 for f=1:N
  px=[];
  for s=1:height(sites),c=sites.FramePixels{s};px=[px;c{f}(:)];end %#ok<AGROW>
  for s=1:height(S.Table_OxygenSinks_Out),c=S.Table_OxygenSinks_Out.FramePixels{s};px=[px;c{f}(:)];end %#ok<AGROW>
  AllDetectedPixels{f}=unique(px);
 end
 cache=string(fullfile(out,'background-inputs.mat'));local=table();
 for e=1:height(E)
  c=sites.FramePixels{E.SurgeID(e)};native=E.StartFrame(e):E.EndFrame(e);
  assert(all(~cellfun(@isempty,c(native))));Pixels{e}=unique(vertcat(c{native}));NativePixels(e,native)=c(native);
  XTrace(e,:)=mean(double(X(Pixels{e},:)),1);
  local=[local;table(session,e,e,cache,E.StartFrame(e),E.EndFrame(e),N,"additional", ...
   'VariableNames',{'Session','EventRow','LocalRow','CachePath','NativeStartFrame','NativeEndFrame','Frames','Cohort'})]; %#ok<AGROW>
 end
 save(cache,'XTrace','Pixels','NativePixels','AllDetectedPixels','-v7.3');writetable(local,fullfile(out,'backgrounds.csv'));
 Provenance=struct('Session',session,'SourceTiff',raw,'SourceSHA256',G.AnalysisInfo.RawSHA256, ...
  'SurgeMat',gf,'SurgeMatSHA256',oxygenFileSHA256(gf),'SinkMat',sf,'SinkMatSHA256',oxygenFileSHA256(sf), ...
  'ReferenceReport',rf,'ReferenceReportSHA256',oxygenFileSHA256(rf),'HistoricalContract',G.AnalysisInfo.PipelineContract, ...
  'ArchiveProfile',M.Profile,'Height',heightPx,'Width',widthPx,'Frames',N,'SampleHz',1,'EventSupports',height(E), ...
  'Scope','Historical native supports on original raw source; no detector rerun or contract upgrade.');
 f=fopen(fullfile(out,'provenance.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(Provenance,'PrettyPrint',true));fclose(f);
 B=[B;local];clear X G S;fprintf('EXTRACTED ADDITIONAL BACKGROUND %s: %d event supports\n',session,height(E)); %#ok<AGROW>
end
end
