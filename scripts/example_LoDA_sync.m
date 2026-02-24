%% ===== Setup paths =====

% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path (so computeLoDA_sync can be found)
addpath(fullfile(projectRoot, 'src','LoDA_sync'));

%% ===== Load data =====
load(fullfile(projectRoot, 'data', 'data_stim_pre.mat'));   % loads data_stim_pre

data = data_stim_pre;

%% ===== Select well & treatment =====
idx = (data.WellID == 4 & data.Treatment == 2);

% Well4, pre-treatment, 4AP group, is chosen as the example

tb = data(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});

%% ===== Compute LoDA =====
recordingwindow_ms = 300000;  % 5 min
[w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,0.5);

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'LoDA_sync_example.mat'), ...
     'w_LoDA', 'w_sync');
