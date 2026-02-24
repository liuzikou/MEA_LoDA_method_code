%% ===== Setup paths =====

% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path (so computeLoDA_sync can be found)
addpath(fullfile(projectRoot, 'src','LoDA_sync'));

%% ===== Load data =====
load(fullfile(projectRoot, 'data', 'data_stim_pre.mat'));   % loads data_stim_pre
load(fullfile(projectRoot, 'data', 'data_dev.mat'));  % loads data_dev

recordingwindow_ms = 300000;  % 5 min

%% ===== Calculate for data_stim_pre =====
data1 = data_stim_pre; % 16 wells, including the baseline of both H2O and 4AP groups
Sync_mean1 = NaN(16,1); % Sync-mean (well-wise sync evaluation) from 16 wells
Channel_Rate_Amp_Sync1 = NaN(192,3); % 192 channels in 16 wells, columnheads are "MSA", "MSR" and "Sync-channel"

for w_idx1=1:8
    for tr_idx1=1:2
        idx = (data1.WellID == w_idx1 & data1.Treatment == tr_idx1);
        tb1 = data1(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});
        Well = w_idx1 + (tr_idx1-1)*8;
        ChannelRange = (1+(Well-1)*12):(Well*12);
       
        %% ===== Compute LoDA =====

        [w_LoDA,w_sync] = computeLoDA_sync(tb1, recordingwindow_ms,0.5);
                
        MSR_channel = sum(w_LoDA.raster, 2) / 300; % a list of 12 values for channels
        MSA_channel = sum(w_LoDA.amp_raster, 2)./sum(w_LoDA.raster, 2); % a list of 12 values for channels
        Sync_channel = w_sync.syncChannels; % a list of 12 values for channels 

        Channel_Rate_Amp_Sync1(ChannelRange,1) = MSR_channel;
        Channel_Rate_Amp_Sync1(ChannelRange,2) = MSA_channel;
        Channel_Rate_Amp_Sync1(ChannelRange,3) = Sync_channel;
        Sync_mean1(Well,1) = w_sync.syncMean;
    end
end

%% ===== Calculate for data_dev =====
data2 = data_dev; % 36 wells, only D28
Sync_mean2 = NaN(36,1); % Sync-mean (well-wise sync evaluation) from 16 wells
Channel_Rate_Amp_Sync2 = NaN(432,3); % 432 channels in 36 wells, columnheads are "MSA", "MSR" and "Sync-channel"

for w_idx=1:36
        idx = (data2.WellID == w_idx & data2.Timepoint == 2); % Only D28 here
        tb2 = data2(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});
        Well = w_idx;
        ChannelRange = (1+(Well-1)*12):(Well*12);
       
        %% ===== Compute LoDA =====

        [w_LoDA,w_sync] = computeLoDA_sync(tb2, recordingwindow_ms,0.5);
                
        MSR_channel = sum(w_LoDA.raster, 2) / 300;
        MSA_channel = sum(w_LoDA.amp_raster, 2)./sum(w_LoDA.raster, 2);
        Sync_channel = w_sync.syncChannels;

        Channel_Rate_Amp_Sync2(ChannelRange,1) = MSR_channel;
        Channel_Rate_Amp_Sync2(ChannelRange,2) = MSA_channel;
        Channel_Rate_Amp_Sync2(ChannelRange,3) = Sync_channel;
        Sync_mean2(Well,1) = w_sync.syncMean;
end

%% ===== Stack results =====
Sync_mean_52well = [Sync_mean1; Sync_mean2];
Channel_Rate_Amp_Sync_624chn = [Channel_Rate_Amp_Sync1;Channel_Rate_Amp_Sync2];

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'MethodValidationA52wells.mat'), ...
     'Sync_mean_52well', 'Channel_Rate_Amp_Sync_624chn');