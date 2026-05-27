function MetadataValues = currentLegacyMetadata()
%CURRENTLEGACYMETADATA Collect legacy wrapper metadata variables if present.

MetadataValues = struct();
if evalin('caller','exist(''Mous'',''var'')')
    MetadataValues.Mouse = evalin('caller','Mous');
else
    MetadataValues.Mouse = 'Unknown';
end

if evalin('caller','exist(''Cond'',''var'')')
    MetadataValues.Condition = evalin('caller','Cond');
else
    MetadataValues.Condition = 'Unknown';
end

if evalin('caller','exist(''Drug'',''var'')')
    MetadataValues.DrugID = evalin('caller','Drug');
else
    MetadataValues.DrugID = 'Unknown';
end

if evalin('caller','exist(''Gen'',''var'')')
    MetadataValues.Genotype = evalin('caller','Gen');
else
    MetadataValues.Genotype = 'Unknown';
end

if evalin('caller','exist(''Promo'',''var'')')
    MetadataValues.Promoter = evalin('caller','Promo');
else
    MetadataValues.Promoter = 'Unknown';
end

if evalin('caller','exist(''Puff'',''var'')')
    MetadataValues.Puff = evalin('caller','Puff');
else
    MetadataValues.Puff = [];
end

end
