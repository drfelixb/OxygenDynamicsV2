function tests=testSurgeMovieRecipe
tests=functiontests(localfunctions);
end
function testGeometryAndFractions(t)
[m,f,r]=createSurgeMovieRecipe(true(128),4.75,600);
verifyTrue(t,any(m(:,:,1)&m(:,:,4),'all'));verifyEqual(t,r.ControlEligibleFractions,[1 1]);
verifyEqual(t,find(f(1,:)>0,1),101);verifyEqual(t,max(f(1,:)),.2,'AbsTol',1e-12);
verifyEqual(t,min(f(6,:)),-.2,'AbsTol',1e-12);verifyEqual(t,find(f(2,:)>0,1,'last'),384);
end
function testDeterministicAndPhysical(t)
[a,f,r]=createSurgeMovieRecipe(true(256),2.35,1200);[b,g,s]=createSurgeMovieRecipe(true(256),2.35,1200);
verifyEqual(t,a,b);verifyEqual(t,f,g);verifyEqual(t,r,s);verifyEqual(t,r.RadiusPixels*2.35,85.5,'AbsTol',1e-12);
end
function testNoTissueFails(t)
verifyError(t,@()createSurgeMovieRecipe(false(128),4.75,600),'OxygenDynamics:NoEligibleChallengePosition');
end
