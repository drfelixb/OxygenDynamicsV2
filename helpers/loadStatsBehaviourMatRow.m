function BehaviourRow = loadStatsBehaviourMatRow(BehaviourRow,BehaviourFolder,RecordingId,Inputs)
%LOADSTATSBEHAVIOURMATROW Load configured MAT-backed behaviour traces.

if isStatsOptionalInputConfigured(Inputs.Posture)
    [PostureData,LoadedPosture] = loadStatsMatVars(BehaviourFolder, ...
        {'LpawMovmm.mat','LpawMovZ.mat','RpawMovmm.mat','RpawMovZ.mat','NoseMovmm.mat','Groomlogical.mat'}, ...
        {'LpawMovmm','LpawMovZ','RpawMovmm','RpawMovZ','NoseMovmm','Groomlogical'}, ...
        'posture',RecordingId);
    if LoadedPosture
        BehaviourRow{1}=PostureData.LpawMovmm;
        BehaviourRow{2}=PostureData.RpawMovmm;
        BehaviourRow{3}=PostureData.NoseMovmm;
        BehaviourRow{4}=PostureData.Groomlogical;
        BehaviourRow{5}=PostureData.LpawMovZ;
        BehaviourRow{6}=PostureData.RpawMovZ;
    end
end

if isStatsOptionalInputConfigured(Inputs.Pupil)
    [PupilData,LoadedPupil] = loadStatsMatVars(BehaviourFolder, ...
        {'PupilDiammm.mat','PupilDiamZ.mat'}, ...
        {'PupilDiammm','PupilDiamZ'}, ...
        'pupil',RecordingId);
    if LoadedPupil
        BehaviourRow{7}=PupilData.PupilDiammm;
        BehaviourRow{8}=PupilData.PupilDiamZ;
    end
end

if isStatsOptionalInputConfigured(Inputs.Puff)
    [PuffData,LoadedPuff] = loadStatsMatVars(BehaviourFolder, ...
        {'Pufflogical.mat'}, ...
        {'Pufflogical'}, ...
        'puff',RecordingId);
    if LoadedPuff
        BehaviourRow{9}=PuffData.Pufflogical;
    end
end
end
