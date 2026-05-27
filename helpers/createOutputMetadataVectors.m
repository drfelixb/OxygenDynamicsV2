function MetadataVectors = createOutputMetadataVectors(numRows,experimentID,recDuration,recArea,metadataValues,includePuff)
%CREATEOUTPUTMETADATAVECTORS Expand recording metadata to output-table rows.

if nargin < 6
    includePuff = false;
end

MetadataVectors = struct();
MetadataVectors.Experiment = repmat({experimentID},numRows,1);
MetadataVectors.Mouse = repmat({getMetadataValue(metadataValues,'Mouse')},numRows,1);
MetadataVectors.Condition = repmat({getMetadataValue(metadataValues,'Condition')},numRows,1);
MetadataVectors.DrugID = repmat({getMetadataValue(metadataValues,'DrugID')},numRows,1);
MetadataVectors.Genotype = repmat({getMetadataValue(metadataValues,'Genotype')},numRows,1);
MetadataVectors.Promoter = repmat({getMetadataValue(metadataValues,'Promoter')},numRows,1);
MetadataVectors.RecDuration = repmat({recDuration},numRows,1);
MetadataVectors.RecAreaSize = repmat({recArea},numRows,1);

if includePuff
    Puff = getMetadataValue(metadataValues,'Puff');
    HasPuff = ~isempty(Puff) && ~(isnumeric(Puff) && all(isnan(Puff)));
    MetadataVectors.PuffStim_locus = repmat(logical(HasPuff),numRows,1);
end

end

function Value = getMetadataValue(metadataValues,fieldName)

if isfield(metadataValues,fieldName) && ~isempty(metadataValues.(fieldName))
    Value = metadataValues.(fieldName);
else
    Value = 'Unknown';
end

end
