function RootFolder = setupOxygenDynamicsPath()
%SETUPOXYGENDYNAMICSPATH Add project support folders to the MATLAB path.

RootFolder = fileparts(mfilename('fullpath'));
addpath(RootFolder);

SupportFolders = {'helpers','external'};
for folderi = 1:numel(SupportFolders)
    FolderPath = fullfile(RootFolder,SupportFolders{folderi});
    if isfolder(FolderPath)
        addpath(FolderPath);
    end
end

end
