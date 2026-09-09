function tests=testEventAmplitudeAudit
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [S,E,O,R]=fixture
R=repmat(reshape([100;200],2,1,1),1,1,30);R(1,1,7:8)=80;R(2,1,15:16)=120;
c=cell(1,30);c(7:8)={1};c(15:16)={2};S=table({c},'VariableNames',{'FramePixels'});O=S([],:);
E=table(["R";"R"],[1;1],[1;2],[7;15],[8;16],[100;200],["valid";"valid"],[4;4],[.2;.4], ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp'});
end
function testIndividualFootprints(t)
[S,E,O,R]=fixture;[A,T]=auditOxygenEventFootprints(S,E,O,R,4,'sink');
verifyTrue(t,all(A.MeasurementMatches));verifyEqual(t,A.RecomputedAmplitude,[.2;.4],'AbsTol',1e-12);
verifyEqual(t,T{1}.Footprint,1);verifyEqual(t,T{2}.Footprint,2);
E.NormOxySinkAmp(2)=.2;A=auditOxygenEventFootprints(S,E,O,R,4,'sink');
verifyEqual(t,A.MeasurementMatches,[true;false]);
end
function testOppositeSignContamination(t)
[S,E,~,R]=fixture;c=cell(1,30);c{14}=2;O=table({c},'VariableNames',{'FramePixels'});
E.BaselineStatus(2)="insufficient_clean_prebaseline";E.BaselineValue(2)=NaN;E.BaselineValidSamples(2)=3;E.NormOxySinkAmp(2)=NaN;
A=auditOxygenEventFootprints(S,E,O,R,4,'sink');
verifyTrue(t,all(A.MeasurementMatches));verifyEqual(t,A.OverlapExcludedFrames,[0;1]);verifyTrue(t,isnan(A.RecomputedAmplitude(2)));
end
function testNoPostEventFallbackAndSurgeSign(t)
[S,E,O,R]=fixture;S.FramePixels{1}=cell(1,30);S.FramePixels{1}(1:2)={1};
E=E(1,:);E=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});
E.StartFrame=1;E.EndFrame=2;E.BaselineValue=NaN;E.BaselineStatus="insufficient_clean_prebaseline";E.BaselineValidSamples=0;E.NormOxySurgeAmp=NaN;
A=auditOxygenEventFootprints(S,E,O,R,4,'surge');verifyTrue(t,A.MeasurementMatches);verifyTrue(t,A.TruncatedBaseline);
[S,E,O,R]=fixture;E=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});E.NormOxySurgeAmp=[-.2;-.4];
A=auditOxygenEventFootprints(S,E,O,R,4,'surge');verifyTrue(t,all(A.MeasurementMatches));verifyTrue(t,all(A.WrongDirection));
end
function testNonfiniteAndEmpty(t)
[S,E,O,R]=fixture;R(1,1,3)=NaN;E.BaselineValue(1)=NaN;E.BaselineStatus(1)="insufficient_clean_prebaseline";E.BaselineValidSamples(1)=3;E.NormOxySinkAmp(1)=NaN;
A=auditOxygenEventFootprints(S,E,O,R,4,'sink');verifyTrue(t,all(A.MeasurementMatches));verifyEqual(t,A.NonfiniteBaselineFrames,[1;0]);
[A,T]=auditOxygenEventFootprints(S,E([],:),O,R,4,'sink');verifyEqual(t,height(A),0);verifyEmpty(t,T);
end

function testNonpositiveBaselineAndMissingEvent(t)
[S,E,O,R]=fixture;R(1,1,3:6)=0;E.BaselineValue(1)=0;
E.BaselineStatus(1)="nonpositive_baseline_or_missing_event_signal";E.NormOxySinkAmp(1)=NaN;
R(2,1,15)=NaN;E.BaselineStatus(2)="nonpositive_baseline_or_missing_event_signal";E.NormOxySinkAmp(2)=NaN;
A=auditOxygenEventFootprints(S,E,O,R,4,'sink');verifyTrue(t,all(A.MeasurementMatches));
verifyEqual(t,A.CleanBaselineFrames,[4;4]);verifyTrue(t,all(isnan(A.RecomputedAmplitude)));
end
