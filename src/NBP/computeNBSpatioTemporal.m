% Compute network burst spatial and temporal features for each active channel.
% Inputs
    % w_LoDA, w_sync : struct, from computeLoDA_sync function results

    % NBP : struct, from computeNetworkBurstPeriod function results

% Output
    % NBST : struct with fields
    % - Waves : [N x Period] mean stacked waveform for each active channel
    % - Wave_amp : [N x 1] mean waveform amplitude per channel
    % - T_half : [Nactive x 1] mean NB building time per channel
    % - Contribution : [%] relative contribution of each channel based on Wave_amp
    % - Sequence : rank order of channels based on T_half (requires tiedrank)

function NBST=computeNBSpatioTemporal(w_LoDA,w_sync,NBP)

% Initialize output structure
    NBST=struct();
% Select only active channels    
    chn_num=sum(w_sync.ChannelStatus);
    LoDA=w_LoDA.LoDA_channel(w_sync.ChannelStatus,:); % using 5-min LoDA segment
    
% Pre-allocate outputs
    NBST.Waves = NaN(chn_num,NBP.Period);
    NBST.Wave_amp = NaN(chn_num,1);
    NBST.T_half = NaN(chn_num,1);

% Compute stacked waveform features for each active channel    
    for i=1:chn_num
        SW=generateStackedWaveform(LoDA(i,:),NBP.Period,NBP.NB_start,NBP.lapse);
        
        NBST.Waves(i,:) = SW.meanwave;
        NBST.Wave_amp(i) = SW.Wave_amp_mean;
        NBST.T_half(i) = SW.T_half_mean;
    end
% Contribution (%) based on waveform amplitude    
    NBST.Contribution = round((NBST.Wave_amp*100./sum(NBST.Wave_amp)),2);
% Temporal sequence: rank channels by T_half (smaller -> earlier rank)
    NBST.Sequence = tiedrank(NBST.T_half);
end