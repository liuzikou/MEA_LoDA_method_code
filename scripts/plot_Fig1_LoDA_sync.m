projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'LoDA_sync_example.mat'));

%% ===== draw figure =====
fig = figure;

row = 4;
col = 3;
fig.Position = [100, 100, col*420, row*336]; % each panel=420*336

tl = tiledlayout(fig,row,col,'TileSpacing','compact','Padding','compact');

    ax1=nexttile(tl);% raster plot
        plot_raster(w_LoDA.chns, w_LoDA.raster, 1:10000);   
    ax2=nexttile(tl);% r2 matrix from raster plot
        r2M_raster = computePairwiseCorrelationR2(w_LoDA.raster,1);
        h2 = plot_r2matrix(w_LoDA.chns, r2M_raster);
        title(h2,"Synchrony (r^2) matrix by raster plot");
    ax3=nexttile(tl);% mean spike rate bar graph
        MSR_channel = sum(w_LoDA.raster, 2) / 300;
        MSR_well    = mean(MSR_channel);
        bar(MSR_channel,"FaceColor",[0 0.5 1]);      
        yline(MSR_well, ...
            'LineStyle','--', ...
            'LineWidth',2, ...
            'Color',[1 0.4 0]); 
        text(12.8,MSR_well+0.5,"MSR in the well","Rotation",90);
        xticklabels(w_LoDA.chns);
        xtickangle(0); 
        xlabel("Channels");
        title('Mean Spike Rate (Hz)');

    ax4=nexttile(tl);% amp_raster plot
        plot_amp_raster(w_LoDA.chns, w_LoDA.amp_raster, 1:10000);
    ax5=nexttile(tl);% r2 matrix from amp_raster
        r2M_amp_raster = computePairwiseCorrelationR2(w_LoDA.amp_raster,1);
        h5 = plot_r2matrix(w_LoDA.chns, r2M_amp_raster);
        title(h5,"Synchrony (r^2) matrix by amp-raster plot");
    ax6=nexttile(tl);% mean spike amplitude bar graph
        MSA_channel = sum(w_LoDA.amp_raster, 2)./sum(w_LoDA.raster, 2);
        MSA_well    = mean(MSA_channel);
        bar(MSA_channel,"FaceColor",[0 0.5 1]);
        yline(MSA_well, ...
            'LineStyle','--', ...
            'LineWidth',2, ...
            'Color',[1 0.4 0]); 
        text(12.8,MSA_well+0.5,"MSA in the well","Rotation",90);
        xticklabels(w_LoDA.chns);
        xtickangle(0); 
        xlabel("Channels");
        title('Mean Spike Amplitude (\muV)');

    ax7 = nexttile(tl); % LoDA_channel plot
        plot_LoDA_channel(w_LoDA.chns, w_LoDA.LoDA_channel, 1:10000);
    
    ax8 = nexttile(tl); % r2 matrix from LoDA_channel
        r2M_LoDA_channel = computePairwiseCorrelationR2(w_LoDA.LoDA_channel,1);
        h8 = plot_r2matrix(w_LoDA.chns, r2M_LoDA_channel);
        title(h8,"Synchrony (r^2) matrix by LoDA-channel");

    ax9 = nexttile(tl); % apply the thredhold of 0.5
        h9 = heatmap(double(w_sync.syncMatrix));
        h9.XDisplayLabels = string(w_LoDA.chns);
        h9.YDisplayLabels = string(w_LoDA.chns);
        h9.YLabel = 'Channels';
        h9.CellLabelColor = 'none';
        h9.Title = 'Synchronization threshold r^2 > 0.5'; 
        cmap = [ones(50,3); repmat([0 0.5 1], 50, 1)];
        h9.Colormap = cmap;
        h9.ColorLimits = [0 1];
        h9.ColorScaling = 'scaled';
    
    ax10 = nexttile(tl); % LoDA_net plot
        plot_LoDA_net(w_LoDA.LoDA_net, 1:10000);
    ax11 = nexttile(tl); % synChannels & syncMean
        bar(w_sync.syncChannels,"FaceColor",[0 0.5 1]);
        yline(w_sync.syncMean, ...
            'LineStyle','--', ...
            'LineWidth',2, ...
            'Color',[1 0.4 0]); 
        text(12.8,w_sync.syncMean+0.02,"Sync-mean","Rotation",90);
        xticklabels(w_LoDA.chns);
        xtickangle(0); 
        xlabel("Channels");
        title('Synchrony (r^2) from channels to network');
    ax12 = nexttile(tl); % MEA view of synchronized channels
        dataM = [2,1,0,2;0,0,1,1;1,1,0,0;2,1,0,2];

        imagesc(ax12, dataM, 'AlphaData', ~isnan(dataM));
        colormap(ax12, [1 1 1; 0 0.5 1; 0.5 0.5 0.5]);  % white, light blue, gray
        clim(ax12, [0 2]);
        axis(ax12, 'image');
        
        xline(ax12, [1.5 2.5 3.5], "k", "LineWidth", 1);
        yline(ax12, [1.5 2.5 3.5], "k", "LineWidth", 1);
        xticks(ax12, 1:4);
        yticks(ax12, 1:4);
        title(ax12, "Channel status");
        
        [row, col] = find(dataM == 1);
        for i = 1:numel(row)
            text(ax12, col(i), row(i), 'Sync', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'Color', 'black', 'FontWeight', 'bold');
        end

set(findall(fig,'Type','axes'), ...
    'FontName','Arial', ...
    'FontSize',10, ...
    'LineWidth',1);

%% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_1_LoDA_sync.tif'), 'Resolution', 600);
close(fig);