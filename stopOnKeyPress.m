function stop = stopOnKeyPress(stopChar, message_or_percentage)
% stopOnKeyPress(stopChar, message)
% stopOnKeyPress(stopChar, percentage)
% stopflag = stopOnKeyPress();
%
% Opens a figure, displays a message or a percentage value and a stop button.
% Also reacts on keypress.
%
% INPUT:    stopChar --> Character when the current process shall be stopped
%                        If stopChar == 'close', the figure will be closed
%                        If stopChar == [] (empty), the message can be updated without changing the stopChar
%            message --> Message to be displayed in the figure
%         percentage --> Alternatively to the message, a percentage is displayed.
%                        If percentage is in [0,1], the fraction is displayed as % with up to 2 digits.
%                        If percentage is > 1, then it is displayed using the %g format specifier.
%
% OUTPUT: none
%
% To query for a stopping condition, call stopOnKeyPress without arguments:
%
% stopOnKeyPress('#', 'Working...');    % open stop figure
% for i = 1:100
%   ... do some work ...
%   if stopOnKeyPress()                 % alternative with update:  if stopOnKeyPress('', percentage)
%      fprintf('Stopped!'); 
%      break;
%   end
% end
%
%
%
% Andreas Sommer, Aug2025
% code@andreas-sommer.eu
%

persistent i_stopFlag i_stopChar h_figure h_label h_button

% Initialize stopFlag
if isempty(i_stopFlag), i_stopFlag = false; end

% Quick return: If no arguments are given, immediate return
stop = i_stopFlag;
if (nargin == 0) || i_stopFlag && (nargin == 2) && isempty(stopChar), return, end

% Ensure we have a char array, not strings
stopChar = convertStringsToChars(stopChar);

% Empty stop char given? Okay if a stop figure is open (message update)
if isempty(stopChar)
   if isValidFigureHandle(h_figure)
      stopChar = i_stopChar;
   end
end

% Ensure that stop char is a single character
if ischar(stopChar) && ~isempty(stopChar)
   % check if user requested "close"
   if strcmpi(stopChar, 'close')
      stop = stopAndCloseFigure();
      return
   end
   % extract first character as stop character
   stopChar = stopChar(1);
else
   error('Invalid stop char. Expeced a nonempty char.');
end

% store stop char
i_stopChar = stopChar;

% If a percentage is given, transform it into a message
if (nargin >= 2)
   if isempty(message_or_percentage)
      message = '';
   elseif isnumeric(message_or_percentage)
      value = message_or_percentage;
      if (value >= 0 && value <=1)
         message = sprintf('%.2f%% done', 100 * value);
      else
         message = sprintf('%g done', value);
      end
   else
      message = message_or_percentage;
   end
else % no message given
   message = sprintf('Press %c to stop', stopChar); 
end

% Create or update figure
if ~isValidFigureHandle(h_figure)
   % If we do not have a figure yet, create a figure for key press detection under the mouse
   i_stopFlag = false;
   mousePos  = get(groot(), 'PointerLocation');
   figHeight = 100;
   figWidth  = 200;
   figPos    = [mousePos(1) - figHeight/2, mousePos(2) + 1.5*figHeight, figWidth, figHeight];
   h_figure  = figure('KeyPressFcn', @keyPressCallback, 'Position', figPos, 'WindowStyle', 'alwaysontop', ...
                      'DeleteFcn', @deleteFigureCallback);
   % remove specific parts of the figure (test if property exists, as not all matlab versions know all propertiers)
   if isprop(h_figure, 'Toolbar'), set(h_figure, 'Toolbar', 'none'); end
   if isprop(h_figure, 'Menubar'), set(h_figure, 'Menubar', 'none'); end
   % make and position the label and the stop button
   h_label   = uilabel(h_figure, 'Text', message, 'HorizontalAlignment', 'center', ...
                                 'Position', [0, figPos(4)/2, figPos(3)  , figPos(4)/2]);
   stopLabel = sprintf('STOP: %c', stopChar);
   h_button  = uibutton(h_figure, 'Text', stopLabel, 'ButtonPushedFcn', @stopButtonCallback, ...
                                  'Position', [figPos(3)/4, 0, figPos(3)/2, figPos(4)/2]);
else
   % update label
   set(h_label, 'Text', message);
end

% finito
stop = i_stopFlag;
return


%% INTERHAL HELPERS

% Callback of figure
function keyPressCallback(~, event)
   if strcmp(event.Character, stopChar)
      stopAndCloseFigure();
   end
end

function stopButtonCallback(~, ~)
   stopAndCloseFigure();
end

function deleteFigureCallback(~, ~)
   i_stopFlag = true;
end

function stop = stopAndCloseFigure()
   if isValidFigureHandle(h_figure)
      close(h_figure)
   end
   i_stopFlag = true;
   i_stopChar = [];
   h_figure   = [];
   h_label    = [];
   stop = i_stopFlag;
end

function tf = isValidFigureHandle(h)
   tf = ~isempty(h) && isgraphics(h, 'figure');
end



end