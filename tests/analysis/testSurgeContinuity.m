function tests=testSurgeContinuity
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testIsolatedExpansionAndContractionRetainRun(t)
F=cell(30,1);
for f=1:30,F{f}=struct('PixelIdxList',(1:(400+400*mod(f,2)))');end
[R,I]=trackSurgeCandidates(F,10,.6,.8,2);
verifySize(t,R,[1 30]);verifyEqual(t,I.ShapeChangeLinkCount,29);verifyEqual(t,I.MinimumMatchedMutualCoverage,.5);
verifyEqual(t,I.MaximumMatchedAreaRatio,2);verifyFalse(t,I.AmbiguousTracking);
verifyEqual(t,I.ShapeChangeLinkFrames,strjoin(string(2:30),';'));
end
function testAbruptOversizeJumpDoesNotLink(t)
F={struct('PixelIdxList',(1:400)');struct('PixelIdxList',(1:801)')};
[R,I]=trackSurgeCandidates(F,1,.6,.8,2);verifySize(t,R,[2 2]);verifyEqual(t,I.ShapeChangeLinkCount,[0;0]);
end
function testPartialContainmentDoesNotLink(t)
F={struct('PixelIdxList',(1:400)');struct('PixelIdxList',(82:881)')};
[R,~]=trackSurgeCandidates(F,1,.6,.8,2);verifySize(t,R,[2 2]);
end
function testNeighborBlocksExpansion(t)
F={struct('PixelIdxList',{(1:400)',(401:800)'});struct('PixelIdxList',(1:800)')};
[R,I]=trackSurgeCandidates(F,1,.6,.8,2);
verifySize(t,R,[3 2]);verifyTrue(t,all(I.AmbiguousTracking));verifyEqual(t,sum(I.ShapeChangeLinkCount),0);
for f=1:2,verifyEqual(t,sort(vertcat(R{:,f})),(1:800)');end
end
function testNeighborBlocksContraction(t)
F={struct('PixelIdxList',(1:800)');struct('PixelIdxList',{(1:400)',(401:800)'})};
[R,I]=trackSurgeCandidates(F,1,.6,.8,2);
verifySize(t,R,[3 2]);verifyEqual(t,sum(I.ShapeChangeLinkCount),0);verifyTrue(t,all(I.AmbiguousTracking));
end
function testEvenSmallCompetingContactBlocksFallback(t)
F={struct('PixelIdxList',{(1:400)',[800;(1000:1398)']});struct('PixelIdxList',(1:800)')};
[R,I]=trackSurgeCandidates(F,1,.6,.8,2);verifySize(t,R,[3 2]);verifyEqual(t,sum(I.ShapeChangeLinkCount),0);
end
function testGapDoesNotFillOrQualifyTwoShortPieces(t)
P=createOxygenMasterParams(4.75,1);F=cell(13,1);
for f=[1:6 8:13],F{f}=struct('PixelIdxList',(1:400)');end
[S,L,~,Q,G]=buildTrackedOxygenSurgeSites(F,P);
verifySize(t,S,[0 13]);verifyEqual(t,countTrackedEvents(L),0);verifyEqual(t,Q.DurationFrames,[6;6]);
verifyFalse(t,any(Q.KeptAsEvent));verifyTrue(t,all(Q.PotentialGapContinuation));verifyEqual(t,G.GapFrames,1);
verifyTrue(t,all(isnan(Q.EventID)));verifyEqual(t,Q.RejectionReason,repmat("below_minimum_contiguous_duration",2,1));
end
function testSameMasksCannotDistinguishDropoutFromRecurrence(t)
P=createOxygenMasterParams(4.75,1);F=cell(21,1);
for f=[1:10 12:21],F{f}=struct('PixelIdxList',(1:400)');end
% These masks are compatible with a measurement dropout OR a true brief return.
[S,L,M,Q,G]=buildTrackedOxygenSurgeSites(F,P);
verifySize(t,S,[1 21]);verifyFalse(t,L(11));verifyEqual(t,height(M),2);verifyEqual(t,Q.DurationFrames,[10;10]);
verifyEqual(t,G.GapSec,1);verifyEqual(t,M.PotentialGapContinuation,[true;true]);
end
function testGapReviewUsesSecondsAndExcludesDistantSites(t)
for fs=[.5 1 2]
 P=createOxygenMasterParams(4.75,fs);N=round(30*fs);d=ceil(10*fs);g=round(2*fs);F=cell(N,1);
 for f=[1:d d+g+1:2*d+g],F{f}=struct('PixelIdxList',(1:400)');end
 [~,~,~,~,G]=buildTrackedOxygenSurgeSites(F,P);verifyEqual(t,G.GapSec,2);
 for f=d+g+1:2*d+g,F{f}=struct('PixelIdxList',(1001:1400)');end
 [~,~,~,~,G]=buildTrackedOxygenSurgeSites(F,P);verifyEqual(t,height(G),0);
end
end
function testTerminalFragmentsAreIncludedInLedger(t)
P=createOxygenMasterParams(4.75,1);F=cell(20,1);
for f=18:20,F{f}=struct('PixelIdxList',(1:400)');end
[~,~,~,Q,~]=buildTrackedOxygenSurgeSites(F,P);
verifyEqual(t,[Q.NativeStartFrame Q.NativeEndFrame Q.DurationFrames],[18 20 3]);verifyFalse(t,Q.KeptAsEvent);
end
function testIndependentRandomizedLinkOracle(t)
rng(823);
for trial=1:100
 F=cell(2,1);
 for f=1:2
  label=randi([0 4],40,1);F{f}=struct('PixelIdxList',{});
  for k=1:4,p=find(label==k);if ~isempty(p),F{f}(end+1).PixelIdxList=p;end;end
 end
 [R,I]=trackSurgeCandidates(F,1,.6,.8,2);
 A=F{1};B=F{2};overlap=zeros(numel(A),numel(B));valid=overlap;fallback=overlap;
 for a=1:numel(A),for b=1:numel(B),overlap(a,b)=numel(intersect(A(a).PixelIdxList,B(b).PixelIdxList));end;end
 for a=1:numel(A)
  for b=1:numel(B)
   na=numel(A(a).PixelIdxList);nb=numel(B(b).PixelIdxList);n=overlap(a,b);
   primary=n>0 && n/na>=.6 && n/nb>=.6;
   shape=n>0 && (n/na>=.8 || n/nb>=.8) && max(na,nb)/min(na,nb)<=2 && nnz(overlap(a,:))==1 && nnz(overlap(:,b))==1;
   valid(a,b)=primary||shape;fallback(a,b)=~primary&&shape;
  end
 end
 % At >50% mutual coverage and isolated fallback, eligible links are unique.
 verifyLessThanOrEqual(t,max([0;sum(valid,2)]),1);verifyLessThanOrEqual(t,max([0 sum(valid,1)]),1);
 actual=0;shapeCount=0;
 for r=1:size(R,1)
  if ~isempty(R{r,1})&&~isempty(R{r,2})
   actual=actual+1;a=find(arrayfun(@(x)isequal(x.PixelIdxList,R{r,1}),A));b=find(arrayfun(@(x)isequal(x.PixelIdxList,R{r,2}),B));
   verifyTrue(t,logical(valid(a,b)));shapeCount=shapeCount+fallback(a,b);
  end
 end
 verifyEqual(t,actual,nnz(valid));verifyEqual(t,sum(I.ShapeChangeLinkCount),shapeCount);
end
end
