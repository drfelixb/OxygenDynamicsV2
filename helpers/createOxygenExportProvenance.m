function P=createOxygenExportProvenance(Saved,implementationNames)
% Separate saved calculation identity from the code reading/exporting it now.
% A calculation schema is not a software release version. Never infer a
% historical creator from current code or from a manifest generated later.
if nargin<2,implementationNames={'createOxygenExportProvenance'};end
P=struct('Schema','oxygen-export-provenance-1');
O=struct('SoftwareVersion','unknown','BuildTimestamp','unknown','SourceCommit','unknown','SourceState','unknown', ...
    'SoftwareIdentityStatus','unknown_not_recorded','CalculationContract',struct(), ...
    'CalculationContractStatus','unknown_not_recorded','EventCalculationSchemas',strings(0,1), ...
    'RegistryCalculationVersions',strings(0,1), ...
    'RegistryVersionRole','saved_calculation_schema_not_software_release', ...
    'ValueRole','saved_values_not_recomputed_by_reader_exporter');
if isfield(Saved,'StatsInfo')&&isstruct(Saved.StatsInfo)&&isscalar(Saved.StatsInfo)
    I=Saved.StatsInfo;
    O=readCreator(O,I,'StatsInfo');
    if isfield(I,'PipelineContract')&&isstruct(I.PipelineContract)
        O.CalculationContract=I.PipelineContract;O.CalculationContractStatus='recorded_in_saved_StatsInfo.PipelineContract';
    end
end
if isfield(Saved,'AnalysisInfo')&&isstruct(Saved.AnalysisInfo)&&isscalar(Saved.AnalysisInfo)&& ...
        isfield(Saved.AnalysisInfo,'PipelineContract')&&isempty(fieldnames(O.CalculationContract))
    O.CalculationContract=Saved.AnalysisInfo.PipelineContract;O.CalculationContractStatus='recorded_in_saved_AnalysisInfo.PipelineContract';
end
if strcmp(O.SoftwareIdentityStatus,'unknown_not_recorded') && isfield(Saved,'AnalysisInfo')
    O=readCreator(O,Saved.AnalysisInfo,'AnalysisInfo');
end
for name={'Table_OxygenSinkEvents_OutCombo','Table_OxygenSurgeEvents_OutCombo'}
    if isfield(Saved,name{1})&&istable(Saved.(name{1}))&&ismember('AnalysisSchemaVersion',Saved.(name{1}).Properties.VariableNames)
        O.EventCalculationSchemas=unique([O.EventCalculationSchemas;string(Saved.(name{1}).AnalysisSchemaVersion(:))],'stable');
    end
end
if isfield(Saved,'RecordingRegistry')&&istable(Saved.RecordingRegistry)&&ismember('PipelineVersion',Saved.RecordingRegistry.Properties.VariableNames)
    O.RegistryCalculationVersions=unique(string(Saved.RecordingRegistry.PipelineVersion(:)),'stable');
end
P.OriginalCalculation=O;P.CurrentReaderExporter=getOxygenPipelineVersion();
P.CurrentReaderExporter.Role='current_reader_exporter_not_historical_calculator';
P.CurrentReaderExporter.Implementation=struct('Function',{},'SHA256',{});
for name=implementationNames
    path=which(name{1});assert(~isempty(path),'OxygenDynamics:MissingExportImplementation','Export implementation is missing.');
    P.CurrentReaderExporter.Implementation(end+1)=struct('Function',name{1},'SHA256',oxygenFileSHA256(path));
end
end
function original=readCreator(original,info,source)
if ~isstruct(info)||~isscalar(info)||~isfield(info,'CalculationSoftware'),return;end
creator=info.CalculationSoftware;
if ~isstruct(creator)||~isscalar(creator)||~isfield(creator,'Version')||~validText(creator.Version),return;end
original.SoftwareVersion=char(string(creator.Version));
original.SoftwareIdentityStatus=['recorded_in_saved_' source '.CalculationSoftware'];
for field={'BuildTimestamp','SourceCommit','SourceState'}
    name=field{1};
    if isfield(creator,name)&&validText(creator.(name)),original.(name)=char(string(creator.(name)));end
end
end

function tf=validText(v)
tf=(ischar(v)||isstring(v))&&isscalar(string(v))&&~ismissing(string(v))&&strlength(string(v))>0;
end
