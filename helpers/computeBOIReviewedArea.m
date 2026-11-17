function Q=computeBOIReviewedArea(D)
% Complete-frame mean and the unchanged event burden/exposure formulas.
validateBOIAreaReview(D);C=D.Context;F=D.FrameDecisions;
state=string({F.Status})';done=state=="accepted"|state=="empty";counts=nan(numel(F),1);outside=zeros(numel(F),1);
for k=1:numel(F)
    if done(k),counts(k)=numel(F(k).Pixels);end
    outside(k)=numel(setdiff(double(F(k).Pixels(:)),double(C.FixedFootprint(:))));
end
Q=struct('Status','incomplete','FramePixels',counts,'OutsideFootprintPixels',outside, ...
    'ReviewedFrames',sum(done),'RequiredFrames',numel(F),'UnresolvedFrames',C.Frames(~done), ...
    'SpatialMismatchFrames',C.Frames(outside>0),'MeanAreaPixels',NaN,'MeanAreaUm2',NaN, ...
    'Contribution',NaN,'NormalizedContribution',NaN,'Complete',false,'AllFramesExplicitlyEmpty',all(state=="empty"));
if any(state=="uncertain"),Q.Status='uncertain';end
if any(outside>0),Q.Status='spatial_mismatch';return;end
if ~all(done),return;end
Q.MeanAreaPixels=mean(counts);Q.MeanAreaUm2=Q.MeanAreaPixels*C.PixelSizeUm^2;
Q.Contribution=C.AmplitudePercent*Q.MeanAreaUm2*C.DurationSec;
Q.NormalizedContribution=Q.Contribution*(1e6/C.RecordingAreaUm2)*(60/C.RecordingDurationSec);
assert(all(isfinite([Q.MeanAreaUm2 Q.Contribution Q.NormalizedContribution])),'OxygenDynamics:InvalidAreaReview','Area/burden arithmetic overflowed.');
Q.Status='complete';Q.Complete=true;
end
