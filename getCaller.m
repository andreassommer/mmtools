function [caller, file, line] = getCaller(depth)
% caller = getCaller()
% caller = getCaller(depth)
% [caller, filename, line] = getCaller(...)
%
% Retrieves the caller of current function.
% getCaller uses dbstack to retrieve the caller, so it is not for time-critical purposes!
%
% INPUT:    depth --> index of caller depth
%                     0: direct caller
%                     1: caller of direct caller
%                     2: caller of caller of direct caller, etc.
%
% OUTPUT:  caller --> name of caller
%        filename --> filename of caller 
%            line --> line number of caller
%
% Matlab's base workspace delivers:
%          caller: [BASE]
%        filename: ''    (empty char array)
%            line: 0
% If an invalid depth is specified, the following are returned:
%          caller: [invalid]
%        filename: ''    (empty char array)
%            line: -1
%
%
% Andreas Sommer, Aug2024
% code@andreas-sommer.eu
%

% depth given?
if (nargin == 0), depth = 0; end

% retrieve stack with absolute path names
stack = dbstack('-completenames');

% determine requested stack index
stackidx = 2 + depth;     % stack(1) = getCaller, stack(2) = caller of getCaller, depth=offset

% shortcut: no caller or depth is too high
if ( stackidx == numel(stack) + 1 )
   caller = '[BASE]';
   file   = '';
   line   = 0;
   return
elseif ( stackidx <= 0 ) || ( stackidx > numel(stack) + 1 )
   caller = '[invalid]';
   file   = '';
   line   = -1;
else
   caller = stack(stackidx).name;
   file   = stack(stackidx).file;
   line   = stack(stackidx).line;
end


end % of function
