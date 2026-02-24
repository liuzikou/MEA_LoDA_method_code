% Network Burst Period analysis
% Input: LoDA_net, one dimentional time series, summarized activities from
% LoDA_sync function

% Output: smoothcounts: from histcounts of LoDA_net, for plotting histogram
%         midedges: from histcounts of LoDA_net, for plotting histogram
%         NB_cutoff: the cutoff value for Network burst
%         NB_idx: the mask of network burst time points
%         Intv_idx: the mask of network burst interval time points
%         NB_count: the number of network burst in the LoDA_net
%         Period: The period dduration of network bursts (ms)
%         NB_start: the time points when each network burst occured
%         NB_end: the time points when each network burst ended
%         NBdur: mean network burst duration
%         Intvdur: mean interval duration
%         Period_start: the time points when each period started
%         Period_end: the time points when each period ended
%         lapse: for stacking waves in the next step

function NBP=computeNetworkBurstPeriod(LoDA_net)

    NBP=struct();

    [counts,edges]=histcounts(LoDA_net,100);% use 100 bins to histcount the LoDA_mean
    NBP.smoothcounts=smoothdata(counts,"movmean",10); % this smoothing method is subject to adjustment
   
    NBP.midedges=(edges(1:end-1)+edges(2:end))./2;
    [~,locs,~,p]=findpeaks(-NBP.smoothcounts);

    bottom_idx=round(mean(locs(p==max(p)))); % if there are multiple bottom, their mean value is selected
    NBP.cutoff=NBP.midedges(bottom_idx); % The bottom of best prominence is the cutoff location
    NB_idx=(smoothdata(LoDA_net,"movmean",50)>NBP.cutoff); % just in case there is acute change, 50ms is the biggest gap in a burst

    minNBDur = 100 ; % minimum network burst duration is 100 ms, anything shorter than this is not recognized as NB
    mergeNBGap = 100 ; % if two NB sessions are closer than 100 ms, they are counted as one NB.

    NB_idx = postprocess_binary(NB_idx, minNBDur, mergeNBGap);
    NBP.NB_idx = NB_idx;
    NBP.Intv_idx = ~ NB_idx;

    NBP.NB_start = find(diff(NB_idx) == 1) + 1; % Adjust for the start of bursts
    NBP.NB_end = find(diff(NB_idx) == -1); % End of bursts

    n = min(length(NBP.NB_start),length(NBP.NB_end));
    NBP.NB_count = n;
    if NB_idx(1)==1
        NBdur = mean(NBP.NB_end(2:n)-NBP.NB_start(1:n-1));
    else
        NBdur = mean(NBP.NB_end(1:n)-NBP.NB_start(1:n));
    end
    NBP.NBdur = round(NBdur);
    NBP.Period=round(mean([diff(NBP.NB_start);diff(NBP.NB_end)]));
    NBP.Intvdur = NBP.Period-NBP.NBdur;
    NBP.lapse=round(0.5*NBP.Intvdur);
end

function idx = postprocess_binary(idx, minDur, mergeGap)
% Remove short segments and merge close ones

    idx = idx(:);

    % remove short ON segments
    [s,e] = logical_to_intervals(idx);
    for i = 1:numel(s)
        if e(i)-s(i)+1 < minDur
            idx(s(i):e(i)) = false;
        end
    end

    % merge close segments
    [s,e] = logical_to_intervals(idx);
    for i = 1:numel(s)-1
        if s(i+1)-e(i)-1 < mergeGap
            idx(e(i):s(i+1)) = true;
        end
    end
end

function [startIdx, endIdx] = logical_to_intervals(idx)
% Convert logical vector to start/end indices

    d = diff([false; idx(:); false]);
    startIdx = find(d==1);
    endIdx   = find(d==-1)-1;
end