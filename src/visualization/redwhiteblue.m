function cmap = redwhiteblue(n)
%REDWHITEBLUE Create a red-white-blue diverging colormap.
%
%   cmap = redwhiteblue(n)
%   n : number of colors (default 256)
%
% Output
%   cmap : n-by-3 RGB colormap

    if nargin < 1 || isempty(n)
        n = 256;
    end

    % Split into two linear gradients:
    % blue -> white, and white -> red
    n1 = floor(n/2);
    n2 = n - n1;

    % Blue to white
    b2w = [linspace(0,1,n1)', linspace(0,1,n1)', ones(n1,1)];

    % White to red
    w2r = [ones(n2,1), linspace(1,0,n2)', linspace(1,0,n2)'];

    cmap = [b2w; w2r];
end
