function [amplitude,source,signConvention]=getBOISinkBurdenAmplitude(E)
% One selector shared by event/recording burden and window composites.
amplitude=[];source=strings(height(E),1);signConvention='positive_drop_percent';
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
    P=boiEpisodeReferencePolicy;
    assert(all(string(E.EpisodeReferenceVersion)==string(P.Version)), ...
        'OxygenDynamics:EpisodeVersion','Unsupported derived reference version.');
    amplitude=double(E.EpisodeAmplitudePercent);
    valid=string(E.EpisodeReferenceStatus)=="valid";
    amplitude(~valid)=NaN;
    source(:)="EpisodeAmplitudePercent ("+string(P.Version)+")";
end
amplitude(amplitude<0)=NaN;
end
function v=numericColumn(v)
% Retain the existing legacy table-column conversion behavior.
if isnumeric(v)||islogical(v),v=double(v);
elseif iscell(v),v=cellfun(@safeCellMean,v);
else,v=str2double(string(v));end
v=v(:);
end
