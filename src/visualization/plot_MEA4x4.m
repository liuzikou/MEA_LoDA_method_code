function ax = plot_MEA4x4(ax, chns, data_chns, plotTitle)
%PLOT_MEA4X4 Plot 4x4 MEA channel data on a given axes.
%
%   ax = plot_MEA4x4(ax, chns, data_chns)
%   ax = plot_MEA4x4(ax, chns, data_chns, plotTitle)
%
% Inputs
%   ax         : target axes handle (e.g., returned by nexttile)
%   chns       : channel IDs (e.g. [11 12 13 ...])
%   data_chns  : values corresponding to each channel
%   plotTitle  : (optional) title string
%
% Output
%   ax         : axes handle

    if nargin < 4
        plotTitle = '';
    end

    idxM = [11,12,13,14;
            21,22,23,24;
            31,32,33,34;
            41,42,43,44];

    dataM = nan(4,4);

    % --- Fill matrix ---
    chns = chns(:);
    data_chns = data_chns(:);

    for i = 1:numel(chns)
        dataM(idxM == chns(i)) = data_chns(i);
    end

    % --- Plot ---
    imagesc(ax, dataM, 'AlphaData', ~isnan(dataM));
    axis(ax, 'image');
    set(ax, 'YDir', 'normal');
    set(ax, 'Color', [0.5 0.5 0.5]);

    hold(ax, 'on');

    % --- Grid lines ---
    xline(ax, [1.5 2.5 3.5], 'k', 'LineWidth', 1);
    yline(ax, [1.5 2.5 3.5], 'k', 'LineWidth', 1);

    % --- Ticks ---
    xticks(ax, 1:4);
    yticks(ax, 1:4);

    % --- Colormap ---
    colormap(ax, redwhiteblue(256));

    % --- Text overlay ---
    for r = 1:4
        for c = 1:4
            val = dataM(r,c);
            if ~isnan(val)
                text(ax, c, r, num2str(round(val,2)), ...
                    'HorizontalAlignment','center', ...
                    'VerticalAlignment','middle', ...
                    'Color','k');
            end
        end
    end

    % --- Title ---
    if ~isempty(plotTitle)
        title(ax, plotTitle);
    end

    hold(ax, 'off');
end
