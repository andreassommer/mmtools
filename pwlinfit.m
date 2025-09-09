function [result, optinfo] = pwlinfit(xdata, ydata, n, varargin)
% NOTE:  This function is not yet in fully functional form.
%
% [result, optinfo] = pwlinfit(x, y, n, ...)
%
% Best fit of a continuous piecewise linear function consisting of n pieces
% to a given function or point cloud y
%
% INPUT:    x --> x values    [UPCOMING: evaluation points or span/interval]
%           y --> y values    [UPCOMING: function ]
%           n --> number of linear pieces
%         ... --> key value pairs
%                 'optimize' --> value one of 'x', 'y', 'both' [default]
%                   'xknots' --> initial grid of x points (equidistant if not specified)
%               'continuous' --> true or false      [ UPCOMING -- currently always true ]
%                'optimizer' --> can be 'lsqnonlin' (requires optimization toolbox)
%                'optimopts' --> optimopts structure passed to the optimizer
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


% process args - olGetOption returns in args the remaining arguments
args = varargin;
[xknots   , args] = olGetOption(args, 'xknots'   , []);
[xmindist , args] = olGetOption(args, 'xmindist' , 10);
[optimizer, args] = olGetOption(args, 'optimizer', @lsqnonlin);
[optimopts, args] = olGetOption(args, 'optimopts', {});

% check all args processed
if ~isempty(args)
   warning('PWLINFIT:UNKNOWN_ARGS', 'Ignoring unknown arguments: %s', sprintf('%s ', args{1:2:end}));
end

% if no initial grid specified, use equidistantly sampled xdata
if isempty(xknots)
   xknots = linspace(xdata(1), xdata(end), n+1);
end

% if x is a 2-point vector, fill it with 
if length(xknots) == 2
   xknots = linspace(xknots(1), xknots(end), n+1);
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

% initial guess for y values
if isempty(yfun)
   yknots = interp1(xdata, ydata, xknots);
else
   yknots = yfun(xknots);
end

% quick and dirty: use lsqnonlin

switch lower(func2str(optimizer))

   case 'lsqnonlin'

      % Ensure that xknots is always monotonically increasing knot vector
      % by using non-negative "increments" as optimization variables
      % Then:  xknot = xmin + cumsum(increments)
      xinc = diff(xknots(1:end-1));   % then xinc >= 0 and xknot = xknot(1) + xinc;
      x0 = [xinc, yknots];
      h  = xknots(end)-xknots(1);
      lb = [xmindist + zeros(numel(xinc), 1)  ; -inf(numel(yknots), 1)  ];
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


% assemboe output
[xknots, yknots] = getKnots(x, xknots);
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
   % split z into inc_x and knot_y part
   [kx, ky] = getKnots(z, xknots);
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




