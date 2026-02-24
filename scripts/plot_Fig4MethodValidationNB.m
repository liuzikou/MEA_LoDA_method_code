projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'MethodValidationB36wells.mat'));
load(fullfile(projectRoot, 'results', 'MethodValidationC36wells5min.mat'));

%% ===== draw figure =====
fig = figure;

row = 2;
col = 2;
fig.Position = [100, 100, col*420, row*336]; % each panel=420*336

tl = tiledlayout(fig,row,col,'TileSpacing','compact','Padding','compact');
    ax1=nexttile(tl);
    
        x1 = WaveAmp_36wells;
        y1 = WaveAmpCV_36wells;
        InterCV1 = std(x1)/mean(x1)*100;
        
        scatter(x1,y1,"filled","MarkerFaceAlpha",0.6);
        ylim([0 30]);%
        ylabel("CV% of Wave-amp in each well");
        xlabel("Wave-amp mean in each well (\muV/ms)");
        yline(mean(y1),"r:");
        text(2.2,25,"N = 36");
        text(2.2,23,sprintf("Averaged CV = %.2f %%", mean(y1)));
        text(2.2,21,sprintf("Inter-well CV = %.2f %%", InterCV1));

    ax2=nexttile(tl);
        x2=Thalf_36wells;
        y2=ThalfCV_36wells;
        InterCV2 = std(x2)/mean(x2)*100;
        
        scatter(x2,y2,"filled","MarkerFaceAlpha",0.6);
        ylim([0 5]);
        ylabel("CV% of T-half in each well");
        xlabel("T-half mean in each well (\muV/ms)");
        yline(mean(y2),"r:");
        text(3500,4.6,"N = 36");
        text(3500,4.2,sprintf("Averaged CV = %.2f %%", mean(y2)));
        text(3500,3.8,sprintf("Inter-well CV = %.2f %%", InterCV2));

    ax3=nexttile(tl);
       [hImg3, M3] = plot_sortcol(Contribution_36well5min, ax3); 
        title(ax3,"Channel contribution (%) in 5min");
        
        n1 = 63;% Blue -> White
        t1 = linspace(0, 1, n1)';
        cmap1 = [t1, t1, ones(n1,1)];        
        n2 = 67;% White -> Red
        t2 = linspace(1, 0, n2)';
        cmap2 = [ones(n2,1), t2, t2];        
        n3 = 126; % Red plateau 
        cmap3 = repmat([1 0 0], n3, 1);              
        RWB_contribution = [cmap1; cmap2; cmap3];% Final colormap
        colormap(ax3,RWB_contribution);
        colorbar;
        yticklabels(ax3,["M1" "M2" "M3" "M4" "M5"]);
        xlabel(ax3,"Channels in networks from 36 wells");

    ax4=nexttile(tl);
       [hImg4, M4] = plot_sortcol(Sequence_36well5min, ax4); 
        title(ax4,"Channel sequence in 5min");
 
        N = 256; % Blue-white-red colormap
        n = N/2;
        t = linspace(0,1,n)';
        cmap4 = [t t ones(n,1)];
        t = linspace(1,0,n)';
        cmap5 = [ones(n,1) t t];
        RWB_sequence = [cmap4; cmap5];
        colormap(ax4,RWB_sequence);
        colorbar;
        yticklabels(ax4,["M1" "M2" "M3" "M4" "M5"]);
        xlabel(ax4,"Channels in networks from 36 wells");

set(findall(fig,'Type','axes'), ...
    'FontName','Arial', ...
    'FontSize',10, ...
    'LineWidth',1);

% %% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_4MethodValidationNB.tif'), 'Resolution', 600);
close(fig);