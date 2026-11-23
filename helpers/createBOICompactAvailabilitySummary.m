function A=createBOICompactAvailabilitySummary(D,Meaning)
% Group the original cell-status rules without materializing the cell report.
% SourceRows is a lossless locator into unchanged primary tables (data rows).
if nargin<2,Meaning=[];end
names={'RecordingID','Experiment','Mouse','SessionID','Condition','EventType','Sheet','Metric','State','Reason','Quality','Comparison', ...
    'NumRows','FirstSourceRow','LastSourceRow','RowsAreContiguous','SourceRows','Segment','SelectionRule','AvailabilityVersion'};
rows=cell(0,numel(names));sheets={'Events','Recordings','Sites','TimeSeries','Phases'};
for sn=sheets
    T=D.(sn{1});if isempty(T),continue;end
    ids=T(:,{'RecordingID','Experiment','Mouse','SessionID','Condition'});
    if ismember('EventType',T.Properties.VariableNames),ids.EventType=string(T.EventType);else,ids.EventType=strings(height(T),1);end
    [~,~,identityGroup]=unique(ids,'rows','stable');
    for f=string(T.Properties.VariableNames)
        v=T.(f);if ~isnumeric(v)&&~islogical(v),continue;end
        state=repmat("available",height(T),1);state(~isfinite(v))="missing_saved_value";
        reason=repmat("copied saved value or declared inventory unit conversion",height(T),1);quality=strings(height(T),1);
        neg=isfinite(v)&v<0;if contains(f,["Amplitude","Contribution","Burden"]),quality(neg)="negative signed value retained as saved; not excluded";end
        if contains(f,["Short","Overlap","AboveRecordingReference","Truncated","Negative"]),quality(isfinite(v)&v==1)="source quality/sign flag set; descriptive only";end
        if startsWith(f,'Reviewed')&&ismember('ReviewStatus',T.Properties.VariableNames)
            no=startsWith(T.ReviewStatus,'No compatible');state(no)="no_review_snapshot";
            ex=false(height(T),1);if ismember('ReviewedExcluded',T.Properties.VariableNames),ex=T.ReviewedExcluded==1;end
            state(ex)="excluded_not_applicable";reason=T.ReviewStatus;
        end
        if ismember('EventType',T.Properties.VariableNames)&&contains(f,["Burden","Contribution"])
            surge=T.EventType=="surge";state(surge)="not_applicable";reason(surge)="hypoxic burden is defined only for sinks";
        end
        comparison="not_assessed";if ~isempty(Meaning),[~,~,~,comparison]=Meaning(f);end
        groups=table(identityGroup,state,reason,quality);[~,first,g]=unique(groups,'rows','stable');
        for gi=1:numel(first)
            ix=find(g==gi);chunks=locators(ix);j=first(gi);
            identity=table2cell(ids(j,:));
            for ci=1:numel(chunks)
                c=chunks(ci);
                rows(end+1,:)=[identity {string(sn{1}),f,state(j),reason(j),quality(j),comparison, ...
                    c.Count,c.First,c.Last,c.Contiguous,c.Text,ci, ...
                    "SourceRows selects exact 1-based data rows in Sheet; Metric selects the column. Excel row = data row + 1. Multiple segments are disjoint.", ...
                    "boi-availability-summary-1"}]; %#ok<AGROW>
            end
        end
    end
end
if isempty(rows)
    A=table();
    for k=1:numel(names)
        if ismember(names{k},{'NumRows','FirstSourceRow','LastSourceRow','RowsAreContiguous','Segment'}),A.(names{k})=zeros(0,1);else,A.(names{k})=strings(0,1);end
    end
else
    A=cell2table(rows,'VariableNames',names);
    for f=string(names)
        if ~ismember(f,["NumRows","FirstSourceRow","LastSourceRow","RowsAreContiguous","Segment"]),A.(f)=string(A.(f));end
    end
end
end
function C=locators(ix)
% Inclusive runs, split into safe Excel text segments without losing row IDs.
start=ix([true;diff(ix)>1]);last=ix([diff(ix)>1;true]);
tokens=string(start);m=last~=start;tokens(m)=tokens(m)+"-"+string(last(m));
C=struct('Text',{},'Count',{},'First',{},'Last',{},'Contiguous',{});a=1;len=0;
for k=1:numel(tokens)
    extra=double(strlength(tokens(k)))+double(k>a);
    if len+extra>30000
        C(end+1)=chunk(a,k-1);a=k;len=0;extra=double(strlength(tokens(k))); %#ok<AGROW>
    end
    len=len+extra;
end
C(end+1)=chunk(a,numel(tokens));
    function c=chunk(lo,hi)
        c=struct('Text',join(tokens(lo:hi),','),'Count',sum(last(lo:hi)-start(lo:hi)+1), ...
            'First',start(lo),'Last',last(hi),'Contiguous',double(lo==hi));
    end
end
