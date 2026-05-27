function [LoadedData, IsLoaded] = loadStatsMatVars(folderPath,fileNames,varNames,label,recordingID)
LoadedData=struct();
IsLoaded=false;

missingFiles=fileNames(~cellfun(@(fileName) isfile(fullfile(folderPath,fileName)),fileNames));
if ~isempty(missingFiles)
    warning('Skipping %s behaviour data for recording %s because these files are missing in %s: %s.',...
        label,recordingID,folderPath,strjoin(missingFiles,', '));
    return
end

for filei=1:numel(fileNames)
    FileData=load(fullfile(folderPath,fileNames{filei}),varNames{filei});
    if ~isfield(FileData,varNames{filei})
        warning('Skipping %s behaviour data for recording %s because %s does not contain variable %s.',...
            label,recordingID,fileNames{filei},varNames{filei});
        LoadedData=struct();
        return
    end
    LoadedData.(varNames{filei})=FileData.(varNames{filei});
end

IsLoaded=true;
end
