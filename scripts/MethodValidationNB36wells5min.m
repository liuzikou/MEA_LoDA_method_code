%% ===== Setup paths =====

% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path
addpath(fullfile(projectRoot, 'src','LoDA_sync'));
addpath(fullfile(projectRoot, 'src','NBP'));

%% ===== Load data =====
load(fullfile(projectRoot, 'data', 'data_dev.mat'));  % loads data_dev

data = data_dev;

Contribution_36well5min = NaN(5,36*12);
Sequence_36well5min = NaN(5,36*12);

for w_idx=1:36
    for min_idx=1:5
        t1=1+60000*(min_idx-1);
        t2=t1+60000-1;
        idx = (data.WellID == w_idx & data.Timepoint == 5 & data.Timestamp_ms>t1&data.Timestamp_ms<t2); % Only D35 here 
        tb = data(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});

        recordingwindow_ms = 60000;  % use each minute for analysis
        [w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,0.5);
        
        LoDA=w_LoDA.LoDA_net;
        NBP=computeNetworkBurstPeriod(LoDA);
        SW=generateStackedWaveform(LoDA,NBP.Period,NBP.NB_start,NBP.lapse);
        NBST=computeNBSpatioTemporal(w_LoDA,w_sync,NBP);

        d=(w_idx-1)*12;
        c = NBST.Contribution(:);
        s = NBST.Sequence(:);
        L = min(numel(c),12);

        Contribution_36well5min(min_idx,(1+d):(L+d)) = c(1:L);
        Sequence_36well5min(min_idx,(1+d):(L+d)) = s(1:L);
    end
end

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'MethodValidationC36wells5min.mat'), ...
     'Contribution_36well5min', 'Sequence_36well5min');