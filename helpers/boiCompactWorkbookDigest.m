function hash=boiCompactWorkbookDigest(value)
%BOICOMPACTWORKBOOKDIGEST Typed column-wise SHA256; never per-cell recursion.
md=java.security.MessageDigest.getInstance('SHA-256');token('boi-compact-table-digest-1');visit(value);
hash=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
    function token(s)
        bytes=unicode2native(char(string(s)),'UTF-8');prefix=uint8(sprintf('%d:',numel(bytes)));
        md.update(typecast(prefix,'int8'));if ~isempty(bytes),md.update(typecast(uint8(bytes),'int8'));end
    end
    function visit(v)
        token(class(v));token(jsonencode(size(v)));
        if istable(v)
            token(jsonencode(v.Properties.VariableNames));
            for k=1:width(v),visit(v.(v.Properties.VariableNames{k}));end
        elseif isstruct(v)
            names=fieldnames(v);token(jsonencode(names));
            for ri=1:numel(v),for ki=1:numel(names),visit(v(ri).(names{ki}));end,end
        elseif iscell(v)
            if iscellstr(v),token(jsonencode(v));else,for ki=1:numel(v),visit(v{ki});end,end
        elseif isnumeric(v)||islogical(v)
            token(string(isreal(v)));
            if islogical(v),bytes=uint8(v(:));else,bytes=typecast(real(v(:)),'uint8');end
            if ~isempty(bytes),md.update(typecast(bytes,'int8'));end
            if ~isreal(v),bytes=typecast(imag(v(:)),'int8');md.update(bytes);end
        elseif isstring(v)||ischar(v)
            token(jsonencode(v));
        elseif iscategorical(v)||isdatetime(v)||isduration(v)
            token(jsonencode(string(v)));
        else
            error('OxygenDynamics:CompactDigestType','Unsupported compact source content type: %s.',class(v));
        end
    end
end
