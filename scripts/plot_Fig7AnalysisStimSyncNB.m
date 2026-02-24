projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'AnalysisStimSyncNB.mat'));

%% ===== draw figure =====
fig = figure;

row = 4;
col = 3;
fig.Position = [100, 100, col*420, row*336]; % each panel=420*336

tl = tiledlayout(fig,row,col,'TileSpacing','compact','Padding','compact');

colors = [0 0.45 0.70;
          0.65 0.15 0.45];   

    ax1 = nexttile(tl,1);
    h1 = plot_bar_mean_sem_ttest2(ax1, Ratios.Sp_rate_mean, colors);
        xticks(ax1,[1,2]);
        xticklabels(ax1,["H2O" "4AP"]);
        ylabel(ax1,"Post/Pre Ratio");
        title(ax1,"Mean spike rate (MSR) change");

    ax2 = nexttile(tl,7);
    h2 = plot_bar_mean_sem_ttest2(ax2, Ratios.MSR_NB, colors);
        xticks(ax2,[1,2]);
        xticklabels(ax2,["H2O" "4AP"]);
        ylabel(ax2,"Post/Pre Ratio");
        title(ax2,"MSR change in network bursts");
        ylim(ax2,[0 1.2]);

    ax3 = nexttile(tl,8);
    h3 = plot_bar_mean_sem_ttest2(ax3, Ratios.MSR_Intv, colors);
        xticks(ax3,[1,2]);
        xticklabels(ax3,["H2O" "4AP"]);
        ylabel(ax3,"Post/Pre Ratio");
        title(ax3,"MSR change in intervals");

    ax4 = nexttile(tl,2);
    h4 = plot_bar_mean_sem_ttest2(ax4, Ratios.Sp_amp_mean, colors);
        xticks(ax4,[1,2]);
        xticklabels(ax4,["H2O" "4AP"]);
        ylabel(ax4,"Post/Pre Ratio");
        title(ax4,"Mean spike amplitude (MSA) change");

    ax5 = nexttile(tl,4);
    h5 = plot_bar_mean_sem_ttest2(ax5, Ratios.MSA_NB, colors);
        xticks(ax5,[1,2]);
        xticklabels(ax5,["H2O" "4AP"]);
        ylabel(ax5,"Post/Pre Ratio");
        title(ax5,"MSA change in network bursts");

    ax6 = nexttile(tl,5);
    h6 = plot_bar_mean_sem_ttest2(ax6, Ratios.MSA_Intv, colors);
        xticks(ax6,[1,2]);
        xticklabels(ax6,["H2O" "4AP"]);
        ylabel(ax6,"Post/Pre Ratio");
        title(ax6,"MSA change in intervals");
        ylim(ax6,[0 1.4]);
        
    ax12 = nexttile(tl,3);
    h12 = plot_bar_mean_sem_ttest2(ax12, Ratios.sync_mean, colors);
        xticks(ax12,[1,2]);
        xticklabels(ax12,["H2O" "4AP"]);
        ylabel(ax12,"Post/Pre Ratio");
        title(ax12,"Network synchrony (Sync-mean) change");
        ylim(ax12,[0 1.4]);
        
    ax7 = nexttile(tl,6);
    h7 = plot_bar_mean_sem_ttest2(ax7, Ratios.Wave_amp, colors);
        xticks(ax7,[1,2]);
        xticklabels(ax7,["H2O" "4AP"]);
        ylabel(ax7,"Post/Pre Ratio");
        title(ax7,"Wave-amp change");

    ax8 = nexttile(tl,9);
    h8 = plot_bar_mean_sem_ttest2(ax8, Ratios.T_half, colors);
        xticks(ax8,[1,2]);
        xticklabels(ax8,["H2O" "4AP"]);
        ylabel(ax8,"Post/Pre Ratio");
        title(ax8,"T-half change");
        ylim(ax8,[0 1.2]);

    ax9 = nexttile(tl,12);
    h9 = plot_bar_mean_sem_ttest2(ax9, Ratios.T_period, colors);
        xticks(ax9,[1,2]);
        xticklabels(ax9,["H2O" "4AP"]);
        ylabel(ax9,"Post/Pre Ratio");
        title(ax9,"Network burst period change");
        ylim(ax9,[0 1.2]);

    ax10 = nexttile(tl,10);
    h10 = plot_bar_mean_sem_ttest2(ax10, Ratios.NB_dur, colors);
        xticks(ax10,[1,2]);
        xticklabels(ax10,["H2O" "4AP"]);
        ylabel(ax10,"Post/Pre Ratio");
        title(ax10,"Network burst duration change");
        ylim(ax10,[0 2]);

    ax11 = nexttile(tl,11);
    h11 = plot_bar_mean_sem_ttest2(ax11, Ratios.Intv_dur, colors);
        xticks(ax11,[1,2]);
        xticklabels(ax11,["H2O" "4AP"]);
        ylabel(ax11,"Post/Pre Ratio");
        title(ax11,"Interval duration change");
        ylim(ax11,[0 1.2]);

 set(findall(fig,'Type','axes'), ...
'FontName','Arial', ...
'FontSize',10, ...
'LineWidth',1);

%% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_7AnalysisStimSyncNB.tif'), 'Resolution', 600);
close(fig);