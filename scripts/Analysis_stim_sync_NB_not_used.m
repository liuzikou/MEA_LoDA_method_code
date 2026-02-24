% this script is not used for the manuscript

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

Stim = struct();

Stim.MSR=zeros(8,4); % H2O-pre, H2O-post, 4AP-pre, 4AP-post, 4 groups
Stim.MSA=zeros(8,4);
Stim.sync_mean=zeros(8,4);

Stim.MSA_NB=NaN(8,4);
Stim.MSA_Intv=NaN(8,4);
Stim.MSR_NB=NaN(8,4);
Stim.MSR_Intv=NaN(8,4);

Stim.Wave_amp=NaN(8,4);
Stim.T_half=NaN(8,4);
Stim.NB_dur=NaN(8,4);
Stim.Intv_dur=NaN(8,4);
Stim.T_period=NaN(8,4);

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
    
            Stim.MSR(w_idx,d) = mean(MSR_channel);
            Stim.MSA(w_idx,d) = MSA_channel;
            Stim.sync_mean(w_idx,d) = w_sync.syncMean;        
            
            %% ===== Calculate MSA & MSR in NB/Intv =====
            NB_sp_amp = w_LoDA.amp_raster(w_sync.ChannelStatus,NBP.NB_idx);
            Intv_sp_amp = w_LoDA.amp_raster(w_sync.ChannelStatus,NBP.Intv_idx);
    
            Stim.MSA_NB(w_idx,d) = sum(NB_sp_amp,"all")./nnz(NB_sp_amp);
            Stim.MSA_Intv(w_idx,d) = sum(Intv_sp_amp,"all")./nnz(Intv_sp_amp);
            Stim.MSR_NB(w_idx,d) = nnz(NB_sp_amp)./numel(NB_sp_amp)*1000;  
            Stim.MSR_Intv(w_idx,d) = nnz(Intv_sp_amp)./numel(Intv_sp_amp)*1000;
            
            %% ===== Calculate Nb features =====    
            Stim.Wave_amp(w_idx,d) = SW.Wave_amp_mean;
            Stim.T_half(w_idx,d) = SW.T_half_mean;
            Stim.NB_dur(w_idx,d) = NBP.NBdur;
            Stim.Intv_dur(w_idx,d) = NBP.Intvdur;
            Stim.T_period(w_idx,d) = NBP.Period;
        end
    end
end


%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'AnalysisStimSyncNBv2.mat'), ...
     'Stim');