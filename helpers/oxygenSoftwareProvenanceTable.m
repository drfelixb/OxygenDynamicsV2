function T = oxygenSoftwareProvenanceTable(saved,exporter)
% One workbook row distinguishing the saved calculator from the current writer.
if nargin<2, exporter=getOxygenPipelineVersion(); end
calculation=struct();
if isfield(saved,'CalculationSoftware'),calculation=saved.CalculationSoftware;end
T=table(value(calculation,'Version'),value(calculation,'SourceCommit'), ...
    value(calculation,'SourceState'),string(exporter.Version), ...
    string(exporter.SourceCommit),string(exporter.SourceState), ...
    'VariableNames',{'CalculationVersion','CalculationSourceCommit','CalculationSourceState', ...
    'ExporterVersion','ExporterSourceCommit','ExporterSourceState'});
end

function s=value(info,name)
s="unknown";
if isstruct(info)&&isscalar(info)&&isfield(info,name)
    item=info.(name);
    if (ischar(item)||isstring(item))&&isscalar(string(item))&&strlength(string(item))>0
        s=string(item);
    end
end
end
