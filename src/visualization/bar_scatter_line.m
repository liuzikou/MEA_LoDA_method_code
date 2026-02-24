%BAR_SCATTER_LINE Bar(mean) + scatter(all points) + adjacent significance (PAIRED).
%
%   ax = BAR_SCATTER_LINE(columns)
%
% Input
%   columns : [N x K] numeric matrix. Each row is the same subject/sample
%             measured at K time points (repeated measures). NaNs allowed.
%
% Output
%   ax : handle of current axes (gca). Works inside tiledlayout.
%
% Statistics (paired / repeated measures)
%   1) Repeated-measures ANOVA across ALL columns using fitrm + ranova.
%   2) Post-hoc pairwise comparisons based on the RM model (paired).
%   3) Only display significance for adjacent pairs in the plot.

function ax = bar_scatter_line(columns)

    ax = gca;
    hold(ax, 'on');

    K = size(columns, 2);

    % ----- Bar of means -----
    means = mean(columns, 1, 'omitnan');
    bar(ax, 1:K, means, ...
        "FaceAlpha", 0.15, ...
        "EdgeColor", "none", ...
        "FaceColor", "b");

    % ----- Scatter of all points -----
    scatter(ax, 1:K, columns, 40, "blue", ...
        "filled", ...
        "MarkerFaceAlpha", 0.20, ...
        "MarkerEdgeColor", "none");

    % ----- Minimal axes formatting -----
    xticks(ax, 1:K);

    % ============================================================
    % Repeated-measures ANOVA + paired post-hoc (all pairs)
    % ============================================================
    % Complete-case rows only (fitrm/ranova generally require this).
    ok = all(~isnan(columns), 2);
    X  = columns(ok, :);

    if size(X, 1) >= 2 && K >= 2
        % Build table for fitrm: each time point is a variable (T1..TK)
        varNames = "T" + string(1:K);
        tbl = array2table(X, 'VariableNames', cellstr(varNames));

        % Within-design table defining the repeated-measures factor "Time"
        within = table((1:K)', 'VariableNames', {'Time'});

        % Fit repeated-measures model (no between-subject factors)
        rm = fitrm(tbl, sprintf('%s-%s ~ 1', varNames(1), varNames(end)), ...
                   'WithinDesign', within);

        % RM-ANOVA (overall effect). (You may use the output outside if needed.)
        % r = ranova(rm);  % not used for plotting here, but computed if you want to inspect.
        ranova(rm);

        % Paired post-hoc comparisons across ALL time points
        % You can change ComparisonType if needed (e.g., 'bonferroni', 'holm', 'tukey-kramer').
        mc = multcompare(rm, 'Time', 'ComparisonType', 'bonferroni');

        % mc is a table with fields like: Time_1, Time_2, pValue (names can vary slightly)
        % We'll robustly detect the p-value column name.
        pCol = "";
        if any(strcmpi(mc.Properties.VariableNames, 'pValue'))
            pCol = "pValue";
        elseif any(strcmpi(mc.Properties.VariableNames, 'p_value'))
            pCol = "p_value";
        else
            error('Cannot find p-value column in multcompare output.');
        end

        % ============================================================
        % Plot only adjacent pair markers (flat segments, consistent height)
        % ============================================================
        yl = ylim(ax);
        yr = yl(2) - yl(1);
        if yr == 0, yr = 1; end

        dataMax = max(columns, [], 'all', 'omitnan');
        if isempty(dataMax) || isnan(dataMax)
            dataMax = max(means, [], 'omitnan');
        end

        ySig = dataMax + 0.08 * yr;   % shared y for all segments
        yTxt = ySig    + 0.02 * yr;   % stars above segment

        % Extend ylim upward if needed (keeps external control; only prevents clipping)
        if yTxt > yl(2)
            ylim(ax, [yl(1), yTxt + 0.05 * yr]);
            yl = ylim(ax);
            yr = yl(2) - yl(1);
            ySig = dataMax + 0.08 * yr;
            yTxt = ySig + 0.02 * yr;
        end

        gap = 0.08;    % small gap at both ends of each horizontal segment
        lw  = 1.2;

        for i = 1:(K-1)
            % Find the row in mc corresponding to (i, i+1)
            % multcompare usually stores factor levels in columns named like 'Time_1' and 'Time_2'
            vnames = mc.Properties.VariableNames;

            % Try to locate the two level columns automatically
            % (Most MATLAB versions: 'Time_1' and 'Time_2')
            c1 = "";
            c2 = "";
            if any(strcmpi(vnames, 'Time_1')), c1 = "Time_1"; end
            if any(strcmpi(vnames, 'Time_2')), c2 = "Time_2"; end
            if c1 == "" || c2 == ""
                % Fallback: find first two columns that contain 'Time' and are numeric/categorical
                timeCols = vnames(contains(lower(vnames), 'time'));
                if numel(timeCols) >= 2
                    c1 = string(timeCols{1});
                    c2 = string(timeCols{2});
                else
                    error('Cannot find Time level columns in multcompare output.');
                end
            end

            a = mc.(c1);
            b = mc.(c2);

            % Ensure they are numeric levels (convert categorical/string if needed)
            if iscategorical(a), a = double(a); end
            if iscategorical(b), b = double(b); end
            if isstring(a) || iscellstr(a), a = str2double(string(a)); end
            if isstring(b) || iscellstr(b), b = str2double(string(b)); end

            idx = find( (a==i & b==i+1) | (a==i+1 & b==i), 1, 'first');
            if isempty(idx)
                continue;
            end

            p = mc.(pCol)(idx);

            % Flat segment (no caps), with a small gap at both ends
            x1 = i + gap;
            x2 = i + 1 - gap;
            plot(ax, [x1 x2], [ySig ySig], 'k-', 'LineWidth', lw);

            % Text centered
            text(ax, (x1+x2)/2, yTxt, sigstar(p), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', ...
                'FontSize', 10);
        end
    end

    hold(ax, 'off');
end