function IM2 = detrend_custom(IM,dimensions)
%DETREND_CUSTOM Legacy polynomial detrending for stacks or trace matrices.

IM2 = nan(size(IM));

switch dimensions
    case 3
        for xx = 1:size(IM,1)
            parfor yy = 1:size(IM,2)
                S1 = (squeeze(IM(xx,yy,:)))';
                [p,~,mu] = polyfit(1:numel(S1),S1,3);
                signaltrend = polyval(p,1:numel(S1),[],mu);
                IM2(xx,yy,:) = S1-signaltrend;
            end
        end
    case 2
        for xx = 1:size(IM,1)
            S1 = IM(xx,:);
            [p,~,mu] = polyfit(1:numel(S1),S1,5);
            signaltrend = polyval(p,1:numel(S1),[],mu);
            IM2(xx,:) = S1-signaltrend;
        end
end

end
