projectRoot = fileparts(fileparts(mfilename('fullpath')));

%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'NBP_SW_ST_example.mat'));
load(fullfile(projectRoot, 'results', 'LoDA_sync_example.mat'));

%% ===== draw figure =====

fig = figure;

row = 2;
col = 1;
fig.Position = [100, 100, col*420, row*336];

chn_num=sum(w_sync.ChannelStatus);
chns=w_LoDA.chns(w_sync.ChannelStatus);

tl=tiledlayout(chn_num,1,"TileSpacing","none","Padding","tight");

for n=1:chn_num
    nexttile;
    plot(NBST.Waves(n,:));
    hold on
    xline(NBST.T_half(n),"r:","Linewidth",2);
    xticklabels([]);
    ylim([0 5]);
    yticks(1:5);
    text(3000,2.5,"Channel "+chns(n));
    xline([NBP.lapse NBP.lapse+NBP.NBdur],"k:","LineWidth",0.5);
end
xticks(0:500:4000);
xticklabels(0:500:4000);
title(tl,"\bf Stacked waveforms in each channel");
ylabel(tl,"LoDA (\muV/ms)");
xlabel(tl,"Time (ms)");

set(findall(fig,'Type','axes'), ...
    'FontName','Arial', ...
    'FontSize',10, ...
    'LineWidth',1);

%% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_2B_SWchannels.tif'), 'Resolution', 600);
close(fig);