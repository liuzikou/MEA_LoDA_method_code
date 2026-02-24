projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'MethodValidationA52wells.mat'));

%% ===== Pre-process input =====
sync_mask = (Channel_Rate_Amp_Sync_624chn(:,3)>0.5);
    sync_MSR = Channel_Rate_Amp_Sync_624chn(sync_mask,1);
    sync_MSA = Channel_Rate_Amp_Sync_624chn(sync_mask,2);
    nonsync_MSR = Channel_Rate_Amp_Sync_624chn(~sync_mask,1);
    nonsync_MSA = Channel_Rate_Amp_Sync_624chn(~sync_mask,2);
    nSync    = sum(sync_mask);
    nNonSync = sum(~sync_mask);

%% ===== draw figure =====
fig = figure;

row = 2;
col = 2;
fig.Position = [100, 100, col*420, row*336]; % each panel=420*336

tl = tiledlayout(fig,row,col,'TileSpacing','compact','Padding','compact');
    ax1=nexttile(tl);
    [ax1,stats] = plot_column_dotswarm(Sync_mean_52well,ax1);
    ylim(ax1,[0 1.1]);
    title(ax1,"Synchronization in 52 wells at D28");
    ylabel(ax1,"Sync-mean");

    ax2=nexttile(tl);
    scatter(ax2,sync_MSA,sync_MSR,10,"filled","MarkerFaceColor",[0 0 1],"MarkerFaceAlpha",0.5);
    hold on
    scatter(ax2,nonsync_MSA,nonsync_MSR,10,"filled","MarkerFaceColor",[0 0.7 0.6],"MarkerFaceAlpha",0.5);
    hold off
    xlabel(ax2,"Mean spike amplitude (\muV)");
    ylabel(ax2,"Mean spike rate (Hz)");
    title(ax2,"Spike properties from each channel");
    legend(ax2,[ ...
    "Synchronized channel (n=" + nSync + ")", ...
    "Non-synchronized channel (n=" + nNonSync + ")" ],"Box","off","Location","northeast");

    ax3=nexttile(tl);
    [ax3, x1] = plot_bar_MeanPlusError(ax3,sync_MSA,nonsync_MSA);
    xticks(x1);    
    xticklabels(ax3,["Synchronized" "Non-synchronized"]);
    title(ax3,"Mean spike amplitude (\muV)");
    
    ax4=nexttile(tl);
    [ax4, x2] = plot_bar_MeanPlusError(ax4,sync_MSR,nonsync_MSR);
    xticks(x2);    
    xticklabels(ax4,["Synchronized" "Non-synchronized"]);
    title(ax4,"Mean spike rate (Hz)");

set(findall(fig,'Type','axes'), ...
    'FontName','Arial', ...
    'FontSize',10, ...
    'LineWidth',1);

% %% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_3MethodValidationSync.tif'), 'Resolution', 600);
close(fig);