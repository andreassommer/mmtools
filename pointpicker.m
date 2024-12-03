function varargout = pointpicker(axh, varargin)
% (1) pointpicker(axh)
% (2) pointpicker('#COMMAND', arg)
% (3) points = pointpicker('#GET')
%
% 
% (1) pointpicker(axh)
%     Registers to axis handle axh and collects clicked points.
%     Then, interaction is done via keyboard shortcuts.
%     'a' --> initiate collecting points (coordinates)
%             using crosshairs, one point per click
%     'd' --> delete the last clicked/collected point (coordinate)
%     'x' --> leave the collecting point 
%     
%     There must be no "special" mode like zooming or rotation be active,
%     otherwise a warning about WindowKeyPressFcn will be issued.
%     
% (2) pointpicker('#COMMAND', args...)
%     #COMMAND args
%     #GET     --        retrieve points, see (3)
%     #RESET   --        delete all stored points and reset pointpicker
%     #SILENT  true      disable text output during usage
%     #SILENT  false     enable text output during usage
%     #SHOW    --        display collected points
%     #SAVE    filename  store collected points to specified file
%     #DELETE  --        delete last stored point
%     #ADD     x, y      manually store point (x,y) 
%               
% (3) points = pointpicker('#GET')
%          returns the collected points as a structure with fields X and Y
%
% Andreas Sommer, Nov2024
% code@andreas-sommer.eu
% 

persistent points mode axishandle silent

% speaking variables
MODE_ADDDING  = 1;
MODE_IDLE     = 0;

% initialize persistent variable
if isempty(points), points = initPoints(); end
if isempty(mode),     mode = MODE_IDLE;    end
if isempty(silent), silent = false;        end

% reset requested?
if ~ishandle(axh)
   command = axh;  % more readable code
   try command = convertStringsToChars(command);
      switch upper(command)
         case '#RESET' ,  points = initPoints();
         case '#ADD'   ,  addPoint(varargin{1},varargin{2});
         case '#REMOVE',  removeLastPoint();
         case '#SHOW'  ,  showPoints();
         case '#SAVE'  ,  savePointsToFile(varargin{1})
         case '#SILENT',  silent = varargin{1};
         case '#GET'   ,  varargout{1} = points;
         otherwise    ,  message('Unknown command: %s', command)
      end
   catch ME
      warning('Invalid axis handle given, class is: %s', class(command));
      error('Invalid axis handle given.')
   end
   return
end

% store axis andle
axishandle = axh;

% register callbacks
fighandle = getParentFigure(axishandle);
set(fighandle, 'WindowKeyPressFcn', @cbKeypress);
message('registered to figure %d [%s]', fighandle.Number, fighandle.Name);

% finito
return

%% INTERNAL HELPERS


% callback for keypress
function cbKeypress(~, event)
   switch event.Key
      case 'a'
         if (mode == MODE_ADDDING)
            setIdleMode();
         else
            getPoints();
         end
      case 'd'
         deleteLastPoint();
   end
end

function savePointsToFile(filespec)
   mat = getMatOfPoints();
   writematrix(mat,filespec,'Delimiter','tab')
end

function showPoints()
   storedsilence = silent;  % store current silent state
   try 
      silent = false;
      message('Showing ~d stored points:', length(points.X));
      mat = getMatOfPoints();
      disp(mat);
   catch exception
      warning(exception);
   end
   silent = storedsilence;  % re-set previous value
end

function mat = getMatOfPoints()
   mat = [ reshape(points.X, [], 1) , reshape(points.Y, [], 1) ];
end

function setIdleMode()
   mode = MODE_IDLE; 
   message('Idle.');
end


function key = getPoints()
   mode = MODE_ADDDING;
   message('Choose points.');
   message('   ADD: ''a'' or left click');
   message('DELETE: ''d'' or right click');
   message('FINISH: ''x'' or ''ENTER''');
   axis(axishandle);  % activate axis
   while true   % ENTER gives empty data
      [x,y,key] = ginput(1);
      if isempty(key), key = 'x'; end
      switch key
         case {'x'}   , setIdleMode(); return;  % ONLY EXIT HERE
         case {'d', 3}, removeLastPoint();
         case {'a', 1}, addPoint(x, y);
      end
   end
end

% add point
function addPoint(x, y)
   points.X(end+1) = x;
   points.Y(end+1) = y;
   len = length(points.X);
   message('Added point ( %g , %g )   [COUNT: %d]', x, y, len);
end


% remove last point
function removeLastPoint()
   if ~isempty(points.X)
      x = points.X(end);
      y = points.Y(end);
      points.X(end) = [];
      points.Y(end) = [];
      message('Removed last point ( %g , %g )', x, y);
   else
      disp('No points stored.')
   end
end


% simple messager
function message(varargin)
   if silent, return; end
   msg = sprintf(varargin{:});
   selfname = upper(mfilename());
   fprintf('%s: %s\n', selfname, msg);
end


function points = initPoints()
   points = struct('X',[], 'Y', []);
   message('Points initialized/reset.');
end


function handle = getParentFigure(axh)
   handle = axh.Parent;
   if isempty(handle), return; end
   while ~( ishandle(handle) && strcmp(get(handle, 'type'), 'figure') )
      handle = handle.Parent;
   end
end

end % of function

