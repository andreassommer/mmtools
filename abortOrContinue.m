function answer = abortOrContinue(infoMsg, abortMsg, continueMsg, defaultAction, warnID)
% abortOrContinue(infoMsg)
% abortOrContinue(infoMsg, abortMsg, continueMsg)
% abortOrContinue(infoMsg, abortMsg, continueMsg, defaultAction)
% abortOrContinue(infoMsg, abortMsg, continueMsg, defaultAction, warnID)
% answer = abortOrContinue(___)
%
% Displays a warning and asks user to continue or not.
%
% INPUT:    infoMsg --> info message to be displayed (as warning if warnID is given)
%          abortMsg --> text for abort                               [default: 'ABORT!'  ]
%       continueMsg --> text for continue                            [default: 'Continue']
%     defaultAction --> 'abort' for abort, 'continue' for continue   [default: 'abort'   ]
%            warnID --> infoMsg will be displayed as warning with this ID
%
% OUTPUT:  [answer] --> user choice 1 (abort) or 0 (continue) -- IMPORTANT: see notes below!
%
% Notes: 
%   - If answer is not queried, then program an error is thrown to stop program execution.
%   - If warnID is specified, the info text will be output as warning
%   - The abortMsg is always displayed first
%   - The default choice is capitalized
%   - Giving an argument as [] takes the default
%
% Andreas Sommer, Nov2024
% code@andreas-sommer.eu
%

% default inputs
if (nargin < 1),        infoMsg = ('Abort or Continue?'); end
if (nargin < 2),       abortMsg = 'ABORT!'              ; end
if (nargin < 3),    continueMsg = 'Continue'            ; end
if (nargin < 4),  defaultAction = 'abort'               ; end
if (nargin < 5),         warnID = ''                    ; end

% check if result is requested
errorOnAbort = (nargout == 0);

% speaking variables -- must be 1 or 2 for "userchoice" below !
ABORT    = 1;
CONTINUE = 2;

% check default
switch lower(defaultAction)
   case 'abort',                defaultAction = ABORT;
   case {'continue', 'cont'},   defaultAction = CONTINUE;
   otherwise
      warnID = 'askAbortOrContinue:invalid_default';
      warning(warnID, 'Invalid default value specified. Using "Abort" as default');
      defaultAction = ABORT;
end

% BELOW HERE, defaultAction IS A NUMBER

% issue warning or info text?
if isempty(warnID)
   disp(infoMsg)
else
   warning(warnID, infoMsg);
end

% capitalize default
if (defaultAction == ABORT)
   abortMsg = upper(abortMsg);
   defaultChoice = 1;
else
   continueMsg = upper(continueMsg); 
   defaultChoice = 2;
end

% ask what to do
answer = userchoice({abortMsg, continueMsg}, defaultChoice);

% do what to do
if answer == ABORT
   if errorOnAbort
      error('No error! Abort due to user request!');
   end
end

end % of function
