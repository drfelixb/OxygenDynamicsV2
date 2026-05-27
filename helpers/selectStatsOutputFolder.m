function [SelectedFolder,HasFolder] = selectStatsOutputFolder(RecordingFolder,NamePattern,SelectionMode,SelectionAge,PromptLabel,varargin)
%SELECTSTATSOUTPUTFOLDER Select oldest/newest/manual stats source folder.

Parser = inputParser;
Parser.addParameter('required',true,@islogical);
Parser.addParameter('recordingId','',@(Value) ischar(Value) || isstring(Value));
Parser.parse(varargin{:});
IsRequired = Parser.Results.required;
RecordingId = char(Parser.Results.recordingId);

FolderList = dir(RecordingFolder);
FolderList = FolderList([FolderList.isdir]);
FolderList = FolderList(~ismember({FolderList.name},{'.','..'}));
FolderList = FolderList(contains({FolderList.name},NamePattern));

HasFolder = ~isempty(FolderList);
if ~HasFolder
    SelectedFolder = '';
    if IsRequired
        error('No %s folders were found for recording %s in %s.',NamePattern,RecordingId,RecordingFolder);
    end
    return
end

if strcmp(SelectionMode,'No')
    if strcmp(SelectionAge,'Oldest')
        [~,SelectedIdx] = min([FolderList.datenum]);
    else
        [~,SelectedIdx] = max([FolderList.datenum]);
    end
else
    [SelectedIdx,WasSelected] = listdlg('PromptString',{sprintf('Select the %s output folder you want.',PromptLabel),''}, ...
        'SelectionMode','single','ListSize',[250,100],'ListString',{FolderList.name,''});
    if ~WasSelected
        error('No data folder was selected.')
    end
end

SelectedFolder = fullfile(FolderList(SelectedIdx).folder,FolderList(SelectedIdx).name);

end
