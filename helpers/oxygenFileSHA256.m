function hash=oxygenFileSHA256(path)
% Stream source bytes; avoid loading another movie-sized array.
fid=fopen(path,'rb');
assert(fid>=0,'OxygenDynamics:MissingSource','Cannot read source file: %s',path);
cleanup=onCleanup(@()fclose(fid));
md=java.security.MessageDigest.getInstance('SHA-256');
while true
    block=fread(fid,8*1024*1024,'*uint8');
    if isempty(block),break;end
    md.update(typecast(block,'int8'));
end
hash=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
