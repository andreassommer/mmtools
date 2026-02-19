function [idx, val, sorted_x, sorted_xq] = findNearestNeighbor(x, xq, searchdir, sortflag_x, sortflag_xq, cornermatch)
%
% Retrieve the indices and/or values of nearest neighboring values in a sorted or unsorted vector.
%
% INPUT:      x --> data vector to search in
%            xq --> query values to be searched for
%     searchdir --> flag to indicate searching only for values smaller or greater than the query values
%                    0: find closest value      [DEFAULT]
%                   +1: find next larger value
%                   -1: find next smaller value
%                   note that +1 and -1 only work for sorted arrays x
%    sortflag_x --> flag to indicate if x is sorted
%                   +1: x is sorted ascending   [DEFAULT]
%                    0: x is not sorted
%                   -1: x is sorted decending
%   sortflag_xq --> flag to indicate if xq is sorted
%                   +1: xq is sorted ascending  [DEFAULT]
%                    0: xq is not sorted
%                   -1: xq is sorted decending
%   cornermatch --> checks if xq is outside the interval [min(x) max(x)]       [DEFAULT: true]
%                   - for searchdir == -1
%                     * if cornermatch is false, idx and val are set to -inf for any xq < min(x)
%                     * if cornermatch is true, idx contains the index to the minimum of x
%                   - for searchdir == +1
%                     * if cornermatch is false, idx and val are set to +inf for any xq > max(x)
%                     * if cornermatch is true, idx contains the index to the maximum of x
%                   - for searchdir == 0, idx(i) contains the index to the closest value of xq(i) in x
%                     independent of the value of cornermatch
%
% OUTPUT:  idx --> vector of nearest neighbors' indices
%          val --> vector of respective neighbor values, i.e. val(i) = x(idx(i)) for finite idx(i)
%      sortedx --> If xq is a vector and x is unsorted, x is sorted ascending for performance reasons.
%                  In that case, sortedx contains the ascending sorted vector x; otherwise NaN.
%     sortedxq --> If xq is an unsorted vector, xq is sorted ascending for performance reasons.
%                  In that case, sortedxq contains the ascending sorted vector xq; otherwise NaN.
%
% Andreas Sommer
% code@andreas-sommer.eu
% Feb2026

% settings and defaults
if (nargin < 3 || isempty(searchdir  )), searchdir   =  0; end
if (nargin < 4 || isempty(sortflag_x )), sortflag_x  = +1; end
if (nargin < 5 || isempty(sortflag_xq)), sortflag_xq = +1; end
nx = numel(x);
nq = numel(xq);
sorted_x  = nan(); % value to recognize that no sorting was done
sorted_xq = nan(); % value to recognize that no sorting was done

% CASE 1: SEARCH A SINGLE VALUE xq IN x
% =====================================
if (nq == 1) % single query value 
  
   % some corner cases first (have to check them in any case): 
   if ~cornermatch
      if (sortflag_x) > 0     % x is ascendingly sorted and xq outside [min(x) max(x)]
         if (searchdir <= -1) && (xq < x(1)) , idx = -inf(); val = -inf(); return; end
         if (searchdir >= +1) && (xq > x(nx)), idx = +inf(); val = +inf(); return; end
      elseif (sortflag_x < 0) % x is descendingly sorted and xq outside [min(x) max(x)]
         if (searchdir <= -1) && (xq < x(nx)), idx = -inf(); val = -inf(); return; end
         if (searchdir >= +1) && (xq > x(1)) , idx = +inf(); val = +inf(); return; end
      end
      % the unsorted case sortflag_x == 0 is done below
   end

% TODO: quick run for sorted x

   % walk through x and find closest smaller and larger value to xq
   dist_closest_smaller = -inf(); idx_closest_smaller = -inf();
   dist_closest_larger  = +inf(); idx_closest_larger  = +inf();
   for i = 1:nx
      dx = x(i) - xq;  % distance to xq
      if (dx == 0)
         idx = i; val = x(i); return;   % QUICK RETURN: found exact value
      elseif (dx > 0) && (dx < dist_closest_larger)
         dist_closest_larger = dx;
         idx_closest_larger  = i; 
      elseif (dx < 0) && (dx > dist_closest_smaller)
         dist_closest_smaller = dx;
         idx_closest_smaller  = i;
      end
   end


   % Set indices depending on search direction
   if (searchdir >= +1)      % SEARCHING FOR LARGER x(i) > xq
      if isfinite(idx_closest_larger)  % look for smallest x(i) that is larger than xq
         idx = idx_closest_larger;
         val = x(idx);
      else  % corner case 1: we search for x(i) > xq but xq > max(x) 
         if (cornermatch)
            idx = idx_closest_smaller;
            val = x(idx);
         else
            idx = +inf();
            val = +inf();
         end
      end
   elseif (searchdir <= -1)  % SEARCHING FOR SMALLER x(i) < xq
      if isfinite(idx_closest_smaller) 
         idx = idx_closest_smaller;
         val = x(idx);
      else % corner case 2: xq < min(x) and we search for smaller values
         if (cornermatch)
            idx = idx_closest_larger;
            val = x(idx);
         else
            idx = -inf();
            val = -inf();
         end
      end
   else % (searchdir == 0)  % DEFAULT -- we have  min(x) < xq < max(x)  --- the case that an x(i)==xq is handled above
      if     ~isfinite(idx_closest_smaller), idx = idx_closest_larger ; val = x(idx);
      elseif ~isfinite(idx_closest_larger ), idx = idx_closest_smaller; val = x(idx);
      else % check if smaller or larger closest value is closer to xq
         if (x(idx_closest_larger) - xq) < (xq - x(idx_closest_smaller))
            idx = idx_closest_larger;
            val = x(idx);
         else
            idx = idx_closest_smaller;
            val = x(idx);
         end
      end
   end
   return
end




% CASE 2: SEARCH MULTIPLE VALUES xq IN x
% ======================================

% initialize output variables
idx = zeros(nq, 1);
val = [];

% first sort the arrays for easier search
x_was_unsorted  = (sortflag_x  == 0);
xq_was_unsorted = (sortflag_xq == 0);
sortidx_x  = [];
sortidx_xq = [];
if (sortflag_x  == 0),  [ x, sortidx_x ] = sort( x,'ascend'); sortflag_x  = +1; end
if (sortflag_xq == 0),  [xq, sortidx_xq] = sort(xq,'ascend'); sortflag_xq = +1; end

% from here, we have both arrays x and xq sorted and sortflag_* is nonzero

% walk through xq depending on sort order: ensure starting with smallest value
qi0   = condSet_(sortflag_xq==+1,  1, nq);  % start with first or last entry
qif   = condSet_(sortflag_xq==+1, nq,  1);  % start with first or last entry
qiinc = condSet_(sortflag_xq==+1,  1, -1);  % go forward or backward in xq

% walk through x depending on sort order: ensure starting with smallest value
xi0   = condSet_(sortflag_x==+1,  1, nx); 
xif   = condSet_(sortflag_x==+1, nx,  1);
xiinc = condSet_(sortflag_x==+1,  1, -1);

% CORNER CASES first: xq values outside [min(x) max(x)]
for i = qi0:qiinc:qif  % check the small values of xq being less than min(x)
   if (xq(i) < x(xi0))
      if (searchdir <= -1) && ~cornermatch
         idx(i) = -inf();
      else
         idx(i) = xi0;
      end
      qi0 = i + qiinc;  % we dont have to care for these entries anymore
   else
      break
   end
end
for i = qif:-qiinc:qi0  % check the large values of xq being greater than max(x)
   if (xq(i) > x(xif) )
      if (searchdir >= +1) && ~cornermatch
         idx(i) = +inf();
      else
         idx(i) = xif;
      end
      qif = i - qiinc;  % we dont have to care for these entries anymore
   else
      break
   end
end

% SCAN x (in ascending order) for the remaining xq (also in ascending order)
qi = qi0;                  % start index in xq
i  = xi0;
done = false;
while ~done
   if (x(i) >= xq(qi))          % find the elements in x that are greater/equal to xq
      idx(qi) = i;              % store the index
      if x(idx(qi)) ~= xq(qi)   % if not hit exactly adjust index depending on sort order and searchdir
         % if (searchdir == +1) % nothing to do
         prevIdx = i - xiinc;   % candidate index in x to check if closer to query value xq(qi)  --- note: i = idx(qi)
         if (searchdir == -1)
            idx(qi) = prevIdx;  % 
         elseif (searchdir == 0)
            if (prevIdx >= 1 && prevIdx <= nx) && ( xq(qi) - x(prevIdx)  <  x(i) - xq(qi)  )
               idx(qi) = idx(qi) - xiinc;
            end
         end
      end
      if (qi == qif), done = true; end % stop when final xq was processed
      qi = qi + qiinc;     % go to next query value
   else
      if ( i == xif), done = true; end  % stop when final x was processed
      i = i + xiinc;       % otherwise increase the index in x
   end
end


% set 2nd output variable if requested - before sorting back to original array
if (nargout >= 2)
   val = zeros(size(idx));
   finiteIdx = isfinite(idx);
   val(finiteIdx) = x(idx(finiteIdx)); % transfer finite values from x
   val(~finiteIdx) = idx(~finiteIdx);  % transfer invalid markers from idx
end

% undo the sorting of xq, if xq was originally unsorted (and we sorted it)
if (xq_was_unsorted)
   inv_sortidx_xq(sortidx_xq) = 1:length(sortidx_xq);
   idx = idx(inv_sortidx_xq);
   val = val(inv_sortidx_xq);
end
% indices and values map to the sorted array x (if we did the sorting, then we have do undo it)
if (x_was_unsorted)
   % inv_sortidx_x(sortidx_x) = 1:length(sortidx_x);
   finiteidx = isfinite(idx);
   idx(finiteidx) = sortidx_x(idx(finiteidx));
end

if (nargout >=3 ), sorted_x  = x;  end
if (nargout >=4 ), sorted_xq = xq; end


% finito
return

end % of function


% HELPERS
% =======
function tf = condSet_(condition, trueval, falseval)
   if (condition), tf = trueval; else, tf = falseval; end
end

