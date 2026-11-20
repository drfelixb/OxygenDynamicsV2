function T=completeOxygenBurdenTimeSeries(T,Registry)
% Keep valid zero-event recordings in the frame-wise output and its group means.
if ~all(ismember({'NFrames','SampleF'},Registry.Properties.VariableNames)),return;end
for i=1:height(Registry)
    R=Registry(i,:);
    if ~isempty(T) && any(string(T.RecordingID)==string(R.RecordingID)),continue;end
    n=R.NFrames;fs=R.SampleF;
    if ~isfinite(n)||n<1||~isfinite(fs)||fs<=0,continue;end
    Z=table(repmat(i,n,1),repmat(string(R.RecordingID),n,1), ...
        'VariableNames',{'RecordingIndex','RecordingID'});
    for f={'Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'}
        Z.(f{1})=repmat(string(R.(f{1})),n,1);
    end
    Z.Frame=(1:n)';Z.TimeSec=(0:n-1)'/fs;Z.SampleFs=repmat(fs,n,1);
    Z.RecordingDuration_sec=repmat(R.RecordingDuration_sec,n,1);
    Z.ActiveHypoxicEvents=zeros(n,1);Z.HypoxicBurdenOverTime=zeros(n,1);
    Z.HypoxicBurdenPerMm2OverTime=zeros(n,1);
    if ~isfinite(R.RecordingArea_um2)||R.RecordingArea_um2<=0,Z.HypoxicBurdenPerMm2OverTime(:)=NaN;end
    Z.Formula=repmat({'sum(active PerEventBurdenContribution / event duration)'},n,1);
    Z.Units=repmat({'percent * um^2'},n,1);Z.UnitsPerMm2=repmat({'percent * um^2 per 1 mm^2 FOV'},n,1);
    T=[T;Z]; %#ok<AGROW>
end
% RecordingIndex is a convenience; persistent identity is RecordingID.
if ~isempty(T)
    for i=1:height(Registry),T.RecordingIndex(string(T.RecordingID)==string(Registry.RecordingID(i)))=i;end
end
end
