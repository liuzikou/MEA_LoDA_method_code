% Description:
%   Visualize spike raster (channels × time), with optional
%   time-window selection and automatic x-axis tick adjustment
%
% Inputs:
%   chns   : Channel labels, size [num_chns x 1] or [1 x num_chns]
%   raster : Binary matrix [num_chns × T], 1 ms resolution (1 column = 1 ms)
%   winIdx : (optional) Time indices to display, e.g., 1:60000 for 60 s
%
% Notes:
%   - Time inside the window is displayed as relative time (starting at 0 s).
%   - X-axis tick spacing is automatically chosen to maintain readability.
%   - Channels appear from top → bottom in numerical order.
%

function plot_raster(chns, raster, winIdx)

    if nargin < 3 || isempty(winIdx)
        winIdx = 1:size(raster,2);
    end
    
    num_chns = size(raster, 1);
    
    raster_win = raster(:, winIdx);
    [row, col] = find(raster_win);
    t_ms = col - 1;
    
    plot(t_ms, row, 'k.', 'MarkerSize', 10, 'Marker', '|');
    set(gca, 'YDir','reverse','XGrid','off','YGrid','on');
    hold on;
    
    set_time_ticks_adaptive(winIdx, 1000, 8);
    
    yticks(1:num_chns);
    try
        yticklabels(chns(:));
    catch
        warning('chns cannot be used as labels; using channel indices instead.');
        yticklabels(1:num_chns);
    end
    ylabel('Channels');
    ylim([0 num_chns + 1]);
    
    t_start_s = (winIdx(1) - 1) / 1000;
    t_end_s   = (winIdx(end) - 1) / 1000;
    title(sprintf('Raster Plot (%.1f–%.1f s)', t_start_s, t_end_s));
    
    hold off;
end