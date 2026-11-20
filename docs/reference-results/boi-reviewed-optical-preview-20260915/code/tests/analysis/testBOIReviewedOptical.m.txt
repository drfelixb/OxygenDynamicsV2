function tests=testBOIReviewedOptical
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testSignedArithmeticTiesAndShortReference(t)
r=100*ones(30,1);r(20:23)=[100;80;80;100];
m=computeBOIReviewedOpticalInterval(r,8:19,20,23,1,'sink');
verifyEqual(t,m.ReferenceSampleCount,12);verifyEqual(t,m.ReferenceMean,100);
verifyEqual(t,m.SignedFraction,[0;-.2;-.2;0],'AbsTol',1e-15);verifyEqual(t,m.MinimumFrames,[21;22]);verifyEqual(t,m.MaximumFrames,[20;23]);
verifyEqual(t,m.SavedSignDirectionalAmplitudeFraction,.2,'AbsTol',1e-15);verifyEqual(t,m.SignedTraceIntegralSec,-.4,'AbsTol',1e-15);
verifyEqual(t,m.DurationSec,4);verifyEqual(t,m.EndpointSpanSec,3);
s=computeBOIReviewedOpticalInterval(r,8:19,20,23,1,'surge');verifyEqual(t,s.SavedSignDirectionalAmplitudeFraction,0);verifyEqual(t,s.MinimumSignedChangeFraction,-.2,'AbsTol',1e-15);
end
function testNegativeDirectionalValueAndRectangleTime(t)
r=100*ones(10,1);r(7:8)=[110;120];
m=computeBOIReviewedOpticalInterval(r,3:6,7,8,2,'sink');verifyEqual(t,m.SavedSignDirectionalAmplitudeFraction,-.1,'AbsTol',1e-15);
verifyEqual(t,m.SignedTraceIntegralSec,.15,'AbsTol',1e-15);verifyEqual(t,m.DurationSec,1);verifyEqual(t,m.EndpointSpanSec,.5);
end
function testUnavailableDoesNotBecomeZeroOrLoseTiming(t)
r=ones(12,1);m=computeBOIReviewedOpticalInterval(r,[],8,10,1,'sink');verifyEqual(t,m.Status,'unavailable_no_accepted_reference');verifyTrue(t,isnan(m.ReferenceSampleCount));verifyEqual(t,m.DurationSec,3);
r(4)=NaN;m=computeBOIReviewedOpticalInterval(r,3:7,8,10,1,'sink');verifyEqual(t,m.Status,'unavailable_nonfinite_reference_samples');verifyTrue(t,isnan(m.ReferenceMean));verifyTrue(t,all(isnan(m.SignedFraction)));
r(4)=1;r(9)=NaN;m=computeBOIReviewedOpticalInterval(r,3:7,8,10,1,'sink');verifyEqual(t,m.Status,'unavailable_nonfinite_event_samples');verifyEqual(t,m.ReferenceMean,1);verifyTrue(t,all(isnan(m.SignedFraction)));verifyTrue(t,isnan(m.SignedTraceIntegralSec));
end
function testInvalidMeanAndOverflow(t)
for value=[0 -1]
 r=ones(12,1);r(3:7)=value;m=computeBOIReviewedOpticalInterval(r,3:7,8,10,1,'surge');verifyEqual(t,m.Status,'unavailable_nonpositive_or_nonfinite_reference_mean');verifyEqual(t,m.ReferenceMean,value);verifyTrue(t,isnan(m.MaximumSignedChangeFraction));
end
r=ones(12,1)*realmin;r(8)=realmax;m=computeBOIReviewedOpticalInterval(r,3:7,8,10,1,'sink');verifyEqual(t,m.Status,'unavailable_nonfinite_derived_arithmetic');verifyTrue(t,all(isnan(m.SignedFraction)));
end
function testInvalidBoundsAndReference(t)
r=ones(12,1);
for c={[3 3],[0 2],[3 8],[4 3],[3 NaN]}
 verifyError(t,@()computeBOIReviewedOpticalInterval(r,c{1},8,10,1,'sink'),'OxygenDynamics:InvalidReviewedOpticalInput');
end
verifyError(t,@()computeBOIReviewedOpticalInterval(r,3:7,8,13,1,'sink'),'OxygenDynamics:InvalidReviewedOpticalInput');
end
function testDefinitionCannotDriftSilently(t)
D=getBOIReviewedOpticalDefinition;verifyEqual(t,D.Dictionary.Version,'0.1.0-draft');verifyFalse(t,D.ScientificAdoption);
folder=tempname;mkdir(folder);c=onCleanup(@()rmdir(folder,'s'));copyfile(D.ContractPath,folder);copyfile(D.DictionaryPath,folder);
[~,name,ext]=fileparts(D.ContractPath);p=fullfile(folder,[name ext]);fid=fopen(p,'a');fprintf(fid,' ');fclose(fid);
verifyError(t,@()getBOIReviewedOpticalDefinition(folder),'OxygenDynamics:ReviewedOpticalDefinitionChanged');
end
