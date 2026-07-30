function Age = inferHypoxiaAmyloidAge(Metadata,RecordingFolder)
%INFERHYPOXIAAMYLOIDAGE Normalize age from metadata or recording path.

Candidates = strings(0,1);
Fields = {'Age','Genotype','DrugID','Condition'};
for Idx = 1:numel(Fields)
    Name = Fields{Idx};
    if isfield(Metadata,Name)
        Value = Metadata.(Name);
        if iscell(Value) && isscalar(Value)
            Value = Value{1};
        end
        Candidates(end+1,1) = string(Value); %#ok<AGROW>
    end
end
Candidates(end+1,1) = string(RecordingFolder);
Text = lower(strjoin(Candidates," "));

if contains(Text,"fourmonth") || contains(Text,"4month") || ...
        contains(Text,"4 month")
    Age = "4 months";
elseif contains(Text,"sixmonth") || contains(Text,"6month") || ...
        contains(Text,"6 month")
    Age = "6 months";
else
    Age = "Unknown";
end
end
