function tests=testDandiConversion
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;addpath(fileparts(mfilename('fullpath')));
end
function testRectangularFractionalRateRoundtrip(t)
[root,file,P,X]=fixture();clean=onCleanup(@()rmdir(root,'s'));
out=fullfile(root,'out.tif');info=convertDandiReferenceStack(file,out,P);
verifyTrue(t,info.PixelRoundtripVerified);
verifyEqual(t,info.IntensityRange,[1 60]);
for k=1:3,verifyEqual(t,imread(out,k),reshape(X(k,:,:),4,5));end
end
function testProfileMismatchRejected(t)
[root,file,P]=fixture();clean=onCleanup(@()rmdir(root,'s'));out=fullfile(root,'out.tif');
bad=P;bad.ArchiveSHA256='wrong';verifyError(t,@()convertDandiReferenceStack(file,out,bad),'OxygenDynamics:ReferenceChecksum');
bad=P;bad.SampleHz=2;verifyError(t,@()convertDandiReferenceStack(file,out,bad),'OxygenDynamics:ReferenceRate');
bad=P;bad.PixelSize=3;verifyError(t,@()convertDandiReferenceStack(file,out,bad),'OxygenDynamics:ReferenceCalibration');
bad=P;bad.TimeAxisHdf5=1;verifyError(t,@()convertDandiReferenceStack(file,out,bad),'OxygenDynamics:ReferenceAxes');
verifyFalse(t,isfile(out));
end
function [root,file,P,X]=fixture()
root=tempname;mkdir(root);file=fullfile(root,'test.nwb');series='/acquisition/test';
X=reshape(uint16(1:60),3,4,5);h5create(file,[series '/data'],size(X),'Datatype','uint16');h5write(file,[series '/data'],X);
h5create(file,[series '/starting_time'],1);h5writeatt(file,[series '/starting_time'],'rate',1.5);
h5writeatt(file,series,'comments','Resolution: 2.5 um/pixel;');
P=struct('ArchiveSHA256',oxygenFileSHA256(file),'TimeAxisHdf5',3,'NwbShape',[5 4 3], ...
    'Frames',3,'Series',series,'SampleHz',1.5,'PixelSize',2.5);
end
