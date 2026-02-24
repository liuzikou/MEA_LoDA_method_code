projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'AnalysisDevNB.mat'));

%% ===== draw figure =====
fig = figure;

row = 3;
col = 2;
fig.Position = [100, 100, col*420, row*336]; % each panel=420*336

tl = tiledlayout(fig,row,col,'TileSpacing','compact','Padding','compact');
    nexttile(tl);
        [ax1, h1] = plot_3pairs_bar(MSA_NB36well3Tp, MSA_Intv36well3Tp);
        ylim(ax1,[10 18]);
        title(ax1,"MSA in NB vs NB-Intv");
        ylabel(ax1,"Mean spike anmplitude (\muV)");
    nexttile(tl);
        [ax2, h2] = plot_3pairs_bar(MSR_NB36well3Tp, MSR_Intv36well3Tp);
        title(ax2,"MSR in NB vs NB-Intv");
        ylabel(ax2,"Mean spike rate (Hz)");
    nexttile(tl);
        [ax3, stats3] = plot_3group_comparison(Wave_amp36well3Tp);
        ylim(ax3,[0 1.8]);
        title(ax3,"Wave-amp change in devepement");
        ylabel(ax3,"Wave-amp (\muV/ms)");
    nexttile(tl);
        [ax4, stats4] = plot_3group_comparison(T_half36well3Tp);
        ylim(ax4,[0 4500]);
        title(ax4,"T-half change in devepement");
        ylabel(ax4,"T-half (ms)");
    ax5=nexttile(tl);
        [hImg5, M_clean5,~] = plot_sortcol(Contribution36well3Tp, ax5);
        n1 = 63;% Blue -> White
        t1 = linspace(0, 1, n1)';
        cmap1 = [t1, t1, ones(n1,1)];        
        n2 = 67;% White -> Red
        t2 = linspace(1, 0, n2)';
        cmap2 = [ones(n2,1), t2, t2];        
        n3 = 126; % Red plateau 
        cmap3 = repmat([1 0 0], n3, 1);              
        RWB_contribution = [cmap1; cmap2; cmap3];% Final colormap
        colormap(ax5,RWB_contribution);
        colorbar;
        title(ax5,"Channel contribution at 3 time points");
        yticklabels(ax5,["D29" "D32" "D35"]);
        xlabel(ax5,"Channels in networks from 36 wells");

   ax6=nexttile(tl);
        [hImg6, M_clean6,~] = plot_sortcol(Sequence36well3Tp, ax6);
        N = 256; % Blue-white-red colormap
        n = N/2;
        t = linspace(0,1,n)';
        cmap4 = [t t ones(n,1)];
        t = linspace(1,0,n)';
        cmap5 = [ones(n,1) t t];
        RWB_sequence = [cmap4; cmap5];
        colormap(ax6,RWB_sequence);
        colorbar;
        title(ax6,"Channel sequence at 3 time points");
        yticklabels(ax6,["D29" "D32" "D35"]);
        xlabel(ax6,"Channels in networks from 36 wells");
        
set(findall(fig,'Type','axes'), ...
    'FontName','Arial', ...
    'FontSize',10, ...
    'LineWidth',1);

% %% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_6AnalysisDevNB.tif'), 'Resolution', 600);
close(fig);