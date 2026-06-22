function [displayText, result] = getMatlabDisplay(thing, trimLF)
% [displayText, result] = getMatlabDisplay(thing, trim)
%
% Evaluates the specified object and captures the display output via evalc().
% The first return value can also be captured and returned.
%
% INPUT:     thing --> variable or char array or string to be evaluated and displayed
%                      If a char array or a string is given, the containing expression will be evaluated
%                      in the caller's workspace and the result captured.
%                      Otherwise, disp() is invoked on the object and its result is returned.
%           trimLF --> flag to indicate if last newline shall be removed [default: true]
%
% OUTPUT:    displayText --> textual output of disp(varname) or output of processed command
%                 result --> result of evaluating var_or_command   [optional]
%
% Andreas Sommer, Jun2026
% code@andreas-sommer.eu
%

% args and defaults
displayText = '';
result      = [];
if (nargin < 1), return;        end
if (nargin < 2), trimLF = true; end

% is a variable or a command given?
command_requested  = ischar(thing) || isstring(thing);
variable_requested = ~command_requested;  % init variable

% special case: requested to evaluate a variable
if command_requested
   if isvarname(thing)             % 1st check: can it be a variable name?
      varNames = evalin('caller', 'who');
      if ismember(thing, varNames) % 2nd check: is it an existing variable in the caller's workspace?
         variable_requested = true;
      end
   end
end


% helper
evalInCaller = @(x) sprintf("evalin('caller','%s')"      , x);
dispInCaller = @(x) sprintf("evalin('caller','disp(%s)')", x);

% evaluate
hotlinkState = feature('hotlinks'); % backup hotlinks state
try 
   if command_requested                   % if a command was requested
      if variable_requested                                      % if a variable is requested as command, ..
         displayText = evalc(dispInCaller(thing));               % .. then get its display by evaluating disp(thing)
         if (nargout >= 2)                                       %
              result = eval(evalInCaller(thing));                % .. and evaluate it to get its content (if requested)
         end                                                     %
      else                                                       % otherwise ..
         if (nargout >= 2)                                       %
            [displayText, result] = evalc(evalInCaller(thing));  % .. evaluate and store display and output
         else                                                    %
            displayText = evalc(evalInCaller(thing));            % .. evaluate and store display
         end
      end
   else                                   % if an object was given ..
      displayText = evalc('disp(thing)'); % .. then get its display (by evaluating it)
      result = thing;                     % .. and return its content
   end
catch ME
   feature('hotlinks', hotlinkState);  % restore hotlinks state
   rethrow(ME);
end
feature('hotlinks', hotlinkState);  % restore hotlinks state

% remove last newline (if present)
if trimLF
   try %#ok<TRYNC>
      if displayText(end) == 10
         displayText = displayText(1:end-1);
      end
   end
end


end % of function



