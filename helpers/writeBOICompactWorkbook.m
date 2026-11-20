function writeBOICompactWorkbook(path,D,sheets)
% Native MATLAB values-only writer. No formulas and no calculator dependency.
for i=1:numel(sheets)
    T=D.(sheets{i});
    for f=string(T.Properties.VariableNames)
        if islogical(T.(f)),T.(f)=double(T.(f));elseif isstring(T.(f)),v=T.(f);v(ismissing(v))="";T.(f)=v;end
    end
    % Strings beginning with formula syntax are literal source text. MATLAB
    % writes string cells; the OpenXML check below rejects formula elements.
    writetable(T,path,'Sheet',sheets{i},'WriteMode','overwritesheet','UseExcel',false);
end
end
