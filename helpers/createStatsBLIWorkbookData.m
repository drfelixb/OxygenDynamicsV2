function BLIWorkbookData = createStatsBLIWorkbookData(AlignedSinkTraces,TraceCorrs, ...
    LPawBinnedTraces,RPawBinnedTraces,PupilBinnedTraces,PooledTraces, ...
    BehaviourLogicals,SampleFs,PuffsFs,FiguresOutputFolder)
%CREATESTATSBLIWORKBOOKDATA Bundle BLI-only workbook and figure export inputs.

BLIWorkbookData = struct();
BLIWorkbookData.AlignedSinkTraces = AlignedSinkTraces;
BLIWorkbookData.TraceCorrs = TraceCorrs;
BLIWorkbookData.LPawBinnedTraces = LPawBinnedTraces;
BLIWorkbookData.RPawBinnedTraces = RPawBinnedTraces;
BLIWorkbookData.PupilBinnedTraces = PupilBinnedTraces;
BLIWorkbookData.PooledTraces = PooledTraces;
BLIWorkbookData.BehaviourLogicals = BehaviourLogicals;
BLIWorkbookData.SampleFs = SampleFs;
BLIWorkbookData.PuffsFs = PuffsFs;
BLIWorkbookData.FiguresOutputFolder = FiguresOutputFolder;

end
