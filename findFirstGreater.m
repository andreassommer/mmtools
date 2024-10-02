function foundidx = findFirstGreater(x, xq, idx, notFoundVal)
% foundidx = findFirstGreater(x, xq, idx)
% foundidx = findFirstGreater(x, xq, idx, notFoundVal)
%
% Find first entry in array that is greater than specified value, 
% starting from given (linear) index.
%
% INPUT:    x --> vector to be searched in 
%          xq --> value to be searched for
%         idx --> linear index in x to start the search in
% notFoundVal --> value to be returned if no value greater than xq can be found [default: 0]
%
% OUTPUT:   foundidx --> linear index in array x of first element greater than xq
%
%
% Andreas Sommer, Sep2024
% code@andreas-sommer.eu
%

% NOTE: Matlab's JIT makes the for loop very fast, no bound checks are done

if (nargin < 4), notFoundVal = 0; end

foundidx = notFoundVal;
for i = idx:numel(x)   
   if x(i) > xq, foundidx = i; return; end
end

end % of function