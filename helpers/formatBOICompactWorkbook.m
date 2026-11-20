function formatBOICompactWorkbook(path,D,sheets)
%FORMATBOICOMPACTWORKBOOK Bulk style native OpenXML; preserve values/types.
% Stream ZIP entries so large sheets never create an uncompressed scratch tree.
input=java.util.zip.ZipFile(java.io.File(path));
zipfile=[tempname(fileparts(path)) '.zip'];
output=java.util.zip.ZipOutputStream(java.io.FileOutputStream(zipfile));
cleanup=onCleanup(@()closeStreams(input,output,zipfile));
[styles,headerID,textID]=addStyles(readEntry(input,'xl/styles.xml'));
entries=input.entries();
while entries.hasMoreElements()
    entry=entries.nextElement();name=char(entry.getName());
    output.putNextEntry(java.util.zip.ZipEntry(name));
    if strcmp(name,'xl/styles.xml')
        writeUTF8(output,styles);
    else
        index=find(strcmp(name,compose('xl/worksheets/sheet%d.xml',1:numel(sheets))),1);
        if ~isempty(index)
            s=readEntry(input,name);s=styleSheet(s,D.(sheets{index}),sheets{index},headerID,textID);
            writeUTF8(output,s);
        elseif ~entry.isDirectory()
            stream=input.getInputStream(entry);streamCleanup=onCleanup(@()stream.close());
            stream.transferTo(output);clear streamCleanup;
        end
    end
    output.closeEntry();
end
output.close();input.close();
movefile(zipfile,path,'f');clear cleanup;
end
function [s,headerID,textID]=addStyles(s)
fonts=regexp(s,'<fonts(?=\s|>)[^>]*count="(\d+)"','tokens','once');fontID=str2double(fonts{1});
s=regexprep(s,'<fonts(?=\s|>)[^>]*>',sprintf('<fonts count="%d">',fontID+2),'once');
s=strrep(s,'</fonts>','<font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Arial"/></font><font><sz val="11"/><color rgb="FF102A43"/><name val="Arial"/></font></fonts>');
fills=regexp(s,'<fills(?=\s|>)[^>]*count="(\d+)"','tokens','once');fillID=str2double(fills{1});
s=regexprep(s,'<fills(?=\s|>)[^>]*>',sprintf('<fills count="%d">',fillID+1),'once');
s=strrep(s,'</fills>','<fill><patternFill patternType="solid"><fgColor rgb="FF243B53"/><bgColor indexed="64"/></patternFill></fill></fills>');
xfs=regexp(s,'<cellXfs(?=\s|>)[^>]*count="(\d+)"','tokens','once');headerID=str2double(xfs{1});textID=headerID+1;
s=regexprep(s,'<cellXfs(?=\s|>)[^>]*>',sprintf('<cellXfs count="%d">',headerID+2),'once');
s=strrep(s,'</cellXfs>',sprintf(['<xf numFmtId="0" fontId="%d" fillId="%d" borderId="0" xfId="0" applyFont="1" applyFill="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>' ...
    '<xf numFmtId="0" fontId="%d" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1"><alignment horizontal="left" vertical="center" wrapText="1"/></xf></cellXfs>'],fontID,fillID,fontID+1));
end
function s=styleSheet(s,T,sheet,headerID,textID)
assert(isempty(regexp(s,'<f(?:\s|>)','once')),'OxygenDynamics:CompactFormula','Source text became an Excel formula.');
view='<sheetViews><sheetView workbookViewId="0" showGridLines="0"><pane xSplit="5" ySplit="1" topLeftCell="F2" activePane="bottomRight" state="frozen"/><selection pane="bottomRight" activeCell="F2" sqref="F2"/></sheetView></sheetViews>';
if contains(s,'<sheetViews>'),s=regexprep(s,'<sheetViews>.*?</sheetViews>',view,'once');
else,s=regexprep(s,'(<sheetData(?=\s|>))',[view '$1'],'once');end
widths=cell(1,width(T));lines=ones(height(T),1);
for j=1:width(T)
    name=T.Properties.VariableNames{j};w=22;
    if j==1,w=38;elseif j>5&&contains(name,{'Source','Version','Policy','Status','Reference','Reason','Meaning','Scope'}),w=42;end
    if strcmp(sheet,'Definitions')&&j>=3,w=55;end
    widths{j}=sprintf('<col min="%d" max="%d" width="%g" customWidth="1"/>',j,j,w);
    value=T.(name);
    if isstring(value)||iscellstr(value)
        len=double(strlength(string(value)));len(isnan(len))=0;lines=max(lines,ceil(len/w));
    end
end
cols=['<cols>' widths{:} '</cols>'];
if contains(s,'<cols>'),s=regexprep(s,'<cols>.*?</cols>',cols,'once');else,s=regexprep(s,'(<sheetData(?=\s|>))',[cols '$1'],'once');end
% Numeric styles are untouched, retaining the writer's exact number formats.
% Text cell opening tags are transformed in a constant number of sheet scans.
s=regexprep(s,'(<c(?=\s|>)(?=[^>]*\st="(?:s|inlineStr)")[^>]*?)\s+s="\d+"','$1');
s=regexprep(s,'<c(?=\s|>)(?=[^>]*\st="(?:s|inlineStr)")',sprintf('<c s="%d"',textID));
row=regexp(s,'<row(?=\s|>)[^>]*r="1"[^>]*>.*?</row>','match','once');
if ~isempty(row)
    r=regexprep(row,'(<c(?=\s|>)[^>]*?)\s+s="\d+"','$1');
    r=regexprep(r,'<c(?=\s|>)',sprintf('<c s="%d"',headerID));s=strrep(s,row,r);
end
heights=[70;min(120,max(20,lines*15))];
s=replaceTags(s,'<row(?=\s|>)[^>]*>',@(tags)rowTags(tags,heights));
last=excelColumn(width(T));filter=sprintf('<autoFilter ref="A1:%s%d"/>',last,max(1,height(T)+1));
if contains(s,'<autoFilter'),s=regexprep(s,'<autoFilter[^>]*/>',filter,'once');else,s=strrep(s,'</sheetData>',['</sheetData>' filter]);end
end
function tags=textTags(tags,id)
tags=regexprep(tags,'\s+s="\d+"','');tags=regexprep(tags,'<c(?=\s|>)',sprintf('<c s="%d"',id));
end
function tags=rowTags(tags,heights)
numbers=regexp(tags,'\sr="(\d+)"','tokens','once');
tags=regexprep(tags,'\s+ht="[^"]*"|\s+customHeight="[^"]*"','');
for k=1:numel(tags)
    r=str2double(numbers{k}{1});assert(r>=1&&r<=numel(heights),'OxygenDynamics:CompactFormat','Unexpected worksheet row.');
    tags{k}=[tags{k}(1:end-1) sprintf(' ht="%d" customHeight="1">',heights(r))];
end
end
function s=replaceTags(s,pattern,transform)
% Rebuild once, never re-search/rebuild the full sheet for each row or cell.
[first,last,tags]=regexp(s,pattern,'start','end','match');if isempty(first),return;end
tags=transform(tags);parts=cell(1,2*numel(first)+1);previous=1;
for k=1:numel(first),parts{2*k-1}=s(previous:first(k)-1);parts{2*k}=tags{k};previous=last(k)+1;end
parts{end}=s(previous:end);s=[parts{:}];
end
function s=readEntry(zip,name)
stream=zip.getInputStream(zip.getEntry(name));c=onCleanup(@()stream.close());
bytes=stream.readAllBytes();s=native2unicode(typecast(bytes(:)','uint8'),'UTF-8');
end
function writeUTF8(stream,s)
bytes=unicode2native(s,'UTF-8');stream.write(typecast(uint8(bytes),'int8'),0,numel(bytes));
end
function closeStreams(input,output,path)
try,output.close();catch,end
try,input.close();catch,end
if isfile(path),delete(path);end
end
function v=excelColumn(n)
v='';while n>0,r=mod(n-1,26);v=[char(65+r) v];n=floor((n-1)/26);end
end
