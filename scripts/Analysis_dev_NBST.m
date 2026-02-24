%% ===== Setup paths =====

% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path
addpath(fullfile(projectRoot, 'src','LoDA_sync'));
addpath(fullfile(projectRoot, 'src','NBP'));

%% ===== Load data =====
load(fullfile(projectRoot, 'data', 'data_dev.mat'));  % loads data_dev

data = data_dev;

MSA_NB36well3Tp=NaN(3,36);
MSA_Intv36well3Tp=NaN(3,36);
MSR_NB36well3Tp=NaN(3,36);
MSR_Intv36well3Tp=NaN(3,36);

Wave_amp36well3Tp=NaN(3,36);
T_half36well3Tp=NaN(3,36);

Contribution36well3Tp=NaN(3,36*12);
Sequence36well3Tp=NaN(3,36*12);

for Tp_idx=1:3
    for w_idx=1:36
        idx = (data.WellID == w_idx & data.Timepoint == (Tp_idx+2)); % D29,D32 & D35 here
        tb = data(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});
        
        recordingwindow_ms = 300000;  % 5 min
        [w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,0.5);
        
        LoDA=w_LoDA.LoDA_net;
        NBP=computeNetworkBurstPeriod(LoDA);
        SW=generateStackedWaveform(LoDA,NBP.Period,NBP.NB_start,NBP.lapse);
        NBST=computeNBSpatioTemporal(w_LoDA,w_sync,NBP);
%% ===== Calculate MSA & MSR in NB/Intv =====
        NB_sp_amp = w_LoDA.amp_raster(w_sync.ChannelStatus,NBP.NB_idx);
        Intv_sp_amp = w_LoDA.amp_raster(w_sync.ChannelStatus,NBP.Intv_idx);

        MSA_NB36well3Tp(Tp_idx,w_idx) = sum(NB_sp_amp,"all")./nnz(NB_sp_amp);
        MSA_Intv36well3Tp(Tp_idx,w_idx) = sum(Intv_sp_amp,"all")./nnz(Intv_sp_amp);
        MSR_NB36well3Tp(Tp_idx,w_idx) = nnz(NB_sp_amp)./numel(NB_sp_amp)*1000;  
        MSR_Intv36well3Tp(Tp_idx,w_idx) = nnz(Intv_sp_amp)./numel(Intv_sp_amp)*1000;

        Wave_amp36well3Tp(Tp_idx,w_idx) = SW.Wave_amp_mean;
        T_half36well3Tp(Tp_idx,w_idx) = SW.T_half_mean;

        d=(w_idx-1)*12;
        c = NBST.Contribution(:);
        s = NBST.Sequence(:);
        L = min(numel(c),12);
        Contribution36well3Tp(Tp_idx,(1+d):(L+d)) = c(1:L);
        Sequence36well3Tp(Tp_idx,(1+d):(L+d)) = s(1:L);
    end
end

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'AnalysisDevNB.mat'), ...
     'MSA_NB36well3Tp', 'MSA_Intv36well3Tp','MSR_NB36well3Tp','MSR_Intv36well3Tp', ...
     'Wave_amp36well3Tp','T_half36well3Tp','Contribution36well3Tp','Sequence36well3Tp');