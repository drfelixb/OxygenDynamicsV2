function Hash = textSha256(TextValue)
%TEXTSHA256 Compute SHA-256 hash for text.

MessageDigest = java.security.MessageDigest.getInstance('SHA-256');
MessageDigest.update(typecast(uint8(char(TextValue)),'int8'));
Digest = typecast(MessageDigest.digest(),'uint8');
Hash = lower(reshape(dec2hex(Digest)',1,[]));

end
