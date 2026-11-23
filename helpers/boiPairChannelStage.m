function message=boiPairChannelStage(channel,sensor,stage)
% Use the RC1 recording workflow's actual stage transitions.
switch string(stage)
    case "preflight",  detail="Checking channel inputs";
    case "staging",    detail="Copying and verifying channel inputs";
    case "analysis",   detail="Detecting and measuring sinks and surges";
    case "statistics", detail="Calculating statistics and writing channel results";
    case "complete",   detail="Channel analysis complete";
    case "evidence",   detail="Reading the saved event measurements";
    otherwise,        detail=string(stage);
end
letters='AB';
message=sprintf('Channel %s (%s)  ·  %s',letters(channel),sensor,detail);
end
