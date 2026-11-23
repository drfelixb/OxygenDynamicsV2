function Comparison = compareOxygenDetectors(Recording,LegacyResult,NewResult,Options)
% Compare explicit native geometry envelopes, never infer masks from legacy TIFFs.
% LegacyResult requires Detector, DetectorVersion, Events and EventFrameMasks.
% Events need EventID, EventType, IntervalStartSec, IntervalEndSec.
if nargin<4, Options=struct(); end
if ~isfield(Options,'MinIoU'), Options.MinIoU=0.1; end
validateattributes(Options.MinIoU,{'numeric'},{'scalar','>',0,'<=',1});
if isfield(LegacyResult,'RunManifest'), label=LegacyResult.RunManifest.Detector; else, label=LegacyResult.Detector; end
assert(string(label)~="eventFirst",'eventFirst:Comparison','Legacy side must have explicit distinct detector origin.');
M=matchOxygenEventMasks(LegacyResult,NewResult,Options.MinIoU);
Comparison=struct('Matches',M.Matches,'MatchedPairs',M.TruePositives, ...
    'UnmatchedLegacyEvents',M.FalseNegatives,'UnmatchedEventFirstEvents',M.FalsePositives, ...
    'LegacyEventCount',height(LegacyResult.Events),'EventFirstCount',height(NewResult.Events), ...
    'MinIoU',M.MinIoU,'MatchingRule',M.MatchingRule);
Comparison.RecordingID=string(Recording.RecordingID);
Comparison.LeftDetector=string(label); Comparison.RightDetector="eventFirst";
Comparison.Interpretation="correspondence only; neither detector is annotation ground truth";
end
