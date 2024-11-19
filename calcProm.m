function [prom, promIdx] = calcProm(x, y, qiy, w, dir)
% [prom, promIdx] = calcProm(x, y, qiy, w, dir)
%
% Calculates prominence of y(idx) in specified signal.
%
% INPUT:  x --> x values (independent variable, must be strongly monotonic increasing)
%         y --> y values (signal)
%       qiy --> query index of y-value whose prominente shall be calculated (can be vector)
%        xw --> selects x window to search for prominence               [ default:  [-inf inf]) ]
%               e.g. xw = 100      searches for prominence within 100 units around x(idx)
%                    xw = [-5 100] searches for prominence in [x(idx) - 5, x(idx) + 100]
%       dir --> select prominence direction:                            [ default: +1 ]
%               +1: search for positive prominence (i.e. "usual prominence") 
%               -1: search for negative prominence (i.e. prominence of negative signal)
%                0; search for both prominences
%
% OUTPUT:   prom -->
%
% If window border is reached ...
%
% Andreas Sommer, Nov2024
% code@andreas-sommer.eu
%

% ensure all variables are present
if (nargin < 4);   w = []; end
if (nargin < 5); dir = +1; end

% if idx is a vector, call self multiple times - not time optimal, as we could store the window calculation
if ~isscalar(qiy)
   [prom, promIdx] = arrayfun(@(i) calcProm(x,y,i,w,dir), qiy);
   return
end

% cut out window
if isempty(w) || all(isinf(w))
   xiL = 1;            % index in x, left bound
   xiR = numel(x);     % index in x, right bound
   qiyy = qiy;         % query index y(qiy) in yy array
   xx = x;             % x array cut to window
   yy = y;             % y array cut to window
else
   % widx = ( x >= x(idx) + w(1) ) | ( x <= x(idx) + w(end) );   % logical indexing is generally slower!
   xiL = findFirstGreater(x, x(qiy)+w( 1 ), 1  ); % start search at 1
   xiR = findFirstGreater(x, x(qiy)+w(end), xiL); % start search after found point
   qiyy = qiy - xiL + 1;                          % index of y(qiy) in yy
   xx = x(xiL:xiR);                               % x array cut to window
   yy = y(xiL:xiR);                               % y array cut to window
end

% initialize empty so we can always concatenate
promPos = [];  promPosIdx = [];  
promNeg = [];  promNegIdx = [];

% determine requested prominences
if (dir >= 0),  [promPos, promPosIdx] = calcProm_internal(xx,  yy, qiyy); end
if (dir <= 0),  [promNeg, promNegIdx] = calcProm_internal(xx, -yy, qiyy); end

% set the index w.r.t. original array
if ~isempty(promPosIdx), promPosIdx = promPosIdx + (xiL - 1); end
if ~isempty(promNegIdx), promNegIdx = promNegIdx + (xiL - 1); end

% assemble result
prom    = [promPos   , promNeg   ];
promIdx = [promPosIdx, promNegIdx];


end % of function


%% HELPER -- Internal helper function to determine the prominence
function [promVal, promIdx] = calcProm_internal(xx, yy, qi)

   % search for higher values to the left and right 
   yq = yy(qi);
   [idxL, foundL] = findFirstGreaterRev( yy, yq, qi,     1      );  % arg4 = 1 --> return at least index 1
   [idxR, foundR] = findFirstGreater   ( yy, yq, qi, length(xx) );  %          --> return at most xxlen

   % check which one leads to smaller difference in x - but do not take border values
   pL = -inf; pR = +inf;   % prominence to left and right 
   if (foundL), pL = xx(idxL) - xx(qi); end   % left proinence is negative
   if (foundR), pR = xx(idxR) - xx(qi); end   % right prominence is positive

   % check which prominence is smaller (absolute values, as they can be pos/neg to indicate direction)
   if (abs(pL) < abs(pR))
      promVal = pL; promIdx = idxL;    % either found both or found pL
   else
      promVal = pR; promIdx = idxR;
   end
   % if no prominence can be determined (i.e. global extremum), return +inf for prominence, and 0 for the index
   if isinf(promVal)
      promIdx = 0;
   end
   
end % of internal function 



