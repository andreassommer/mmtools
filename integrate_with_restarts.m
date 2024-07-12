function varargout = integrate_with_restarts(solORsolver, odefun, tspan, y0, varargin)
% sol = integrate_with_restarts(solORsolver, odefun, tspan, y0, varargin)
% [T,Y,Tr,sol] = integrate_with_restarts(solORsolver, odefun, tspan, y0, varargin)
% [T,Y,TE,YE,IE,Tr,sol] = integrate_with_restarts(solORsolver, odefun, tspan, y0, varargin)
%
% Uses the specified to integrate a function.
% If the integrator is stopped in between (e.g. by an event function),
% the integration is continued at the current point.
%
% INPUT: solORsolver --> (a) handle to ode-solver (e.g. @ode45)
%                            will be called as odesolver(odefun, tspan, y0, options)
%                        (b) a sol object from a previous solution 
%                            that shall be continued
%             odefun --> rhs function of ode
%              tspan --> (a) if a handle to an ode-solver is given, then tspan = [t0 tf]
%                        (b) if a sol object is given, tspan may also just specify tf
%                 y0 --> initial value (state)
%           varargin --> additional arguments as key-value-pairs as below
%
% Optional input arguments passed as key-value-pairs:
%      solveroptions --> Cell array of arguments passed to the odesolver
%     stateupdatefun --> Function that may update the states at each stop,
%                        and is of form newstate = updfun(t,y,sol),
%                        see below for details.
%     modelupdatefun --> Function delivering new right hand sides at each stop
%             cadlag --> Flag indicating wether the output shall be made cadlag,
%                        (continue a droite, limite a gauche) by shifting the end
%                        of each interval is shifted by an epsilon to the left.
%                        NOTE: This allows easy usage of "interp" and "deval".
%     diagnosticmode --> Flag to set the diagnostic mode
%
% OUTPUT:    T --> vector of times
%            Y --> matrix of results as from odesolver
%           TE --> event times of integator
%           YE --> event states of integrator
%           IE --> event indices of integrator
%           Tr --> time points of integrator restarts
%          sol --> solution structure of integrator additional fields
%                  .restarts  (= Tr = time points of restars)
%                  .intervals (number of integration intervals)
%
%
% State Update Function:
%    The function is of form newstate = stateUpdFun(t,y,sol) where
%         t --> current time
%         y --> current state
%       sol --> current solution structure ('sol' from odesolver or odextend)
%
% Model Update Function:
%    The function is of form newrhs = modelUpdateFunction(t,y,sol)
%    With same arguments as the state update function and delivering
%    a funtion handle newrhs that will be used as right hand side on the
%    next integration interval.
%
%
% (c) Andreas Sommer, Nov2016, Feb2017, Jun2017
% andreas.sommer@iwr.uni-heidelberg.de
% code@andreas-sommer.eu
%

% Changelog
% Nov2016 -- Initial version, state updates only
% Feb2017 -- Output of sol-objects, added model updates
% Jun2017 -- Input of sol-objects

% NOTES:
%   * If an event function signals a terminal event, matlab *always* adds the
%     terminal time and terminal state to the result vector. This happens also
%     if that time point was not specifically requested in tspan.





% ===========================
% PROCESSING ARGUMENTS

% set defaults
stateupdatefun = [];
modelupdatefun = [];
cadlag         = false;
solveroptions  = {};
diagnosticMode = true;  % DEBUG

% deprecated arguments (for backward compatibility
if hasOption(varargin, 'updatefunction')
   warning('Deprecated argument "updatefunction", use "stateupdatefun" instead!')
   stateupdatefun = getOption(varargin, 'updatefunction');
end
if hasOption(varargin, 'interpolatable')
   warning('Deprecated argument "interpolatable", use "cadlag" instead!')
   cadlag = getOption(varargin, 'interpolatable');
end

% process optional arguments
if hasOption(varargin, 'diagnosticmode'), diagnosticMode = getOption(varargin, 'diagnosticmode'); end
if hasOption(varargin, 'stateupdatefun'), stateupdatefun = getOption(varargin, 'stateupdatefun'); end
if hasOption(varargin, 'modelupdatefun'), modelupdatefun = getOption(varargin, 'modelupdatefun'); end
if hasOption(varargin, 'solveroptions'),  solveroptions  = getOption(varargin, 'solveroptions');  end
if hasOption(varargin, 'cadlag'),         cadlag         = getOption(varargin, 'cadlag');         end

% if solveroptions is not a cell array, wrap it
if ~iscell(solveroptions)
   solveroptions = {solveroptions};
end

% error checks on number of output arguments:
if nargout==0, warning('No output args specified. Delivering sol structure.'), end
if nargout >7, warning('Too many output args specified! Trying my best...'), end

% if a sol-object was given, ensure tspan has the correct layout of [t0 ... tf]
if ~isa(solORsolver, 'function_handle')
   tspan = [solORsolver.x(end) tspan(end)]; 
end

% END OF PROCESSING ARGUMENTS
% ===========================






% ===========================
% PREPARE INTEGRATION

% extract start and end time
t0 = tspan(1);
tf = tspan(end);

% prepare result variables
restarts = cell(1);
rhsfuncs = cell(1);

% set current state
currentTime  = t0;
currentState = y0;

% prepare integration
diagmsg('Starting integration ...\n', t0, tf);
intvl = 1;   % loop counter
ticID = tic; % start timer



% ===========================
% FIRST INTEGRATION INTERVAL - IF NO SOL OBJECT IS GIVEN AS INPUT

if isa(solORsolver, 'function_handle')
   % ODESOLVER was given
   diagmsg('Using specified integrator @%s on interval [%g, %g]\n', func2str(solORsolver), t0, tf);
   diagmsg('\nStart of Interval: #%d  @ time: %18.18g\n', intvl, currentTime);
   sol = solORsolver(odefun, [currentTime tf], currentState, solveroptions{:});
   restarts{intvl} = currentTime;
   rhsfuncs{intvl} = odefun;
   % add additional information to sol
   sol.rhsfuncs  = rhsfuncs;
   sol.restarts  = cell2mat(restarts);
   sol.intervals = intvl;
else
   % SOL-OBJECT was given (possibly returned from a previous call to iwr)
   sol = solORsolver;
   diagmsg('Extending given solution generated by @%s on interval [%g, %g]\n', sol.solver, t0, tf);
   intvl    = sol.intervals;
   restarts = num2cell(sol.restarts);  % use cell arrays, as they grow
   rhsfuncs = sol.rhsfuncs;
end


% ===========================
% EXTRACT INFO FROM SOL OBJECT

% store current time and state
currentTime  = sol.x(end);
currentState = sol.y(:,end);
restartTimeIndex = length(sol.x);



% ===========================
% INTEGRATION LOOP

while (currentTime < tf) 

   % iterate
   intvl = intvl + 1;
   diagmsg('\nStart of Interval: #%d  @ time: %18.18g\n', intvl, currentTime);

   % update the initial state for the next interval
   if ~isempty(stateupdatefun)
      diagmsg('Updating state...');
      currentState = stateupdatefun(currentTime, currentState, sol);
      diagmsg('State update done!\n');
   end

   % update the model for the next interval
   if ~isempty(modelupdatefun)
      diagmsg('Updating model...');
      odefun = modelupdatefun(currentTime, currentState, sol);
      diagmsg('Model update done! New model: @%s\n', func2str(odefun));
   end

   % store current integration (re-)start time
   restarts{intvl} = currentTime;
   rhsfuncs{intvl} = odefun;
   
   % extend current solution and adjust sol structure
   sol = odextend(sol, odefun, tf, currentState);  % NOT CHANGED!, solveroptions{:});

   % possibly adjust solution for being cadlag
   if cadlag
      sol.x(restartTimeIndex) = sol.x(restartTimeIndex) - eps(sol.x(restartTimeIndex));
   end

   % add additional information to sol
   sol.rhsfuncs = rhsfuncs;
   sol.restarts = cell2mat(restarts);
   sol.intervals = intvl;
   
   % Update and store current time and state
   currentTime  = sol.x(end);
   currentState = sol.y(:,end);
   restartTimeIndex = length(sol.x);
   
end
% stop timer
elapsedTime = toc(ticID);



% ===========================
% ADJUSTMENTS


% some statistics
diagmsg('\nIntegration took %g seconds\n', elapsedTime);
diagmsg('Number of restarts: %d\n', intvl);


% NOT NEEDED ANYMORE --> ALREADY DONE IN INTEGRATION LOOP
% make interpolatable function if requested (ensures strong monotonic time)
% NOTE: This makes the function cadlag 
%if cadlag
%   idx = ismember(sol.x, restarts(2:end));     % find restart times
%   idx = find(idx);                            % get the linear indices
%   idx = idx(2:2:end);                         % indices of new interval starts
%   sol.x(idx) = sol.x(idx) + eps(sol.x(idx));  % adjust the respective entries
%end



% ===========================
% OUTPUT ASSEMBLY


% Assemble output arguments as requested by user
if (nargout==0) % no output args: warn and return sol structure
   warning('No output args specified. Delivering sol structure.')
   varargout{1} = sol;
end
if (nargout == 1) % return sol structure
   varargout{1} = sol;
end
if (nargout >= 2) % requested: T, Y, [Tr]
   if length(tspan)==2
      varargout{1} = sol.x;   % if onty t0 and tf specified, 
      varargout{2} = sol.y;   % return the steps as determined by solver
   else
      varargout{1} = tspan;   % otherwise return tspan and 
      varargout{2} = deval(sol,tspan); % interpolate at requested times
   end
   varargout{3} = cell2mat(restarts);
end
if (nargout >=4 ) % requested: T, Y, TE, YE, IE, [Tr}
   varargout{3} = sol.xe;
   varargout{4} = sol.ye;
   varargout{5} = sol.ie;
   varargout{6} = cell2mat(restarts);
end

% Too manx output arguments?
maxnargout = 6;
if (nargout > maxnargout)
   warning('Invalid number of output arguments: %d (max: %d)!', nargout, maxnargout);
end



% FINITO
return


% ===========================================================
% ===========================================================



% === HELPERS ===
   function diagmsg(messagestr, varargin)
      if diagnosticMode
         fprintf(messagestr, varargin{:}) %#ok<PRTCAL>
      end
   end


% end of main function
end

