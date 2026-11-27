function [amplitude,source,signConvention]=getBOISinkBurdenAmplitude(E,SelectionPolicy)
% One selector shared by event/recording burden and window composites.
if nargin<2,SelectionPolicy=[];end
selection=boiBurdenSelectionPolicy(E,SelectionPolicy);
amplitude=[];source=strings(height(E),1);signConvention='positive_drop_percent';
if ismember('EventReferenceVersion',E.Properties.VariableNames)
    P=boiEventReferencePolicy; Q=boiEventReferencePolicy(0);
    assert(all(ismember(string(E.EventReferenceVersion),[string(P.Version),string(Q.Version)]))&& ...
        all(ismember({'EventAmplitudePercent','EventAmplitudeAvailable'},E.Properties.VariableNames)), ...
        'OxygenDynamics:EventReferenceVersion','Unsupported or incomplete event-reference result.');
    amplitude=double(E.EventAmplitudePercent);
    amplitude(~E.EventAmplitudeAvailable)=NaN;
    source="EventAmplitudePercent ("+string(E.EventReferenceVersion)+")";
    if ~selection.IncludeFiniteNegative,amplitude(amplitude<0)=NaN;end
    if selection.IncludeFiniteNegative,amplitude(~isfinite(amplitude))=NaN;end
    return
end
if ismember('NormOxySinkAmpPercent',E.Properties.VariableNames)
    amplitude=numericColumn(E.NormOxySinkAmpPercent);source(:)="NormOxySinkAmpPercent";
elseif ismember('NormOxySinkAmp',E.Properties.VariableNames)
    amplitude=100*numericColumn(E.NormOxySinkAmp);source(:)="NormOxySinkAmp_x100";
else,return;end
if ismember('AmplitudeSignConvention',E.Properties.VariableNames)
    neg=string(E.AmplitudeSignConvention)=="negative_drop_percent";
    amplitude(neg)=-amplitude(neg);
end
if ismember('EpisodeReferenceVersion',E.Properties.VariableNames)
    P=boiEpisodeReferencePolicy; Q=boiEpisodeReferencePolicy(0);
    assert(all(ismember(string(E.EpisodeReferenceVersion),[string(P.Version),string(Q.Version)])), ...
        'OxygenDynamics:EpisodeVersion','Unsupported derived reference version.');
    amplitude=double(E.EpisodeAmplitudePercent);
    valid=string(E.EpisodeReferenceStatus)=="valid";
    amplitude(~valid)=NaN;
    source="EpisodeAmplitudePercent ("+string(E.EpisodeReferenceVersion)+")";
end
if ~selection.IncludeFiniteNegative,amplitude(amplitude<0)=NaN;end
if selection.IncludeFiniteNegative,amplitude(~isfinite(amplitude))=NaN;end
end
function v=numericColumn(v)
% Retain the existing legacy table-column conversion behavior.
if isnumeric(v)||islogical(v),v=double(v);
elseif iscell(v),v=cellfun(@safeCellMean,v);
else,v=str2double(string(v));end
v=v(:);
end
