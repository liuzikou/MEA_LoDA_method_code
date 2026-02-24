%PLOT_LODA_NET Plot 1D LoDA-net trace with adaptive time ticks.
%
% Inputs
%   LoDA_net : [1xT] or [Tx1] vector (LoDA-net)
%   winIdx   : indices (1-based) of samples to plot, e.g. 1:60000
%
% Notes
%   Assumes sampling rate = 1000 Hz. Change fs if needed.

function plot_LoDA_net(LoDA_net, winIdx)

    if nargin < 2 || isempty(winIdx)
        winIdx = 1:numel(LoDA_net);
    end

    % --- parameters ---
    fs = 1000;           % Hz (modify if your data differs)
    nTicksTarget = 8;    % target number of x ticks (passed to helper)

    % --- ensure vector & index valid ---
    LoDA_net = LoDA_net(:);  % force column vector

    winIdx = winIdx(:);
    winIdx = winIdx(winIdx >= 1 & winIdx <= numel(LoDA_net));
    if isempty(winIdx)
        error('winIdx is empty after clipping; please check index range.');
    end

    % --- slice ---
    y = LoDA_net(winIdx);

    % --- plot ---
    plot(y, 'LineWidth', 1);
    ylabel("LoDA-net (\muV/ms)");
    grid on

    % --- adaptive time ticks (x is sample index within window) ---
    set_time_ticks_adaptive(1:numel(winIdx), fs, nTicksTarget);

    % --- title with absolute time (seconds) ---
    t_start_s = (winIdx(1) - 1) / fs;
    t_end_s   = winIdx(end) / fs;
    title(sprintf('LoDA network (%.1f–%.1f s)', t_start_s, t_end_s));
end
