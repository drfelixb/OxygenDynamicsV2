function writeBOIRunJSON(Path,Value)
%WRITEBOIRUNJSON Write a human-readable lifecycle/receipt record.
fid=fopen(Path,'w');assert(fid>=0,'OxygenDynamics:RunWriteFailed','Cannot write %s.',Path);
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(Value,'PrettyPrint',true));
end
