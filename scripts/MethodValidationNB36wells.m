%% ===== Setup paths =====

% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path
addpath(fullfile(projectRoot, 'src','LoDA_sync'));
addpath(fullfile(projectRoot, 'src','NBP'));

%% ===== Load data =====
load(fullfile(projectRoot, 'data', 'data_dev.mat'));  % loads data_dev

data = data_dev;

WaveAmp_36wells = NaN(36,1);
Thalf_36wells = NaN(36,1);
WaveAmpCV_36wells = NaN(36,1);
ThalfCV_36wells = NaN(36,1);

for w_idx=1:36
        idx = (data.WellID == w_idx & data.Timepoint == 5); % Only D35 here
        tb = data(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});
        
        recordingwindow_ms = 300000;  % 5 min
        [w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,0.5);
        
        LoDA=w_LoDA.LoDA_net;
        NBP=computeNetworkBurstPeriod(LoDA);
        SW=generateStackedWaveform(LoDA,NBP.Period,NBP.NB_start,NBP.lapse);
        NBST=computeNBSpatioTemporal(w_LoDA,w_sync,NBP);

        WaveAmp_36wells(w_idx,1) = SW.Wave_amp_mean;
        Thalf_36wells(w_idx,1) = SW.T_half_mean;
        WaveAmpCV_36wells(w_idx,1)=std(SW.Wave_amp)/SW.Wave_amp_mean*100;
        ThalfCV_36wells(w_idx,1)=std(SW.T_half)/SW.T_half_mean*100;
end

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'MethodValidationB36wells.mat'), ...
     'WaveAmp_36wells', 'Thalf_36wells','WaveAmpCV_36wells', 'ThalfCV_36wells');