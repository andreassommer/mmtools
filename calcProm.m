function [prom, promIdx] = calcProm(x, y, qiy, w, type, dir, infVal)
% [prom, promIdx] = calcProm(x, y, qiy, w, type)
%
% Calculates prominence of y(qiy) in specified signal.
%
% INPUT:  x --> x values (independent variable, must be strongly monotonic increasing)
%         y --> y values (signal), same size as x
%       qiy --> query index of y-value whose prominence shall be calculated (can be vector)
%         w --> selects x window to search for prominence                          [ default:  [-inf inf] ]
%               e.g. w = 100      searches for prominence within 100 units around x(qiy)
%                    w = [-5 100] searches for prominence in [x(qiy) - 5, x(qiy) + 100]
%                    w = []       searches for prominence in whole interval [-inf +inf]
%      type --> select prominence type:                                            [ default: +1 ]
%               +1: search for positive prominence (i.e. "usual prominence") 
%               -1: search for negative prominence (i.e. prominence of negative signal)
%                0: search for both prominences
%       dir --> direction for prominence calculation                               [ default: 0 ]
%               +1: search in positive direction (to the right, increasing x values)
%                0: search in both directions (to the left and right) 
%               -1: search in negative direction (to the left, decreasing x values)
%    infVal --> value for infinite prominence                                      [ default: x(end)-x(1) ]
%
% OUTPUT:   prom --> determined prominence of points specified in y(qiy)
%        promIdx --> indices of elements in y belonging to the prominence values in array prom
%
%
% Andreas Sommer, Nov2024, Sep2025
% code@andreas-sommer.eu
%

% ensure all variables are present
if (nargin < 4);      w = [];   end
if (nargin < 5);   type = +1;   end
if (nargin < 6);    dir =  0;   end
if (nargin < 7); infVal = x(end)-x(1); end

% if qiy is a vector, call self multiple times - not time optimal, as we could store the window calculation
if ~isscalar(qiy)
   if (type<0), y = -y; end                      % manually inverse y signal here instead within every sub-call
   [prom, promIdx] = arrayfun(@(i) calcProm(x,y,i,w,+1,dir,infVal), qiy);  % always use positive direction in sub-call
   return
end

% cut out window
if isempty(w) || all(isinf(w))
   xiL = 1;            % index in x, left bound
   %xiR = numel(x);    % index in x, right bound
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
if (type >= 0),  [promPos, promPosIdx] = calcProm_internal(xx,  yy, qiyy, dir, infVal); end
if (type <= 0),  [promNeg, promNegIdx] = calcProm_internal(xx, -yy, qiyy, dir, infVal); end

% set the index w.r.t. original array
if ~isempty(promPosIdx), promPosIdx = promPosIdx + (xiL - 1); end
if ~isempty(promNegIdx), promNegIdx = promNegIdx + (xiL - 1); end

% assemble result
prom    = [promPos   , promNeg   ];
promIdx = [promPosIdx, promNegIdx];


end % of function


%% HELPER -- Internal helper function to determine the prominence
function [promVal, promIdx] = calcProm_internal(xx, yy, qi, dir, infVal)
   % This function only checks for "ordinary" prominence: the distance you have to go in specified direction
   % until you reach a point that is higher then the specified point yy(qi)
   % xx:  x values
   % yy:  y values
   % qi:  query index (must be scalar!)
   % dir: direction (-1|0|+ = left|both|right)

   % search for higher values to the left and/or right, depending on "dir"
   foundL = false;
   foundR = false;
   yq = yy(qi);
   if (dir <=0), [idxL, foundL] = findFirstGreaterRev( yy, yq, qi,     1      ); end % arg4 = 1 --> return at least index 1
   if (dir >=0), [idxR, foundR] = findFirstGreater   ( yy, yq, qi, length(xx) ); end %          --> return at most xxlen

   % check which one leads to smaller difference in x - but do not take border values
   pL = -inf; pR = +inf;   % prominence to left and right 
   if (foundL), pL = xx(idxL) - xx(qi); end   %  left prominence is negative
   if (foundR), pR = xx(idxR) - xx(qi); end   % right prominence is positive

   % retrieve prominence in the requested direction
   if (dir < 0)
      promVal = pL; promIdx = idxL;
   elseif (dir > 0)
      promVal = pR; promIdx = idxR;
   else % dir == 0
      % check which prominence is smaller (absolute values, as they can be pos/neg to indicate direction)
      if (abs(pL) < abs(pR))
         promVal = pL; promIdx = idxL;    % either found both or found pL
      else
         promVal = pR; promIdx = idxR;
      end
   end

   % if no prominence can be determined (i.e. global extremum), return +/- infVal for prominence, and 0 for the index
   if isinf(promVal)
      promVal = infVal * sign(promVal);
      promIdx = 0;
   end
   
end % of internal function 



