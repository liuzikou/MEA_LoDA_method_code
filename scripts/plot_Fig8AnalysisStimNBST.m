projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src', 'visualization'));
%% ===== Load data =====
load(fullfile(projectRoot, 'results', 'AnalysisStimNBST.mat'));

%% ===== draw figure =====
fig = figure;

row = 4;
col = 2;
fig.Position = [100, 100, col*420, row*336]; % each panel=420*336

tl = tiledlayout(fig,row,col,'TileSpacing','compact','Padding','compact');

    ax1=nexttile(tl,[2 1]);
        M1=Contribution(1:10,:);
        [hImg1, M_clean1, ~] = plot_sortcol(M1, ax1, [10 9 8 7]);
        yticklabels(ax1,["Pre1" "Pre2" "Pre3" "Pre4" "Pre5" "Post1" "Post2" "Post3" "Post4" "Post5"]);
        xlabel(ax1,"Channels in networks from 8 wells");
        title(ax1,"Channel contribution (%) Pre/Post H2O");
        yline(ax1,5.5,"k","LineWidth",1);
        n1 = 63;% Blue -> White
        t1 = linspace(0, 1, n1)';
        cmap1 = [t1, t1, ones(n1,1)];        
        n2 = 67;% White -> Red
        t2 = linspace(1, 0, n2)';
        cmap2 = [ones(n2,1), t2, t2];        
        n3 = 126; % Red plateau 
        cmap3 = repmat([1 0 0], n3, 1);              
        RWB_contribution = [cmap1; cmap2; cmap3];% Final colormap
        colormap(ax1,RWB_contribution);

    ax2=nexttile(tl,[2 1]);
        M2=Contribution(11:20,:);
        [hImg2, M_clean2, ~] = plot_sortcol(M2, ax2, [10 9 8 7]);
        yticklabels(ax2,["Pre1" "Pre2" "Pre3" "Pre4" "Pre5" "Post1" "Post2" "Post3" "Post4" "Post5"]);
        xlabel(ax2,"Channels in networks from 8 wells");
        title(ax2,"Channel contribution (%) Pre/Post 4AP");
        yline(ax2,5.5,"k","LineWidth",1);
        colormap(ax2,RWB_contribution);
        colorbar(ax2);

    ax3=nexttile(tl,[2 1]);
        M3=Sequence(1:10,:);
        [hImg3, M_clean3, ~] = plot_sortcol(M3, ax3, [10 9 8 7]);
        yticklabels(ax3,["Pre1" "Pre2" "Pre3" "Pre4" "Pre5" "Post1" "Post2" "Post3" "Post4" "Post5"]);
        xlabel(ax3,"Channels in networks from 8 wells");
        title(ax3,"Channel sequence Pre/Post H2O");
        yline(ax3,5.5,"k","LineWidth",1);
        N = 256; % Blue-white-red colormap
        n = N/2;
        t = linspace(0,1,n)';
        cmap4 = [t t ones(n,1)];
        t = linspace(1,0,n)';
        cmap5 = [ones(n,1) t t];
        RWB_sequence = [cmap4; cmap5];
        colormap(ax3,RWB_sequence);

    ax4=nexttile(tl,[2 1]);
        M4=Sequence(11:20,:);
        [hImg4, M_clean4, ~] = plot_sortcol(M4, ax4, [10 9 8 7]);
        yticklabels(ax4,["Pre1" "Pre2" "Pre3" "Pre4" "Pre5" "Post1" "Post2" "Post3" "Post4" "Post5"]);
        xlabel(ax4,"Channels in networks from 8 wells");
        title(ax4,"Channel sequence Pre/Post 4AP");
        yline(ax4,5.5,"k","LineWidth",1);
        colormap(ax4,RWB_sequence);
        colorbar(ax4);

set([ax1 ax2 ax3 ax4], 'FontName','Arial','FontSize',10,'LineWidth',1);

% %% ===== export figure =====
exportgraphics(fig, fullfile(projectRoot, 'figures','Figure_8AnalysisStimNBST.tif'), 'Resolution', 600);
close(fig);

%% ===== Calculate correlation =====
Ms = {M_clean1,M_clean2,M_clean3,M_clean4};
NBSTCorr = NaN(9,4);

for i=1:4
    M=Ms{1,i};
    for k=1:9
        x=M(k,:);
        y=M(k+1,:);
        mask = ~isnan(x) & ~isnan(y);
    
        [rho,~] = corr(x(mask).', y(mask).',"Type","Spearman");
        NBSTCorr(k,i) = rho;
    end
end

