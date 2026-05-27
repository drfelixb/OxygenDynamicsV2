function BLIData = createStatsBLIData(BehaviourDataCombo,BehaviourLogicals,ROIsTraces,ExportTraceCorrs,TraceCorrs)
%CREATESTATSBLIDATA Bundle BLI-only stats outputs before legacy MAT export.

BLIData = struct();
BLIData.BehaviourDataCombo = BehaviourDataCombo;
BLIData.BehaviourLogicals = BehaviourLogicals;
BLIData.ROIsTraces = ROIsTraces;
BLIData.ExportTraceCorrs = ExportTraceCorrs;
BLIData.TraceCorrs = TraceCorrs;

end
