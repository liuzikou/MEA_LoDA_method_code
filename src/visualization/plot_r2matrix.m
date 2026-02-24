
function h = plot_r2matrix(chns,r2Matrix)

    h = heatmap(r2Matrix,"XData",chns,"YData",chns,"YLabel","Channels","CellLabelColor","none");
    h.ColorLimits = [0 1];
    
end
