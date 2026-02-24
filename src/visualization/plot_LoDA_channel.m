% Description:
%   Visualize LoDA_channel (channels × time) as an image (LoDA in each channel).
%   X-axis uses adaptive time ticks for consistent visualization.
%
% Inputs:
%   chns        : Channel labels, size [num_chns x 1] or [1 x num_chns]
%   LoDA_channel  : LoDA matrix from computeLoDA-sync.m [num_chns × T], 1 ms resolution
%   winIdx : (optional) Time indices to display, e.g., 1:60000 for 60 s

function plot_LoDA_channel(chns, LoDA_channel,winIdx)

    % -------------------- Basic checks --------------------
    if nargin < 3 || isempty(winIdx)
        winIdx = 1:size(LoDA_channel,2);
    end

    amp_raster_win = LoDA_channel(:, winIdx);
    num_chns = size(amp_raster_win, 1);

    % -------------------- Plotting --------------------
    t_ms = 0:(numel(winIdx)-1);  % relative time within window
    imagesc(t_ms, 1:num_chns, amp_raster_win);
    axis tight;
    set(gca, 'YDir', 'reverse');

    % -------------------- Colorbar --------------------
    c = colorbar;
    c.Label.String  = ' LoDA (\muV/ms)';
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
    title(sprintf('LoDA channel plot (%.1f–%.1f s)', ...
                  t_start_s, t_end_s));

end
