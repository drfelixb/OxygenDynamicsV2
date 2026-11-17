function tests=testBOITissueSupport
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testDefaultAutomaticMaskUnchanged(t)
rng(23);X=randn(12,15,9);
expected=mean(single(X>mean(mean(X,1),2)),3);
expected=expected>prctile(expected(:),30);
A=computeRecordingArea(X,2,30,'recAreaBinHalfSizeUm',2);
verifyEqual(t,A.Mask,expected);verifyEqual(t,A.AutomaticMask,expected);
verifyEqual(t,A.AreaUm2,nnz(expected)*4);
verifyEmpty(t,resolveBOITissueSupport([],size(expected),'source'));
end
function testReplacementAndBinsUseDeclaredMask(t)
X=zeros(8,8,3);mask=false(8);mask(1:4,1:4)=true;
A=computeRecordingArea(X,1,30,'eligibleMask',mask,'recAreaBinHalfSizeUm',2);
verifyFalse(t,any(A.AutomaticMask(:)));verifyEqual(t,A.Mask,mask);
verifyEqual(t,A.AreaUm2,16);verifyEqual(t,A.Bins,[1 1]);
end
function testNativeCoordinatesAndSource(t)
D=declaration();[mask,R]=resolveBOITissueSupport(snapshot(D),[4 5],'fixture');
verifyTrue(t,mask(2,3));verifyEqual(t,nnz(mask),numel(D.MaskPixels));verifyEqual(t,R.Actor,D.Actor);
verifyError(t,@()resolveBOITissueSupport(snapshot(D),[4 5],'other'),'OxygenDynamics:TissueSourceMismatch');
verifyError(t,@()resolveBOITissueSupport(snapshot(D),[5 4],'fixture'),'OxygenDynamics:TissueShapeMismatch');
end
function testInvalidMasksFailWithoutCoercion(t)
D=declaration();
for value={[],[0;1],[1;1],[1.5;2],[1;21],[NaN;2]}
    D.MaskPixels=value{1};
    verifyError(t,@()resolveBOITissueSupport(snapshot(D),[4 5],'fixture'),'OxygenDynamics:InvalidTissueSupport');
end
verifyError(t,@()computeRecordingArea(zeros(4,5,3),1,30,'eligibleMask',false(4,5)), ...
    'OxygenDynamics:InvalidTissueSupport');
end
function testUnreviewedOrUntraceableDeclarationFails(t)
D=declaration();D.ReviewStatus='proposed_not_adopted';
verifyError(t,@()resolveBOITissueSupport(snapshot(D),[4 5],'fixture'),'OxygenDynamics:InvalidTissueDeclaration');
D=declaration();D.Evidence='';
verifyError(t,@()resolveBOITissueSupport(snapshot(D),[4 5],'fixture'),'OxygenDynamics:InvalidTissueDeclaration');
D=declaration();D.Extra='typo';
verifyError(t,@()resolveBOITissueSupport(snapshot(D),[4 5],'fixture'),'OxygenDynamics:InvalidTissueDeclaration');
D=declaration();D.Modality='IOSI';
verifyError(t,@()resolveBOITissueSupport(snapshot(D),[4 5],'fixture'),'OxygenDynamics:InvalidTissueDeclaration');
end
function testContractVerifiesActualSupportAndChangeLedger(t)
I=info();[C,Q,F]=createBOIRecordingInputContract(I,"R",[4 5]);
verifyEqual(t,C.TissueDecision.DecisionID,'SYNTHETIC-1');
verifyTrue(t,contains(C.TissueValidityStatus,'reviewed_static_support_declared'));
verifyEqual(t,C.ScientificEligibility,'not_established_by_input_contract');
verifyTrue(t,any(Q.IssueID=="R1-REVIEWED-TISSUE"));
verifyEqual(t,F.SinkAnalyzedArea_um2,ones(3,1)*numel(I.SinkEligibleTissuePixels)*4);
I.SurgeEligibleTissuePixels=1;I.SurgeRecordingAreaUm2=4;
verifyError(t,@()createBOIRecordingInputContract(I,"R",[4 5]),'OxygenDynamics:TissueDecisionMismatch');
I=info();I.TissueSupportAudit.RemovedPixels=1;
verifyError(t,@()createBOIRecordingInputContract(I,"R",[4 5]),'OxygenDynamics:TissueDecisionMismatch');
end
function testCandidateOverlapDoesNotClipEvent(t)
BW=false(8);BW(3:4,3:6)=true;support=false(8);support(:,1:4)=true;
kept=filterRegionCandidates(BW,support,1,Inf,0,.5,[]);
verifyEqual(t,kept,BW); % exactly half outside: existing rule retains all pixels
support(:,4)=false;
verifyFalse(t,any(filterRegionCandidates(BW,support,1,Inf,0,.5,[]),'all'));
end
function testOccupancyIntersectsExplicitSupport(t)
R=table("R",{'fixture'},{'Unknown'},{'Unknown'},{'Unknown'},{'Unknown'},false,2,1,2,8,2,"loaded", ...
    'VariableNames',{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','PixelSize','AnalysisStatus'});
P={[1;2;3],[]};Q={[2;3],[]};
S=table(["R";"R"],{1;1},{1;1},{8;8},{P;Q},{[2;4];[2;4]}, ...
    'VariableNames',{'RecordingID','Start','Duration','RecAreaSize','FramePixels','EligibleTissuePixels'});
E=table("R",0,1,10,12,'VariableNames',{'RecordingID','StartSec','EndSec','NormOxySinkAmpPercent','EventArea_um2'});
[W,F]=createOxygenAnalysisWindows(R,S,E);
verifyEqual(t,F.OccupiedArea_um2,[4;0]);verifyEqual(t,W.CoveredAreaTime_um2_sec,4);
verifyEqual(t,W.AnalyzedTissueTime_um2_sec,16);verifyEqual(t,W.MeanOccupiedTissueFraction,.25);
end
function testSourceSnapshotCannotChangeOrBeAddedRetrospectively(t)
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
raw=fullfile(folder,'source.tif');fid=fopen(raw,'w');fprintf(fid,'fixture');fclose(fid);
I=struct('RawFile',raw,'RawSHA256',oxygenFileSHA256(raw),'DenoisedFile','','DenoisedSHA256','');
I.BOITissueSupport=captureBOITissueSupport(folder,[4 5],I.RawSHA256);
D=declaration();D.RawSHA256=I.RawSHA256;file=fullfile(folder,'BOITissueSupport.json');write(file,D);
verifyError(t,@()validateOxygenSourceFiles(I,folder),'OxygenDynamics:TissueSupportChanged');
legacy=rmfield(I,'BOITissueSupport');
verifyError(t,@()validateOxygenSourceFiles(legacy,folder),'OxygenDynamics:TissueSupportChanged');
I.BOITissueSupport=captureBOITissueSupport(folder,[4 5],I.RawSHA256);validateOxygenSourceFiles(I,folder);
D.Reason='changed';write(file,D);
verifyError(t,@()validateOxygenSourceFiles(I,folder),'OxygenDynamics:TissueSupportChanged');
delete(file);verifyError(t,@()validateOxygenSourceFiles(I,folder),'OxygenDynamics:TissueSupportChanged');
end
function testProposalMutationAndOverwriteGuards(t)
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
rec=fullfile(folder,'rec');mkdir(rec);saveastiff(uint16(ones(4,5,3)),fullfile(rec,'source.tif'));
Mask=true(4,5);proposal=fullfile(folder,'proposal');reviewBOITissueSupport(rec,Mask,proposal);
verifyFalse(t,isfile(fullfile(rec,'BOITissueSupport.json')));
verifyError(t,@()reviewBOITissueSupport(rec,Mask,proposal),'OxygenDynamics:ReviewOutputExists');
Mask(1)=false;save(fullfile(proposal,'ProposedMask.mat'),'Mask');
decision=rmfield(declaration(),{'Schema','Modality','RawSHA256','FrameSize','IndexConvention','MaskPixels','ReviewStatus','RecordedUTC'});
verifyError(t,@()writeBOITissueSupport(rec,proposal,decision),'OxygenDynamics:TissueProposalChanged');
mkdir(fullfile(rec,'OxygenSinks_Output'));
verifyError(t,@()writeBOITissueSupport(rec,proposal,decision),'OxygenDynamics:TissueMasterExists');
end
function I=info()
D=declaration();mask=resolveBOITissueSupport(snapshot(D),[4 5],'fixture');
sink=false(4,5);sink(2:3,2:4)=mask(2:3,2:4);
I=struct('NFrames',3,'AnalysisParams',struct('fs',1,'PixelSize',2,'Pixel_frame',1), ...
    'RawSHA256','fixture','DenoisedSHA256','','BOITissueSupport',snapshot(D), ...
    'SinkEligibleTissuePixels',find(sink),'SurgeEligibleTissuePixels',find(mask), ...
    'RecordingAreaUm2',nnz(sink)*4,'SurgeRecordingAreaUm2',nnz(mask)*4);
I.TissueSupportAudit=struct('Schema','boi-tissue-support-application-1', ...
    'AutomaticTissuePixels',zeros(0,1),'AddedPixels',find(mask),'RemovedPixels',zeros(0,1));
end
function D=declaration()
D=struct('Schema','boi-static-tissue-support-1','Modality','BOI','RawSHA256','fixture', ...
    'FrameSize',[4 5],'IndexConvention','MATLAB_one_based_column_major_row_column', ...
    'MaskPixels',[1;6;10;11],'ReviewStatus','reviewed_for_static_support', ...
    'DecisionID','SYNTHETIC-1','Actor','automated fixture','Reason','Verify support transport', ...
    'Evidence','Known synthetic geometry; no biological review', ...
    'AlignmentEvidence','Mask constructed in native fixture coordinates','RecordedUTC','2026-09-10T12:00:00Z');
end
function S=snapshot(D)
S=struct('State','captured','RawJSON',jsonencode(D),'SHA256','fixture');
end
function write(file,D)
fid=fopen(file,'w');cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(D));
end
