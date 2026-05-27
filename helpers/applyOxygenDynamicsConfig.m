function Config = applyOxygenDynamicsConfig(Config,sectionName)
%APPLYOXYGENDYNAMICSCONFIG Override defaults from OxygenDynamics_Config.m.

ConfigFile = which('OxygenDynamics_Config');
if isempty(ConfigFile)
    return
end

AllConfig = OxygenDynamics_Config();
if ~isfield(AllConfig,sectionName)
    return
end

OverrideConfig = AllConfig.(sectionName);
OverrideFields = fieldnames(OverrideConfig);
for fieldi = 1:numel(OverrideFields)
    FieldName = OverrideFields{fieldi};
    if ~isfield(Config,FieldName)
        error('OxygenDynamics_Config.%s contains unknown field "%s".',sectionName,FieldName);
    end
    Config.(FieldName) = OverrideConfig.(FieldName);
end

end
