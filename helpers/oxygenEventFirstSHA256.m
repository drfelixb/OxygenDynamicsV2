function hash = oxygenEventFirstSHA256(file)
fid=fopen(file,'rb'); assert(fid>=0,'eventFirst:Source','Cannot read %s',file);
cleanup=onCleanup(@()fclose(fid)); digest=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid)
    bytes=fread(fid,1048576,'*uint8'); digest.update(typecast(bytes,'int8'));
end
hash=string(lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[])));
end
