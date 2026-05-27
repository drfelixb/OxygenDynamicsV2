function TimeWindows = selectStatsBehaviourTimeWindows(DefaultWindows,Interactive,BehaviourDataCombo,ManualEvents)
%SELECTSTATSBEHAVIOURTIMEWINDOWS Return behaviour-event time windows for stats.

TimeWindows = DefaultWindows;
HasBehaviourOrManualEvents = any(~cellfun(@isempty,BehaviourDataCombo),'all') || ~isempty(ManualEvents);
if Interactive && HasBehaviourOrManualEvents
    Prompt = {'Enter window for manual event:', ...
        'Enter window for body movement/whisking:', ...
        'Enter window for pupil:', ...
        'Enter window for whisker stimulation:'};
    DlgTitle = 'Behaviour time window(s)';
    Dims = [1 65];
    TimeWindows = inputdlg(Prompt,DlgTitle,Dims,DefaultWindows);
end
end
