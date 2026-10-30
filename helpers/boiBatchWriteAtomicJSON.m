function boiBatchWriteAtomicJSON(Path,Value)
%BOIBATCHWRITEATOMICJSON Replace a small queue state without a partial file.
parent=fileparts(Path);temporary=[tempname(parent) '.json'];
cleanup=onCleanup(@()removeTemporary(temporary));
fid=fopen(temporary,'wb');
assert(fid>=0,'OxygenDynamics:BatchQueueWrite','Cannot write queue state in %s.',parent);
bytes=unicode2native([jsonencode(Value,'PrettyPrint',true) newline],'UTF-8');
try,count=fwrite(fid,bytes,'uint8');catch err,fclose(fid);rethrow(err);end
closed=fclose(fid);
assert(count==numel(bytes)&&closed==0,'OxygenDynamics:BatchQueueWrite','Incomplete queue-state write.');
source=java.io.File(temporary).toPath();destination=java.io.File(Path).toPath();
if isfile(Path)
    options=javaArray('java.nio.file.CopyOption',2);
    options(1)=java.nio.file.StandardCopyOption.ATOMIC_MOVE;
    options(2)=java.nio.file.StandardCopyOption.REPLACE_EXISTING;
    java.nio.file.Files.move(source,destination,options);
else
    java.nio.file.Files.createLink(destination,source);
end
end
function removeTemporary(Path)
if isfile(Path),delete(Path);end
end
