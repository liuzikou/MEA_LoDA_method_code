function set_time_ticks_adaptive(winIdx, fs, maxTicks)
%SET_TIME_TICKS_ADAPTIVE Adaptive x-axis ticks for time window
%
% winIdx   : time indices (e.g. 1:60000)
% fs       : sampling rate (Hz), e.g. 1000
% maxTicks : optional, default = 8

if nargin < 3
    maxTicks = 8;
end

win_len_samples = numel(winIdx);
win_len_s = win_len_samples / fs;

niceGaps = [0.5 1 2 5 10 20 30 60 120 300 600];

gap_s = niceGaps(find((win_len_s ./ niceGaps) <= maxTicks, 1, 'first'));
if isempty(gap_s)
    gap_s = niceGaps(end);
end

xticks_s = 0:gap_s:win_len_s;
xticks_samples = xticks_s * fs;

xlim([0 win_len_samples]);
xticks(xticks_samples);
xticklabels(xticks_s);
xlabel('Time (s)');
end