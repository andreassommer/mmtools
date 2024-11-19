function [foundidx, foundflag] = findFirstGreater(x, xq, idx, notFoundVal)
% [foundidx, foundflag] = findFirstGreater(x, xq, idx)
% [foundidx, foundflag] = findFirstGreater(x, xq, idx, notFoundVal)
%
% Find first entry in array that is GREATER than specified value, 
% starting search FORWARD from given (linear) index.
%
% INPUT:    x --> vector to be searched in 
%          xq --> value to be searched for
%         idx --> linear index in x to start the search in
% notFoundVal --> value to be returned if no value GREATER than xq can be found [default: 0]
%
% OUTPUT:   foundidx --> linear index in array x of first element greater than xq
%          foundflag --> true if a value GREATER than xq was found, false otherwise
%
%
% Andreas Sommer, Sep2024, Nov2024
% code@andreas-sommer.eu
%

% NOTE: Matlab's JIT makes the for loop very fast, no bound checks are done

if (nargin < 4), notFoundVal = 0; end

foundidx = notFoundVal;
foundflag = false;
for i = idx:numel(x)   
   if x(i) > xq, foundidx = i; foundflag = true; return; end
end

end % of function