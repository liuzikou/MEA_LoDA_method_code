
% computeT_half  Time index at which cumulative area reaches half total area
%
% This function computes, for each wave, the earliest time index at which
% the cumulative sum of the signal reaches half of its total area.
% Both single-wave and multi-wave time series are supported.
%
% INPUT
%   wave : T×N matrix or T×1 vector
%          Time series data, where T is the number of time samples
%          and N is the number of waves.
%
% OUTPUT
%   T_half : 1×N vector
%            Time index (sample index) at which cumulative area
%            first reaches half of the total area for each wave.
%            Returns NaN if the total area is zero or invalid.
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
        idx = find(cumulative_area(:, n) >= half_area(c), 1, "first");
        T_half(n) = idx;
    end
end
