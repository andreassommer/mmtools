function [rounded, timings] = roundto_example(values, roundval, displayflag)
% Example for ROUNDTO function
%
% Displays exemplary rounding result.
%
% INPUT:    values --> values to be rounded
%         roundval --> value to be rounded to
%      displayflag --> if false, no screen output is generated
%
% OUTPUT:  rounded --> matrix of rounded values (inputs are linearized)
%     timin
%
% If no input arguments are given, an exemplary output is generated.
%
%
% Andreas Sommer, Apr2024
% code@andreas-sommer.eu
%

% argument checking
if (nargin==1), error('Need 2 or 0 arguments.'), end
if (nargin <3), displayflag = true; end

% defaults
if (nargin==0)
   values   = -7:0.5:7;
   roundval = 2;
end

% linearize input
values = values(:);

% perform roundings
ticID=tic();   r0      = roundto(values, roundval,    0);   timings.zero   = toc(ticID);
ticID=tic();   rNegInf = roundto(values, roundval, -inf);   timings.neginf = toc(ticID);
ticID=tic();   rPosInf = roundto(values, roundval, +inf);   timings.posinf = toc(ticID);
ticID=tic();   rPlus   = roundto(values, roundval,   +1);   timings.plus   = toc(ticID);
ticID=tic();   rMinus  = roundto(values, roundval,   -1);   timings.minus  = toc(ticID);

% display (if queried)
if displayflag
   if length(values) <= 100
      varnames = {'value', '-1', '+1', '0', '-oo', '+oo'};
      tab = table(values, rMinus, rPlus, r0, rNegInf, rPosInf, 'VariableNames', varnames);
      disp(tab);
   else
      disp('Too many values to display. Skipping.');
   end
   disp('Time for rounding towards ...')
   disp(timings);
end

% output matrix
if (nargout > 0)
   rounded = [values, rMinus, rPlus, r0, rNegInf, rPosInf];
end

end % of function
