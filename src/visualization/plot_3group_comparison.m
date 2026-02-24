function [ax, stats] = plot_3group_comparison(data)
%PLOT_3GROUP_COMPARISON  Bar plot for 3 paired groups with SEM and paired t-tests.
%
% INPUT
%   data : 3 x N matrix (rows = groups/timepoints, columns = subjects), paired by column.
%
% OUTPUT
%   ax    : axes handle (for tiledlayout/nexttile usage)
%   stats : struct containing p-values and summary statistics
%           stats.means, stats.sems, stats.p12, stats.p23
%
% Notes
%   - This function does NOT create a figure; it plots into the current axes (gca).
%   - Axis limits, title, ylabel, etc. can be set outside by the caller.
%   - Keeps the local helper function sigstar() for significance annotation.

    % ---- Validate input ----
    if ~isnumeric(data) || ~ismatrix(data) || size(data,1) ~= 3
        error('Input data must be a numeric 3xN matrix.');
    end

    ax = gca;

    % Muted color palette
    colors = [0.969, 0.988, 0.725;   % Light yellow-green
              0.678, 0.867, 0.557;   % Mid green
              0.000, 0.373, 0.318];  % Dark blue-green

    means = mean(data, 2);
    sems  = std(data, 0, 2) ./ sqrt(size(data, 2));

    hold(ax, 'on');

    % ---- Bars ----
    hb = gobjects(1,3);
    for i = 1:3
        hb(i) = bar(ax, i, means(i), 'FaceColor', colors(i,:), 'BarWidth', 0.8);
    end

    % ---- Error bars (no connecting line) ----
    he = errorbar(ax, 1:3, means, sems, 'k.', 'LineWidth', 1.5, ...
        'LineStyle', 'none', 'HandleVisibility', 'off');

    % ---- Paired t-tests (1 vs 2, 2 vs 3) ----
    [~, p12] = ttest(data(1,:), data(2,:));
    [~, p23] = ttest(data(2,:), data(3,:));

    % ---- Significance annotations ----
    yTop = max(means + sems) * 1.10;     % baseline height for brackets
    tick = max(means + sems) * 0.03;     % bracket tick height

    % 1 vs 2
    line(ax, [1.1 1.9], [yTop yTop], 'Color', 'k','HandleVisibility', 'off',"LineWidth",1);
    text(ax, 1.5, yTop + tick*0.2, sigstar(p12), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'HandleVisibility', 'off');

    % 2 vs 3 (slightly higher to avoid overlap if needed)

    line(ax, [2.1 2.9], [yTop yTop], 'Color', 'k','HandleVisibility', 'off',"LineWidth",1);
    text(ax, 2.5, yTop + tick*0.2, sigstar(p23), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'HandleVisibility', 'off');

    % ---- X-axis formatting (caller can override if desired) ----
    xticks(ax,1:3);
    xticklabels(ax,["D29" "D32" "D35"]);
    hold(ax, 'off');

    % ---- Outputs ----
    stats = struct();
    stats.means = means;
    stats.sems  = sems;
    stats.p12   = p12;
    stats.p23   = p23;

    % (optional) return handles if you want to tweak externally
    stats.hBar = hb;
    stats.hErr = he;
end