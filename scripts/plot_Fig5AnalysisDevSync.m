projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'AnalysisDevSync.mat'));

%% ===== draw figure =====
fig = figure;

row = 2;
col = 2;
fig.Position = [100, 100, col*420, row*336]; % each panel=420*336

tl = tiledlayout(fig,row,col,'TileSpacing','compact','Padding','compact');
    
    nexttile(tl);
        ax1 = bar_scatter_line(Sp_rate_mean);
        title(ax1,"Well-level MSR in developement");
        ylim(ax1,[0 30]);
        ylabel(ax1,"Mean spike rate (Hz)");
        xticklabels(ax1,["D21" "D28" "D29" "D32" "D35"]);
    nexttile(tl);
        ax2 = bar_scatter_line(Sp_amp_mean);
        title(ax2,"Well-level MSA in developement");
        ylim(ax2,[0 20]);
        ylabel(ax2,"Mean spike amplitude (\muV)");
        xticklabels(ax2,["D21" "D28" "D29" "D32" "D35"]);
    nexttile(tl);
        ax3 = bar_scatter_line(sync_chn_count);
        title(ax3,"Sync-channel count in developement");
        ylim(ax3,[0 15]);
        yline(ax3,12,"k:");
        yticks(ax3,0:2:12);
        ylabel(ax3,"Sync-channel count");
        xticklabels(ax3,["D21" "D28" "D29" "D32" "D35"]);
    nexttile(tl);
        ax4 = bar_scatter_line(sync_mean);
        title(ax4,"Sync-mean in developement");
        ylim(ax4,[0 1.2]);
        yticks(ax4,0:0.2:1.2);
        ylabel(ax4,"Sync-mean");
        yline(ax4,1,"k:");
        xticklabels(ax4,["D21" "D28" "D29" "D32" "D35"]);

 set(findall(fig,'Type','axes'), ...
'FontName','Arial', ...
'FontSize',10, ...
'LineWidth',1);

%% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_5AnalysisDevSync.tif'), 'Resolution', 600);
close(fig);