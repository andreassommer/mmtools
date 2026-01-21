function s = truncate_arrays_in_struct(s, idx_start, idx_end)
% s = truncate_arrays_in_struct(s, idx_start, idx_end)
%
% Truncates all arrays (also cell arrays) that are 1st level fields in a struct to specific indices.
% Scalar fields, chars or strings are left unmodified.
% Also arrays that do not have sufficient size are unmodified.
%
% INPUT:       s --> struct whose fields shall be truncated
%      idx_start --> starting index (inclusive)
%        idx_end --> end index (inclusive), can be +inf 
%
% OUTPUT:      s --> truncated struct
%
% NOTE:  Immediate return if idx_start is 1 and idx_end is inf
%
%
% Andreas Sommer, Nov2025
% code@andreas-sommer.eu
%

% immediate return if nothing to cut
if (idx_start == 1) && isinf(idx_end)
   return
end

% error if s is not a struct
if ~isstruct(s)
   error('Input must be a struct.');
end

% walk through fields
fnames = fieldnames(s);
for k = 1:length(fnames)

   % get data from field
   f = fnames{k};
   data = s.(f);
   len = numel(data);

   % skip field if ...
   if ( len < idx_start )                  , continue; end   % ... we cannot even reference idx_start
   if ( ~isnumeric(data) && ~iscell(data) ), continue; end   % ... it is not numeric or cell 
  
   % use last index if idx_end is inf
   if isinf(idx_end), idx_end = len;  end

   % try to truncate
   s.(f) = data(idx_start:idx_end);
   
end