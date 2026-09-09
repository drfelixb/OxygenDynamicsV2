function [Summary,Statuses]=createOxygenMeasurementQC(Registry,Sinks,Surges)
% Recording-level measurement availability, not biological detection accuracy.
assert(ismember('RecordingID',Registry.Properties.VariableNames));
ids=string(Registry.RecordingID);
assert(numel(unique(ids))==numel(ids),'Duplicate registry RecordingID.');
Summary=table('Size',[0 22],'VariableTypes', ...
    [{'string','string'} repmat({'double'},1,20)], ...
    'VariableNames',{'RecordingID','EventType','DetectedEvents','ValidBaselineEvents', ...
    'FiniteAmplitudeEvents','UnavailableAmplitudeEvents','WrongDirectionAmplitudeEvents', ...
    'ValidBaselineFraction','FiniteAmplitudeFraction','TimingResolvedEvents','TimingUnresolvedEvents','TimingNotAssessedEvents','CloseNativeRunEvents','RecurrenceNotAssessedEvents','AmbiguousTrackingEvents','TrackingNotAssessedEvents','AmbiguousSiteAssignmentEvents','SiteAssignmentNotAssessedEvents','ShapeChangeLinkedEvents','ShapeChangeTrackingNotAssessedEvents','PotentialGapContinuationEvents','GapReviewNotAssessedEvents'});
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
        T=E(rows,:);n=height(T);valid=0;finite=0;wrong=0;resolved=0;unresolved=0;notAssessed=n;closeRuns=0;recurrenceNotAssessed=n;ambiguousTracking=0;trackingNotAssessed=n;ambiguousSite=0;siteNotAssessed=n;shapeEvents=0;shapeNotAssessed=n;gapEvents=0;gapNotAssessed=n;
        if n>0
            if ismember('TimingResolved',T.Properties.VariableNames)
                assert(all(ismember(T.TimingResolved,[0 1])),'OxygenDynamics:InvalidTimingQC','TimingResolved must be Boolean.');
                resolved=sum(T.TimingResolved);unresolved=n-resolved;notAssessed=0;
            end
            if ismember('CloseNativeRun',T.Properties.VariableNames)
                assert(all(ismember(T.CloseNativeRun,[0 1])),'OxygenDynamics:InvalidRecurrenceQC','CloseNativeRun must be Boolean.');
                closeRuns=sum(T.CloseNativeRun);recurrenceNotAssessed=0;
            end
            if ismember('AmbiguousTracking',T.Properties.VariableNames)
                assert(all(ismember(T.AmbiguousTracking,[0 1])),'Tracking QC must be Boolean.');
                ambiguousTracking=sum(T.AmbiguousTracking);trackingNotAssessed=0;
            end
            if ismember('SiteAssignmentAmbiguous',T.Properties.VariableNames)
                assert(all(ismember(T.SiteAssignmentAmbiguous,[0 1])),'Site assignment QC must be Boolean.');
                ambiguousSite=sum(T.SiteAssignmentAmbiguous);siteNotAssessed=0;
            end
            if ismember('ShapeChangeLinkCount',T.Properties.VariableNames)
                assert(all(isfinite(T.ShapeChangeLinkCount)&T.ShapeChangeLinkCount>=0&T.ShapeChangeLinkCount==fix(T.ShapeChangeLinkCount)));
                shapeEvents=sum(T.ShapeChangeLinkCount>0);shapeNotAssessed=0;
            end
            if ismember('PotentialGapContinuation',T.Properties.VariableNames)
                assert(all(ismember(T.PotentialGapContinuation,[0 1])));
                gapEvents=sum(T.PotentialGapContinuation);gapNotAssessed=0;
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
            valid/denom,finite/denom,resolved,unresolved,notAssessed,closeRuns,recurrenceNotAssessed,ambiguousTracking,trackingNotAssessed,ambiguousSite,siteNotAssessed,shapeEvents,shapeNotAssessed,gapEvents,gapNotAssessed}; %#ok<AGROW>
    end
end
end
