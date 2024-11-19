function [foundidx, foundflag] = findFirstSmaller(x, xq, idx, notFoundVal)
% [foundidx, foundflag] = findFirstSmaller(x, xq, idx)
% [foundidx, foundflag] = findFirstSmaller(x, xq, idx, notFoundVal)
%
% Find first entry in array that is SMALLER than specified value, 
% starting search FORWARD from given (linear) index.
%
% See findFirstGreater.m for details.
%
% Andreas Sommer, Nov2024
% code@andreas-sommer.eu
%

% NOTE: Matlab's JIT makes the for loop very fast, no bound checks are done

if (nargin < 4), notFoundVal = 0; end

foundidx = notFoundVal;
foundflag = false;
for i = idx:numel(x)   
   if x(i) < xq, foundidx = i; foundflag = true; return; end
end

end % of function