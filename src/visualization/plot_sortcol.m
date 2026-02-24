function [hImg, M_clean, sortIdx] = plot_sortcol(M, ax, sortRows, keepRow)
% SORTCOL  Sort columns of an R-by-N matrix and visualize as a heatmap.
%
% USAGE
%   [hImg, M_clean] = sortcol(M)
%   [hImg, M_clean] = sortcol(M, ax)
%   [hImg, M_clean] = sortcol(M, ax, sortRows, keepRow)
%
% INPUT
%   M        : R-by-N numeric matrix (NaN allowed)
%   ax       : (optional) axes handle (default: gca)
%   sortRows : (optional) row indices used for sorting priority
%              default = R:-1:2
%   keepRow  : (optional) row index used to remove NaN columns
%              default = R
%
% OUTPUT
%   hImg     : imagesc handle
%   M_clean  : sorted matrix after NaN-column removal
%   sortIdx  : original column indices after sorting & filtering
%
% NOTES
%   - Does NOT create figure or colorbar
%   - Compatible with tiledlayout
%   - Automatically adapts to 3xN, 5xN, R×N matrices

% ---------------- axes ----------------
if nargin < 2 || isempty(ax)
    ax = gca;
end

% ---------------- validate M ----------------
if ~isnumeric(M) || ~ismatrix(M)
    error('M must be a numeric R-by-N matrix.');
end

[R, N] = size(M);

% ---------------- defaults ----------------
if nargin < 3 || isempty(sortRows)
    sortRows = R:-1:2;   % e.g. 5→4→3→2 or 3→2
end

if nargin < 4 || isempty(keepRow)
    keepRow = R;         % last row
end

% ---------------- sanity checks ----------------
if any(sortRows < 1 | sortRows > R)
    error('sortRows must be valid row indices within 1..%d.', R);
end

if keepRow < 1 || keepRow > R
    error('keepRow must be within 1..%d.', R);
end

% ---------------- sort columns ----------------
Mt = M.';                     % N-by-R
idx = (1:N).';                % original column indices

T = [Mt, idx];                % N-by-(R+1)
Tsorted = sortrows(T, sortRows, 'ascend');

M_sorted = Tsorted(:,1:R).';  % R-by-N
sortIdxAll = Tsorted(:,end).';

% ---------------- remove NaN columns ----------------
mask = ~isnan(M_sorted(keepRow,:));
M_clean = M_sorted(:, mask);
sortIdx = sortIdxAll(mask);

% ---------------- plot ----------------
hImg = imagesc(ax, M_clean, ...
    'AlphaData', ~isnan(M_clean));

set(ax, 'Color', [0.5 0.5 0.5]);
axis(ax, 'tight');

% ---------------- axis formatting ----------------
yticks(ax, 1:R);
xticks(ax, []);

end