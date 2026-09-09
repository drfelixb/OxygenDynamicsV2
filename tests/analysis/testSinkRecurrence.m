function tests=testSinkRecurrence
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testKnownRepeatedRunsAcrossGapAndClockSweep(t)
for fs=[1 1.01 2]
 for gapFrames=[1 2 5 15 19 20 21 30 40 41 60]
  duration=round(20*fs);a=61;b=a+duration-1;c=b+gapFrames+1;d=c+duration-1;
  P=cell(1,d+30);P(a:b)={1};P(c:d)={1};
  [Q,L]=filterSinkRunsByDuration(P,3*fs,150*fs);
  verifyEqual(t,Q,P);verifyEqual(t,nnz(L),2*duration);
  E=fixture([a;c],[b;d],[1;1]);E=annotateOxygenEventRecurrence(E,fs,20);
  verifyEqual(t,E.CloseNativeRun,repmat(gapFrames/fs<20,2,1));
  verifyEqual(t,E.PreviousNativeGapSec(2),gapFrames/fs,'AbsTol',1e-12);
  verifyTrue(t,isnan(E.PreviousNativeGapSec(1))&&isnan(E.NextNativeGapSec(2)));
 end
end
end
function testDurationLimitsStillRemoveShortAndLongRuns(t)
P=cell(3,170);P(1,1:2)={1};P(1,10:12)={1};P(2,1:151)={2};
[Q,L]=filterSinkRunsByDuration(P,3,150);
verifySize(t,Q,[1 170]);verifyEqual(t,find(L),10:12);
[Q,L]=filterSinkRunsByDuration(cell(0,20),3,150);verifySize(t,Q,[0 20]);verifyEmpty(t,L);
end
function testUnsortedRowsAndDifferentSites(t)
E=fixture([40;10;20],[45;15;25],[1;1;2]);E=annotateOxygenEventRecurrence(E,1,30);
verifyEqual(t,E.CloseNativeRun,[true;true;false]);verifyEqual(t,E.PreviousNativeGapSec(1),24);
verifyTrue(t,isnan(E.PreviousNativeGapSec(3))&&isnan(E.NextNativeGapSec(3)));
end
function testSingleFragmentedExcursionIsFlaggedAndTimingUnresolved(t)
% Prescribed candidate dropout: a stage-level challenge, not detector accuracy.
x=zeros(1,110);x(20:80)=-.5*sin(pi*(0:60)/60).^2;
E=fixture([25;53],[47;75],[1;1]);E=annotateOxygenEventRecurrence(E,1,20);
verifyTrue(t,all(E.CloseNativeRun));
A=resolveSinkEventTiming(25:47,x,zeros(size(x)),.015,20,1,50);
B=resolveSinkEventTiming(53:75,x,zeros(size(x)),.015,20,51,110);
verifyFalse(t,A.TimingResolved);verifyFalse(t,B.TimingResolved);
verifyLessThan(t,A.EndFrame,B.StartFrame);
end
function testTrueSeparateExcursionsMayHaveResolvedTimingButStayFlagged(t)
x=zeros(1,110);x(25:47)=-.5;x(53:75)=-.5;
E=annotateOxygenEventRecurrence(fixture([25;53],[47;75],[1;1]),1,20);
A=resolveSinkEventTiming(25:47,x,zeros(size(x)),.015,20,1,50);
B=resolveSinkEventTiming(53:75,x,zeros(size(x)),.015,20,51,110);
verifyTrue(t,all(E.CloseNativeRun));verifyTrue(t,A.TimingResolved&&B.TimingResolved);
end
function testQCSeparatesRecurrenceFromAmplitudeAndTiming(t)
E=annotateOxygenEventRecurrence(fixture([61;96],[80;115],[1;1]),1,20);
E.RecordingID=["R";"R"];E.BaselineStatus=["valid";"insufficient_clean_prebaseline"];
E.NormOxySinkAmp=[.2;NaN];E.TimingResolved=[true;false];
[Q,~]=createOxygenMeasurementQC(table(["R";"zero"],'VariableNames',{'RecordingID'}),E,table());
q=Q.EventType=="sink";
verifyEqual(t,Q.DetectedEvents(q),[2;0]);verifyEqual(t,Q.CloseNativeRunEvents(q),[2;0]);
verifyEqual(t,Q.FiniteAmplitudeEvents(q),[1;0]);verifyEqual(t,Q.TimingUnresolvedEvents(q),[1;0]);
verifyEqual(t,Q.RecurrenceNotAssessedEvents(q),[0;0]);
end
function E=fixture(a,b,sites)
E=table(sites,a,b,'VariableNames',{'SinkID','NativeStartFrame','NativeEndFrame'});
end
