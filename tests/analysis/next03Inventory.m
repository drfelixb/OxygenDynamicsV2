function next03Inventory(Root)
% Ingredient-only inventory before expected answers and case evaluations.
folder=fullfile(Root,'reference-validation','software-next03-calculations-20261004');
stats={'software-g2-workflow-20260923/gui-run/statistics/Stats_Output_20260923T102730', ...
    'boi-c02-strict-roi-20260912/run-01/statistics/Stats_Output_20260912T155949'};
audits={'software-g2-workflow-20260923/gui-run/Recording/BOIReview/event-amplitude-audit.mat', ...
    'boi-c02-strict-roi-20260912/audit-01/source-amplitude-audit/event-amplitude-audit.mat'};
for k=1:2
    path=fullfile(Root,'reference-validation',stats{k},'DataOutput.mat');
    L=load(path,'StatsInfo','RecordingRegistry','Table_OxygenSinkEvents_OutCombo','Table_OxygenSurgeEvents_OutCombo','HypoxicBurden','HypoxicEventSpecificMetrics');
    I=struct('Path',path,'StatsInfoFields',{fieldnames(L.StatsInfo)},'StatsInfo',L.StatsInfo,'RecordingRegistry',table2struct(L.RecordingRegistry));
    % Keep metadata compact; source paths remain pinned in the original inputs.
    I.StatsInfo=struct;if isfield(L.StatsInfo,'PipelineContract'),I.StatsInfo.PipelineContract=L.StatsInfo.PipelineContract;end
    for name={'CalculationSoftwareVersion','CalculationBuildTimestamp','PipelineVersion','SoftwareVersion'}
        if isfield(L.StatsInfo,name{1}),I.StatsInfo.(name{1})=L.StatsInfo.(name{1});end
    end
    Specific=load(fullfile(Root,'reference-validation',stats{k},'HypoxicEventSpecificMetrics4LME.mat'),'Eventspecificmetrics');
    I.EventSpecificFields=Specific.Eventspecificmetrics.Properties.VariableNames;
    cols=intersect({'RecordingID','SinkID','EventIndex','EventID','Area_um'},I.EventSpecificFields,'stable');
    I.EventSpecificAreaIngredients=table2struct(Specific.Eventspecificmetrics(:,cols));
    A=load(fullfile(Root,'reference-validation',audits{k}),'Audit','Traces','AnalysisInfo');
    I.AuditSourceSHA256=A.AnalysisInfo.RawSHA256;I.AuditSampleHz=A.AnalysisInfo.AnalysisParams.fs;
    I.AuditRows=cell(height(A.Audit),1);
    for e=1:height(A.Audit)
        r=A.Audit(e,:);t=A.Traces{e};
        row=table2struct(r(:,{'EventType','SiteID','EventID','StartFrame','EndFrame','RecomputedStatus','RecomputedBaseline','StoredAmplitude'}));
        row.ReferenceFrames=t.CleanBaselineFrames;row.ReferenceValues=t.Raw(t.CleanBaselineFrames);
        row.MeasurementValues=t.Raw(r.StartFrame:r.EndFrame);
        row.RequiredReferenceSamples=r.BaselineWindowFrames;I.AuditRows{e}=row;
    end
    I.SinkEventColumns=L.Table_OxygenSinkEvents_OutCombo.Properties.VariableNames;
    I.SurgeEventColumns=L.Table_OxygenSurgeEvents_OutCombo.Properties.VariableNames;
    I.BurdenEventColumns=L.HypoxicBurden.EventTable.Properties.VariableNames;
    I.BurdenRecordingColumns=L.HypoxicBurden.RecordingTable.Properties.VariableNames;
    f=fopen(fullfile(folder,sprintf('saved-%02d-ingredients.json',k)),'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(I,'PrettyPrint',true));clear c
end
end
