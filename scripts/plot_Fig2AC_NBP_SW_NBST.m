projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'NBP_SW_ST_example.mat'));
load(fullfile(projectRoot, 'results', 'LoDA_sync_example.mat'));

%% ===== draw figure =====
fig = figure;

row = 4;
col = 3;
fig.Position = [100, 100, col*420, row*336];

tl = tiledlayout(fig, row, col, ...
    'TileSpacing','compact', ...
    'Padding','compact');

ax1 = nexttile(tl, 1);
plot(ax1, NBP.midedges, NBP.smoothcounts);
xlabel(ax1,"LoDA (\muV/ms)");
ylabel(ax1,"Count");
title(ax1,"Bimodal distribution of LoDA-net");
hold(ax1,'on')
xline(ax1, NBP.cutoff,":r","LineWidth",1.5);
text(ax1,1,2000,"Cutoff");
text(ax1,0.2,25000,"NB-intv");
text(ax1,2.6,5000,"NB");
hold(ax1,'off')

% ---- (1,2)-(1,3): span two columns
ax2 = nexttile(tl, 2, [1 2]);
plot(ax2, w_LoDA.LoDA_net(1,1:60000));
xlim(ax2,[0 60000]);
title(ax2,"NB and NB-intv marked on LoDA-net (0.0-60.0 s)");
hold(ax2,'on')
NB_band    = find(NBP.NB_idx);
NBintv_band = find(NBP.Intv_idx);
scatter(ax2, NB_band, ...
    NBP.cutoff*ones(numel(NB_band),1), ...
    "b","|",'MarkerFaceAlpha',0.5);
scatter(ax2, NBintv_band, ...
    NBP.cutoff*ones(numel(NBintv_band),1), ...
    "r","|",'MarkerFaceAlpha',0.5);
ylabel(ax2,"LoDA (\mu/ms)");
xlabel(ax2,"Time (s)");
xticks(0:10000:60000);
xticklabels(0:10:60);
hold(ax2,'off')

% ---- second row: tiles 4,5,6
ax3 = nexttile(tl, 4);
plot(ax3, SW.meanwave);
hold(ax3,'on')
plot(ax3, SW.meanwave-SW.std,":","Color",[1 0.5 0]);
plot(ax3, SW.meanwave+SW.std,":","Color",[1 0.5 0]);
title(ax3,"Stacked waves from NB periods");
ylabel(ax3,"LoDA (\mu/ms)");
xlabel(ax3,"Time (ms)");

Wave_amp = round(SW.Wave_amp_mean,2);
text(ax3,2400,2.55,"Wave-amp="+Wave_amp);
yline(ax3,[0 Wave_amp],"k:","Linewidth",0.5);

T_half = round(SW.T_half_mean,2);
text(ax3,2000,-0.25,"T-half="+T_half);
xline(ax3,T_half,"k:","Linewidth",0.5);

hold(ax3,'off')

ax4 = nexttile(tl, 5);
plot_column_dotswarm(SW.Wave_amp, ax4);
ylim(ax4,[2.4 3.2]);
ylabel(ax4,"Wave-amp (\muV/ms)");
title(ax4,"Wave amplitude in each period");

ax5 = nexttile(tl, 6);
plot_column_dotswarm(SW.T_half, ax5);
ylim(ax5,[1850 2000]);
ylabel(ax5,"T-half (ms)");
title(ax5,"T-half in each period");

chns=w_LoDA.chns(w_sync.ChannelStatus);
ax8 = nexttile(tl, 8);
    pWave_amp = plot_MEA4x4(ax8,chns,NBST.Wave_amp,"Wave-amp (\muV/ms) in each channel");

ax9 = nexttile(tl, 9);
    pContribution = plot_MEA4x4(ax9, chns,NBST.Contribution,"Channel contribution (%)");

ax11 = nexttile(tl, 11);
    pT_half = plot_MEA4x4(ax11,chns,NBST.T_half,"T-half (ms) in each channel");

ax12 = nexttile(tl, 12);
    pSequence = plot_MEA4x4(ax12,chns,NBST.Sequence,"Channel sequence");

set(findall(fig,'Type','axes'), ...
    'FontName','Arial', ...
    'FontSize',10, ...
    'LineWidth',1);

%% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_2AC_NBP_SW_NBST.tif'), 'Resolution', 600);
close(fig);