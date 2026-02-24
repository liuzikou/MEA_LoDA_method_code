% ===== Setup paths =====

% Get project root: Method_paper/
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add src to path
addpath(fullfile(projectRoot, 'src','LoDA_sync'));
addpath(fullfile(projectRoot, 'src','NBP'));

%% ===== Load data =====
load(fullfile(projectRoot, 'data', 'data_stim_pre.mat'));  % loads data_stim pre & post
load(fullfile(projectRoot, 'data', 'data_stim_post.mat'));  

datas = {data_stim_pre,data_stim_post};

Sp_rate_mean=zeros(4,8); % H2O-pre, H2O-post, 4AP-pre, 4AP-post, 4 groups
Sp_amp_mean=zeros(4,8);
sync_mean=zeros(4,8);

MSA_NB=NaN(4,8);
MSA_Intv=NaN(4,8);
MSR_NB=NaN(4,8);
MSR_Intv=NaN(4,8);

Wave_amp=NaN(4,8);
T_half=NaN(4,8);
NB_dur=NaN(4,8);
Intv_dur=NaN(4,8);
T_period=NaN(4,8);

for Tp_idx=1:2

    data=datas{Tp_idx};

    for Treat=1:2

        d = Tp_idx+2*(Treat-1);

        for w_idx=1:8
            
            idx = (data.WellID == w_idx & data.Treatment == Treat);
            tb = data(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});
            
            recordingwindow_ms = 300000;  % 5 min
            [w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,0.5);
            LoDA=w_LoDA.LoDA_net;
            NBP=computeNetworkBurstPeriod(LoDA);
            SW=generateStackedWaveform(LoDA,NBP.Period,NBP.NB_start,NBP.lapse);
            NBST=computeNBSpatioTemporal(w_LoDA,w_sync,NBP);
        
            %% ===== Calculate MSA, MSR & Sync in each well =====
            MSR_channel = sum(w_LoDA.raster, 2) / 300;
            MSA_channel = sum(w_LoDA.amp_raster,"all")./sum(w_LoDA.raster,"all");
    
            Sp_rate_mean(d, w_idx) = mean(MSR_channel);
            Sp_amp_mean(d, w_idx) = MSA_channel;
            sync_mean(d, w_idx) = w_sync.syncMean;        
            
            %% ===== Calculate MSA & MSR in NB/Intv =====
            NB_sp_amp = w_LoDA.amp_raster(w_sync.ChannelStatus,NBP.NB_idx);
            Intv_sp_amp = w_LoDA.amp_raster(w_sync.ChannelStatus,NBP.Intv_idx);
    
            MSA_NB(d, w_idx) = sum(NB_sp_amp,"all")./nnz(NB_sp_amp);
            MSA_Intv(d, w_idx) = sum(Intv_sp_amp,"all")./nnz(Intv_sp_amp);
            MSR_NB(d, w_idx) = nnz(NB_sp_amp)./numel(NB_sp_amp)*1000;  
            MSR_Intv(d, w_idx) = nnz(Intv_sp_amp)./numel(Intv_sp_amp)*1000;
            
            %% ===== Calculate Nb features =====    
            Wave_amp(d, w_idx) = SW.Wave_amp_mean;
            T_half(d, w_idx) = SW.T_half_mean;
            NB_dur(d, w_idx) = NBP.NBdur;
            Intv_dur(d, w_idx) = NBP.Intvdur;
            T_period(d, w_idx) = NBP.Period;
        end
    end
end

Ratios=struct();
Ratios.Sp_rate_mean = calculateRatio(Sp_rate_mean);
Ratios.Sp_amp_mean = calculateRatio(Sp_amp_mean);

Ratios.MSA_NB = calculateRatio(MSA_NB);
Ratios.MSA_Intv = calculateRatio(MSA_Intv);
Ratios.MSR_NB = calculateRatio(MSR_NB);
Ratios.MSR_Intv = calculateRatio(MSR_Intv);

Ratios.Wave_amp = calculateRatio(Wave_amp);
Ratios.T_half = calculateRatio(T_half);
Ratios.NB_dur = calculateRatio(NB_dur);
Ratios.Intv_dur = calculateRatio(Intv_dur);
Ratios.T_period = calculateRatio(T_period);

Ratios.sync_mean = calculateRatio(sync_mean);

function ratio = calculateRatio(rows)        
    columns = rows';
    ratio = columns(:,[2 4])./columns(:,[1 3]);
end

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'AnalysisStimSyncNB.mat'), ...
     'Ratios');