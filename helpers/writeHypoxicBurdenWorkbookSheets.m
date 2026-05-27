function writeHypoxicBurdenWorkbookSheets(OutputXlsx,HypoxicBurden)
%WRITEHYPOXICBURDENWORKBOOKSHEETS Write hypoxic burden sheets to stats workbook.

if isempty(HypoxicBurden) || ~isstruct(HypoxicBurden)
    return
end

if isfield(HypoxicBurden,'MetricBasis') && ~isempty(HypoxicBurden.MetricBasis)
    writetable(HypoxicBurden.MetricBasis,OutputXlsx,'Sheet','HypoxicBurden_Basis');
end

if isfield(HypoxicBurden,'EventTable') && ~isempty(HypoxicBurden.EventTable)
    writetable(HypoxicBurden.EventTable,OutputXlsx,'Sheet','HypoxicBurden_EventBased');
end

if isfield(HypoxicBurden,'RecordingTable') && ~isempty(HypoxicBurden.RecordingTable)
    writetable(HypoxicBurden.RecordingTable,OutputXlsx,'Sheet','HypoxicBurden_ByRecording');
end

if isfield(HypoxicBurden,'GroupSummaryTable') && ~isempty(HypoxicBurden.GroupSummaryTable)
    writetable(HypoxicBurden.GroupSummaryTable,OutputXlsx,'Sheet','HypoxicBurden_GroupSummary');
end

end
