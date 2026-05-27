function Context = createLegacyRecordingContext(SFs,Mous,Cond,PiSz,Gen,Promo,Drug,Posture,Pupil,Puff,strOW)
%CREATELEGACYRECORDINGCONTEXT Build explicit context for legacy run scripts.

Context = struct();
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
