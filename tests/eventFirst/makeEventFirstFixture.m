function [R,C] = makeEventFirstFixture()
rng(17); n=120; x=100+0.4*randn(12,14,n);
x(4:6,5:7,31:36)=x(4:6,5:7,31:36)-20;
x(8:10,9:11,71:76)=x(8:10,9:11,71:76)+30;
R=struct('RecordingID',"synthetic",'MouseID',"fixture",'SourceIdentity',"seed17", ...
    'SignalProvenance',"synthetic intensity; independent additive Gaussian noise", ...
    'PixelSizeUm',[2 3],'NFrames',n,'Intensity',x,'AxisOrder',"YXT",'ValidMask',true(12,14), ...
    'TissueMask',true(12,14),'fs',2,'DarkOffset',0,'DarkOffsetProvenance',"known synthetic zero");
C=oxygenEventFirstConfig(struct('SpatialScalesUm',0,'BaselineWindowSec',30,'MinDurationSec',1));
end
