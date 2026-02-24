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

Contribution=NaN(20,8*12); % pre 5 min + post 5 min = 10 rows, 8 wells in each group, H2O & 4AP two groups
Sequence=NaN(20,8*12);


for Tp_idx=1:2
    
    data=datas{Tp_idx};
    
    for Treat=1:2
        
        d = Tp_idx+2*(Treat-1);

        for w_idx=1:8            
            
            k=(w_idx-1)*12;

            for min_idx=1:5
                
                t1=1+60000*(min_idx-1);
                t2=t1+60000-1;

                idx = (data.WellID == w_idx & data.Treatment == Treat);
                tb = data(idx, {'ChannelLabel','Timestamp_ms','Spike_amp_\muV'});
                ts=tb.Timestamp_ms-min(tb.Timestamp_ms)+1; % data_stim_post has later starting timestamp
                tb = tb(ts >= t1 & ts <= t2, :);

                recordingwindow_ms = 60000;  % use each minute for analysis
                [w_LoDA,w_sync] = computeLoDA_sync(tb, recordingwindow_ms,0.5);
                
                LoDA=w_LoDA.LoDA_net;
                NBP=computeNetworkBurstPeriod(LoDA);
                SW=generateStackedWaveform(LoDA,NBP.Period,NBP.NB_start,NBP.lapse);
                NBST=computeNBSpatioTemporal(w_LoDA,w_sync,NBP);


                c = NBST.Contribution(:);
                s = NBST.Sequence(:);
                L = min(numel(c),12);

                Contribution(min_idx+5*(d-1),(1+k):(L+k)) = c(1:L);
                Sequence(min_idx+5*(d-1),(1+k):(L+k)) = s(1:L);
            end
        end
    end
end

%% ===== Save results =====
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, 'AnalysisStimNBST.mat'), ...
     'Contribution','Sequence');