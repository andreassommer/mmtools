function value = DEBUGME(varargin)
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
%         message --> optional debug message to be displayed (passed to fprintf)
%
% OUTPUT:   value --> same as input value
%
% NOTE:   if message containts a "%", then the value is forwarded to fprintf.
%
%
% Andreas Sommer, Aug2024
% code@andreas-sommer.eu
%

persistent default_message default_includevalueinmessage

% initialize persistent variables
if isempty(default_message) || isempty(default_includevalueinmessage)
   default_message = 'INIT';
   default_includevalueinmessage = false;
   DEBUGME('#reset');
   value = DEBUGME(varargin{:}); % replay command
   return
end

% NO INPUT: just print marker
if (nargin == 0)
   if default_includevalueinmessage
      fprintf(default_message, nan());
   else
      fprintf(default_message)
   end
   return;
end

% set defaults
message               = default_message;
includevalueinmessage = default_includevalueinmessage;

% dissect input
if (nargin >= 1)
   value = varargin{1};
end
if (nargin >= 2)
   message = varargin{2};
   includevalueinmessage = contains(message, '%');
end


% check if we got a special value
if ischar(value) && value(1)=='#'
   switch lower(value)
      case '#reset' ,   DEBUGME('#echo%g');
      case '#debug' ,   DEBUGME('#setmessage', 'DEBUG');
      case '#echo%g',   DEBUGME('#setmessage', 'DEBUGME(%g)');
      case '#setmessage'
         default_message = message;
         if contains(default_message, '%')
            default_includevalueinmessage = true;
         end
      otherwise
         error('Unknown special command: %s', value);
   end
   return
end


% generate output
if includevalueinmessage
   fprintf(message, value);
else
   fprintf(message);
end

% value is just forwarded unchanged

end % of function
