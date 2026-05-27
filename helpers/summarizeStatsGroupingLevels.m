function [SinkTable,GroupingLevels] = summarizeStatsGroupingLevels(SinkTable,NumRecordings)
%SUMMARIZESTATSGROUPINGLEVELS Normalize and report stats grouping levels.

if ~ischar(SinkTable.Mouse{1})
    SinkTable.Mouse = cellfun(@num2str,SinkTable.Mouse,'UniformOutput',false);
end

GroupingLevels = struct();
GroupingLevels.Mice = uniqueStrCell(SinkTable.Mouse);
GroupingLevels.Conditions = uniqueStrCell(SinkTable.Condition);
GroupingLevels.Drugs = uniqueStrCell(SinkTable.DrugID);
GroupingLevels.StimCond = unique(SinkTable.PuffStim);

fprintf('The dataset contains %d recording sessions... \n',NumRecordings);
printLevelList(sprintf('From %d mice... \n',length(GroupingLevels.Mice)),GroupingLevels.Mice);
printLevelList(sprintf('The between subjects grouping variable DrugID has %d levels... \n', ...
    length(GroupingLevels.Drugs)),GroupingLevels.Drugs);
printLevelList(sprintf('The within subjects grouping variable Condition has %d levels... \n', ...
    length(GroupingLevels.Conditions)),GroupingLevels.Conditions);

fprintf('The within subjects grouping variable Stimulation has %d levels... \n', ...
    length(GroupingLevels.StimCond));
for leveli = 1:length(GroupingLevels.StimCond)
    if GroupingLevels.StimCond(leveli)
        fprintf('With stimulation \n');
    else
        fprintf('Without stimulation \n');
    end
end
end

function printLevelList(Header,Values)
fprintf(Header);
for valuei = 1:length(Values)
    fprintf('%s\n',Values{valuei});
end
end
