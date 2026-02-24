function [ax, h] = plot_3pairs_bar(a1, a2)
%PLOT_3PAIRS_BAR  Plot 3 paired NB vs Intv bar pairs with SEM and paired t-tests.
%
% Inputs
%   a1 : 3 x N matrix, NB values (paired by columns)
%   a2 : 3 x N matrix, Intv values (paired by columns)
%
% Outputs
%   ax : axes handle used for plotting
%   h  : struct with handles and computed statistics:
%        h.hNB, h.hIntv, h.legend
%        h.err (1x3), h.bracket (1x3), h.starText (1x3)
%        h.means (1x6), h.sems (1x6), h.p (1x3)
%
% Notes
%   - No figure() is created; the function plots into the current axes (gca),
%     so it is compatible with tiledlayout/nexttile.
%   - Axis limits, title, ylabel, and xticklabels should be set outside.

% -------------------- Validate inputs --------------------
if ~isnumeric(a1) || ~ismatrix(a1) || size(a1,1) ~= 3
    error('a1 must be a numeric 3 x N matrix.');
end
if ~isnumeric(a2) || ~ismatrix(a2) || size(a2,1) ~= 3
    error('a2 must be a numeric 3 x N matrix.');
end
if size(a1,2) ~= size(a2,2)
    error('a1 and a2 must have the same number of columns (paired samples).');
end

ax = gca;

% -------------------- Summary stats --------------------
means = zeros(1,6);
sems  = zeros(1,6);

n1 = size(a1,2);
n2 = size(a2,2);

for i = 1:3
    means(2*i-1) = mean(a1(i,:));
    means(2*i)   = mean(a2(i,:));

    sems(2*i-1)  = std(a1(i,:), 0, 2) / sqrt(n1);
    sems(2*i)    = std(a2(i,:), 0, 2) / sqrt(n2);
end

% x positions for the 3 pairs: (2,3), (5,6), (8,9)
x = [2 3 5 6 8 9];

% Colors: NB (blue) for 2/5/8, Intv (red) for 3/6/9
cNB   = [0 0 1];
cIntv = [1 0 0];

hold(ax, 'on');

% -------------------- Bars --------------------
% Keep only two bar handles visible for legend; other bars hidden from legend.
hNB = bar(ax, x(1), means(1), 0.8, 'FaceColor', cNB,   'EdgeColor', 'none');
bar(ax, x(3), means(3), 0.8, 'FaceColor', cNB,   'EdgeColor', 'none', 'HandleVisibility', 'off');
bar(ax, x(5), means(5), 0.8, 'FaceColor', cNB,   'EdgeColor', 'none', 'HandleVisibility', 'off');

hIntv = bar(ax, x(2), means(2), 0.8, 'FaceColor', cIntv, 'EdgeColor', 'none');
bar(ax, x(4), means(4), 0.8, 'FaceColor', cIntv, 'EdgeColor', 'none', 'HandleVisibility', 'off');
bar(ax, x(6), means(6), 0.8, 'FaceColor', cIntv, 'EdgeColor', 'none', 'HandleVisibility', 'off');

lgd = legend(ax, [hNB, hIntv], {'NB', 'NB-Intv'}, 'Location', 'northwest');
lgd.AutoUpdate = 'off';

% -------------------- Error bars (no lines between groups) --------------------
err = gobjects(1,3);
err(1) = errorbar(ax, x(1:2), means(1:2), sems(1:2), 'k', ...
    'LineStyle', ':', 'LineWidth', 1, 'Marker', 'none', 'HandleVisibility', 'off');
err(2) = errorbar(ax, x(3:4), means(3:4), sems(3:4), 'k', ...
    'LineStyle', ':', 'LineWidth', 1, 'Marker', 'none', 'HandleVisibility', 'off');
err(3) = errorbar(ax, x(5:6), means(5:6), sems(5:6), 'k', ...
    'LineStyle', ':', 'LineWidth', 1, 'Marker', 'none', 'HandleVisibility', 'off');

% -------------------- Minimal axis formatting (leave labels/titles to caller) --------------------
xticks(ax,[2.5 5.5 8.5]);
xticklabels(ax,["D29" "D32" "D35"]);
box(ax, 'on');

% -------------------- Paired t-tests + significance brackets --------------------
xPairs = [2 3; 5 6; 8 9];
idxPairs = [1 2; 3 4; 5 6];

p = nan(1,3);
bracket = gobjects(1,3);
starText = gobjects(1,3);

for i = 1:3
    [~, p(i)] = ttest(a1(i,:), a2(i,:));

    idxNB   = idxPairs(i,1);
    idxIntv = idxPairs(i,2);

    % bracket position above the higher mean+SEM bar
    yMax = max([means(idxNB)+sems(idxNB), means(idxIntv)+sems(idxIntv)]);
    yTop = yMax * 1.05;
    hTick = yMax * 0.03;

    xi1 = xPairs(i,1);
    xi2 = xPairs(i,2);

    bracket(i) = plot(ax, [xi1 xi2], [yTop yTop], ...
        'k-', 'LineWidth', 1, 'HandleVisibility', 'off');

    starText(i) = text(ax, mean([xi1, xi2]), yTop + hTick*0.2, sigstar(p(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 12, 'HandleVisibility', 'off');
end

hold(ax, 'off');

% -------------------- Outputs --------------------
h = struct();
h.hNB = hNB;
h.hIntv = hIntv;
h.legend = lgd;
h.err = err;
h.bracket = bracket;
h.starText = starText;

h.means = means;
h.sems = sems;
h.p = p;
end