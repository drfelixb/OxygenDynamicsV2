function hash=boiPocketDigest(value)
%BOIPOCKETDIGEST Identity for embedded reviewed ingredients; never raw movie IO.
bytes=unicode2native(jsonencode(value),'UTF-8');
md=java.security.MessageDigest.getInstance('SHA-256');md.update(typecast(uint8(bytes),'int8'));
hash=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
