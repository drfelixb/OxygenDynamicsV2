function [raw,denoised]=findBOIPairedMovies(folder,assigned)
% Suggest a complete TCA pair of the same preparation stage. Manual choices remain possible.
if nargin<2, assigned=strings(1,0); end
assigned=assigned(assigned~="");
files=dir(fullfile(folder,'*.tif*')); names=string({files(~[files.isdir]).name});
names=names(endsWith(names,[".tif",".tiff"],'IgnoreCase',true));
movies=names(startsWith(names,"TCA_aligned_Camera",'IgnoreCase',true) & ...
    ~contains(names,["AVG_","denoised"],'IgnoreCase',true));
raw=["",""]; denoised=raw;
for corrected=[true false]
    pool=movies(contains(movies,"_coupledMC.",'IgnoreCase',true)==corrected);
    choices=["",""];
    for c=1:2
        hits=pool(startsWith(pool,"TCA_aligned_Camera"+c+"_",'IgnoreCase',true));
        if isscalar(hits), choices(c)=hits; end
    end
    if all(choices~="")
        candidates=fullfile(string(folder),choices);
        if ~all(ismember(assigned,candidates)), continue; end
        raw=candidates;
        for c=1:2
            [~,stem]=fileparts(choices(c));
            matches=names(ismember(lower(names),lower(stem+["_denoised.tif","_denoised.tiff"])));
            if isscalar(matches), denoised(c)=fullfile(string(folder),matches); end
        end
        return
    end
end
end
