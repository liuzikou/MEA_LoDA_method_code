% LoDA + synchrony analysis
%
% This function converts raw spike data (timestamps & amplitudes)
% into time-series representations (channel × time matrices) and
% computes both LoDA features and synchrony measures.
%
% INPUT:
%   tb                 : table with at least the following columns:
%                        - ChannelLabel
%                        - Timestamp_ms
%                        - Spike_amp_\muV
%   recordingwindow_ms : total analysis window in ms (e.g. 300000 for 5 min)
%   syncThreshold      : threshold on r² (0–1) to define synchronized
%   pairs, typically set to be 0.5
%
% OUTPUT:
%   w_LoDA : struct containing
%       .chns         : channel labels
%       .raster       : (numChannels × RecordingWindow_ms) binary spike raster
%       .amp_raster   : (numChannels × RecordingWindow_ms) amplitude raster
%       .LoDA_channel : channel-level LoDA time series
%       .LoDA_well    : well-level LoDA (mean across all channels)
%       .LoDA_net     : network-level LoDA (mean across synchronized channels,
%                       or zeros if no valid network)
%       .windowSize   : LoDA sliding window size (in samples / ms)
%
%   w_sync : struct containing
%       .r2channelPair : pairwise r² between LoDA_channel (ch × ch)
%       .syncMatrix    : logical matrix (ch × ch), true if r² > syncThreshold
%       .ChannelStatus : logical vector (ch × 1), true if channel is
%                        synchronized with >1 other channel
%       .syncChannels  : 1 × numChannels r² values between each channel
%                        and LoDA_net (last-row correlation)
%       .syncMean      : mean synchrony to the network (scalar)

function [w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,syncThreshold)

    % Ensure the table has the required columns
    if ~all(ismember({'ChannelLabel', 'Timestamp_ms', 'Spike_amp_\muV'}, ...
                     tb.Properties.VariableNames))
        error('Input table must contain "ChannelLabel", "Timestamp_ms", and "Spike_amp_\muV" columns.');
    end

    % Total analysis window (ms)
    RecordingWindow_ms = recordingwindow_ms;

    % Initialize output structure
    w_LoDA = struct();

    %% -----------------------------------------
    % 1. Extract channels & normalize timestamps
    % ------------------------------------------

    channelList  = unique(tb.ChannelLabel);
    numChannels  = numel(channelList);
    w_LoDA.chns  = channelList;

    % Normalize timestamps to start from 1
    tb.Timestamp_ms = tb.Timestamp_ms - min(tb.Timestamp_ms) + 1;


    %% -----------------------------------------
    % 2. Construct spike raster & amplitude raster
    % ------------------------------------------

    w_LoDA.raster     = zeros(numChannels, RecordingWindow_ms);
    w_LoDA.amp_raster = zeros(numChannels, RecordingWindow_ms);

    for i = 1:numChannels
        currentChannel = channelList(i);

        % Select this channel's events
        idx = (tb.ChannelLabel == currentChannel);
        spikeTimeIdx      = table2array(tb(idx, "Timestamp_ms"));
        spikeAmplitude_uV = table2array(tb(idx, "Spike_amp_\muV"));
        
        validMask = spikeTimeIdx >= 1 & ...
                    spikeTimeIdx <= RecordingWindow_ms;

        spikeTimeIdx      = spikeTimeIdx(validMask);
        spikeAmplitude_uV = spikeAmplitude_uV(validMask);
        
        % Write to raster matrices (channel × time)
        w_LoDA.amp_raster(i, spikeTimeIdx) = spikeAmplitude_uV;
        w_LoDA.raster(i,     spikeTimeIdx) = 1;
    end

    %% -----------------------------------------
    % 3. Compute LoDA with adaptive sliding window
    % ------------------------------------------

    % Total spike count
    numSpikesTotal = nnz(w_LoDA.raster);

    if numSpikesTotal == 0
        error("no spikes in this well");
    end

    % Estimate mean inter-spike interval across channels (ms)
    meanISI_ms = round(numChannels * RecordingWindow_ms / numSpikesTotal);

    % LoDA window size = slidingwindowfactor × meanISI_ms
    w_LoDA.windowSize = max(1, 10 * meanISI_ms);

    % LoDA signal: moving average of amplitude raster along time dimension
    w_LoDA.LoDA_channel = movmean(w_LoDA.amp_raster, w_LoDA.windowSize, 2);

    % Well-level LoDA = average across channels
    w_LoDA.LoDA_well = mean(w_LoDA.LoDA_channel, 1);

    % -------------------------------
    % 4. Pairwise synchrony (channel × channel)
    % -------------------------------
    w_sync.r2channelPair = computePairwiseCorrelationR2(w_LoDA.LoDA_channel, 1);

    % Determine synchronization status for each channel pair
    w_sync.syncMatrix = w_sync.r2channelPair > syncThreshold;

    % Channel is considered "synchronized" if correlated with >1 other channel
    % (including itself on the diagonal)
    w_sync.ChannelStatus = (sum(w_sync.syncMatrix, 2) > 1);

    % -------------------------------
    % 5. Network-level LoDA & synchrony to network
    % -------------------------------
    if sum(w_sync.ChannelStatus) > 1
        % Average LoDA for synchronized channels only
        w_LoDA.LoDA_net = mean(w_LoDA.LoDA_channel(w_sync.ChannelStatus, :), 1);

        % Calculate the synchrony from each channel to the network
        w_sync.syncChannels = computePairwiseCorrelationR2( ...
            [w_LoDA.LoDA_channel; w_LoDA.LoDA_net], 2);

        % Determine the mean synchrony (across all channels)
        w_sync.syncMean = mean(w_sync.syncChannels);
    else
        % If fewer than 2 sync-ed channels → no meaningful network
        w_LoDA.LoDA_net    = zeros(1, RecordingWindow_ms);
        w_sync.syncChannels = zeros(1, numChannels);
        w_sync.syncMean     = 0;
    end
end

% ------------------------------------------------
% Helper: compute pairwise r² between channels
% ------------------------------------------------
function r2 = computePairwiseCorrelationR2(timeSeries_ChByt,outputOption)
    %% ---------------------------------------------------------------
    % 1. Convert to (time × channel) for corrcoef
    %% ---------------------------------------------------------------
    ts_TByCh = timeSeries_ChByt.'; 

    %% ---------------------------------------------------------------
    % 2. Compute Pearson correlation and square to obtain r²
    %% ---------------------------------------------------------------
    rMatrix = corrcoef(ts_TByCh);
    
    r2Matrix = rMatrix.^2;

    if outputOption == 1
        % Full matrix
        r2 = r2Matrix;
    elseif outputOption == 2
        % Last row vs all previous (e.g., each channel to network)
        r2 = r2Matrix(end, 1:end-1);
    else
        error('Invalid output option. Choose 1 or 2.');
    end
end
