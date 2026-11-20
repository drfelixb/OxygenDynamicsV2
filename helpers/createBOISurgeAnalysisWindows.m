function [W,F]=createBOISurgeAnalysisWindows(Registry,Contracts,Sites,Events,Windows)
%CREATEBOISURGEANALYSISWINDOWS Bind surge denominators to saved source evidence.
if nargin<5,Windows=table();end
assert(iscell(Contracts)&&numel(Contracts)==height(Registry), ...
    'OxygenDynamics:InputContractIdentity','One input contract per registry row is required.');
surgeRegistry=Registry; % The original sink registry and outputs remain unchanged.
for k=1:height(Registry)
    c=Contracts{k};r=Registry(k,:);
    assert(strcmp(c.Schema,'boi-recording-input-1')&&string(c.RecordingID)==string(r.RecordingID)&& ...
        string(c.RawSHA256)==string(r.RawSHA256)&&isequal(c.NFrames,r.NFrames)&& ...
        isequal(c.SampleHz,r.SampleF)&&isequal(c.PixelSizeUm,r.PixelSize), ...
        'OxygenDynamics:InputContractIdentity','Surge source, clock and calibration must match the registry.');
    p=c.SurgeEligibleTissuePixels(:);
    assert(isnumeric(p)&&all(isfinite(p)&p>=1&p<=prod(c.FrameSize)&p==fix(p))&&numel(unique(p))==numel(p), ...
        'OxygenDynamics:InvalidNativeSupport','Invalid saved surge tissue support.');
    surgeRegistry.RecordingArea_um2(k)=numel(p)*c.PixelSizeUm^2;
    if ismember('RecordingID',Sites.Properties.VariableNames)&&ismember('EligibleTissuePixels',Sites.Properties.VariableNames)
        s=find(string(Sites.RecordingID)==string(r.RecordingID));
        for j=s(:)'
            assert(isequal(sort(Sites.EligibleTissuePixels{j}(:)),sort(p)), ...
                'OxygenDynamics:TissueAreaMismatch','Surge site support differs from the saved input contract.');
        end
    end
end
[W,F]=createOxygenAnalysisWindows(surgeRegistry,Sites,Events,Windows,'surge');
end
