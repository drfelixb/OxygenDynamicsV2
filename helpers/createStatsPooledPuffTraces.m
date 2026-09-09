function PooledTraces = createStatsPooledPuffTraces(FiltersROIsAndEvents,BehaviourDataCombo, ...
    PuffsToUse,SampleFs,Mice,ROIsTraces,NumOngoingOxysinks,TotalSinkAreaNorm, ...
    TotalSinkAreaUm,NumOngoingOxysinksPerMm2,NumOngoingOxysurges,TotalSurgeArea,PuffsFs)
%CREATESTATSPOOLEDPUFFTRACES Build group-level puff-aligned pooled traces.

TargetFs=max(cell2mat(SampleFs(:))); TargetTime=(-round(30*TargetFs):round(60*TargetFs))/TargetFs;
PooledTraces = cell(15,size(FiltersROIsAndEvents,2));
PooledTraces(1:3,:) = FiltersROIsAndEvents(1:3,:);
PooledTraceMice = cell(15,size(FiltersROIsAndEvents,2));
PooledTraceMice(1:3,:) = FiltersROIsAndEvents(1:3,:);

for GroupIdx = 1:size(FiltersROIsAndEvents,2)
    GroupMask = FiltersROIsAndEvents{4,GroupIdx};
    GroupBehaviour = BehaviourDataCombo(GroupMask,:);
    GroupPuffsToUse = PuffsToUse(GroupMask);
    GroupSampleFs = SampleFs(GroupMask,:);
    GroupMice = Mice(GroupMask,:);
    GroupROIsTraces = ROIsTraces(GroupMask,:);
    GroupNumOngoingSinks = NumOngoingOxysinks(GroupMask,:);
    GroupTotalSinkAreaNorm = TotalSinkAreaNorm(GroupMask,:);
    GroupNumOngoingSinksPerMm2 = NumOngoingOxysinksPerMm2(GroupMask,:);
    GroupNumOngoingSurges = NumOngoingOxysurges(GroupMask,:);
    GroupTotalSurgeArea = TotalSurgeArea(GroupMask,:);
    GroupTotalSinkAreaUm = TotalSinkAreaUm(GroupMask,:);

    for RecordingIdx = 1:size(GroupBehaviour,1)
        if isempty(GroupBehaviour{RecordingIdx,9})
            continue
        end

        SelectedPuffs = parseNumericList(GroupPuffsToUse{RecordingIdx});
        PuffTraceSources = {GroupROIsTraces{RecordingIdx,7},GroupROIsTraces{RecordingIdx,8}, ...
            GroupROIsTraces{RecordingIdx,9},GroupNumOngoingSinks{RecordingIdx,6}, ...
            GroupNumOngoingSinksPerMm2{RecordingIdx,6},GroupTotalSinkAreaNorm{RecordingIdx,6}, ...
            GroupNumOngoingSurges{RecordingIdx,6},GroupTotalSurgeArea{RecordingIdx,6}, ...
            GroupROIsTraces{RecordingIdx,10},GroupROIsTraces{RecordingIdx,11},GroupROIsTraces{RecordingIdx,12}, ...
            GroupTotalSinkAreaUm{RecordingIdx,6}};
        [PuffAlignedTraces,PuffMouseLabels] = extractPuffAlignedTraceRows( ...
            GroupBehaviour{RecordingIdx,9},SelectedPuffs,PuffTraceSources, ...
            GroupSampleFs{RecordingIdx},PuffsFs,GroupMice{RecordingIdx});

        for j=1:numel(PuffAlignedTraces)
            X=PuffAlignedTraces{j};
            if ~isempty(X) && GroupSampleFs{RecordingIdx}~=TargetFs
                oldTime=(-round(30*GroupSampleFs{RecordingIdx}):round(60*GroupSampleFs{RecordingIdx}))/GroupSampleFs{RecordingIdx};
                PuffAlignedTraces{j}=interp1(oldTime,X',TargetTime,'previous',NaN)';
            end
        end
        for PuffMetricIdx = 1:numel(PuffAlignedTraces)
            PooledTraces{PuffMetricIdx+3,GroupIdx} = vertcat( ...
                PooledTraces{PuffMetricIdx+3,GroupIdx},PuffAlignedTraces{PuffMetricIdx});
            PooledTraceMice{PuffMetricIdx+3,GroupIdx} = vertcat( ...
                PooledTraceMice{PuffMetricIdx+3,GroupIdx},PuffMouseLabels);
        end
    end
end

PooledTraces = formatPooledTracesForExport(PooledTraces,PooledTraceMice,TargetTime);

end
