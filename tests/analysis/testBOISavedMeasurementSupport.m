function tests=testBOISavedMeasurementSupport
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;addpath(fileparts(mfilename('fullpath')));
end
function [S,E,I]=fixture(kind)
P={[1;2],2,[],5};Q={[2;3],[3;4],[],[]};Z={[],[],6,[]};
S=table(repmat("R",3,1),(1:3)',{P;Q;Z},{(1:5)';(1:5)';(1:5)'},{[1 4];1;3},{[2 1];2;1},{20;20;20}, ...
 'VariableNames',{'RecordingID','SiteID','FramePixels','EligibleTissuePixels','Start','Duration','RecAreaSize'});
E=table(repmat("R",4,1),[1;1;2;3],[1;2;1;1],[-.2;NaN;NaN;1],["valid";"missing";"missing";"valid"],[1;3;1;3],[2;4;3;3], ...
 'VariableNames',{'RecordingID','SinkID','EventID','NormOxySinkAmp','BaselineStatus','StartFrame','EndFrame'});
I=struct('NFrames',4,'FrameSize',[2 3],'AnalysisParams',struct('fs',1,'PixelSize',2), ...
 'SinkEligibleTissuePixels',(1:5)','SurgeEligibleTissuePixels',(1:5)','RawSHA256','fixture');
if strcmp(kind,'surge')
 S=renamevars(S,{'Start','Duration','RecAreaSize'},{'Start_Surge','Duration_Surge','RecAreaSize_Surge'});
 E=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});
end
end
function testDisjointPartitionNegativeAmplitudeAndTiming(t)
for kind={'sink','surge'}
 [S,E,I]=fixture(kind{1});original=E;[A,V,F]=auditBOISavedMeasurementSupport(S,E,I,kind{1},"R");
 verifyEqual(t,E,original);verifyEqual(t,F.FiniteAmplitudeOnlyPixels,[1;1;0;0]);
 verifyEqual(t,F.UnavailableAmplitudeOnlyPixels,[1;2;0;1]);verifyEqual(t,F.SharedPixels,[1;0;0;0]);
 verifyEqual(t,[A.FiniteOnlyAreaTimeUm2Sec,A.UnavailableOnlyAreaTimeUm2Sec,A.SharedAreaTimeUm2Sec],[8 16 4]);
 verifyEqual(t,A.AllOccupiedFraction,.35,'AbsTol',1e-14);verifyEqual(t,A.FiniteAmplitudeUnionOccupiedFraction,.15,'AbsTol',1e-14);
 verifyEqual(t,[A.Events A.FiniteAmplitudeEvents A.UnavailableAmplitudeEvents A.NegativeFiniteAmplitudes],[4 2 2 1]);
 verifyEqual(t,V.MeasurementSecondsOutsideNativeRun,[0;1;1;0]);verifyEqual(t,A.RecurrentSiteEvents,2);
 verifyEqual(t,[A.MeasurementStartContact A.MeasurementEndContact],[2 1]);verifyTrue(t,all(isnan(V.CloseNativeRun)));
end
end
function testMissingMasksAndUnmatchedEventsCannotBecomeZero(t)
[S,E,I]=fixture('sink');bad=S;bad.FramePixels{1}=bad.FramePixels{1}(1:3);
verifyError(t,@()auditBOISavedMeasurementSupport(bad,E,I,'sink',"R"),'OxygenDynamics:SupportAuditMasks');
bad=E;bad.EventID(1)=99;verifyError(t,@()auditBOISavedMeasurementSupport(S,bad,I,'sink',"R"),'OxygenDynamics:SupportAuditIdentity');
bad=S;bad.EligibleTissuePixels{1}=[1;2];verifyError(t,@()auditBOISavedMeasurementSupport(bad,E,I,'sink',"R"),'OxygenDynamics:SupportAuditMasks');
end
function testZeroRecordingAndZeroTissueAreDifferent(t)
[S,E,I]=fixture('sink');S=S([],:);E=E([],:);A=auditBOISavedMeasurementSupport(S,E,I,'sink',"R");
verifyEqual(t,A.AllOccupiedFraction,0);verifyTrue(t,isnan(A.UnavailableOnlyFractionOfCoveredAreaTime));
I.SinkEligibleTissuePixels=[];A=auditBOISavedMeasurementSupport(S,E,I,'sink',"R");verifyTrue(t,isnan(A.AllOccupiedFraction));
end

function testLegacyDimensionsUseExplicitSavedSiteEvidence(t)
[S,E,I]=fixture('sink');S.FrameSize=repmat({I.FrameSize},height(S),1);I=rmfield(I,'FrameSize');
A=auditBOISavedMeasurementSupport(S,E,I,'sink',"R");verifyEqual(t,A.AllOccupiedFraction,.35,'AbsTol',1e-14);
verifyTrue(t,contains(A.FrameSizeEvidence,'saved_site_table'));
S.FrameSize{2}=[3 2];verifyError(t,@()auditBOISavedMeasurementSupport(S,E,I,'sink',"R"),'OxygenDynamics:SupportAuditMasks');
end
