function hash = oxygenEventFirstArraySHA256(A)
% Hash type, dimensions and column-major effective calculation input bytes.
digest=java.security.MessageDigest.getInstance('SHA-256');
header=unicode2native([class(A) ':' mat2str(size(A)) ':'],'UTF-8'); digest.update(typecast(header,'int8'));
for first=1:1048576:numel(A)
    block=A(first:min(numel(A),first+1048575));
    if islogical(block), block=uint8(block); end
    digest.update(typecast(block(:),'int8'));
end
hash=string(lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[])));
end
