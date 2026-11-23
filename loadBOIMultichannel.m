function P=loadBOIMultichannel(file)
% Reopen a completed paired result, even after moving the whole result folder.
setupOxygenDynamicsPath;
if isfolder(file), file=fullfile(file,'Multichannel.mat'); end
statusFile=fullfile(fileparts(file),'PairStatus.json');
assert(isfile(statusFile),'BOIPair:Incomplete','Select Multichannel.mat in a completed result folder.');
status=jsondecode(fileread(statusFile));
assert(strcmp(status.Status,'complete') && isfield(status,'ResultSHA256'),'BOIPair:Incomplete','Paired output is incomplete.');
assert(strcmp(oxygenFileSHA256(file),status.ResultSHA256),'BOIPair:Changed','Paired result differs from its completion record.');
s=load(file,'Pair'); P=s.Pair;
assert(strcmp(P.Schema,'boi-multichannel-1'),'BOIPair:Schema','Unsupported paired result.');
if ~ismember('MeanDurationSec',P.Summary.Properties.VariableNames)
    P.Summary=boiPairSummaryMeans(P.Summary,P.Events);
end
end
