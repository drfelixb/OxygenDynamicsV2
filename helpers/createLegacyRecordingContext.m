function Context = createLegacyRecordingContext(SFs,Mous,Cond,PiSz,Gen,Promo,Drug,Posture,Pupil,Puff,strOW,BOISupportProfile)
%CREATELEGACYRECORDINGCONTEXT Build explicit context for legacy run scripts.

if nargin<12,BOISupportProfile='whole-image';end
Context = struct();
Context.BOISupportProfile=getBOISupportProfile(struct('BOISupportProfile',BOISupportProfile));
Context.SFs = SFs;
Context.Mous = Mous;
Context.Cond = Cond;
Context.PiSz = PiSz;
Context.Gen = Gen;
Context.Promo = Promo;
Context.Drug = Drug;
Context.Posture = Posture;
Context.Pupil = Pupil;
Context.Puff = Puff;
Context.strOW = strOW;

end
