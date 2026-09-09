function T=auditSurgeFootprintContributions(root,priorRoot)
% Post-experiment decomposition of applied increments on matched footprints.
% Positive/negative changes are classified from paired constructed/source pixels;
% they are not a biological sign classifier for natural recordings.
setupOxygenDynamicsPath;T=table();
for category=["evidence","prior-evidence"]
 files=dir(fullfile(root,category,'*','*','matched-surge-signal-audit.csv'));
 for f=1:numel(files)
  [parent,name]=fileparts(files(f).folder);[~,session]=fileparts(parent);
  rec=fullfile(root,session,name);if category=="prior-evidence",rec=fullfile(priorRoot,session,name);end
  Matches=readtable(fullfile(files(f).folder,files(f).name),'TextType','string');Matches=Matches(Matches.BestEventRow>0,:);
  if isempty(Matches),continue;end
  M=jsondecode(fileread(fullfile(rec,'challenge-manifest.json')));
  assert(strcmp(oxygenFileSHA256(M.SourceTiff),M.SourceSHA256));
  [Y,~,~]=loadtiff(fullfile(rec,'challenge_original.tif'));[X,~,~]=loadtiff(M.SourceTiff);
  data=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));assert(isscalar(data));U=load(fullfile(data.folder,data.name));
  E=U.Table_OxygenSurgeEvents_Out;P=U.AnalysisInfo.AnalysisParams;
  xx=reshape(X,[],M.Frames);yy=reshape(Y,[],M.Frames);
  for e=1:height(Matches)
   row=Matches.BestEventRow(e);cells=U.Table_OxygenSurges_Out.FramePixels{E.SurgeID(row)};
   first=E.NativeStartFrame(row);last=E.NativeEndFrame(row);px=unique(vertcat(cells{first:last}));
   source=double(xx(px,:));delta=double(yy(px,:))-source;denom=sum(source,1);denom(denom==0)=NaN;
   positive=sum(max(delta,0),1)./denom;negative=sum(min(delta,0),1)./denom;net=sum(delta,1)./denom;
   assert(all(abs(net-positive-negative)<1e-12|isnan(net)));
   support=Matches.TruthStartFrame(e):Matches.TruthEndFrame(e);pre=max(1,first-round(P.quantBaselineWindowSec*P.fs)):first-1;
   pos=max(positive(support),[],'omitnan');neg=min(negative(support),[],'omitnan');peak=max(net(support),[],'omitnan');
   preDenom=sum(source(:,pre),'all');prePos=sum(max(delta(:,pre),0),'all')/preDenom;preNeg=sum(min(delta(:,pre),0),'all')/preDenom;
   assert(abs(peak-Matches.PeakAppliedChangeOnEventFootprint(e))<1e-12);
   assert(abs(prePos+preNeg-Matches.AppliedChangeInNativePrebaselineFraction(e))<1e-12);
   npos=nnz(any(delta(:,support)>0,2));nneg=nnz(any(delta(:,support)<0,2));
   T=[T;table(category,string(session),string(name),Matches.TruthRow(e),row,numel(px),numel(px)*P.PixelSize^2,npos,nneg, ...
    pos,neg,peak,prePos,preNeg,prePos+preNeg, ...
    'VariableNames',{'EvidenceGroup','Session','Case','TruthRow','BestEventRow','FootprintPixels','FootprintAreaUm2', ...
    'PositiveChangedPixelsDuringSupport','NegativeChangedPixelsDuringSupport','PeakPositiveFraction','MinimumNegativeFraction', ...
    'PeakNetFraction','NativePrePositiveFraction','NativePreNegativeFraction','NativePreNetFraction'})]; %#ok<AGROW>
  end
 end
end
writetable(T,fullfile(root,'footprint-contributions.csv'));
Report=struct('MatchedSurgeRowsDecomposed',height(T),'PositiveAndNegativeSumToNet',true,'SavedCounterfactualDiagnosticsReproduced',true, ...
 'RowsWithNegativeContribution',nnz(T.NegativeChangedPixelsDuringSupport>0),'AuditSourceSHA256',oxygenFileSHA256([mfilename('fullpath') '.m']), ...
 'Interpretation','Applied changes on paired constructed/source pixels only; natural fluctuations are preserved in both movies and subtract out. Positive and negative extrema need not occur in the same frame.');
f=fopen(fullfile(root,'footprint-contribution-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(Report,'PrettyPrint',true));fclose(f);disp(Report);
end
