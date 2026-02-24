% DESCRIPTION:
%   Computes pairwise Pearson correlation (r²) between channels given a
%   time-series matrix of size (channels × time).
%
% INPUTS:
%   timeSeries_ChByt : (channels × time) double matrix
%   outputOption     : 1 → full r² matrix (channels × channels)
%                      2 → r² between the last channel and all others
%
% OUTPUT:
%   r2 : full matrix or row vector depending on outputOption

function r2 = computePairwiseCorrelationR2(timeSeries_ChByt,outputOption)
    %% ---------------------------------------------------------------
    % 1. Convert to (time × channel) for corrcoef
    %% ---------------------------------------------------------------
    ts_TByCh = timeSeries_ChByt.'; 

    %% ---------------------------------------------------------------
    % 2. Compute Spearman correlation and square to obtain r²
    %% ---------------------------------------------------------------
    rMatrix = corr(ts_TByCh, 'Type', "Spearman", 'Rows', 'pairwise');
    
    r2Matrix = rMatrix.^2;

    if outputOption == 1
        r2=r2Matrix;
        elseif outputOption == 2
        r2=r2Matrix(end,1:end-1);
        else
        error('Invalid output option. Choose 1 or 2.');
    end
end
