function [LeftPawExport,RightPawExport,PupilExport] = createStatsBinnedTraceExports( ...
    GroupHeaders,Titles,BinsLeftPaw,BinsRightPaw,BinsPupil,FiltersROIsAndEvents,IsBLI)
%CREATESTATSBINNEDTRACEEXPORTS Build optional BLI binned trace export tables.

LeftPawExport = GroupHeaders;
RightPawExport = GroupHeaders;
PupilExport = GroupHeaders;

if ~IsBLI
    return
end

LeftPawExport = createBinnedTraceExport(LeftPawExport,FiltersROIsAndEvents,BinsLeftPaw);
RightPawExport = createBinnedTraceExport(RightPawExport,FiltersROIsAndEvents,BinsRightPaw);
PupilExport = createBinnedTraceExport(PupilExport,FiltersROIsAndEvents,BinsPupil);

LeftPawExport = [Titles,LeftPawExport];
RightPawExport = [Titles,RightPawExport];
PupilExport = [Titles,PupilExport];

end
