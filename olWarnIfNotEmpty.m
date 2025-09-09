function olWarnIfNotEmpty(cellarray, dropToDebugger, warnID)
% olWarnIfNotEmpty(cellarray, dropToDebugger, warnID)
%
% Gives a warning if cellarray is not empty (i.e. not all argument have been processed).
%
% INPUT:   cellarray --> cell array to process
%     dropToDebugger --> if true, program is halted by invoking "keyboard"
%             warnID --> warn id to be used instead of default
%
% OUTPUT:   none
%
%
% Author:  Andreas Sommer, 2024
% code@andreas-sommer.eu
%

% defaults
if ( nargin < 3 || isempty(warnID) )       ,         warnID = 'OL:arglistNotEmpty'; end
if ( nargin < 2 || isempty(dropToDebugger)), dropToDebugger = false;                end

% check if all arguments are processed
if ~isempty(cellarray)
   warning(warnID, 'Unprocessed config file arguments (length = %d)!', length(cellarray));
   disp('Content of nonempty optionlist:'); disp(cellarray);
   if dropToDebugger
      disp('Execution paused. Continue with F5.')
      keyboard();
   end
end


end % of function