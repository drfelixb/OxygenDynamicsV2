function Report = runOxygenDetectionBenchmark(Manifest,Configurations)
% Local, no-download benchmark. Each entry: Recording, Partition, optional Annotation.
% Annotation requires Events, EventFrameMasks, Provenance (independent/manual/synthetic).
% Optional UncertainEventIDs are removed from truth AND overlapping detections.
% Configurations are frozen before calling heldout data; no fitting occurs here.
if isstruct(Configurations), Configurations=num2cell(Configurations); end
mice=arrayfun(@(m)string(m.Recording.MouseID),Manifest); parts=string({Manifest.Partition});
mice=mice(:); parts=parts(:);
for mouse=unique(mice)'
    assert(numel(unique(parts(mice==mouse)))==1,'eventFirst:Leakage','All sessions of a mouse must share a partition.');
end
rows=struct([]); Report.Runs=cell(numel(Manifest),numel(Configurations));
for i=1:numel(Manifest)
    for j=1:numel(Configurations)
        R=Manifest(i).Recording; started=tic;
        X=runOxygenEventFirst(R,Configurations{j}); Report.Runs{i,j}=X;
        for threshold=[0.1 0.25 0.5]
            P=NaN; recall=NaN; fp=NaN; tp=NaN; fn=NaN; splits=NaN; merges=NaN; iou=NaN; onset=NaN; offset=NaN; amp=NaN; area=NaN; duration=NaN;
            status="no independent annotations; detection counts only";
            if isfield(Manifest(i),'Annotation') && ~isempty(Manifest(i).Annotation)
                A=Manifest(i).Annotation;
                assert(isfield(A,'Provenance')&&strlength(string(A.Provenance))>0,'eventFirst:Annotation','Annotation provenance required.');
                Y=X;
                if isfield(A,'UncertainEventIDs')
                    uncertain=ismember(string(A.Events.EventID),string(A.UncertainEventIDs)); U=A; U.Events=A.Events(uncertain,:);
                    % Ignore all overlapping detections, not just one-to-one matches.
                    for u=1:height(U.Events)
                        one=U; one.Events=U.Events(u,:);
                        for d=height(Y.Events):-1:1
                            det=Y; det.Events=Y.Events(d,:); m=matchOxygenEventMasks(one,det,eps);
                            if m.TruePositives>0, Y.Events(d,:)=[]; end
                        end
                    end
                    A.Events=A.Events(~uncertain,:);
                end
                match=matchOxygenEventMasks(A,Y,threshold);
                P=match.Precision; recall=match.Recall; fp=match.FalsePositives; tp=match.TruePositives; fn=match.FalseNegatives;
                splits=match.SplitCandidates; merges=match.MergeCandidates; status="evaluated: "+string(A.Provenance);
                if ~isempty(match.Matches)
                    iou=mean(match.Matches.SpatiotemporalIoU); onset=mean(abs(match.Matches.OnsetErrorSec)); offset=mean(abs(match.Matches.OffsetErrorSec));
                    amp=mean(abs(match.Matches.PeakRelativeBLIError),'omitnan'); area=mean(abs(match.Matches.MeanAreaUm2Error),'omitnan'); duration=mean(abs(match.Matches.ObservedDurationSecError),'omitnan');
                end
            end
            exposure=X.RecordingQC.ValidAreaUm2Seconds/1e6; falseRate=NaN;
            if exposure>0, falseRate=60*fp/exposure; end
            c=X.RunManifest.Configuration;
            row=struct('RecordingID',string(R.RecordingID),'MouseID',string(R.MouseID),'Partition',string(Manifest(i).Partition), ...
                'ConfigurationIndex',j,'AnalysisRunID',X.RunManifest.AnalysisRunID,'DetectorVersion',c.Version, ...
                'SeedSD',c.SeedSD,'GrowSD',c.GrowSD,'BaselineWindowSec',c.BaselineWindowSec,'MinIoU',threshold, ...
                'EventCount',height(X.Events),'Precision',P,'Recall',recall,'TP',tp,'FP',fp,'FN',fn, ...
                'FalseDetectionsPerMm2Min',falseRate,'MeanIoU',iou,'MeanAbsoluteOnsetErrorSec',onset,'MeanAbsoluteOffsetErrorSec',offset, ...
                'SplitCandidates',splits,'MergeCandidates',merges,'MeanAbsolutePeakRelativeBLIError',amp,'MeanAbsoluteAreaUm2Error',area, ...
                'MeanAbsoluteDurationSecError',duration,'RuntimeSec',toc(started),'Status',status);
            rows=[rows; row]; %#ok<AGROW>
        end
    end
end
Report.Metrics=struct2table(rows); Report.Configurations=Configurations;
Report.Interpretation="No model selection or biological superiority claim; mouse partitions are enforced; frozen grid evaluated unchanged.";
end
