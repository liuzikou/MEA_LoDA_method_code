function [startIdx, endIdx] = logical_to_intervals(idx)
% Convert logical vector to start/end indices

    d = diff([false; idx(:); false]);
    startIdx = find(d==1);
    endIdx   = find(d==-1)-1;
end