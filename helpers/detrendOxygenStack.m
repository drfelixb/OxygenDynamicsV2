function IM2 = detrendOxygenStack(IM,dimensions)
%DETRENDOXYGENSTACK Remove polynomial trends from traces in an image stack.

IM2 = single(nan(size(IM)));

switch dimensions
    case 3
        for xx = 1:size(IM,1)
            parfor yy = 1:size(IM,2)
                Signal = squeeze(IM(xx,yy,:))';
                [p,~,mu] = polyfit(1:numel(Signal),Signal,3);
                SignalTrend = polyval(p,1:numel(Signal),[],mu);
                IM2(xx,yy,:) = Signal - SignalTrend;
            end
        end

    case 2
        for xx = 1:size(IM,1)
            Signal = IM(xx,:);
            [p,~,mu] = polyfit(1:numel(Signal),Signal,5);
            SignalTrend = polyval(p,1:numel(Signal),[],mu);
            IM2(xx,:) = Signal - SignalTrend;
        end

    otherwise
        error('detrendOxygenStack:UnsupportedDimensions', ...
            'Only 2-D traces or 3-D image stacks are supported.');
end

IM2 = single(IM2);

end
