function value = DEBUGME(value, message)
% value = DEBUGME(value)
% value = DEBUGME(value, message)
% DEBUGME('#setmessage', messagefmt)
%
% Returns the same value but displays a debug message.
% Useful for testing/changing values and not to forget to change them back.
%
% INPUT:    value --> value to be echoed, or special value for subsequent calls
%                     #reset      --> reset to defaults
%                     #debug      --> output debug marker only
%                     #echo%g     --> output debug marker and echo the value on the screen
%                     #setmessage --> set debug message for subsequent called
%                     #printer    --> handle to printer to be used (@fprintf, @warning, etc)
%         message --> optional debug message to be displayed (passed to fprintf)
%
% OUTPUT:   value --> same as input value
%
% NOTE:   For message containing "%", value is forwarded to the printer.
%
%
% Andreas Sommer, Aug2024
% code@andreas-sommer.eu
%

persistent storedMessage storedMessageIncludesValue printer

% printer
if isempty(printer)
   printer = @warning;
end

% initialize persistent variables
if isempty(storedMessage) || isempty(storedMessageIncludesValue)
   storedMessage = 'INIT';
   storedMessageIncludesValue = false;
   DEBUGME('#reset');
end


% NO INPUT: just print storedMessage and return
if (nargin == 0)
   if storedMessageIncludesValue
      printer(storedMessage, []);
   else
      printer(storedMessage)
   end
   return;
end


% check if we got a special value
if ischar(value) && value(1)=='#'
   switch lower(value)
      case '#reset' ,   DEBUGME('#echo%g');
      case '#debug' ,   DEBUGME('#setmessage', 'DEBUG');
      case '#echo%g',   DEBUGME('#setmessage', 'DEBUGME(%g)');
      case '#printer'
         if isa(message, 'function_handle')
            printer = message;
         end
      case '#setmessage'
         storedMessage = message;
         if contains(storedMessage, '%')
            storedMessageIncludesValue = true;
         end
      otherwise
         error('Unknown special command: %s', value);
   end
   return
end


% dissect input
if (nargin < 1)
   value = [];
end
if (nargin < 2)
   message              = storedMessage;
   messageIncludesValue = storedMessageIncludesValue;
else
   messageIncludesValue = contains(message, '%');
end


% generate output
if messageIncludesValue
   printer(message, value);
else
   printer(message);
end

% value is just forwarded unchanged

end % of function
