function [Summary,Statuses]=createOxygenMeasurementQC(Registry,Sinks,Surges)
% Recording-level measurement availability, not biological detection accuracy.
assert(ismember('RecordingID',Registry.Properties.VariableNames));
ids=string(Registry.RecordingID);
assert(numel(unique(ids))==numel(ids),'Duplicate registry RecordingID.');
Summary=table('Size',[0 27],'VariableTypes', ...
    [{'string','string'} repmat({'double'},1,25)], ...
    'VariableNames',{'RecordingID','EventType','DetectedEvents','ValidBaselineEvents', ...
    'FiniteAmplitudeEvents','UnavailableAmplitudeEvents','WrongDirectionAmplitudeEvents', ...
    'ValidBaselineFraction','FiniteAmplitudeFraction','TimingResolvedEvents','TimingUnresolvedEvents','TimingNotAssessedEvents','CloseNativeRunEvents','RecurrenceNotAssessedEvents','AmbiguousTrackingEvents','TrackingNotAssessedEvents','AmbiguousSiteAssignmentEvents','SiteAssignmentNotAssessedEvents','ShapeChangeLinkedEvents','ShapeChangeTrackingNotAssessedEvents','PotentialGapContinuationEvents','GapReviewNotAssessedEvents', ...
    'ContactTrackingEvents','ContactTrackingNotAssessedEvents','ContactWithRejectedCandidateEvents','ContactEventFrames','ContactEventDurationSec'});
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
        contactEvents=0;contactNotAssessed=n;rejectedContactEvents=0;contactFrames=0;contactDuration=0;
        if n>0
            present=ismember(surgeContactMetadataFields(),T.Properties.VariableNames);
            assert(~any(present)||all(present),'OxygenDynamics:InvalidContactQC','Contact metadata must be complete.');
            if all(present)
                count=T.ContactFrameCount;
                assert(all(isfinite(count)&count>=0&count==fix(count)) && ...
                    all(isfinite(T.ContactDurationSec)&T.ContactDurationSec>=0) && ...
                    all((count==0)==(T.ContactDurationSec==0)) && ...
                    all(ismember(T.ContactWithRejectedCandidate,[0 1])), ...
                    'OxygenDynamics:InvalidContactQC','Invalid contact count, duration or flag.');
                if ismember('AmbiguousTracking',T.Properties.VariableNames)
                    assert(isequal(logical(T.AmbiguousTracking),count>0), ...
                        'OxygenDynamics:InvalidContactQC','Contact exposure disagrees with tracking ambiguity.');
                end
                assert(all(~T.ContactWithRejectedCandidate|count>0), ...
                    'OxygenDynamics:InvalidContactQC','Rejected-neighbor contact requires a contact frame.');
                contactEvents=sum(count>0);contactNotAssessed=0;
                rejectedContactEvents=sum(T.ContactWithRejectedCandidate);
                contactFrames=sum(count);contactDuration=sum(T.ContactDurationSec);
            end
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
            valid/denom,finite/denom,resolved,unresolved,notAssessed,closeRuns,recurrenceNotAssessed,ambiguousTracking,trackingNotAssessed,ambiguousSite,siteNotAssessed,shapeEvents,shapeNotAssessed,gapEvents,gapNotAssessed, ...
            contactEvents,contactNotAssessed,rejectedContactEvents,contactFrames,contactDuration}; %#ok<AGROW>
    end
end
end
