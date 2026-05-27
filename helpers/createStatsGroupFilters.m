function GroupFilters = createStatsGroupFilters(DrugValues,ConditionValues,StimValues, ...
    DrugsUnique,ConditionsUnique,StimUnique,varargin)
%CREATESTATSGROUPFILTERS Build grouped logical filters for stats exports.

Parser = inputParser;
Parser.addParameter('mouseValues',[]);
Parser.addParameter('withStimLabel','With stimulation',@(Value) ischar(Value) || isstring(Value));
Parser.addParameter('withoutStimLabel','Without stimulation',@(Value) ischar(Value) || isstring(Value));
Parser.parse(varargin{:});

MouseValues = Parser.Results.mouseValues;
WithStimLabel = char(Parser.Results.withStimLabel);
WithoutStimLabel = char(Parser.Results.withoutStimLabel);

HasMouseValues = ~isempty(MouseValues);
NumHeaderRows = 4+double(HasMouseValues);
GroupFilters = cell(NumHeaderRows,numel(DrugsUnique)*numel(ConditionsUnique)*numel(StimUnique));

Counter = 1;
for DrugIdx = 1:numel(DrugsUnique)
    DrugFilter = strcmp(DrugValues(:),DrugsUnique{DrugIdx});

    for ConditionIdx = 1:numel(ConditionsUnique)
        ConditionFilter = strcmp(ConditionValues(:),ConditionsUnique{ConditionIdx});

        for StimIdx = 1:numel(StimUnique)
            StimFilter = StimValues(:)==StimUnique(StimIdx);
            GroupFilter = DrugFilter & ConditionFilter & StimFilter;

            GroupFilters{1,Counter} = DrugsUnique{DrugIdx};
            GroupFilters{2,Counter} = ConditionsUnique{ConditionIdx};
            if StimUnique(StimIdx)
                GroupFilters{3,Counter} = WithStimLabel;
            else
                GroupFilters{3,Counter} = WithoutStimLabel;
            end
            GroupFilters{4,Counter} = GroupFilter;

            if HasMouseValues
                GroupFilters{5,Counter} = unique(MouseValues(GroupFilter));
            end

            Counter = Counter+1;
        end
    end
end

end
