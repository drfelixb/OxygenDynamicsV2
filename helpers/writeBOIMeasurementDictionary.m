function Definitions = writeBOIMeasurementDictionary(OutputFolder,OutputXlsx)
%WRITEBOIMEASUREMENTDICTIONARY Export the same definitions for GUI and batch.
% Additive guide; does not replace detailed legacy column definitions.
[Definitions,D,source]=getBOIMeasurementDictionary();
assert(isfolder(OutputFolder),'Output folder must already exist.');
copyfile(source,fullfile(OutputFolder,'BOIMeasurementDictionary.json'));
lines=["# BOI measurement and calculation guide"; ""; ...
    "Version: " + string(D.Version); string(D.Scope); ""; ...
    "Teaching examples are not measured cohort results. Numerical availability does not establish biological accuracy."; ...
    string(D.AggregationRule); ""];
fields=Definitions.Properties.VariableNames;
for i=1:height(Definitions)
    lines(end+1)="## " + Definitions.MeasurementID(i) + " — " + Definitions.Name(i);
    lines(end+1)="";
    for j=3:numel(fields)
        lines(end+1)="**" + string(fields{j}) + ":** " + Definitions.(fields{j})(i);
        lines(end+1)="";
    end
end
fid=fopen(fullfile(OutputFolder,'BOIMeasurementGuide.md'),'w');
assert(fid>=0,'Cannot write BOI measurement guide.');
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',lines);
if nargin>1 && ~isempty(OutputXlsx)
    writetable(Definitions,OutputXlsx,'Sheet','BOIMeasurementDictionary');
end
end
