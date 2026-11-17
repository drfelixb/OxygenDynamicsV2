function tests=testBOIBatchImportPaths
% Synthetic path import, mapping and saved draft checks. No recordings run.
tests=functiontests(localfunctions);
end

function testRelativePathsUseCSVFolder(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
mkdir(fullfile(root,'Data','one'));mkdir(fullfile(root,'Data','two'));
csv=fullfile(root,'input.csv');
original=sprintf('Paths,BatchRowID,Notes\n%s,0012,%s\n%s,0007,%s\n', ...
    '\Data\one','"leave \metadata, untouched"','Data/two','"ordinary text"');
fid=fopen(csv,'wb');fwrite(fid,original);fclose(fid);
batch=readBOIBatchCSV(csv);
verifyEqual(t,batch.Rows.Paths,string({fullfile('Data','one');fullfile('Data','two')}));
verifyEqual(t,batch.Rows.BatchRowID,["0012";"0007"]);
verifyEqual(t,batch.Rows.Notes,["leave \metadata, untouched";"ordinary text"]);
expected=[string(fullfile(root,'Data','one'));string(fullfile(root,'Data','two'))];
expected=string(cellfun(@(p)char(java.io.File(p).getCanonicalPath()),cellstr(expected),'UniformOutput',false));
resolved=resolveBOIBatch(batch);
verifyEqual(t,resolved.Paths,expected);
verifyEmpty(t,batch.PathImport.NeedsMapping);
verifyEqual(t,fileread(csv),original);
end

function testWindowsNativePathsAndUnixForeignRoots(t)
paths=["Data/one";"C:\Data\two";"\\host\share\three";"//host/share/four"; ...
    "/Volumes/Lab/project/five";"D:relative\six"];
[translated,info]=prepareBOIBatchImportPaths(paths,pwd,[],[],true);
expected=paths;expected(1)="Data\one";
verifyEqual(t,translated,expected);
verifyEqual(t,info.ChangedCount,1);
verifyEqual(t,info.NeedsMapping.RowIndex,[5;6]);
verifyEqual(t,info.NeedsMapping.Root,["/Volumes/Lab";"D:"]);
verifyEqual(t,info.SuggestedPrefix,"/Volumes/Lab/project");
end

function testForeignMappingMatchesWholeDirectories(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
root=char(java.io.File(root).getCanonicalPath());
paths=["C:\Study\one";"c:/Study2/two";"\\server\share\three";"D:drive-relative"];
[~,suggested]=prepareBOIBatchImportPaths(["C:\Lab\project\one";"c:/lab/project/batch/two";paths(3)],root,[],[],false);
verifyEqual(t,suggested.SuggestedPrefix,"C:/Lab/project");
[mapped,info]=prepareBOIBatchImportPaths(paths,root,"c:\study",root,false);
expected=paths;expected(1)=string(fullfile(root,'one'));
verifyEqual(t,mapped,expected);
verifyEqual(t,info.MappedCount,1);
verifyEqual(t,info.NeedsMapping.Path,paths(2:4));
verifyEqual(t,info.NeedsMapping.Root,["c:";"//server/share";"D:"]);
[mapped,info]=prepareBOIBatchImportPaths(paths,root,"d:",root,false);
verifyEqual(t,mapped(4),string(fullfile(root,'drive-relative')));
verifyEqual(t,info.MappedCount,1);
unix=["/Volumes/Lab/study/run";"/Volumes/Lab2/run";"C:\native\run"];
[mapped,info]=prepareBOIBatchImportPaths(unix,root,"/Volumes/Lab",root,true);
expected=unix;expected(1)=string(fullfile(root,'study','run'));
verifyEqual(t,mapped,expected);
verifyEqual(t,info.NeedsMapping.Path,unix(2));
verifyError(t,@()prepareBOIBatchImportPaths("C:\Study\..\outside",root,"C:/Study",root,false), ...
    'OxygenDynamics:BatchPathMapping');
end

function testUnmappedForeignPathSurvivesSaveAndIsHeld(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
foreign="C:\Foreign\recording";
if ispc,foreign="/Volumes/Foreign/recording";end
batch=createBOIBatch(table(foreign,'VariableNames',{'Paths'}),root);
file=fullfile(root,'draft.csv');writeBOIBatchCSV(batch,file);
read=readBOIBatchCSV(file);
verifyEqual(t,read.Rows.Paths,foreign);
verifyEqual(t,read.PathImport.NeedsMapping.Path,foreign);
[~,report,requests]=checkBOIBatch(read);
verifyEqual(t,report.ResolvedPath,foreign);
verifyEqual(t,report.InputStatus,"Needs attention");
verifyTrue(t,contains(report.Message,'OxygenDynamics:BatchForeignPath'));
verifyEmpty(t,requests{1});
end
