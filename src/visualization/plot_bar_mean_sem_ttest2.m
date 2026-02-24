
%PLOT_BAR_MEAN_SEM_TTEST2 Bar plot (mean ± SEM) for two columns + ttest2 + sigstar.
%
% INPUT
%   ax : (optional) axes handle; if empty/missing -> gca
%   X  : N×2 numeric matrix. Column 1 vs Column 2 (independent samples).
%        NaN will be ignored.
%   colors: colors for two columns
%
% OUTPUT
%   h : struct of handles for external customization:
%       h.ax, h.bar, h.err, h.sigLine, h.sigText, h.connectLine
%
% Notes:
%   - Uses unpaired two-sample t-test: ttest2
%   - Does NOT set labels/ylim, so it works cleanly under nexttile.

function h = plot_bar_mean_sem_ttest2(ax, X, colors)

    x1 = X(:,1);
    x2 = X(:,2);
    
    axes(ax);
    hold(ax, 'on');

    % Stats: mean and SEM
    m1 = mean(x1);
    m2 = mean(x2);
    sem1 = std(x1) / sqrt(numel(x1));
    sem2 = std(x2) / sqrt(numel(x2));

    % Unpaired t-test
    [~, p] = ttest2(x1, x2);

    % Plot settings
    x = [1 2];
    y = [m1 m2];
    e = [sem1 sem2];

    % Bars
    h.ax = ax;
    h.bar = bar(ax, x, y, 'FaceColor', 'flat');
    h.bar.CData = colors;

     % Error bars
    h.err = errorbar(ax, x, y, e, 'k', ...
        'LineStyle', 'none', 'LineWidth', 1);

    % A light connector line (optional aesthetics; keep as handle)
    h.connectLine = plot(ax, x, y, 'k:', 'LineWidth', 0.8);

    % Significance line & text position (relative to current data)
    yTop = max(y + e);
    ySig = yTop + 0.08 * max(1, yTop);     % offset above bars
    yText = ySig + 0.03 * max(1, yTop);

    h.sigLine = plot(ax, x, [ySig ySig], 'k', 'LineWidth', 1.8);
    h.sigText = text(ax, mean(x), yText, sigstar(p), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 16);

    hold(ax, 'off');
end