function olWarnIfNotEmpty(cellarray, dropToKeyboard, warnID)
% olWarnIfNotEmpty(cellarray, dropToKeyboard, warnID)
%
% Gives a warning if cellarray is not empty (i.e. not all argument have been processed).
%
% INPUT:   cellarray --> cell array to process
%             warnID --> warn id to be used instead of default
%     dropToDebugger --> if true, program is halted by invoking "keyboard"
%
% OUTPUT:   none
%
%
% Author:  Andreas Sommer, 2024
% code@andreas-sommer.eu
%

% defaults
if ( nargin < 3 || isempty(warnID) )       ,         warnID = 'OL:arglistNotEmpty'; end
if ( nargin < 2 || isempty(dropToKeyboard)), dropToKeyboard = true;                 end

% check if all arguments are processed
if ~isempty(cellarray)
   warning(warnID, 'Unprocessed config file arguments (length = %d)!', length(cellarray));
   disp('Content of nonempty optionlist:'); disp(cellarray);
   if dropToKeyboard
      disp('Execution paused. Continue with F5.')
      keyboard();
   end
end


end % of function