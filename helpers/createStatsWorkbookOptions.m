function WorkbookOptions = createStatsWorkbookOptions(IsBLI,BLIWorkbookData)
%CREATESTATSWORKBOOKOPTIONS Build optional BLI workbook/figure export options.

WorkbookOptions = struct();
if ~IsBLI
    return
end

WorkbookOptions.AlignedSinkTraces = BLIWorkbookData.AlignedSinkTraces;
WorkbookOptions.TraceCorrs = BLIWorkbookData.TraceCorrs;
WorkbookOptions.LPawBinnedTraces = BLIWorkbookData.LPawBinnedTraces;
WorkbookOptions.RPawBinnedTraces = BLIWorkbookData.RPawBinnedTraces;
WorkbookOptions.PupilBinnedTraces = BLIWorkbookData.PupilBinnedTraces;
WorkbookOptions.PooledTraces = BLIWorkbookData.PooledTraces;
WorkbookOptions.BehaviourLogicals = BLIWorkbookData.BehaviourLogicals;
WorkbookOptions.SampleFs = BLIWorkbookData.SampleFs;
WorkbookOptions.PuffsFs = BLIWorkbookData.PuffsFs;
WorkbookOptions.FiguresOutputFolder = BLIWorkbookData.FiguresOutputFolder;

end
