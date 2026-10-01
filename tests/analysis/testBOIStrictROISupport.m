function tests=testBOIStrictROISupport
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testIndependentArithmetic(t)
X=reshape(sin(1:5*6*12)+(1:5*6*12)/100,5,6,12);M=false(5,6);M(2:5,2:5)=true;M(3,3)=false;
[A,Z]=normalizeToZStat(X,M);
v=reshape(X,[],12);v=v(M(:),:);a=zeros(size(v));
for f=1:12
    mu=sum(v(:,f))/size(v,1);sd=sqrt(sum((v(:,f)-mu).^2)/(size(v,1)-1));a(:,f)=(v(:,f)-mu)/sd;
end
z=zeros(size(a));
for p=1:size(a,1)
    mu=sum(a(p,:))/12;sd=sqrt(sum((a(p,:)-mu).^2)/11);z(p,:)=(a(p,:)-mu)/sd;
end
flatA=reshape(A,[],12);flatZ=reshape(Z,[],12);
verifyEqual(t,flatA(M(:),:),single(a),'AbsTol',single(2e-7));
verifyEqual(t,flatZ(M(:),:),single(z),'AbsTol',single(2e-7));
[~,F,Q]=preprocessDetectionStack(X,2,'eligibleMask',M);
% Independent explicit neighbor averaging, without conv2 or the production normalizer.
manual=zeros(size(X),'single');weights=zeros(size(M));
for y=1:5
    for x=1:6
        ys=max(1,y-2):min(5,y+2);xs=max(1,x-2):min(6,x+2);local=M(ys,xs);
        weights(y,x)=nnz(local)/25;
        if ~M(y,x),continue;end
        for f=1:12
            patch=Z(ys,xs,f);manual(y,x,f)=single(sum(double(patch(local)))/nnz(local));
        end
    end
end
verifyEqual(t,F,manual,'AbsTol',single(2e-7)); % smooth/2=1 => unchanged temporal samples
verifyEqual(t,Q.NeighborWeightMap,weights,'AbsTol',1e-15);
verifyEqual(t,flatZ(~M(:),:),zeros(nnz(~M),12,'single'));
end
function testExteriorIndependenceAndBothSigns(t)
rng(720);M=false(32);M(6:26,7:27)=true;M(14:16,15:17)=false;
X=100+randn(32,32,60);X(10:18,8:15,20:28)=X(10:18,8:15,20:28)-40;
X(22:30,18:25,38:50)=X(22:30,18:25,38:50)+60;
Y=reshape(X,[],60);Y(~M(:),:)=1e6*randn(nnz(~M),60);Y=reshape(Y,size(X));
D=single(detrend_custom(X,3));E=single(detrend_custom(Y,3));
[Z,F]=preprocessDetectionStack(D,4,'eligibleMask',M);
[Z2,F2]=preprocessDetectionStack(E,4,'eligibleMask',M);
verifyEqual(t,Z,Z2);verifyEqual(t,F,F2);
for kind={'invert','mat2gray'}
    p=params(kind{1});a=detectFrameRegionCandidates(F,M,p);b=detectFrameRegionCandidates(F2,M,p);
    verifyEqual(t,a,b);verifyGreaterThan(t,sum(cellfun(@numel,a)),0);
    for f=1:numel(a)
        for k=1:numel(a{f}),verifyTrue(t,all(M(a{f}(k).PixelIdxList)));end
    end
end
end
function testBoundaryWeakStrongRecurrentSustained(t)
M=false(20);M(5:16,5:16)=true;
for sign=[-1,1]
    for strength=[.001,1000]
        X=zeros(20,20,40);X(3:8,8:11,6:9)=sign*strength;
        X(3:8,8:11,18:32)=sign*strength;
        p=params('mat2gray');if sign<0,p.frameTransform='invert';end
        p.percentileThreshold=80;
        c=detectFrameRegionCandidates(X,M,p);
        expected=find(M & repmat((1:20)'<=8,1,20)&repmat((1:20)>=8 & (1:20)<=11,20,1));
        for f=1:40
            if ismember(f,[6:9,18:32])
                verifyEqual(t,numel(c{f}),1);verifyEqual(t,c{f}.PixelIdxList,expected);
            else,verifyEmpty(t,c{f});end
        end
    end
end
end
function testConstantEmptyAndInvalid(t)
M=false(8);M(2:6,2:6)=true;
[Z,F]=preprocessDetectionStack(100*ones(8,8,30),4,'eligibleMask',M);
verifyEqual(t,Z,zeros(8,8,30,'single'));verifyEqual(t,F,Z);
for kind={'invert','mat2gray'}
    c=detectFrameRegionCandidates(F,M,params(kind{1}));verifyTrue(t,all(cellfun(@isempty,c)));
end
for mask={false(8),true(7),ones(8),[]}
    verifyError(t,@()normalizeToZStat(ones(8,8,5),mask{1}),'OxygenDynamics:InvalidDetectionSupport');
end
X=ones(8,8,5);X(3,3,1)=NaN;
verifyError(t,@()normalizeToZStat(X,M),'OxygenDynamics:InvalidDetectionInput');
verifyError(t,@()detectFrameRegionCandidates(F,false(8),params('invert')),'OxygenDynamics:InvalidDetectionSupport');
end
function testExactFinalContainment(t)
S=table({{[12;13],[],[13;14]}},'VariableNames',{'FramePixels'});
validateBOINativeSupport(S,12:14,[8,8]);
verifyError(t,@()validateBOINativeSupport(S,12:13,[8,8]),'OxygenDynamics:NativeSupportViolation');
validateBOINativeSupport(S([],:),12:14,[8,8]);
S.FramePixels{1}{1}=NaN;
verifyError(t,@()validateBOINativeSupport(S,12:14,[8,8]),'OxygenDynamics:NativeSupportViolation');
end
function testLegacyReplayAndVersion(t)
old=oxygenPipelineContract();roi=oxygenPipelineContract('craniotomy-roi-1');
verifyEqual(t,old.Schema,'3.0-dev');verifyNotEqual(t,old,roi);
verifyEqual(t,getBOISupportProfile(struct()),'whole-image');
verifyError(t,@()oxygenPipelineContract('craniotomy'),'OxygenDynamics:InvalidSupportProfile');
verifyError(t,@()oxygenPipelineContract(''),'OxygenDynamics:InvalidSupportProfile');
rng(6);X=randn(10,11,30);
[~,Z]=normalizeToZStat(X);[Z2,F]=preprocessDetectionStack(X,4);
k=ones(9)/81;oldF=zeros(size(Z),'single');
for f=1:30,oldF(:,:,f)=single(conv2(Z(:,:,f),k,'same'));end
oldF=smoothdata(oldF,3,'gaussian',2);
verifyEqual(t,Z2,Z);verifyEqual(t,F,oldF);
end
function testRejectMixedSignMethods(t)
f=tempname;mkdir(f);cleanup=onCleanup(@()rmdir(f,'s'));
AnalysisInfo=struct('PipelineContract',oxygenPipelineContract());save(fullfile(f,'sink.mat'),'AnalysisInfo');
AnalysisInfo.BOISupportProfile='craniotomy-roi-1';AnalysisInfo.PipelineContract=oxygenPipelineContract('craniotomy-roi-1');save(fullfile(f,'surge.mat'),'AnalysisInfo');
Registry=table("R",'VariableNames',{'RecordingID'});
Recordings=struct('SinksMatFile',fullfile(f,'sink.mat'),'SurgesMatFile',fullfile(f,'surge.mat'));
verifyError(t,@()buildBOIRecordingInputContracts(Registry,Recordings),'OxygenDynamics:MixedSupportProfiles');
end
function testSpatialBinMeansUseIncludedObservations(t)
M=true(4);M(1,1)=false;X=ones(4,4,8,'single')*7;X(1,1,:)=0;
trace=extractSpatialBinTraces(X,[1,1],4,M);
verifyEqual(t,trace,ones(1,8)*7);
legacy=extractSpatialBinTraces(X,[1,1],4);
verifyEqual(t,legacy,ones(1,8)*7*15/16);
X(1,1,:)=100000;verifyEqual(t,extractSpatialBinTraces(X,[1,1],4,M),trace);
end
function p=params(kind)
p=struct('percentileThreshold',90,'minArea',1,'maxArea',Inf,'minCircularity',0, ...
    'maxOutsideFraction',.5,'frameTransform',kind,'restrictToSupport',true);
end
