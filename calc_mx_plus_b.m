function [m, b] = calc_mx_plus_b(x1, y1, x2, y2)
% [m, b] = calc_mx_plus_b(x1, y1, x2, y2)
%
% Determine slope and y-axis intercept from two given points (x1,y1), (x2,y2) of a line.
%
% INPUT:    x1 --> x coordinate of first point
%           y1 --> y coordinate of first point
%           x2 --> x coordinate of second point
%           y2 --> y coordinate of second point
%
% OUTPUT:    m --> slope of straight line through (x1,y1) and (x2,y2)
%            b --> y-axis intercept of that line
%
% NOTE:  Function is vectorized; all inputs must have same dimension.
%
% Andreas Sommer, Jul2026
% code@andreas-sommer.eu
%

m = (y2-y1) ./ (x2-x1);
b = y1 - m.*x1;

end % of function

