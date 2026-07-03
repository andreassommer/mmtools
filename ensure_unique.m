function unique_values = ensure_unique(values, reladjust, absadjust)
%
% unique_values = ENSURE_UNIQUE(values, reladjust, absadjust)
%
% Ensures that the specified values are unique, by adjusting non-unique items.
%
% INPUT:    values --> values to become unique
%        reladjust --> adjusting non-unique values:
%                      the k-th occurrence of a value will be adjusted by 
%                      a factor of (k-1)*reladjust*eps(1)                   [default: 1]
%        absadjust --> adjusting non-unique values:
%                      the k-th occurrence of a value will be adjusted by
%                      an absolute value of absadjust                       [default: 0]
%                      See the notes!
%
% OUTPUT:  unique_values --> unique values
%
% NOTE: * Function accepts multi-dimensional arrays by processing them as values(:).
%         If that order is not appropriate or only parts of the array shall be unique, then
%         first extract the values that must be unique, call ensure_unique() on them, and
%         write them back into the original array.
%       * Using "absadjust", it is not guaranteed that the resulting array is really unique,
%         due to floating point precision limitations.
%         E.g. using an absadjust of 1e-17 to the vector [1 1 2 2 3 3] will result in an 
%         unmodified vector, because 1 + 1e-17 = 1 in double-float arithmetics.
%
% Andreas Sommer, Jul2026
% code@andreas-sommer.eu
%

% ensure args
if (nargin < 2), reladjust = 1.0; end
if (nargin < 3), absadjust = 0.0; end

% get unique values
[~,ia,ic] = unique(values);

% number of unique elements
nunique = length(ia); 

% check occurrences of same value
if verLessThan('MATLAB', '9.7')  % groupcounts was introduced in R2019a = Matlab 9.6
   counts = zeros(nunique, 1);
   for i = 1:numel(ic)
      counts(ic(i)) = counts(ic(i)) + 1;
   end
else
   counts = groupcounts(values(:));  % groupcounts is much faster
end

% decrement all by 1 because we only copy for non-unique values
counts = counts - 1;
adjustment = reladjust * eps(1);

% for i = numel(values):-1:1
if (absadjust < 0) || (reladjust < 0)
   from = 1;
   to = numel(values);
   step = 1;
else
   from = numel(values);
   to = 1;
   step = -1;
end

% run through the values
for i = from:step:to
   idx = ic(i);
   if counts(idx) > 0
      % values(i) = (1 + adjustment * counts(idx)) * values(i)  +  absadjust * counts(idx);  % little bit slower ?!
      values(i) = values(i)  +  adjustment * counts(idx) * values(i)  +  absadjust * counts(idx);
      counts(idx) = counts(idx) - 1;
   end
end

% result
unique_values = values;

end % of function

