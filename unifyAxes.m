function unifyAxes(axh, xlimits, ylimits, zlimits, linkopt, gridopt)
% unifyAxes(axh, xlimits, ylimits, zlimits, linkopt, gridopt)
%
% Unifies and links axis scaling, possibly with grid.
%
% INPUT:     axh --> vector of axis handles to unify and link
%        xlimits --> vector of x axis limits: [lower upper]   [defaults to min/max of all current x limits]
%        ylimits --> vector of y axis limits: [lower upper]   [defaults to min/max of all current y limits]
%        zlimits --> vector of z axis limits: [lower upper]   [defaults to min/max of all current z limits]
%        linkopt --> dimension of axes to link, passed to linkaxes()  [default: 'off'];
%        gridopt --> argument forwarded to matlab's grid()            [default: 'off'];
%
% OUTPUT:   none
%
% NOTES:
%         * if a limit is set to [] or NaN, it defaults to current min/max limit value
%         * link may be one of 'x', 'y', 'z', 'xy', 'xz', 'yz', 'xyz', 'all', 'off'
%
% Example calls:
%    1) unifyAxisAcales(axh, [], [nan 10], [-5 5], 'xy', 'minor')
%                            |--> do not unify x axis
%                                |--> use minimum of current axes for lower y limit, and 10 for upper y limit
%                                          |--> use -5 for lower z limit, and 5 for upper z limit
%                                                 |--> link axes x and y
%                                                        | activate minor grid on every plot
%
% Author: Andreas Sommer, Jun2026
% code@andreas-sommer.eu
%

% error if args missing
if (nargin < 1), error('Not enough input arguments. Need at least axh.'); end

% defaults for args
if (nargin < 2) || isempty(xlimits) || all(isnan(xlimits)),  xlimits = [nan() nan()];  end    % ensure we have a 1x2
if (nargin < 3) || isempty(xlimits) || all(isnan(xlimits)),  ylimits = [nan() nan()];  end    % vector in every limit
if (nargin < 4) || isempty(xlimits) || all(isnan(xlimits)),  zlimits = [nan() nan()];  end
if (nargin < 5) ,  linkopt = '';  end
if (nargin < 6) ,  gridopt = '';  end


% special case for linkaxes: 'all'
if strcmpi(linkopt, 'all'), linkopt = 'xyz'; end

% helper to get axis information
applyToAxes = @(fun, axh) cell2mat(arrayfun(fun, axh, 'UniformOutput', false));

% get current limits
curlimx = applyToAxes(@xlim, axh);
curlimy = applyToAxes(@ylim, axh);
curlimz = applyToAxes(@zlim, axh);

% get minima and maxima
xmin = min(curlimx(:,1));     xmax = max(curlimx(:,2));
ymin = min(curlimy(:,1));     ymax = max(curlimy(:,2));
zmin = min(curlimz(:,1));     zmax = max(curlimz(:,2));

% process given axis limits
if isfinite(xlimits(1)), xmin = xlimits(1); end
if isfinite(xlimits(2)), xmax = xlimits(2); end
if isfinite(ylimits(1)), ymin = ylimits(1); end
if isfinite(ylimits(2)), ymax = ylimits(2); end
if isfinite(zlimits(1)), zmin = zlimits(1); end
if isfinite(zlimits(2)), zmax = zlimits(2); end

% apply axis limits
for k = 1:length(axh)
   xlim(axh(k), [xmin xmax]);
   ylim(axh(k), [ymin ymax]);
   zlim(axh(k), [zmin zmax]);
end

% apply linking
if ~isempty(linkopt)
   linkaxes(axh, linkopt)
end

% apply grids
if ~isempty(gridopt)
   grid(axh, gridopt)
end

end