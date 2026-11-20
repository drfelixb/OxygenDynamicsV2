function plot_areaerrorbar(data, options)
% plot_areaerrorbar plots the mean trace with a shaded error area.
% Copyright (c) 2018, Victor Martinez-Cagigal.
% Distributed under upstream BSD-3-Clause terms; see
% ../THIRD_PARTY_NOTICES.md.

if nargin<2
    options.handle     = figure(1);
    options.color_area = [128 193 219]./255;
    options.color_line = [52 148 186]./255;
    options.alpha      = 0.5;
    options.line_width = 2;
    options.error      = 'std';
end
if isfield(options,'x_axis')==0
    options.x_axis = 1:size(data,2);
end
options.x_axis = options.x_axis(:);

data_mean = mean(data,1);
data_std  = std(data,0,1);

switch options.error
    case 'std'
        errorValues = data_std;
    case 'sem'
        errorValues = data_std./sqrt(size(data,1));
    case 'var'
        errorValues = data_std.^2;
    case 'c95'
        errorValues = (data_std./sqrt(size(data,1))).*1.96;
end

figure(options.handle);
x_vector = [options.x_axis', fliplr(options.x_axis')];
areaPatch = fill(x_vector, [data_mean+errorValues,fliplr(data_mean-errorValues)], options.color_area);
set(areaPatch, 'edgecolor', 'none');
set(areaPatch, 'FaceAlpha', options.alpha);
hold on;
plot(options.x_axis, data_mean, 'color', options.color_line, ...
    'LineWidth', options.line_width);
hold off;

end
