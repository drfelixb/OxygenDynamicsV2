function Out = runEventFirstLegacyComparison(folder)
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); addpath(root); setupOxygenDynamicsPath;
if nargin<1, folder=fullfile(root,'examples','eventFirst','comparison-results'); end
if ~isfolder(folder), mkdir(folder); end
rng(21); [yy,xx]=ndgrid(1:96,1:96); level=300+150*exp(-((yy-48).^2+(xx-48).^2)/1500);
raw=repmat(level,1,1,120)+2*randn(96,96,120);
raw(30:49,30:49,31:42)=raw(30:49,30:49,31:42)-80;
raw(40:69,40:69,76:95)=raw(40:69,40:69,76:95)+100;
saveastiff(uint16(raw),fullfile(folder,'synthetic_raw.tif'),struct('overwrite',true));
context=createLegacyRecordingContext(1,'synthetic-mouse','synthetic',4.75,'synthetic','synthetic','none','','','','N');
context.DetectorMode='compare'; context.EventFirstConfig=oxygenEventFirstConfig(struct('AnalysisRunID',"comparison-example"));
started=tic; Out=runOxygenDynamicsMaster(folder,context); fprintf('COMPARISON %.2f sec\n',toc(started)); disp(Out.Comparison);
R=loadOxygenEventFirstRecording(folder,context);
renderOxygenEventFirstReview(R,Out.EventFirstResult,fullfile(folder,'event-first-review.png'));
save(fullfile(folder,'ComparisonOutput.mat'),'Out','-v7.3');
L=createLegacyOxygenComparisonEnvelope(R,Out);
renderOxygenDetectorComparison(R,L,Out.EventFirstResult,fullfile(folder,'detector-comparison.png'));

end
