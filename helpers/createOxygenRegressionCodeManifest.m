function CodeManifest = createOxygenRegressionCodeManifest(ProjectRoot)
%CREATEOXYGENREGRESSIONCODEMANIFEST Create a compact manifest of MATLAB code files.

if nargin<1 || isempty(ProjectRoot)
    ProjectRoot = fileparts(fileparts(mfilename('fullpath')));
end

Files = dir(fullfile(ProjectRoot,'**','*.m'));
Files = Files(~[Files.isdir]);
Files = Files(~contains(fullfile({Files.folder},{Files.name})',fullfile(ProjectRoot,'Legacy_Archive')));

RelativePath = strings(numel(Files),1);
Bytes = zeros(numel(Files),1);
Modified = strings(numel(Files),1);
SHA256 = strings(numel(Files),1);

for FileIdx = 1:numel(Files)
    FilePath = fullfile(Files(FileIdx).folder,Files(FileIdx).name);
    RelativePath(FileIdx) = string(makeRelativePath(FilePath,ProjectRoot));
    Bytes(FileIdx) = Files(FileIdx).bytes;
    Modified(FileIdx) = string(formatRegressionTimestamp(Files(FileIdx).datenum));
    SHA256(FileIdx) = string(fileSha256(FilePath));
end

CodeManifest = table(RelativePath,Bytes,Modified,SHA256);
CodeManifest = sortrows(CodeManifest,'RelativePath');

end

function RelativePath = makeRelativePath(FilePath,ProjectRoot)

RelativePath = erase(FilePath,[ProjectRoot filesep]);
RelativePath = strrep(RelativePath,'\','/');

end
