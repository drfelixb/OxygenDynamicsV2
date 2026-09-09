function Results=runKnownSignalPilot(sourceTiff,outputRoot)
% Paired-background stress test of the unchanged existing detector.
% This fixed pilot is ID400 awake only, NOT a labelled accuracy benchmark.
setupOxygenDynamicsPath;
assert(~isfolder(outputRoot),'Use a new output root.');
sourceHash=oxygenFileSHA256(sourceTiff);
assert(strcmp(sourceHash,'695f8390be5fe18d06685d718b7e99c73d08715f51ef11ec14c694b32b599a05'),'Wrong reference TIFF.');
info=imfinfo(sourceTiff);assert(numel(info)==600&&info(1).Width==512&&info(1).Height==512);
mkdir(outputRoot);
X=zeros(256,256,180,'uint16');
for t=1:180
 p=imread(sourceTiff,t);X(:,:,t)=p(129:384,129:384);
end
[y,x]=ndgrid(1:256,1:256);mask=(x-128).^2+(y-128).^2<=18^2;
windows=[61 80;96 115];
Cases=table(["control";"sink05";"sink20";"surge05";"surge20";"global_drop20";"global20_local05"], ...
 [0;-.05;-.2;.05;.2;0;.15],[0;0;0;0;0;-.2;-.2], ...
 'VariableNames',{'Case','LocalAdditiveFraction','GlobalFraction'});
M=struct('SourceTiff',sourceTiff,'SourceSHA256',sourceHash, ...
 'SourceSession','M400-01-baseline-awake','SourceFrames',[1 180],'SourceRows',[129 384], ...
 'SourceColumns',[129 384],'SampleHz',1,'PixelSizeUm',4.75,'CircleCenterXY',[128 128], ...
 'CircleRadiusPixels',18,'WindowsInclusive',windows,'Cases',table2struct(Cases), ...
 'PipelineContract',oxygenPipelineContract(),'MatlabVersion',version, ...
 'Interpretation','Counterfactual injections on an unlabelled recorded background. Cropping and shortening change normalization and trend fitting; not full-recording accuracy. Fractions multiply each original pixel; uint16 rounding is measured. Global20_local05 means -20% outside, -5% inside.');
f=fopen(fullfile(outputRoot,'manifest.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(M,'PrettyPrint',true));fclose(f);
code=createOxygenRegressionCodeManifest(fileparts(fileparts(fileparts(mfilename('fullpath')))));
writetable(code,fullfile(outputRoot,'code-manifest.csv'));
Results=table();
for c=1:height(Cases)
 Y=double(X);active=false(1,180);
 for w=1:size(windows,1),active(windows(w,1):windows(w,2))=true;end
 factor=1+Cases.GlobalFraction(c)+Cases.LocalAdditiveFraction(c)*mask;
 Y(:,:,active)=Y(:,:,active).*factor;
 assert(all(Y(:)>=0&Y(:)<=65535),'Injection would clip.');
 rounding=max(abs(Y(:)-round(Y(:))));Y=uint16(round(Y));
 rec=fullfile(outputRoot,char(Cases.Case(c)));mkdir(rec);
 saveastiff(Y,fullfile(rec,'pilot_original.tif'),struct('overwrite',true));
 C=struct('SFs',1,'PiSz',4.75,'Mous','ID400','Cond','SyntheticPilot','Drug','None', ...
  'Gen','WT','Promo','GFAP.PHP','Puff',NaN,'strOW','Y');
 runOxygenDynamicsMaster(rec,C);
 for kind=["sink" "surge"]
  if kind=="sink"
   files=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));assert(numel(files)==1);
   D=load(fullfile(files.folder,files.name));S=D.Table_OxygenSinks_Out;E=D.Table_OxygenSinkEvents_Out;
   id='SinkID';amp='NormOxySinkAmp';
  else
   files=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));assert(numel(files)==1);
   D=load(fullfile(files.folder,files.name));S=D.Table_OxygenSurges_Out;E=D.Table_OxygenSurgeEvents_Out;
   id='SurgeID';amp='NormOxySurgeAmp';
  end
  for w=1:size(windows,1)
   a=windows(w,1);b=windows(w,2);best=0;bestRow=0;hits=0;bestA=NaN;bestB=NaN;
   truthVolume=nnz(mask)*(b-a+1);
   for e=1:height(E)
    pc=S.FramePixels{E.(id)(e)};runs=regionprops(~cellfun(@isempty,pc),'PixelIdxList');
    frames=runs(E.EventID(e)).PixelIdxList;intersection=0;volume=0;
    for t=reshape(frames,1,[])
     px=pc{t};volume=volume+numel(px);
     if t>=a&&t<=b,intersection=intersection+nnz(mask(px));end
    end
    if intersection>0,hits=hits+1;end
    iou=intersection/(volume+truthVolume-intersection);
    if iou>best,best=iou;bestRow=e;bestA=frames(1);bestB=frames(end);end
   end
   onset=NaN;offset=NaN;amplitude=NaN;resolved=NaN;
   if bestRow>0
    onset=E.StartFrame(bestRow)-a;offset=E.EndFrame(bestRow)-b;amplitude=E.(amp)(bestRow);
    if ismember('TimingResolved',E.Properties.VariableNames),resolved=double(E.TimingResolved(bestRow));end
   end
   raw=double(X(:,:,a:b));changed=double(Y(:,:,a:b));sel=repmat(mask,1,1,b-a+1);
   actual=mean(changed(sel))/mean(raw(sel))-1;
   row=table(Cases.Case(c),kind,w,height(E),hits,best,bestRow,bestA,bestB,onset,offset,amplitude,resolved,actual,rounding, ...
    'VariableNames',{'Case','DetectionSign','Window','TotalDetectedEvents','OverlappingEvents','BestNativeSpacetimeIoU', ...
    'BestEventRow','NativeStartFrame','NativeEndFrame','MeasuredOnsetErrorSec','MeasuredOffsetErrorSec', ...
    'MeasuredAmplitudeFraction','TimingResolved','ActualInjectedLocalFraction','MaxRoundingError'});
   Results=[Results;row]; %#ok<AGROW>
  end
 end
 writetable(Results,fullfile(outputRoot,'pilot-results.csv'));
 close all force;
end
Final=createOxygenRegressionCodeManifest(fileparts(fileparts(fileparts(mfilename('fullpath')))));
assert(isequal(code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})),'Source changed during pilot.');
save(fullfile(outputRoot,'pilot-results.mat'),'Results','M');
disp(Results);
end
