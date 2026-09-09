function [Summary,Statuses]=createOxygenMeasurementQC(Registry,Sinks,Surges)
% Recording-level measurement availability, not biological detection accuracy.
assert(ismember('RecordingID',Registry.Properties.VariableNames));
ids=string(Registry.RecordingID);
assert(numel(unique(ids))==numel(ids),'Duplicate registry RecordingID.');
Summary=table('Size',[0 12],'VariableTypes', ...
    {'string','string','double','double','double','double','double','double','double','double','double','double'}, ...
    'VariableNames',{'RecordingID','EventType','DetectedEvents','ValidBaselineEvents', ...
    'FiniteAmplitudeEvents','UnavailableAmplitudeEvents','WrongDirectionAmplitudeEvents', ...
    'ValidBaselineFraction','FiniteAmplitudeFraction','TimingResolvedEvents','TimingUnresolvedEvents','TimingNotAssessedEvents'});
Statuses=table('Size',[0 4],'VariableTypes',{'string','string','string','double'}, ...
    'VariableNames',{'RecordingID','EventType','BaselineStatus','EventCount'});
inputs={Sinks,Surges};kinds=["sink","surge"];
amplitudes={'NormOxySinkAmp','NormOxySurgeAmp'};
for k=1:2
    E=inputs{k};amp=amplitudes{k};
    if ~isempty(E)
        assert(all(ismember({'RecordingID','BaselineStatus',amp},E.Properties.VariableNames)), ...
            'OxygenDynamics:MissingMeasurementProvenance','Event measurement provenance is required.');
        assert(all(ismember(string(E.RecordingID),ids)), ...
            'OxygenDynamics:UnknownRecording','Event has no matching recording.');
    end
    for r=1:numel(ids)
        rows=false(height(E),1);
        if ~isempty(E),rows=string(E.RecordingID)==ids(r);end
        T=E(rows,:);n=height(T);valid=0;finite=0;wrong=0;resolved=0;unresolved=0;notAssessed=n;
        if n>0
            if ismember('TimingResolved',T.Properties.VariableNames)
                assert(all(ismember(T.TimingResolved,[0 1])),'OxygenDynamics:InvalidTimingQC','TimingResolved must be Boolean.');
                resolved=sum(T.TimingResolved);unresolved=n-resolved;notAssessed=0;
            end
            status=string(T.BaselineStatus);
            assert(all(~ismissing(status) & strlength(status)>0),'Missing event baseline status.');
            valid=sum(status=="valid");finite=sum(isfinite(T.(amp)));
            wrong=sum(isfinite(T.(amp)) & T.(amp)<0);
            assert(all(~isfinite(T.(amp)) | status=="valid"), ...
                'OxygenDynamics:InconsistentMeasurement','Finite amplitude requires a valid baseline.');
            for name=reshape(unique(status),1,[])
                Statuses(end+1,:)={ids(r),kinds(k),name,sum(status==name)}; %#ok<AGROW>
            end
        end
        denom=n;if n==0,denom=NaN;end
        Summary(end+1,:)={ids(r),kinds(k),n,valid,finite,n-finite,wrong, ...
            valid/denom,finite/denom,resolved,unresolved,notAssessed}; %#ok<AGROW>
    end
end
end
