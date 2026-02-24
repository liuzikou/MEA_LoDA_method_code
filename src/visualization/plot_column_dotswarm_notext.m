function [ax,stats] = plot_column_dotswarm_notext(x, ax)
% PLOT_COLUMN_DOTSWARM
% Stacked dot-swarm (dot matrix) plot for a single column in a given axes.
%
% INPUT
%   x   : Nx1 vector
%   ax  : (optional) target axes handle (e.g., from nexttile)
%
% OUTPUT
%   ax
%   stats.mean
%   stats.std
%   stats.cv_percent

    %% Ensure column vector
    x = x(:);
    n = numel(x);

    %% Statistics
    mu = mean(x);
    sd = std(x);
    cv = sd / mu * 100;

    stats.mean = mu;
    stats.std  = sd;
    stats.cv_percent = cv;

    %% Target axes (IMPORTANT)
    if nargin < 2 || isempty(ax) || ~isvalid(ax)
        ax = gca;
    end

    % Do NOT create new figure/axes here
    hold(ax,'on');

    x0 = 1;

    %% Point appearance
    marker_size = 25;
    alpha_val   = 0.6;

    dx = 0.03;
    dy = max(sd / 4, (max(x)-min(x))/120 + eps);

    %% 1) Build symmetric dot-matrix positions
    [xs, order] = sort(x, 'ascend');
    bin_id = floor((xs - xs(1)) / dy);

    xpos_sorted = zeros(n,1);

    unique_bins = unique(bin_id);
    for b = unique_bins(:)'
        idx = find(bin_id == b);
        k = numel(idx);

        offsets = zeros(k,1);
        for j = 1:k
            if j == 1
                offsets(j) = 0;
            else
                m = ceil((j-1)/2);
                if mod(j,2) == 0
                    offsets(j) = +m;
                else
                    offsets(j) = -m;
                end
            end
        end

        xpos_sorted(idx) = x0 + offsets * dx;
    end

    xpos = zeros(n,1);
    xpos(order) = xpos_sorted;

    %% 2) Scatter points (draw into ax)
    scatter(ax, xpos, x, marker_size, ...
        'filled', ...
        'MarkerFaceColor', [0 0.45 0.9], ...
        'MarkerEdgeColor', 'none', ...
        'MarkerFaceAlpha', alpha_val);

    %% 3) Mean and ±STD
    plot(ax, [x0-0.04 x0+0.04], [mu mu], 'r-', 'LineWidth',2);
    plot(ax, [x0 x0], [mu-sd mu+sd], 'r-', 'LineWidth',0.5);
    plot(ax, [x0-0.02 x0+0.02], [mu-sd mu-sd], 'r-', 'LineWidth',1);
    plot(ax, [x0-0.02 x0+0.02], [mu+sd mu+sd], 'r-', 'LineWidth',1);

    %% 4) Axis formatting
    xlim(ax, [0.7 1.6]);
    set(ax,'XTick',[]);
    box(ax,'off');
    set(ax,'LineWidth',1.2);

    hold(ax,'off');
end
