function M=computeBOIReviewedPocketMeasures(raw,corrected,R,W,referenceState,clock)
%COMPUTEBOIREVIEWEDPOCKETMEASURES Two signed troughs; no sign repair or fitting.
id='OxygenDynamics:InvalidPocketFrames';raw=double(raw(:));corrected=double(corrected(:));N=numel(raw);
assert(isnumeric(R)&&isreal(R)&&(isempty(R)||isvector(R))&&all(isfinite(R(:)))&& ...
    all(R(:)==fix(R(:)))&&all(R(:)>=1&R(:)<=N)&&all(diff(R(:))>0),id,'Reference frames must be unique increasing recorded integers.');
assert(isnumeric(W)&&isreal(W)&&isvector(W)&&~isempty(W)&&all(isfinite(W(:)))&& ...
    all(W(:)==fix(W(:)))&&all(W(:)>=1&W(:)<=N)&&all(diff(W(:))==1)&&all(R(:)<W(1)),id,'Episode frames must be contiguous; reference strictly precedes onset.');
R=double(R(:));W=double(W(:));
assert(ismember(referenceState,{'accepted_local_state','provisional_local_state','unsuitable','not_assessed'}),id,'Unknown reference suitability.');
assert(isempty(corrected)||numel(corrected)==N,id,'Saved correction length differs.');
M=struct('ArithmeticStatus','unavailable','PrimaryStatus','unavailable','CompanionStatus','unavailable', ...
    'ReferenceSampleCount',numel(R),'RawReferenceMean',NaN,'CorrectedReferenceMean',NaN, ...
    'CorrectedSignedTroughPercent',NaN,'RawSignedTroughPercent',NaN, ...
    'CorrectedMinimumFrames',zeros(0,1),'RawMinimumFrames',zeros(0,1), ...
    'RawReferenceValues',raw(R),'RawEventValues',raw(W),'CorrectedReferenceValues',zeros(0,1),'CorrectedEventValues',zeros(0,1), ...
    'RawSignedPercent',nan(numel(W),1),'CorrectedSignedPercent',nan(numel(W),1));
if ~strcmp(clock,'external_trigger_1Hz'),M.ArithmeticStatus='unavailable_unverified_clock';return;end
if ismember(referenceState,{'unsuitable','not_assessed'}),M.ArithmeticStatus=['unavailable_reference_' referenceState];return;end
if isempty(R),M.ArithmeticStatus='unavailable_empty_reference';return;end
if ~all(isfinite(raw(R))),M.ArithmeticStatus='unavailable_nonfinite_reference';return;end
B=mean(raw(R));M.RawReferenceMean=B;
if ~isfinite(B)||B<=0,M.ArithmeticStatus='unavailable_nonpositive_reference_mean';return;end
if ~all(isfinite(raw(W))),M.ArithmeticStatus='unavailable_nonfinite_event';return;end
q=100*(raw(W)-B)/B;
if ~all(isfinite(q)),M.ArithmeticStatus='unavailable_nonfinite_arithmetic';return;end
status='computed_exploratory';if strcmp(referenceState,'provisional_local_state'),status='conditional_exploratory';end
M.RawSignedPercent=q;M.RawSignedTroughPercent=min(q);M.RawMinimumFrames=W(q==min(q));M.CompanionStatus=status;
if isempty(corrected),M.PrimaryStatus='unavailable_missing_saved_correction';M.ArithmeticStatus='raw_only_missing_correction';return;end
M.CorrectedReferenceValues=corrected(R);M.CorrectedEventValues=corrected(W);
if ~all(isfinite(corrected([R;W]))),M.PrimaryStatus='unavailable_nonfinite_saved_correction';M.ArithmeticStatus='raw_only_nonfinite_correction';return;end
C=mean(corrected(R));M.CorrectedReferenceMean=C;q=100*(corrected(W)-C)/B;
if ~isfinite(C)||~all(isfinite(q)),M.PrimaryStatus='unavailable_nonfinite_corrected_arithmetic';M.ArithmeticStatus='raw_only_nonfinite_correction';return;end
M.CorrectedSignedPercent=q;M.CorrectedSignedTroughPercent=min(q);M.CorrectedMinimumFrames=W(q==min(q));M.PrimaryStatus=status;M.ArithmeticStatus=status;
end
