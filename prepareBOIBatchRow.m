function [Request,LegacyInput,Metadata]=prepareBOIBatchRow(Row,OutputFolder,Origins)
%PREPAREBOIBATCHROW Adapt one resolved public CSV row to the shared boundary.
% Read-only preparation: no source copy, directory creation or engine call.
setupOxygenDynamicsPath;
assert(istable(Row)&&height(Row)==1,'OxygenDynamics:InvalidBatch','Supply one resolved batch row.');
if nargin<3,Origins=table();end
o=struct('RecordingFolder',char(Row.Paths),'OutputFolder',char(OutputFolder), ...
    'SampleHz',str2double(Row.SampleF),'PixelSizeUm',str2double(Row.Pixelsize), ...
    'SupportProfile',char(Row.BOISupportProfile));
% PuffsFile/Puff_2use stay descriptive metadata; neither enters the BOI request.
labels={'Mouse','Condition','DrugID','Genotype','Promoter'};
for k=1:numel(labels)
    f=labels{k};
    if ismember(f,Row.Properties.VariableNames)&&strlength(strtrim(string(Row.(f))))>0
        o.(f)=char(Row.(f));
    end
end
Request=prepareBOIRecordingRequest(o);
if ~isempty(Origins)
    names={'SampleF','Pixelsize','BOISupportProfile'};targets={'SampleHz','PixelSizeUm','SupportProfile'};
    for k=1:numel(names),Request.SettingOrigins.(targets{k})=char(Origins.(names{k}));end
end
% The verbose compatibility table is generated internally, never user-required.
% A future execution adapter supplies the staged folder and engine RecordingID.
% Stimulation placeholders remain NaN regardless of descriptive CSV values.
o=Request.Options;
LegacyInput=table({o.RecordingFolder},NaN,NaN,NaN,NaN,{o.Mouse},{o.Genotype}, ...
    {o.Condition},{o.DrugID},{o.Promoter},o.SampleHz,o.PixelSizeUm,NaN,"", ...
    'VariableNames',{'Paths','PostureFile','PupilFile','PuffsFile','WhiskingFile', ...
    'Mouse','Genotype','Condition','DrugID','Promoter','SampleF','Pixelsize','Puff_2use','RecordingID'});
Metadata=struct('Schema','boi-batch-row-metadata-1','BatchRowID',char(Row.BatchRowID), ...
    'Names',{Row.Properties.VariableNames},'Values',{cellstr(string(table2cell(Row)))});
end
