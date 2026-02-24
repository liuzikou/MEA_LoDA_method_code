% ===== Setup paths =====

% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path
addpath(fullfile(projectRoot, 'src','LoDA_sync'));
addpath(fullfile(projectRoot, 'src','NBP'));

%% ===== Load data =====
load(fullfile(projectRoot, 'data', 'data_dev.mat'));  % loads data_dev

data = data_dev;

Sp_rate_mean=zeros(36,5);
Sp_amp_mean=zeros(36,5);
sync_chn_count=zeros(36,5);
sync_mean=zeros(36,5);

for Tp_idx=1:5
    for w_idx=1:36
        idx = (data.WellID == w_idx & data.Timepoint == Tp_idx);
        tb = data(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});
        
        recordingwindow_ms = 300000;  % 5 min
        [w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,0.5);

        MSR_channel = sum(w_LoDA.raster, 2) / 300;
        MSA_channel = sum(w_LoDA.amp_raster,"all")./sum(w_LoDA.raster,"all");

        Sp_rate_mean(w_idx, Tp_idx) = mean(MSR_channel);
        Sp_amp_mean(w_idx, Tp_idx) = MSA_channel;
        sync_chn_count(w_idx, Tp_idx) = sum(w_sync.ChannelStatus);
        sync_mean(w_idx, Tp_idx) = w_sync.syncMean;
    end
end

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'AnalysisDevSync.mat'), ...
     'Sp_rate_mean', 'Sp_amp_mean','sync_chn_count', 'sync_mean');