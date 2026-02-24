% Description:
%   Visualize spike amplitude raster (channels × time) as an image (peak-to-peak amplitude).
%   X-axis uses adaptive time ticks for consistent visualization.
%
% Inputs:
%   chns        : Channel labels, size [num_chns x 1] or [1 x num_chns]
%   amp_raster  : Amplitude matrix [num_chns × T], 1 ms resolution
%   winIdx : (optional) Time indices to display, e.g., 1:60000 for 60 s

function plot_amp_raster(chns, amp_raster,winIdx)

    % -------------------- Basic checks --------------------
    if nargin < 3 || isempty(winIdx)
        winIdx = 1:size(amp_raster,2);
    end

    amp_raster_win = amp_raster(:, winIdx);
    num_chns = size(amp_raster_win, 1);

    % -------------------- Plotting --------------------
    t_ms = 0:(numel(winIdx)-1);  % relative time within window
    imagesc(t_ms, 1:num_chns, amp_raster_win);
    axis tight;
    set(gca, 'YDir', 'reverse');

    % -------------------- Colorbar --------------------
    c = colorbar;
    c.Label.String  = 'Spike amplitude (\muV)';
    c.Label.Rotation = 270;
    c.Label.VerticalAlignment = 'middle';
    c.Label.Position(1) = c.Label.Position(1) + 0.5;

    % -------------------- Y-axis: channels --------------------
    ylabel('Channels');
    yticks(1:num_chns);
    try
        yticklabels(chns(:));
    catch
        warning('chns cannot be used as labels; using channel indices instead.');
        yticklabels(1:num_chns);
    end

    % -------------------- X-axis: adaptive time ticks --------------------

    set_time_ticks_adaptive(1:numel(winIdx), 1000, 8);
    
    % -------------------- Title with absolute time --------------------
    t_start_s = (winIdx(1) - 1) / 1000;
    t_end_s   = (winIdx(end) - 1) / 1000;
    title(sprintf('Amp-Raster Plot (%.1f–%.1f s)', ...
                  t_start_s, t_end_s));

end
