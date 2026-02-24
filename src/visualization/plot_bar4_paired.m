% plot_bar4_paired
% Minimal: bar(4) + SEM + points + paired lines + p-value stars (1vs2, 3vs4).
%
% INPUT
%   ax   : axes handle (e.g., ax = nexttile). If empty, uses gca.
%   data : N×4 numeric matrix
%
% OUTPUT (handles + stats)
%   h.ax, h.bar, h.err, h.scat, h.line12, h.line34, h.sig12, h.sig34
%   h.means, h.sems, h.p12, h.p34

function h = plot_bar4_paired(ax, data)

% Drop rows containing NaN
data = data(all(~isnan(data),2), :);
N = size(data,1);

% ---- stats (paired t-tests) ----
h.means = mean(data, 1);
h.sems  = std(data, 0, 1) ./ sqrt(N);
[~, h.p12] = ttest(data(:,1), data(:,2));
[~, h.p34] = ttest(data(:,3), data(:,4));

% ---- plotting ----
h.ax = ax;
hold(ax,'on');

colors = [0.10 0.30 0.65; 0.30 0.55 0.90; 0.75 0.30 0.10; 0.95 0.60 0.25];


h.bar = bar(ax, h.means);
h.bar.FaceColor = 'flat';
h.bar.CData = colors;
h.bar.FaceAlpha = 0.8;

h.err = errorbar(ax, 1:4, h.means, h.sems, 'k', ...
    'LineStyle','none','LineWidth',1);

% Points (robust scatter for N×4)
x = repmat(1:4, N, 1);
h.scat = scatter(ax, x(:), data(:), 24, 'k', 'filled');

% Paired lines
h.line12 = plot(ax, [1 2], data(:,1:2)', 'k:');
h.line34 = plot(ax, [3 4], data(:,3:4)', 'k:');

% Significance bars + text
yMax  = max(data, [], 'all');
yLine = yMax * 1.05;
yText = yMax * 1.06;
ylim(ax, [0, yMax*1.2]);

plot(ax, [1 2], [yLine yLine], 'k-', 'LineWidth', 1);
plot(ax, [3 4], [yLine yLine], 'k-', 'LineWidth', 1);

h.sig12 = text(ax, 1.5, yText, sigstar(h.p12), ...
    'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',12);
h.sig34 = text(ax, 3.5, yText, sigstar(h.p34), ...
    'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',12);

xticks(ax, 1:4);
labels = ["H2O-Pre","H2O-Post","4AP-Pre","4AP-Post"];
xticklabels(ax, labels);

hold(ax,'off');

end