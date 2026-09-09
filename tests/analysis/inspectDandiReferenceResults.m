function qc=inspectDandiReferenceResults(outputRoot)
% Numerical QC and label-review inventory; detections are not ground truth.
R=load(fullfile(outputRoot,'reference-report.mat'),'report');
assert(strcmp(R.report.Status,'master_and_stats_completed'));
folder=fileparts(R.report.StatsOutput);
D=load(R.report.StatsOutput,'RecordingRegistry','RecordingWindowMetrics','EventMeasurementQC','EventBaselineStatusCounts');
assert(height(D.RecordingRegistry)==1 && D.RecordingRegistry.NFrames==600);
assert(D.RecordingRegistry.RecordingDuration_sec==600);
assert(isfinite(D.RecordingRegistry.RecordingArea_um2) && D.RecordingRegistry.RecordingArea_um2>0);
fraction=D.RecordingWindowMetrics.MeanOccupiedTissueFraction;
assert(all(isfinite(fraction) & fraction>=0 & fraction<=1+1e-12));
qc=struct('MeanOccupiedTissueFraction',fraction,'LabelsAvailable',false);
for kind=["Sink","Surge"]
    S=load(fullfile(folder,char(kind+"Table4LME.mat")));
    E=load(fullfile(folder,char(kind+"EventTable.mat")));
    sn=fieldnames(S);en=fieldnames(E);sites=S.(sn{1});events=E.(en{1});
    qc.(char(kind+"Sites"))=height(sites);qc.(char(kind+"Events"))=height(events);
    row=D.EventMeasurementQC(D.EventMeasurementQC.EventType==lower(kind),:);
    assert(height(row)==1 && row.DetectedEvents==height(events));
    qc.(char(kind+"FiniteAmplitudes"))=row.FiniteAmplitudeEvents;
    qc.(char(kind+"WrongDirectionAmplitudes"))=row.WrongDirectionAmplitudeEvents;
    if ~isempty(events)
        assert(all(events.StartFrame>=1 & events.EndFrame<=600 & events.EndFrame>=events.StartFrame));
        assert(all(abs(events.DurationSec-(events.EndFrame-events.StartFrame+1))<1e-10));
        assert(ismember('BaselineStatus',events.Properties.VariableNames));
        qc.(char(kind+"ValidBaselines"))=sum(string(events.BaselineStatus)=="valid");
        assert(row.ValidBaselineEvents==qc.(char(kind+"ValidBaselines")));
        statuses=unique(string(events.BaselineStatus));
        counts=arrayfun(@(s)sum(string(events.BaselineStatus)==s),statuses);
        writetable(table(statuses,counts),fullfile(outputRoot,char(lower(kind)+"-baseline-status.csv")));
    else
        qc.(char(kind+"ValidBaselines"))=0;
    end
end
save(fullfile(outputRoot,'reference-qc.mat'),'qc');
fid=fopen(fullfile(outputRoot,'reference-qc.json'),'w');assert(fid>=0);
closer=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(qc,'PrettyPrint',true));
disp(qc);
end
