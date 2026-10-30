function hash=boiBatchWriteSnapshot(Path,Name,Value)
%BOIBATCHWRITESNAPSHOT Publish a new immutable MATLAB snapshot, never replace.
assert(~isfile(Path)&&~isfolder(Path),'OxygenDynamics:BatchQueueWrite','A snapshot already exists: %s.',Path);
temporary=[tempname(fileparts(Path)) '.mat'];cleanup=onCleanup(@()removeTemporary(temporary));
data=struct();data.(Name)=Value;
save(temporary,'-struct','data','-mat');
hash=oxygenFileSHA256(temporary);
java.nio.file.Files.createLink(java.io.File(Path).toPath(),java.io.File(temporary).toPath());
end
function removeTemporary(Path)
if isfile(Path),delete(Path);end
end
