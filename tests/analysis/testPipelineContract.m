function tests=testPipelineContract
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testTemporalStandardDeviation(t)
rng(41);X=randn(7,8,60).*reshape(linspace(.3,4,56),7,8)+10;
[A,Z]=normalizeToZStat(X);
verifyEqual(t,std(double(reshape(A,[],60)),0,1),ones(1,60),'AbsTol',1e-6);
verifyEqual(t,std(double(Z),0,3),ones(7,8),'AbsTol',1e-6);
verifyEqual(t,mean(double(Z),3),zeros(7,8),'AbsTol',1e-6);
[~,scaled]=normalizeToZStat(5*X+70);verifyEqual(t,Z,scaled,'AbsTol',1e-5);
end
function testConstantAndInvalidInput(t)
[A,Z]=normalizeToZStat(ones(5,6,8)*100);
verifyEqual(t,A,zeros(5,6,8,'single'));verifyEqual(t,Z,A);
[~,Z]=normalizeToZStat(repmat(reshape(1:30,5,6),1,1,61));
verifyEqual(t,Z,zeros(5,6,61,'single'));
X=ones(5,6,8);X(1)=NaN;
verifyError(t,@()normalizeToZStat(X),'OxygenDynamics:InvalidDetectionInput');
end
function testContractAndSettings(t)
C=oxygenPipelineContract();M=struct('PixelSize',2.5,'SampleF',2);
I=struct('PipelineContract',C,'AnalysisSchemaVersion',C.Schema, ...
    'AnalysisParams',createOxygenMasterParams(2.5,2),'NFrames',100, ...
    'RecordingAreaUm2',25,'SinkEligibleTissuePixels',(1:4)','SurgeEligibleTissuePixels',(1:4)');
validateOxygenPipelineContract(I,M);
old=I;old.AnalysisSchemaVersion='2.1';
verifyError(t,@()validateOxygenPipelineContract(old,M),'OxygenDynamics:ReanalysisRequired');
old=I;old.PipelineContract.Detector='previous';
verifyError(t,@()validateOxygenPipelineContract(old,M),'OxygenDynamics:ReanalysisRequired');
old=I;old.PipelineContract.Measurement='event-footprint-candidate-ledger-6';
verifyError(t,@()validateOxygenPipelineContract(old,M),'OxygenDynamics:ReanalysisRequired');
old=I;old.AnalysisParams.PercentileDetectionThres=98;
verifyError(t,@()validateOxygenPipelineContract(old,M),'OxygenDynamics:AnalysisSettingsMismatch');
old=I;old.AnalysisParams.PixelSize=5;
verifyError(t,@()validateOxygenPipelineContract(old,M),'OxygenDynamics:CalibrationMismatch');
end
function testSourceHashAndMutation(t)
folder=tempname;mkdir(folder);file=fullfile(folder,'raw.tif');
f=fopen(file,'wb');fwrite(f,'abc');fclose(f);
h=oxygenFileSHA256(file);
verifyEqual(t,h,'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
I=struct('RawFile',file,'RawSHA256',h,'DenoisedFile','','DenoisedSHA256','');
validateOxygenSourceFiles(I,folder);
f=fopen(file,'ab');fwrite(f,'d');fclose(f);
verifyError(t,@()validateOxygenSourceFiles(I,folder),'OxygenDynamics:SourceChanged');
end
