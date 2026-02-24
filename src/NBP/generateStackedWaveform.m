% Description
% Stack periodic LoDA waveforms aligned to event onsets (NB_start).
%
% INPUTS
%   LoDA     - 1-D time series (vector). Both LoDA_net & LoDA_channel can be used here.
%   Period   - window length in samples
%   NB_start - event onset indices (samples, 1-based)
%   lapse    - number of samples before NB_start included in the window
%
% OUTPUT
%   SW.waves    - [nEvents x Period] stacked waveforms (NaN padded)
%   SW.meanwave     - mean waveform (omit NaN)
%   SW.std      - std waveform (omit NaN)
%   SW.Wave_amp - wave amp in each period
%   SW.Wave_amp_mean
%   SW.T_half   - time to build burst in each period
%   SW.T_half_mean


function SW = generateStackedWaveform(LoDA, Period, NB_start, lapse)

    SW = struct();

    x = LoDA(:).';          % vector -> row

    N = numel(x);

    NB_start = NB_start(:);
    n = numel(NB_start);

    waves = nan(n, Period);

    for i = 1:n
        % Ideal source window in LoDA coordinates (1-based)
        src_s = NB_start(i) - lapse;
        src_e = src_s + Period - 1;

        % Clip to valid signal range [1, N]
        src_s_clip = max(1, src_s);
        src_e_clip = min(N, src_e);

        % If the window does not overlap the signal at all, skip
        if src_s_clip > src_e_clip
            continue;
        end

        % Map clipped source segment to destination indices in [1, Period]
        % If src_s < 1, we need to start filling later in the destination window.
        dst_s = 1 + (src_s_clip - src_s);
        dst_e = dst_s + (src_e_clip - src_s_clip);

        % Assign
        waves(i, dst_s:dst_e) = x(src_s_clip:src_e_clip);
    end

    SW.waves = waves';
    SW.meanwave  = mean(waves, 1, "omitnan");
    SW.std   = std(waves,  [], 1, "omitnan");

    SW.Wave_amp = max(SW.waves,[],1);
    SW.Wave_amp_mean = mean (SW.Wave_amp,"all");
    SW.T_half = computeT_half(SW.waves);
    SW.T_half_mean = mean(SW.T_half,"all");
end

function T_half=computeT_half(wave)

    % Total area for each channel
    total_area = sum(wave, 1, "omitnan");   % 1 × N
    half_area  = total_area / 2;
    % Cumulative area along the time dimension
    cumulative_area = cumsum(wave, 1, "omitnan");  % T × N
    % Preallocate output
    num_channels = size(wave, 2);
    T_half = NaN(1, num_channels);

    for n = 1:num_channels
        % First time index where cumulative area reaches half
        idx = find(cumulative_area(:, n) >= half_area(n), 1, "first");
        T_half(n) = idx;
    end
end