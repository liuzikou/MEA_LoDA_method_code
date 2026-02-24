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