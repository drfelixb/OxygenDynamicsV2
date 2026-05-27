function Behaviouraldatalogical = createBehaviourLogicalTraces(BehaviourDataCombo,BehFs)
%CREATEBEHAVIOURLOGICALTRACES Build logical event vectors from behaviour traces.

Behaviouraldatalogical = cell(size(BehaviourDataCombo,1),6);

for RecordingIdx = 1:size(BehaviourDataCombo,1)
    if ~isempty(BehaviourDataCombo{RecordingIdx,1})
        [~,Locations] = findpeaks(BehaviourDataCombo{RecordingIdx,1},'MinPeakProminence',0.5);
        Behaviouraldatalogical{RecordingIdx,1} = removeShortLogicalEvents(createWindowedEventMask( ...
            length(BehaviourDataCombo{RecordingIdx,1}),Locations,fix(BehFs/2)),BehFs);
        Behaviouraldatalogical{RecordingIdx,3} = BehaviourDataCombo{RecordingIdx,4};
    end

    if ~isempty(BehaviourDataCombo{RecordingIdx,2})
        [~,Locations] = findpeaks(BehaviourDataCombo{RecordingIdx,2},'MinPeakProminence',0.5);
        Behaviouraldatalogical{RecordingIdx,2} = removeShortLogicalEvents(createWindowedEventMask( ...
            length(BehaviourDataCombo{RecordingIdx,2}),Locations,fix(BehFs/2)),BehFs);
    end

    if ~isempty(BehaviourDataCombo{RecordingIdx,7})
        PupilSmoothDiff = builtin('diff',movingAverageShrink(BehaviourDataCombo{RecordingIdx,7},200));
        [Locations,~] = peakfinder(PupilSmoothDiff);
        Behaviouraldatalogical{RecordingIdx,4} = createWindowedEventMask( ...
            length(BehaviourDataCombo{RecordingIdx,7}),Locations,fix(BehFs/2));
    end

    if ~isempty(BehaviourDataCombo{RecordingIdx,9})
        Behaviouraldatalogical{RecordingIdx,5} = BehaviourDataCombo{RecordingIdx,9};
    end

    if ~isempty(BehaviourDataCombo{RecordingIdx,10})
        Behaviouraldatalogical{RecordingIdx,6} = removeShortLogicalEvents( ...
            BehaviourDataCombo{RecordingIdx,10}>5,BehFs);
    end
end

end
