function [result, optinfo] = pwlinfit(xdata, ydata, varargin)
% NOTE:  This function is not yet in fully functional form.
%
% [result, optinfo] = pwlinfit(x, y, ...)
% [result, optinfo] = pwlinfit(x, y, n, ...)
%
% Best fit of a continuous piecewise linear function consisting of n pieces
% to a given function or point cloud y
%
% INPUT:    x --> x values    [UPCOMING: evaluation points or span/interval]
%           y --> y values    [UPCOMING: function ]
%           n --> number of linear pieces (can alternatively be given as key-value-argument 'n')
%         ... --> key-value-pairs
%                        'n' --> number of linear pieces
%                    'knots' --> initial grid of x points (equidistant if not specified)
%                  'mindist' --> minimum distance of x knots
%                'optimizer' --> can be 'lsqnonlin' (requires optimization toolbox)
%                'optimopts' --> optimopts structure passed to the optimizer
%                 'optimize' --> value one of 'x', 'y', 'both'    [ UPCOMING -- not yet implemented   ]
%               'continuous' --> true or false                    [ UPCOMING -- currently always true ]
%
% OUTPUT:   result --> structure with fields:
%                      xknots --> x values of piecewise linear approximation
%                      yknots --> y values associated to x values
%          optinfo --> optimization info (e.g. output from lsqnonlin)
%
% Andreas Sommer, Sep2024, Sep2025
% code@andreas-sommer.eu
%


% possible ideas:
% piecewise linear fit
% (a) not continuous
% (b) continuous
%
% Possible approaches
% 1) fit all at once in single fiting problem (then nonlinear)
% 2) make linear fits on intervals, possibily adding continuity as constraint

% possible extensions (tbd):
% if y is function, evaluate it
% 1. Fall: x und y sind Punktwolken
% 2. Fall: y is fhandle


% check if number of linear pieces is specifed (required argument)
args = varargin;
if ~isempty(args) && isnumeric(args{1})  % user specified n directly, add it to the argument list
   args = ['n', args];
end

% calculate a default xmindist
default_mindist = @() 1e-10 * (xdata(end)-xdata(1));

% process args - olGetOption returns in args the remaining arguments
[n           , args] = olGetOption(args, 'n'           , []         );
[xknots      , args] = olGetOption(args, 'knots'       , []         );
[mindist     , args] = olGetOption(args, 'mindist'     , default_mindist, true);  % evaluate by formula if not given
[optimizer   , args] = olGetOption(args, 'optimizer'   , 'lsqnonlin');
[optimopts   , args] = olGetOption(args, 'optimopts'   , {}         );
[yscale      , args] = olGetOption(args, '#yscale'     , []         );            % undocumented experimental
[makefeasible, args] = olGetOption(args, 'makefeasible', false      );            % !! TO BE DONE !!

% check all args processed
if ~isempty(args)
   warning('PWLINFIT:UNKNOWN_ARGS', 'Ignoring unknown arguments: %s', sprintf('%s ', args{1:2:end}));
end

% no n specified? error!
if ~isnumeric(n) || isempty(n) || (n <= 0)
   error('Number of pieces "n" must be specified!');
end

% if no initial grid specified, use equidistantly sampled xdata
if isempty(xknots)
   xknots = linspace(xdata(1), xdata(end), n+1);
end

% if x is a 2-point vector, fill it with 
if length(xknots) == 2
   xknots = linspace(xknots(1), xknots(end), n+1);
end

% ensure n (number of linear pieces) fits to number of knots 
if (n ~= length(xknots)-1)
   error('Number of knots (%d) does not fit to "n" (%d)', length(xknots), n);
end

% if y is a function, store the handle separately
yfun = [];
if isa(ydata, 'function_handle')
   yfun = ydata;
   ydata = yfun(xknots);  %% Should have a flag if yfun can handle vectors or must be evaluated using arrayfun
end

% ensure data range is inside knot range
if (xdata(1) < xknots(1)) || (xdata(end) > xknots(end))
   warning('PWLINFIT:DATA_OUTSIDE_KNOTS', 'xdata range [%g %g] exceeds knot range [%g %g]', ...
      xdata(1), xdata(end), xknots(1), xknots(end));
end

% initial guess for y values at the knots
if isempty(yfun)
   yknots = interp1(xdata, ydata, xknots);
else
   yknots = yfun(xknots);
end

% ensure optmizer is a char array
if isa(optimizer, 'function_handle')
   optimizer = func2str(optimizer);
end

% ensure that the initial node distribution is feasible - we should not just map on lower bounds
if makefeasible && ~all( diff(xknots) >= mindist )
   error('not yet implemented');
   newknots = make_feasible(xknots, mindist);
   if ~isempty(newknots)
      xknots = newknots;
   end
end


% select optimizer
switch lower(optimizer)

   case 'lsqnonlin'

      % Ensure that xknots is always monotonically increasing knot vector
      % by using non-negative "increments" as optimization variables
      % Then:  xknot = xmin + cumsum(increments)
      xinc = diff(xknots(1:end-1));   % then xinc >= 0 and xknot = xknot(1) + xinc;
      z0 = [xinc, yknots];
      h  = xknots(end)-xknots(1);
      lb = [ mindist + zeros(numel(xinc), 1)  ; -inf(numel(yknots), 1)  ];
      ub = [        h * ones(numel(xinc), 1)  ; +inf(numel(yknots), 1)  ];
      fun = @minFunXY;
      opts = optimoptions(@lsqnonlin ...
         , 'Algorithm'        , 'levenberg-marquardt'  ...
         , 'Display'          , 'iter'                 ...
         , 'UseParallel'      , false                  ...
         , 'FunctionTolerance', 1e-4                   ...
         , optimopts{:});
      % x = lsqnonlin(fun, x0, lb, ub, opts);
      [z,resnorm,residual,exitflag,output] = lsqnonlin(fun, z0, lb, ub, opts);
      optinfo = struct('x', z, 'resnorm', resnorm, 'residual', residual, 'exitflag', exitflag, 'output', output);

   case 'fminsearch'
      % fminsearch is an unconstrained optimizer, so we have to use a penalty approach
      % scaling for nelder-mead
      [xscale, xrange] = get_scale_and_range(xdata);
      [yscale, yrange] = get_scale_and_range(ydata, yscale);      % take yscale from input
      [xdata  , org_xdata  ] = scale_data(xdata  , xscale, xrange);
      [ydata  , org_ydata  ] = scale_data(ydata  , yscale, yrange);
      [xknots , org_xknots ] = scale_data(xknots , xscale, xrange);
      [yknots , org_yknots ] = scale_data(yknots , yscale, yrange);
      [mindist, org_mindist] = scale_data(mindist, xscale, xrange);
      xinc = diff(xknots(1:end-1));   % then xinc >= 0 and xknot = xknot(1) + xinc; -- fixes first and last node
      z0 = [xinc, yknots];
      minFunXYpenalized(0);  % init call counter
      fun = @minFunXYpenalized;
      opts = optimset( optimset('fminsearch') ...
                       , 'display', 'final' ...
                       , 'MaxFunEvals', 1000 * length(z0) ...
                       , 'MaxIter'    , 1000 * length(z0) ...
                       );
      if ~isempty(optimopts), opts = optimset(opts, optimopts); end  % update options from user input
      [z,fval,exitflag,output] = fminsearch(fun,z0,opts);            % invoke optimizer      
      % undo scaling
      z(1:length(xknots)-2)   = unscale_data(z(1:length(xknots)-2)  , xscale, xrange);
      z(length(xknots)-1:end) = unscale_data(z(length(xknots)-1:end), yscale, yrange);
      xdata   = org_xdata;
      ydata   = org_ydata;
      xknots  = org_xknots; 
      yknots  = org_xknots; % yknots is not used (it is recalculated from x and konts)
      mindist = org_mindist; 
 

   otherwise
      error('Unknown optimizer: %s', func2str(optimizer));

end


% assemble output
[xknots, yknots] = getKnots(z, xknots);
result.xknots = xknots;
result.yknots = yknots;

% figure(555); clf; hold on; plot(xknot, yknot, 'r.', 'MarkerSize', 10); plot(datax, datay, 'g.', 'MarkerSize', 2);

% finito
return


%% INTERNAL HELPERS

function [x, y] = dissectXY(z, nkx)
   x = z(     1 : nkx );
   y = z( nkx+1 : end );
end

function [kx, ky] = getKnots(z, kx)
   [xincr, ky] = dissectXY(z, length(kx)-2);  % first and last x knot is fixed
   kx = [kx(1) , kx(1) + cumsum(xincr) , kx(end)];
end

function rv = minFunXY(z)
   [kx, ky] = getKnots(z, xknots);          % split z into inc_x and knot_y part
   rv = calcResVec(kx, ky, xdata, ydata);  % get the residual vector
end

function fval = minFunXYpenalized(z)
   persistent nn                                    % call counter
   if isscalar(z) && (z==0), nn = 0; return, end    % init call counter
   nn = nn + 1;                                     % step call counter
   [kx, ky] = getKnots(z, xknots);               % split z into inc_x and knot_y part
   n_incs = (length(xknots)-2);                  % number of increments (knot variables)
   incs   = z(1:n_incs);                        % increments (knot variables)
   % rv = calcResVec(kx, ky, xdata, ydata);       % get the residual vector
   % rn = norm(rv);                               % residual norm
   rn = calcResValue(kx, ky, xdata, ydata);       % get the residual vector
   penalty = 0;                                 % initialize penalty
   if any(incs < mindist)
      penalty = sum( max(0, mindist - incs).^2 );  % penalty when approaching mindist
   end
   fval = rn + penalty;
   if ~mod(nn, 1000), fprintf('Iteration #%3d:  fval = %10.6g  (%10.6g +  %10.6g penalty) \n', nn/1000, fval, rn, penalty); end
end



end % of function



%% HELPERS

% get range of data values and scaling for them
function [scale, range] = get_scale_and_range(data, scaleIN)
   if (nargin <= 1), scaleIN = []; end
   mindata = min(data);
   maxdata = max(data);
   if mindata >= 0
      if isempty(scaleIN), scale = [ 0  1]; else, scale = scaleIN; end
      range = [mindata maxdata];
   else
      if isempty(scaleIN), scale = [-1 +1]; else, scale = scaleIN; end
      range = [-1 +1] * max(abs(data)); 
   end
end

function [scaleddata, orgdata] = scale_data(data, scale, range)
   orgdata = data;
   scaleddata = rescale(data, scale(1), scale(2), 'InputMin', range(1), 'InputMax', range(2));
end

function [scaleddata, orgdata] = unscale_data(data, scale, range)
   orgdata = data;
   scaleddata = rescale(data, range(1), range(2), 'InputMin', scale(1), 'InputMax', scale(2));
end



function resval = calcResValue(knot_x, knot_y, data_x, data_y)
   resval = 0;
   ki = 2;
   xl = knot_x(ki-1); % current  left x knot value
   xr = knot_x(ki);   % current right x knot value
   yr = knot_y(ki-1); % current right y knot value
   for i = 1:length(data_x)
      x = data_x(i);
      % step forward the current interval if needed
      if (x > xr)
         ki = ki + 1;
         xl = xr;
         xr = knot_x(ki);
      end
      yl = knot_y(ki-1);
      yr = knot_y(ki);
      resval = resval + abs( data_y(i) - ( yl + (yr - yl) / (xr - xl) * (x - xl) ) );
   end
end

% Faster in profiler, but much slower when compiled
function resvec = calcResVecXX(knot_x, knot_y, data_x, data_y)
   resvec = zeros(size(data_x));
   % first retrieve the entry points, so we can then vectorize on individual intervals
   next_knot_idx = 2;
   next_knot_val = knot_x(next_knot_idx);
   dl = 1;  % data left idx
   for i = 1:length(data_x)
      if data_x(i) > next_knot_val
         yl = knot_y(next_knot_idx-1);   yr = knot_y(next_knot_idx);
         xl = knot_x(next_knot_idx-1);   xr = knot_x(next_knot_idx);
         idx = dl:i;
         resvec(idx) = data_y(idx) - ( yl + (yr - yl) / (xr - xl) * (data_x(idx) - xl) );
         dl = i+1;
         next_knot_idx = next_knot_idx + 1;
         next_knot_val = knot_x(next_knot_idx);
      end
   end
   % last interval
   yl = knot_y(next_knot_idx-1);   yr = knot_y(next_knot_idx);
   xl = knot_x(next_knot_idx-1);   xr = knot_x(next_knot_idx);
   idx = dl:length(data_x);
   resvec(idx) = data_y(idx) - ( yl + (yr - yl) / (xr - xl) * (data_x(idx) - xl) );
end



%%% -- CALCULATE RESIDUAL VECTOR
function resvec = calcResVec(knot_x, knot_y, data_x, data_y)
   resvec = zeros(size(data_x));
   % walk through data, step the current knots forward when needed
   ki = 2;
   xl = knot_x(ki-1); % current left x knot
   xr = knot_x(ki);   % current right x knot
   for i = 1:length(data_x)
      x = data_x(i);
      % step forward the current interval if needed
      if (x > xr)
         ki = ki + 1;
         xl = xr;
         xr = knot_x(ki);
      end
      % determine y value at current x
      %          y(x_i) - y(x_i-1)
      %  y(x) = ------------------- * (x - x_i-) + y(x_i-)  for x in [x_i-1  x_i]
      %            x_i  -  x_i-1
      yl = knot_y(ki-1);
      yr = knot_y(ki);
      y  = yl + (yr - yl) / (xr - xl) * (x - xl);
      % set residual
      resvec(i) = data_y(i) - y;
   end
end

%%% -- CONDENSED VERSION OF calcResVec -- little bit slower
% function resvec = calcResVec2(knot_x, knot_y, data_x, data_y)
%    resvec = zeros(size(data_x));
%    ki = 2;
%    for i = 1:length(data_x)
%       if (data_x(i) > knot_x(ki))
%          ki = ki + 1;
%       end
%       % set residual
%       resvec(i) = data_y(i) - ( knot_y(ki-1) + (knot_y(ki) - knot_y(ki-1)) / (knot_x(ki) - knot_x(ki-1)) * (data_x(i) - knot_x(ki-1)) );
%    end
% end


%%% --- TO BE DONE ---
% function newnodes = make_feasible_heuristic(nodes, mindist)
% 
%    idx_infeasible = find(diff(nodes) < mindist);
%    for i = 1:
% 
% end



%%% --- THIS HAS TO BE CHECKED -- probably not functional
% % since variables are the increments, default mapping on minimum is not valid!
% % we formulate an lp with "movements" as variables (split in move-left and move-right non-negative variables)
% function newnodes = make_feasible(nodes, mindist)
% 
%    n = numel(nodes); % number of nodes
%    m = n - 2;        % number of movable nodes (first and last not moveable)
% 
%    % movement s_i described as difference  s_i+ - s_i- ==> (move right) - (move left)  ==> in total 2*m variables
%    f = [ones(m,1); ones(m,1)];   % minimize sum (s_i+ + s_i-)
% 
%    % Distances between neighbouring points -- idea to form the matrices (sparse!)
%    % for i = 1:n-1
%    %    if i == 1             % at start, only x_2 movable
%    %       A(i, 1)   = -1;   % -s_i^+
%    %       A(i, m+1) = 1;    % +s_i^-
%    %    elseif i == n-1       % at end, only x_(n-1) movable
%    %       A(i, m)   = 1;    % +s_i^+
%    %       A(i, m+m) = -1;   % -s_i^-
%    %    else                    % inner points all movable
%    %       A(i, i-1)   = 1;    % +s_i^+
%    %       A(i, m+i-1) = -1;   % -s_i^-
%    %       A(i, i)     = -1;   % -s_(i+1)^+
%    %       A(i, m+i)   = 1;    % +s_(i+1)^-
%    %    end
%    %    b(i) = (x_orig(i+1) - x_orig(i)) - z;
%    % end
% 
%    % Sparse direct creation
%    A = spdiags([+1 -1], -1:0, n-1, n-2);
%    A = [A -A];
%    b = nodes(2:n) - nodes(1:n-1) - mindist;
% 
%    % Constaints: s^+ >= 0, s^- >= 0
%    lb = zeros(2*m,1);
%    ub = [];
% 
%    % Call optimizer
%    options = optimoptions('linprog','Display','none');
%    [s_opt, ~, exitflag] = linprog(f, A, b, [], [], lb, ub, options);
%    if exitflag ~= 1
%       warning('Cannot solve infeasibility in initial guess.');
%       newnodes = [];
%       return
%    end
% 
%    % Calculate new nodes
%    s = s_opt(1:m) - s_opt(m+1:end);
%    newnodes        = nodes;
%    newnodes(2:n-1) = nodes(2:n-1) + s';
% 
% end



% function z = ppLinVal(x, y, xq)
%    %          f(x_i+1) - f(x_i)
%    %  g(x) = ------------------- * (x - x_i) + f(x_i)  for x in [x_i  x_i+1]
%    %            x_i+1  -  x_i
%    %
%    % x contains the x_i
%    % y contains the f(x_i)
%    % xq contains the query points (must be monotonic increasing)
%    %
%    LO = 1;               % lower index limit of xq belonging to current interval
%    z  = zeros(size(xq)); % prepare output array
%    xqlen = length(xq);
%    % walk through intervals in x
%    for i = 1:length(x)-1
%       xi = x(i);   xip1 = x(i+1);
%       yi = y(i);   yip1 = y(i+1);
%       UP = findFirstGreater(xq, xip1, LO, xqlen+1) - 1;
%       z(LO:UP) = (yip1 - yi) / (xip1 - xi) * (xq(LO:UP) - xi) + yi;
%       LO = UP + 1;
%       if (UP == xqlen), break, end  % all query points done
%    end
% end
% 
% 
% % OLD VERSION -- takes 100% more runtime
% function resvec = calcResvec_old(knot_x, knot_y, data_x, data_y)
%    % calculate residual to linear fit (regression)
%    y = ppLinVal(knot_x, knot_y, data_x);
%    resvec = data_y - y;
% end