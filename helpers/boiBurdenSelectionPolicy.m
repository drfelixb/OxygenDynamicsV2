function P=boiBurdenSelectionPolicy(E,requested)
% Selection provenance is separate from event-reference arithmetic/version.
% No arguments requests the current policy. Unmarked saved tables stay legacy.
current="boi-signed-contributions-1";legacy="boi-legacy-nonnegative-1";
id='OxygenDynamics:BurdenSelectionPolicy';stored="";
if nargin==0
    version=current;
else
    assert(istable(E),id,'Supply an event table.');
    if ismember('BurdenSelectionPolicyVersion',E.Properties.VariableNames)&&height(E)>0
        values=unique(string(E.BurdenSelectionPolicyVersion));
        assert(isscalar(values)&&~ismissing(values)&&strlength(values)>0,id,'Mixed or missing burden selection policies.');
        stored=values;
    end
    version=stored;
    if nargin>=2&&~isempty(requested)
        if isstruct(requested),requested=requested.Version;end
        if istable(requested),requested=requested.Version;end
        requested=string(requested);
        assert(isscalar(requested)&&~ismissing(requested)&&strlength(requested)>0,id,'Supply one burden selection version.');
        assert(stored==""||stored==requested,id,'Requested policy conflicts with saved event provenance.');
        version=requested;
    end
    if version=="",version=legacy;end
end
assert(any(version==[current legacy]),id,'Unsupported burden selection policy.');
P=struct('Version',char(version),'IncludeFiniteNegative',version==current, ...
    'ReferenceRole','separate_unchanged_event_reference', ...
    'ContributionFormula','amplitude_percent * mean_area_um2 * duration_s', ...
    'Normalization','strict_sum * 1e6/analyzed_area_um2 * 60/recording_duration_s', ...
    'Completeness','all_required_retained_contributions; no_partial_sum', ...
    'NegativeRule','legacy_nonnegative_eligibility', ...
    'Quantity','legacy_source_specific_burden');
if P.IncludeFiniteNegative
    P.NegativeRule='include_signed_and_flag; negative_terms_subtract';
    P.Quantity='signed_burden_composite; not_calibrated_oxygen';
end
end
