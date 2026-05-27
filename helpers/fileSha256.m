function Hash = fileSha256(FilePath)
%FILESHA256 Compute SHA-256 hash for a file.

Hash = '';
MessageDigest = java.security.MessageDigest.getInstance('SHA-256');
Fid = fopen(FilePath,'r');
if Fid<0
    return
end
CleanupObj = onCleanup(@() fclose(Fid));
CleanupObj; %#ok<VUNUS>

while true
    Bytes = fread(Fid,1024*1024,'*uint8');
    if isempty(Bytes)
        break
    end
    MessageDigest.update(typecast(Bytes(:),'int8'));
end

Digest = typecast(MessageDigest.digest(),'uint8');
Hash = lower(reshape(dec2hex(Digest)',1,[]));

end
