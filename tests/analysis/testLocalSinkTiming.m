function tests=testLocalSinkTiming
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testCrossingWithoutSampleInsideTolerance(t)
x=ones(1,60)*.2;x(18:27)=-.3;
T=resolveSinkEventTiming(20:24,x,zeros(size(x)),.015,20,1,60);
verifyEqual(t,[T.StartFrame T.EndFrame],[18 27]);verifyTrue(t,T.TimingResolved);
end
function testDoesNotCrossOppositeExcursion(t)
x=-ones(1,100);x(25:35)=1;x(55:end)=1;
T=resolveSinkEventTiming(40:45,x,zeros(size(x)),.015,40,1,100);
verifyEqual(t,[T.StartFrame T.EndFrame],[36 54]);
end
function testUnresolvedSearchRetainsNative(t)
x=-ones(1,100);T=resolveSinkEventTiming(40:45,x,zeros(size(x)),.015,20,1,100);
verifyEqual(t,[T.StartFrame T.EndFrame],[40 45]);verifyFalse(t,T.TimingResolved);
verifyEqual(t,T.StartBoundaryStatus,"search_limit_unresolved");
end
function testSeparatedEventsDoNotShareWindow(t)
x=-ones(1,100);x(1:10)=1;x(90:end)=1;
A=resolveSinkEventTiming(20:25,x,zeros(size(x)),.015,80,1,42);
B=resolveSinkEventTiming(60:65,x,zeros(size(x)),.015,80,43,100);
verifyLessThan(t,A.EndFrame,B.StartFrame);verifyEqual(t,A.EndFrame,25);verifyEqual(t,B.StartFrame,60);
verifyEqual(t,A.StartFrame,11);verifyEqual(t,B.EndFrame,89);
end
function testRecordingBoundaryAndInvalidSeed(t)
x=-ones(1,50);A=resolveSinkEventTiming(1:4,x,zeros(size(x)),.015,20,1,50);
verifyEqual(t,A.StartBoundaryStatus,"recording_boundary_unresolved");verifyEqual(t,A.StartFrame,1);
x(20)=NaN;B=resolveSinkEventTiming(20:24,x,zeros(size(x)),.015,20,1,50);
verifyEqual(t,B.StartBoundaryStatus,"nonfinite_seed");
x(20)=.2;B=resolveSinkEventTiming(20:24,x,zeros(size(x)),.015,20,1,50);
verifyEqual(t,B.StartBoundaryStatus,"seed_not_below_return_level");verifyTrue(t,B.NativeTraceCrossesReturnLevel);
end
function testMissingSearchCannotBeSkipped(t)
x=-ones(1,50);x(14)=1;x(18)=NaN;
A=resolveSinkEventTiming(20:24,x,zeros(size(x)),.015,20,1,50);
verifyEqual(t,A.StartFrame,20);verifyEqual(t,A.StartBoundaryStatus,"nonfinite_search");
end
function testPhysicalLimitAndInclusiveDuration(t)
x=ones(1,90);x(10:65)=-1;
fs=1.01;cap=floor(20*fs);
A=quantifyOxygenSinkEvent(30:45,x,zeros(size(x)),100+10*x,.015,round(20*fs),cap,1,90);
verifyEqual(t,[A.StartFrame A.EndFrame],[10 65]);verifyEqual(t,A.DurationFrames,56);
verifyLessThanOrEqual(t,(30-A.StartFrame)/fs,20);
end

function testMixedSignNativeSeedIsNotFullyResolved(t)
x=ones(1,60);x(18:27)=-.3;x(22)=.1;
A=resolveSinkEventTiming(20:24,x,zeros(size(x)),.015,20,1,60);
verifyEqual(t,[A.StartFrame A.EndFrame],[18 27]);verifyFalse(t,A.TimingResolved);
verifyTrue(t,A.NativeTraceCrossesReturnLevel);
end
function testTimingQCKeptSeparateFromBaselineQC(t)
R=table("R",'VariableNames',{'RecordingID'});
E=table(["R";"R"],["valid";"valid"],[.1;.2],[true;false], ...
 'VariableNames',{'RecordingID','BaselineStatus','NormOxySinkAmp','TimingResolved'});
[Q,~]=createOxygenMeasurementQC(R,E,table());
verifyEqual(t,Q.FiniteAmplitudeEvents,[2;0]);verifyEqual(t,Q.TimingResolvedEvents,[1;0]);
verifyEqual(t,Q.TimingUnresolvedEvents,[1;0]);verifyEqual(t,Q.TimingNotAssessedEvents,[0;0]);
end
