function Pixels=collectBOINativePixels(Sinks,Surges,N)
% Both signs, full inventory; call before curation or statistics filtering.
Pixels=cell(1,N);
for T={Sinks,Surges}
    S=T{1};if isempty(S),continue;end
    assert(ismember('FramePixels',S.Properties.VariableNames), ...
        'OxygenDynamics:EpisodeEvidence','Saved native masks are required.');
    for s=1:height(S)
        c=S.FramePixels{s};assert(iscell(c)&&numel(c)==N, ...
            'OxygenDynamics:EpisodeEvidence','Native masks disagree with recording length.');
        for t=1:N,Pixels{t}=[Pixels{t};c{t}(:)];end %#ok<AGROW>
    end
end
for t=1:N,Pixels{t}=unique(Pixels{t});end
end
