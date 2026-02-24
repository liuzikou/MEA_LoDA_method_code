% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path
addpath(fullfile(projectRoot, 'src','NBP'));

%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'LoDA_sync_example.mat')); % w_LoDA is calculated previously from LoDA_sync

%% =====compute network burst period and stacked waveform
LoDA=w_LoDA.LoDA_net;
NBP=computeNetworkBurstPeriod(LoDA);
SW=generateStackedWaveform(LoDA,NBP.Period,NBP.NB_start,NBP.lapse);

%% =====compute network burst spatial and temporal features
NBST=computeNBSpatioTemporal(w_LoDA,w_sync,NBP);

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
save(fullfile(resultsDir, 'NBP_SW_ST_example.mat'), ...
     'NBP', 'SW','NBST');