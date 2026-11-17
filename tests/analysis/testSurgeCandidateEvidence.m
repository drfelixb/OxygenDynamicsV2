function tests=testSurgeCandidateEvidence
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;addpath('tests/analysis');
end
function testGrowingSupportAndEmptyOutside(t)
M=struct('Height',120,'Width',120,'CentersXY',[40 60;80 60],'Windows',[2 4], ...
 'RadiusUmByFrame',[10 10 15 20 20],'SourceProfile',struct('PixelSize',2));
A=surgeEvidenceTruthMask(M,2,1,2);B=surgeEvidenceTruthMask(M,2,1,4);
verifyFalse(t,any(surgeEvidenceTruthMask(M,2,1,1),'all'));verifyTrue(t,all(B(A)));verifyGreaterThan(t,nnz(B),nnz(A));
end
function testMovingSupportUsesPhysicalDisplacement(t)
M=struct('Height',100,'Width',300,'CentersXY',[50 50;100 50],'Windows',repmat([101 160],8,1),'RadiusPixels',10, ...
 'MotionUmPerSec',4.75,'SampleHz',1,'SourceProfile',struct('PixelSize',4.75));
A=regionprops(surgeEvidenceTruthMask(M,2,8,101),'Centroid');B=regionprops(surgeEvidenceTruthMask(M,2,8,111),'Centroid');
verifyEqual(t,B.Centroid-A.Centroid,[10 0]);
end
function testShapeLinkExplainedIndependently(t)
P=createOxygenMasterParams(4.75,1);F={struct('PixelIdxList',(1:400)');struct('PixelIdxList',(1:800)')};
[R,~]=trackSurgeCandidates(F,1,.6,.8,2);T=summarizeSurgeCandidateTransitions(R,{(1:400)',(1:800)'},P);
verifyEqual(t,height(T),1);verifyEqual(t,T.Reason,"isolated_shape_link");verifyEqual(t,T.MutualCoverage,.5);verifyTrue(t,T.ActualLinked);
end
function testCompetingContactExplained(t)
P=createOxygenMasterParams(4.75,1);F={struct('PixelIdxList',{(1:400)',(401:800)'});struct('PixelIdxList',(1:800)')};
[R,~]=trackSurgeCandidates(F,1,.6,.8,2);T=summarizeSurgeCandidateTransitions(R,{(1:800)',(1:800)'},P);
verifyEqual(t,height(T),2);verifyEqual(t,T.Reason,repmat("competing_overlap_blocks_fallback",2,1));verifyFalse(t,any(T.ActualLinked));
end
function testNoOverlapAndMissingFrameAreVisible(t)
P=createOxygenMasterParams(4.75,1);R=cell(2,3);R{1,1}=(1:400)';R{2,3}=(1:400)';
T=summarizeSurgeCandidateTransitions(R,{(1:400)',[],(1:400)'},P);
verifyEqual(t,T.Reason,["no_overlapping_successor";"no_overlapping_predecessor"]);verifyFalse(t,any(T.ActualLinked));
end
function testExcessiveAreaChangeExplained(t)
P=createOxygenMasterParams(4.75,1);F={struct('PixelIdxList',(1:400)');struct('PixelIdxList',(1:1000)')};
[R,~]=trackSurgeCandidates(F,1,.6,.8,2);T=summarizeSurgeCandidateTransitions(R,{(1:400)',(1:1000)'},P);
verifyEqual(t,T.Reason,"excessive_area_change");verifyEqual(t,T.AreaRatio,2.5);
end
function testSpatialNormalizationRemovesPerFrameAffineGain(t)
rng(48);X=rand(20,30,40)+2;Y=X;
for f=1:40,Y(:,:,f)=X(:,:,f)*(1+.3*sin(f/7))+.2*cos(f/4);end
[A,B]=normalizeToZStat(X);[C,D]=normalizeToZStat(Y);
verifyEqual(t,C,A,'AbsTol',single(1e-6));verifyEqual(t,D,B,'AbsTol',single(1e-6));
verifyGreaterThan(t,max(abs(mean(reshape(Y-X,[],40),1))),.1);
end
