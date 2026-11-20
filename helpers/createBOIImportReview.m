function Review=createBOIImportReview(Validation,SampleHz,PixelSizeUm)
%CREATEBOIIMPORTREVIEW Shared preflight evidence for MATLAB GUI and batch review.
% Readability and supported time/support models do not establish eligibility.
Review=struct('Files',Validation,'Status','import_failure','InputCompatible',false, ...
    'ScientificStatus','not_established','SampleHz',SampleHz,'PixelSizeUm',PixelSizeUm, ...
    'RawSHA256','','MetadataSnapshot',[],'Acquisition',struct(), ...
    'TissueSnapshot',[],'TissueDeclaration',struct(),'TissueStatus','not_assessed', ...
    'DeclarationFiles',struct('Name',{},'SHA256',{}));
Review.QC=table('Size',[0 5],'VariableTypes',repmat({'string'},1,5), ...
    'VariableNames',{'IssueID','Disposition','AffectedMeasurements','Message','Action'});
if ~Validation.IsValid
    for i=1:numel(Validation.Errors)
        Review.QC(end+1,:)={"IMPORT-FILES","import_failure","All measurements", ...
            string(Validation.Errors{i}),"Correct source selection or metadata, then run verification again. Keep historical analysis outputs separate from acquisition inputs."};
    end
    return
end
try
    Review.RawSHA256=oxygenFileSHA256(Validation.RawFile);
    for name={'BOIInputMetadata.json','BOITissueSupport.json'}
        file=fullfile(Validation.RecordingFolder,name{1});
        if isfile(file)
            Review.DeclarationFiles(end+1)=struct('Name',name{1},'SHA256',oxygenFileSHA256(file));
        end
    end
    [Review.MetadataSnapshot,Review.Acquisition,Review.QC]=captureBOIAcquisitionMetadata( ...
        Validation.RecordingFolder,Validation.RawTiffInfo.Frames,SampleHz,Review.RawSHA256,false);
    [Review.TissueSnapshot,~,Review.TissueDeclaration]=captureBOITissueSupport(Validation.RecordingFolder, ...
        [Validation.RawTiffInfo.Height Validation.RawTiffInfo.Width],Review.RawSHA256);
    Review.InputCompatible=Review.Acquisition.InputCompatible;
    Review.Status='descriptive_input_requires_scientific_review';
    if ~Review.InputCompatible,Review.Status='held_for_current_uniform_time_pipeline';end
    if any(startsWith(Review.QC.IssueID,"SOURCE-") & Review.QC.Disposition=="hold_recording")
        Review.Status='held_for_source_review';
    end
    Review.TissueStatus='static_tissue_mask_is_computed_by_master; dynamic_validity_requires_review';
    if strcmp(Review.TissueSnapshot.State,'captured')
        Review.TissueStatus='reviewed_static_support_declared; anatomical_evidence_and_dynamic_validity_require_assessment';
        Review.QC(end+1,:)={"R1-REVIEWED-TISSUE","review","Tissue-normalized measurements and candidate support", ...
            "Static support decision " + string(Review.TissueDeclaration.DecisionID) + ...
            " by " + string(Review.TissueDeclaration.Actor) + ". Evidence: " + string(Review.TissueDeclaration.Evidence) + ...
            ". Alignment: " + string(Review.TissueDeclaration.AlignmentEvidence), ...
            "Assess the declared evidence and motion over time. A declaration does not establish scientific eligibility or full event-footprint containment."};
    else
        Review.QC(end+1,:)={"R1-STATIC-TISSUE","review","Occupied tissue fraction, area-normalized measurements and candidate support", ...
            "No reviewed tissue mask is supplied. The master will estimate static support from intensity; anatomical coverage and validity over time are not established.", ...
            "Review observable tissue and alignment. Record a supported mask decision before a fresh master if appropriate; do not substitute exploratory detection outputs for anatomical evidence."};
    end
catch err
    Review.InputCompatible=false;Review.Status='import_failure';
    Review.QC(end+1,:)={"IMPORT-DECLARATION","import_failure","All measurements", ...
        string(err.identifier) + ": " + string(err.message), ...
        "Correct the source-bound declaration or input file, preserving earlier evidence. Run verification again; the declaration has not been accepted."};
end
end
