function Info = writeAutomaticAmplitudeExport(Folder,Workbook,D)
% New companion artifacts; old result columns and sheets are untouched.
Info=struct('Report',fullfile(Folder,'AutomaticAmplitudeGuide.md'), ...
    'AverageCountsCSV',fullfile(Folder,'AutomaticAverageCounts.csv'), ...
    'AvailabilityCSV',fullfile(Folder,'AutomaticAmplitudeAvailability.csv'));
writetable(D.Definitions,Workbook,'Sheet','AutomaticAmplitudeGuide');
writetable(D.AverageCounts,Workbook,'Sheet','AutomaticAverageCounts');
writetable(D.Availability,Workbook,'Sheet','AutomaticAmplitudeAvailability');
writetable(D.Definitions,fullfile(Folder,'AutomaticAmplitudeDefinitions.csv'));
writetable(D.AverageCounts,Info.AverageCountsCSV);
writetable(D.Availability,Info.AvailabilityCSV);
AutomaticAmplitudeExport=D; %#ok<NASGU>
save(fullfile(Folder,'AutomaticAmplitudeExport.mat'),'AutomaticAmplitudeExport');
f=fopen(Info.Report,'w');assert(f>=0,'Cannot write automatic amplitude guide.');cleanup=onCleanup(@()fclose(f)); %#ok<NASGU>
fprintf(f,'# Automatic optical amplitude and summary guide\n\n');
fprintf(f,'Automatic sink amplitude is a positive optical drop; automatic surge amplitude is a positive optical increase. A fraction of 0.05 is 5%%. Negative finite values stay negative in event rows and site means. The reviewed-pocket corrected measurement is separate and uses a negative sign for a downward excursion. These values do not measure oxygen concentration or absolute oxygen pressure.\n\n');
fprintf(f,'The signal is preserved-input TIFF intensity averaged over the fixed union of native event pixels. The reference is the mean of the configured immediately preceding window (normally 20 seconds), before the saved measurement start. All requested samples must be finite and free of overlapping native detections of either sign, with a positive mean. No earlier search or post-event replacement is used. This screen does not prove the reference is physiologically suitable. Sink measurement bounds are refined; surge bounds are native. No correction is fitted for these exports.\n\n');
fprintf(f,'## Which observations contribute?\n\nSite means use finite event fractions, including negatives. Grouped site sheets list sites under each mouse; they do not average those sites into a mouse result. Recording burden-amplitude means use nonnegative drop-oriented percentages (zero included). Area, duration and composite means each have their own contributing subset. Within-mouse means require every recording value; one missing recording makes the mouse mean unavailable. Group means give each finite mouse mean equal weight, regardless of event or recording counts.\n\n');
fprintf(f,'AutomaticAverageCounts.csv gives the existing value, contributing count, total count, observation unit and rule for each affected mean or median. Within-mouse counts show non-NaN recording inputs, but a partial count does not authorize a partial mean. Count rules follow the existing finite/omitnan/strict arithmetic exactly.\n\n');
fprintf(f,'AutomaticAmplitudeAvailability.csv separates unavailable amplitudes, negative finite amplitudes, negative drop-oriented amplitudes excluded from burden, and unavailable unnormalized event composites. These categories overlap: an unavailable or excluded amplitude also prevents its composite. An available amplitude may still have an unavailable composite because area or duration is missing. Normalized composite means have their own counts in AutomaticAverageCounts.csv. Blank composite counts mean not assessed (missing identity/support for a site) or not defined (surges), not zero. A missing amplitude never deletes the event from detection counts or coverage.\n\n');
fprintf(f,'## Example observations from this export\n\n| Level | Mouse / site | Metric | Value | Contributing / total | Observation unit |\n|---|---|---|---:|---:|---|\n');
A=D.AverageCounts;selected=[];
for kind=["sink","surge"]
    q=find(A.SummaryLevel=="site" & A.EventType==kind);selected=[selected;q(1:min(2,numel(q)))]; %#ok<AGROW>
end
q=find(A.SummaryLevel=="recording");selected=[selected;q(1:min(7,numel(q)))];
for level=["within_mouse","equal_mouse_group"]
    q=find(A.SummaryLevel==level & (contains(A.Metric,'MeanBurdenAmplitudePercent') | contains(A.Metric,'Burden_AmplitudeComposite')));
    selected=[selected;q(1:min(4,numel(q)))]; %#ok<AGROW>
end
for i=reshape(selected,1,[])
    T=A(i,:);identity=T.Mouse;
    if strlength(T.SiteID)>0,identity=identity+" / "+T.EventType+" site "+T.SiteID;end
    fprintf(f,'| %s | %s | %s | %.15g %s | %d / %d | %s |\n',levelLabel(T.SummaryLevel),identity,metricLabel(T.Metric),T.Value,T.Units,T.ContributingCount,T.TotalCount,T.CountUnit);
end
fprintf(f,'\n## Recording availability\n\nCounts below overlap; they must not be added together. Negative exclusion is assessed after explicit sign-provenance conversion. Unavailable composite counts concern the unnormalized event product. NaN means not defined/assessed, not zero.\n\n| Recording | Sign | Total events | Unavailable amplitude | Negative amplitude | Negative excluded from burden | Unavailable composite |\n|---|---|---:|---:|---:|---:|---:|\n');
V=D.Availability(D.Availability.SummaryLevel=="recording",:);
for i=1:min(6,height(V))
    fprintf(f,'| %s | %s | %d | %d | %d | %g | %g |\n',V.RecordingID(i),V.EventType(i),V.TotalEvents(i),V.UnavailableAmplitudeEvents(i),V.NegativeAmplitudeEvents(i),V.NegativeAmplitudeExcludedFromBurdenEvents(i),V.UnavailableCompositeEvents(i));
end
fprintf(f,'\nThe full CSV tables and workbook companion sheets retain recording, mouse, site and group identity. AutomaticAmplitudeDefinitions.csv gives source, reference, formula, sign, units and interpretation limits. Existing result identifiers and numerical values are preserved.\n');
end

function text=levelLabel(level)
switch level
    case "site",text="Site";
    case "recording",text="Recording";
    case "within_mouse",text="Mouse (recording mean)";
    otherwise,text="Group (equal mouse weights)";
end
end
function text=metricLabel(metric)
metric=erase(metric,"_Mean");
switch metric
    case "MeanOxySinkEvent_NormAmp",text="Mean automatic optical drop";
    case "MeanOxySurgeEvent_NormAmp",text="Mean automatic optical increase";
    case "MeanBurdenAmplitudePercent",text="Mean nonnegative optical drop";
    case "MeanBurdenArea_um2",text="Mean event area";
    case "MeanBurdenDuration_sec",text="Mean saved event duration";
    case "MeanEventBurdenContribution",text="Mean amplitude-area-duration product";
    case "MedianEventBurdenContribution",text="Median amplitude-area-duration product";
    case "MeanEventBurdenContribution_per_mm2",text="Mean product per mm2";
    case "MedianEventBurdenContribution_per_mm2",text="Median product per mm2";
    case "Burden_AmplitudeComposite",text="Total amplitude-area-duration product";
    otherwise,text=metric;
end
end
