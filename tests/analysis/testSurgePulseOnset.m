function tests=testSurgePulseOnset
tests=functiontests(localfunctions);
end
function testNoiselessRecipes(t)
x=100*ones(48,240);truth=zeros(48,1);j=0;
for a=[.02 .05 .1 .2],for rise=[5 15 30],for shape=["linear","sine_squared"],for delay=[10 25]
 j=j+1;truth(j)=120-delay;x(j,:)=100*(1+a*surgeTracePanelEnvelope(240,truth(j),rise,shape));
end,end,end,end
R=estimateSurgePulseOnset(x,120:180,1,false(1,240));
verifyTrue(t,all(string({R.Status})=="resolved"));verifyLessThanOrEqual(t,max(abs([R.OnsetFrame]'-truth)),5);
end
function testFlatLinearFalling(t)
f=1:200;x=[100*ones(1,200);100+.1*f;200-max(0,f-100)];
R=estimateSurgePulseOnset(x,120:150,1,false(1,200));verifyFalse(t,any(string({R.Status})=="resolved"));
end
function testNeighborAndNoBaseline(t)
x=100*(1+.2*surgeTracePanelEnvelope(200,101,15,"linear"));b=false(1,200);b(75)=true;
R=estimateSurgePulseOnset(x,120:150,1,b);verifyEqual(t,R.OnsetFrame,101);verifyEqual(t,R.FitStartFrame,76);
b(110)=true;R=estimateSurgePulseOnset(x,120:150,1,b);verifyEqual(t,R.Status,"insufficient_clean_context");
end
function testMissingSignalAndGain(t)
x=100*(1+.2*surgeTracePanelEnvelope(200,101,15,"linear"));Y=[x;5*x;x;x];Y(3,90)=NaN;Y(4,145)=NaN;
R=estimateSurgePulseOnset(Y,120:150,1,false(1,200));
verifyEqual(t,R(1).OnsetFrame,R(2).OnsetFrame);verifyEqual(t,R(1).ProvisionalAmplitude,R(2).ProvisionalAmplitude,'AbsTol',1e-12);
verifyEqual(t,R(3).Status,"nonfinite_fit");verifyEqual(t,R(4).BaselineStatus,"missing_native_signal");verifyTrue(t,isnan(R(4).ProvisionalAmplitude));
end
function testNonpositiveReference(t)
x=-100+20*surgeTracePanelEnvelope(200,101,15,"linear");R=estimateSurgePulseOnset(x,120:150,1,false(1,200));
verifyEqual(t,R.Status,"resolved");verifyEqual(t,R.BaselineStatus,"nonpositive_baseline");verifyTrue(t,isnan(R.ProvisionalAmplitude));
end
function testUnequalRecoveryAndRecordingStart(t)
f=1:100;u=max(0,min(1,(f-30)/5));d=max(0,min(1,(30+5+10+30-f)/30));x=100+20*min(u,d);
R=estimateSurgePulseOnset(x,50:80,1,false(1,100));verifyEqual(t,R.OnsetFrame,31);verifyEqual(t,R.FitStartFrame,1);
end
