function [Registry,Contracts,QC,Frames] = buildBOIRecordingInputContracts(Registry,Recordings)
%BUILDBOIRECORDINGINPUTCONTRACTS Keep original master evidence with portable IDs.
assert(height(Registry)==numel(Recordings),'OxygenDynamics:InputContractIdentity','Recording source map must match the registry.');
for field={'InputContractVersion','FrameTimingStatus','CameraExposureStatus','TissueValidityStatus','AcquisitionMetadataState','AnalysisSupportStatus','DetectionSupportProfile'}
    Registry.(field{1})=strings(height(Registry),1);
end
Contracts=cell(height(Registry),1);Q=cell(size(Contracts));F=cell(size(Contracts));
for i=1:height(Registry)
    info=loadRequiredMatVar(Recordings(i).SinksMatFile,'AnalysisInfo');
    surge=loadRequiredMatVar(Recordings(i).SurgesMatFile,'AnalysisInfo');
    profile=getBOISupportProfile(info);
    assert(strcmp(profile,getBOISupportProfile(surge))&&isequaln(info.PipelineContract,surge.PipelineContract), ...
        'OxygenDynamics:MixedSupportProfiles','Sink and surge methods differ. Select a consistent run.');
    if i>1
        assert(isequaln(info.PipelineContract,Contracts{1}.PipelineContract), ...
            'OxygenDynamics:MixedSupportProfiles','Whole-image and restricted ROI methods cannot be pooled.');
    end
    a=[];b=[];
    if isfield(info,'BOIAcquisitionMetadata'),a=info.BOIAcquisitionMetadata;end
    if isfield(surge,'BOIAcquisitionMetadata'),b=surge.BOIAcquisitionMetadata;end
    assert(isequaln(a,b),'OxygenDynamics:MixedInputMetadata','Sink and surge master metadata snapshots differ. Select a consistent run.');
    for field={'BOITissueSupport','TissueSupportAudit','DetectionSupportAudit','SinkEligibleTissuePixels','SurgeEligibleTissuePixels'}
        a=[];b=[];
        if isfield(info,field{1}),a=info.(field{1});end
        if isfield(surge,field{1}),b=surge.(field{1});end
        assert(isequaln(a,b),'OxygenDynamics:MixedTissueSupport','Sink and surge support evidence differs. Select a consistent master run.');
    end
    assert(strcmp(info.RawSHA256,Registry.RawSHA256(i)), 'OxygenDynamics:InputContractIdentity','Registry source mismatch.');
    if isfield(info,'FrameSize')
        shape=info.FrameSize;
    else
        % Source inventory/hash was verified by the stats loader. Recover only
        % TIFF dimensions, never historical timing/exposure metadata.
        [~,name,extension]=fileparts(info.RawFile);
        tif=Tiff(fullfile(Recordings(i).Folder,[name extension]),'r');clean=onCleanup(@()close(tif));
        shape=[getTag(tif,'ImageLength'),getTag(tif,'ImageWidth')];clear clean
    end
    [c,Q{i},F{i}]=createBOIRecordingInputContract(info,Registry.RecordingID(i),shape);
    assert(c.InputCompatible,'OxygenDynamics:UnsupportedBOIInput','Saved acquisition declarations require assessment before uniform-time statistics.');
    c.DetectionSupportProfile=profile;
    c.PipelineContract=info.PipelineContract;
    c.DetectionSupportAudit=struct();
    if isfield(info,'DetectionSupportAudit')
        c.DetectionSupportAudit=rmfield(info.DetectionSupportAudit,'NeighborWeightMap');
        c.DetectionSupportAudit.NeighborWeightMapLocation='AnalysisInfo.DetectionSupportAudit.NeighborWeightMap in both original master MAT files';
    end
    Contracts{i}=c;
    Registry.DetectionSupportProfile(i,1)=string(profile);
    Registry.InputContractVersion(i,1)=string(c.Schema);
    Registry.FrameTimingStatus(i,1)=string(c.FrameTimingStatus);
    Registry.CameraExposureStatus(i,1)=string(c.ExposureStatus);
    Registry.TissueValidityStatus(i,1)=string(c.TissueValidityStatus);
    Registry.AcquisitionMetadataState(i,1)=string(c.MetadataState);
    Registry.AnalysisSupportStatus(i,1)="descriptive_static_uniform_assumptions";
    if ~isempty(fieldnames(c.TissueDecision))
        Registry.AnalysisSupportStatus(i,1)="descriptive_reviewed_static_support_uniform_intervals";
    end
end
QC=vertcat(Q{:});Frames=vertcat(F{:});
end
