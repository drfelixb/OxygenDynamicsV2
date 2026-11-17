function Summary=sweepLocalSinkTiming(referenceRoot,outputRoot)
% Fixed-trace sensitivity diagnostic; no saved analysis is overwritten.
P=jsondecode(fileread(fullfile(referenceRoot,'reference-set-profile.json')));
if ~isfolder(outputRoot),mkdir(outputRoot);end
Summary=table();Default=table();Details=table();
for i=1:numel(P.Records)
 R=P.Records(i);f=dir(fullfile(referenceRoot,R.Session,'Recording','OxygenSinks_Output','OxygenSinks_Urefined*.mat'));
 S=load(fullfile(f.folder,f.name));sites=S.Table_OxygenSinks_Out;E=S.Table_OxygenSinkEvents_Out;N=S.AnalysisInfo.NFrames;fs=R.SampleHz;
 for seconds=[5 10 20 40]
  rows=struct([]);idx=0;
  for s=1:height(sites)
   x=S.Mean_OxySink_Trace_Convo(s,:);[p,~,mu]=polyfit(1:N,x,7);trend=polyval(p,1:N,[],mu);
   c=sites.FramePixels{s};runs=regionprops(~cellfun(@isempty,c),'PixelIdxList');
   for k=1:numel(runs)
    native=runs(k).PixelIdxList;lo=1;hi=N;
    if k>1,lo=floor((runs(k-1).PixelIdxList(end)+native(1))/2)+1;end
    if k<numel(runs),hi=floor((native(end)+runs(k+1).PixelIdxList(1))/2);end
    T=resolveSinkEventTiming(native,x,trend,S.AnalysisInfo.AnalysisParams.eventBaselineReturnTolerance,floor(seconds*fs),lo,hi);
    T.SiteID=s;T.EventID=k;idx=idx+1;
    if idx==1,rows=T;else,rows(idx,1)=T;end
   end
  end
  A=struct2table(rows);assert(height(A)==height(E));
  assert(all(A.StartFrame<=A.NativeStartFrame&A.EndFrame>=A.NativeEndFrame));
  assert(all(A.NativeStartFrame-A.StartFrame<=floor(seconds*fs))&&all(A.EndFrame-A.NativeEndFrame<=floor(seconds*fs)));
  for s=reshape(unique(A.SiteID),1,[])
   B=sortrows(A(A.SiteID==s,:),'NativeStartFrame');assert(all(B.EndFrame(1:end-1)<B.StartFrame(2:end)));
  end
  A.Session=repmat(string(R.Session),height(A),1);A.SearchLimitSec=repmat(seconds,height(A),1);
  Details=[Details;A]; %#ok<AGROW>
  row=table(string(R.Session),string(R.Role),seconds,height(A),sum(A.TimingResolved),sum(~A.TimingResolved), ...
   sum(A.StartFrame<A.NativeStartFrame),sum(A.EndFrame>A.NativeEndFrame), ...
   sum(A.StartBoundaryStatus=="search_limit_unresolved"),sum(A.EndBoundaryStatus=="search_limit_unresolved"), ...
   sum(A.NativeTraceCrossesReturnLevel), ...
   'VariableNames',{'Session','Role','SearchLimitSec','SinkEvents','TimingResolved','TimingUnresolved', ...
   'StartsExtended','EndsExtended','StartsSearchLimited','EndsSearchLimited','MixedOrInvalidNativeTrace'});
  Summary=[Summary;row]; %#ok<AGROW>
  if seconds==20,Default=[Default;A];end %#ok<AGROW>
 end
end
writetable(Summary,fullfile(outputRoot,'search-limit-sensitivity.csv'));
writetable(Details,fullfile(outputRoot,'search-limit-event-details.csv'));
writetable(Default,fullfile(outputRoot,'default-timing-prediction.csv'));
disp(Summary);
end
