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
[n        , args] = olGetOption(args, 'n'        , []);
[knots    , args] = olGetOption(args, 'knots'    , []);
[mindist  , args] = olGetOption(args, 'mindist'  , default_mindist, true);  % evaluate by formula if not given
[optimizer, args] = olGetOption(args, 'optimizer', 'lsqnonlin');
[optimopts, args] = olGetOption(args, 'optimopts', {});

% check all args processed
if ~isempty(args)
   warning('PWLINFIT:UNKNOWN_ARGS', 'Ignoring unknown arguments: %s', sprintf('%s ', args{1:2:end}));
end

% no n specified? error!
if ~isnumeric(n) || isempty(n) || (n <= 0)
   error('Number of pieces "n" must be specified!');
end

% if no initial grid specified, use equidistantly sampled xdata
if isempty(knots)
   knots = linspace(xdata(1), xdata(end), n+1);
end

% if x is a 2-point vector, fill it with 
if length(knots) == 2
   knots = linspace(knots(1), knots(end), n+1);
end

% if y is a function, store the handle separately
yfun = [];
if isa(ydata, 'function_handle')
   yfun = ydata;
   ydata = yfun(knots);  %% Should have a flag if yfun can handle vectors or must be evaluated using arrayfun
end

% ensure data range is inside knot range
if (xdata(1) < knots(1)) || (xdata(end) > knots(end))
   warning('PWLINFIT:DATA_OUTSIDE_KNOTS', 'xdata range [%g %g] exceeds knot range [%g %g]', ...
      xdata(1), xdata(end), knots(1), knots(end));
end

% initial guess for y values
if isempty(yfun)
   yknots = interp1(xdata, ydata, knots);
else
   yknots = yfun(knots);
end

% ensure optmizer is a char array
if isa(optimizer, 'function_handle')
   optimizer = func2str(optimizer);
end

% select optimizer
switch lower(optimizer)

   case 'lsqnonlin'

      % Ensure that xknots is always monotonically increasing knot vector
      % by using non-negative "increments" as optimization variables
      % Then:  xknot = xmin + cumsum(increments)
      xinc = diff(knots(1:end-1));   % then xinc >= 0 and xknot = xknot(1) + xinc;
      x0 = [xinc, yknots];
      h  = knots(end)-knots(1);
      lb = [ mindist + zeros(numel(xinc), 1)  ; -inf(numel(yknots), 1)  ];
      ub = [        h * ones(numel(xinc), 1)  ; +inf(numel(yknots), 1)  ];
      fun = @minFunXY;
      opts = optimoptions(@lsqnonlin, 'Algorithm', 'Levenberg-Marquardt'  ...
         , 'Display', 'iter' ...
         , 'UseParallel', false ...
         , 'FunctionTolerance', 1e-4 ...
         , optimopts{:});
      % x = lsqnonlin(fun, x0, lb, ub, opts);
      [x,resnorm,residual,exitflag,output] = lsqnonlin(fun, x0, lb, ub, opts);
      optinfo = struct('x', x, 'resnorm', resnorm, 'residual', residual, 'exitflag', exitflag, 'output', output);

   otherwise
      error('Unknown optimizer: %s', func2str(optimizer));

end


% assemble output
[knots, yknots] = getKnots(x, knots);
result.xknots = knots;
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
   % split z into inc_x and knot_y part
   [kx, ky] = getKnots(z, knots);
   % transform increments into knots
   rv = calcResvec(kx, ky, xdata, ydata);
end




end % of function



%% HELPERS



function z = ppLinVal(x, y, xq)
%          f(x_i+1) - f(x_i)
%  g(x) = ------------------- * (x - x_i) + f(x_i)  for x in [x_i  x_i+1]
%            x_i+1  -  x_i
%
% x contains the x_i
% y contains the f(x_i)
% xq contains the query points (must be monotonic increasing)
%
LO = 1;               % lower index limit of xq belonging to current interval
z  = zeros(size(xq)); % prepare output array
xqlen = length(xq);
% walk through intervals in x
for i = 1:length(x)-1 
   xi = x(i);   xip1 = x(i+1);
   yi = y(i);   yip1 = y(i+1);
   UP = findFirstGreater(xq, xip1, LO, xqlen+1) - 1;
   z(LO:UP) = (yip1 - yi) / (xip1 - xi) * (xq(LO:UP) - xi) + yi;
   LO = UP + 1;
   if (UP == xqlen), break, end  % all query points done
end

end % of function ppLinVal


function resvec = calcResvec(knot_x, knot_y, data_x, data_y)
   % calculate residual to linear fit (regression)
   y = ppLinVal(knot_x, knot_y, data_x);
   resvec = data_y - y;
end




