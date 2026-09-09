function tests=testMeasurementAvailability
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testSiteRateUnits(t)
S=table(10,10,{100},3,{120},{[2 4]},{[.1 .3]},{[0 0]},2, ...
    'VariableNames',{'MeanOxySinkArea_um','MeanOxySinkFilledArea_um','RecAreaSize', ...
    'NumOxySinkEvents','RecDuration','Duration','NormOxySinkAmp','Size_modulation','SampleF'});
U=S;U.Properties.VariableNames={'MeanOxySurgeArea_um','MeanOxySurgeFilledArea_um','RecAreaSize_Surge', ...
    'NumOxySurgeEvents','RecDuration_Surge','Duration_Surge','NormOxySurgeAmp','Size_Surge_modulation','SampleF'};
A=createAdditionalOxygenSinkMetrics(S);B=createAdditionalOxygenSurgeMetrics(U);
verifyEqual(t,A.SinkSiteEventRate_per_min,1.5);
verifyEqual(t,B.SurgeSiteEventRate_per_min,1.5);
verifyEqual(t,A.MeanOxySinkEvent_Duration,1.5);
verifyEqual(t,B.MeanOxySurgeEvent_Duration,1.5);
end
function testMissingAndZeroEventRecordings(t)
R=table(["R1";"R2"],'VariableNames',{'RecordingID'});
E=table(repmat("R1",3,1),["valid";"insufficient_clean_prebaseline";"valid"],[.2;NaN;-.1], ...
    'VariableNames',{'RecordingID','BaselineStatus','NormOxySinkAmp'});
[Q,C]=createOxygenMeasurementQC(R,E,table());
verifyEqual(t,Q.DetectedEvents,[3;0;0;0]);
verifyEqual(t,Q.FiniteAmplitudeEvents,[2;0;0;0]);
verifyEqual(t,Q.UnavailableAmplitudeEvents,[1;0;0;0]);
verifyEqual(t,Q.WrongDirectionAmplitudeEvents,[1;0;0;0]);
verifyEqual(t,Q.FiniteAmplitudeFraction(1),2/3);
verifyTrue(t,all(isnan(Q.FiniteAmplitudeFraction(2:end))));
verifyEqual(t,sum(C.EventCount),3);
end
function testBothEventTypes(t)
R=table("R1",'VariableNames',{'RecordingID'});
E=table("R1","valid",.3,'VariableNames',{'RecordingID','BaselineStatus','NormOxySurgeAmp'});
[Q,C]=createOxygenMeasurementQC(R,table(),E);
verifyEqual(t,Q.EventType,["sink";"surge"]);
verifyEqual(t,Q.ValidBaselineEvents,[0;1]);verifyEqual(t,C.EventType,"surge");
end
function testInvalidProvenance(t)
R=table("R1",'VariableNames',{'RecordingID'});
E=table("R2","valid",.3,'VariableNames',{'RecordingID','BaselineStatus','NormOxySinkAmp'});
verifyError(t,@()createOxygenMeasurementQC(R,E,table()),'OxygenDynamics:UnknownRecording');
E.RecordingID="R1";E.BaselineStatus="insufficient_clean_prebaseline";
verifyError(t,@()createOxygenMeasurementQC(R,E,table()),'OxygenDynamics:InconsistentMeasurement');
end
