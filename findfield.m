function [foundNames, exact] = findfield(s, query, ignoreCase)
% [foundNames, exact] = findfield(s, query)
% [foundNames, exact] = findfield(s, query, ignoreCase)
%
% Searches for query pattern in fields of structure s
%
% INPUT:        s --> struct to be searchedin
%           query --> char array or regular expression to search for in fieldnames
%      ignoreCase --> flag indicating to ignore case (small or capital letters)
%
% OUTPUT:  
%      foundNames --> found field names matching the regexp pattern (cell string)
%           exact --> flag, exact(i) is true if fnames{i} matches exactly
%
%
% Andreas Sommer, Nov2024
% code@andreas-sommer.eu
%

% all input given?
if (nargin < 3), ignoreCase = false; end

% ensure s is a struct and get its fieldnames
if ~isstruct(s), error('First input is not a struct'); end
fnames = fieldnames(s);

% ensure that query is a single character array or string
if isstring(query), query = convertStringsToChars(query); end
if ~(ischar(query) && size(query, 1) == 1)
   error('Second input is not a char array.')
end

% if it is a regular expression (or looks like one) call regexp
if isregexp(query)
   % SEARCH FOR REGULAR EXPRESSION
   if ignoreCase, caseSensitivity = 'ignorecase'; else, caseSensitivity = 'matchcase'; end
   foundIdx = regexp(fnames, query, caseSensitivity, 'forcecelloutput');
   foundIdx = cellfun(@(x) ~isempty(x), foundIdx);
else
   % SEARCH FOR SUBSTRING
   foundIdx = contains(fnames, query, 'ignoreCase', ignoreCase);
end

% if we're here, foundidx is properly set
foundNames = fnames(foundIdx);

% if exact flag was specified, determine exact matches
if (nargout >= 2)
   exact = strcmp(foundNames, query);
end

end

% check if we're searching for a substring, no regexp
function isRegExp = isregexp(query)
   normalChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_';
   isRegExp = any( ~ismember(query, normalChars) );
end