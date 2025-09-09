function [idxPeaks, valPeaks, peakInfo] = findLocalPeaks(signal, direction, varargin)
% [idxPeaks, valPeaks, peakInfo] = findLocalPeaks(signal, direction, [, key-value-pairs]*)
%
% Detects local peaks in specified signal
%
% INPUT:    signal --> signal vector to be investigated
%        direction --> +1 detects maxima, -1 detects minima, 0 detects both   [default: +1]
%
%       key-value-pairs:
%               xvals --> x points associated to the signal (assuming equidistant if not specified)
%     includeBoundary --> if set to true, will always be returned as peaks    [default: false]
%          onlyStrict --> only search for strict local extrema                [default: true ]
%             minProm --> minimum prominence value                            [default: 0    ]
%             relProm --> relative prominence, w.r.t. highest signal value    [default: false]
% 
%                sort --> sort order of found peaks:
%                            'signal' -> keep order as in signal
%                            'ascend' -> sort in ascending order
%                           'descend' -> sort in descending order
%                         'absascend' -> sort in ascending order of absolute value
%                        'absdescend' -> sort in descending order of absolute value
%
% OUTPUT: idxPeaks --> linear indices of peaks in signal
%         valPeaks --> associated peak values
%         peakInfo --> structure with full information about peaks
%
% NOTES:
%  - if you have piecewise constant data, set 'minslope' to a nonzero value to avoid 
%    detecting all constant values as (weak) local extrema
%
%
% Andreas Sommer, Sep2024
% code@andreas-sommer.eu
%

% direction default
if (nargin <= 1) || isempty(direction), direction = +1; end

% arguments
args = varargin;
[minslope       , args] = olGetOption(args, 'minslope'       , 0.0  ); % don't advertise this in help
[xvals          , args] = olGetOption(args, 'xvals'          , []   );
[includeBoundary, args] = olGetOption(args, 'includeBoundary', false);
[onlyStrict     , args] = olGetOption(args, 'onlyStrict'     , true );
[sortOrder      , args] = olGetOption(args, 'sort'           , ''   );
[minProm        , args] = olGetOption(args, 'minProm'        , 0    );
[relProm        , args] = olGetOption(args, 'relProm'        , false);
[mostProminent  , args] = olGetOption(args, 'mostProminent'  , 0    );


% arguments left?
if ~isempty(args)
   warnID = strcat(mfilename(), ':UNKNOWN_ARGUMENTS');
   warning(warnID, 'Unknown arguments: %s', sprintf('%s ', args{1:2:end}));
end

% output arguments determine what to compute
calculate_valPeaks = (nargout >= 2) || ~isempty(sortOrder); % sorting requires peak values 
calculate_peakInfo = (nargout >= 3);

% reshape signal to single row
signal = reshape(signal, 1, []); 
xvals  = reshape(xvals , 1, []);

% pos/neg approximate derivative   
grad  = diff(signal);
if xvals
   grad = grad ./ diff(xvals); 
end

% give linear indices to every signal point
lastlinidx = numel(signal);
linidx = 1:lastlinidx;
idx_rising  = [grad >  minslope , false];
idx_falling = [grad < -minslope , false];
linidx_rising  = [linidx(idx_rising)  , lastlinidx];   % add lastlinidx to keep last peak
linidx_falling = [linidx(idx_falling) , lastlinidx];
linidx_falling_start = linidx_falling;
linidx_falling_start([false diff(linidx_falling) == 1]) = [];
linidx_falling_end = 1 + linidx_falling(diff(linidx_falling) > 1);
linidx_rising_start = linidx_rising;
linidx_rising_start([false diff(linidx_rising) == 1]) = [];
linidx_rising_end = 1 + linidx_rising(diff(linidx_rising) > 1);


% find local extrema
% we have a local MAXimum (weak if constant before)
%    (1) at end of rising parts & (2) on begin of falling parts
% we have a local MINimum (weak if constant before)
%    (1) at end of falling parts & (2) on begin of rising parts
idxMin = []; idxMax = [];
if direction >= 0 
   idxMax = union(linidx_rising_end, linidx_falling_start);
end
if direction <= 0
   idxMin = union(linidx_falling_end, linidx_rising_start);
end

% minimum prominence requested?
if (minProm > 0)
   % determine prominences
   promsMin = []; promsMax = [];
   if direction >= 0, promsMax = calcProm(xvals, signal, idxMax, [], +1); end
   if direction <= 0, promsMin = calcProm(xvals, signal, idxMin, [], -1); end
   promsMin = abs(promsMin);  % calcProms encodes left/right prominence info with +/- sign
   promsMax = abs(promsMax);
   % if relative prominence requested, normalize by maximum (absolute) signal
   if relProm, promsMin = promsMin / max(abs(signal)); end
   if relProm, promsMax = promsMax / max(abs(signal)); end
   % only keep those with minimum prominence
   idxMin = idxMin( promsMin >= minProm );
   idxMax = idxMax( promsMax >= minProm );
end

% combine minima and maxima, ensure single row
idxExtrema = reshape( union(idxMax, idxMin), 1, [] );

% only keep those with largest prominence
if (mostProminent ~= 0)
   % calculate the prominences to the left - within the extrema (not the signal, as it might be too noisy)
   xExtrema = xvals(idxExtrema);
   yExtrema = signal(idxExtrema);
   iExtrema = 1:length(idxExtrema);
   if (mostProminent > 0) % total/combined prominence, checked in both directions 
      proms = calcProm(xExtrema, yExtrema, iExtrema, [], 0, 0);
   end
   % % % promsL = calcProm(xExtrema, yExtrema, iExtrema, [], 0, -1);
   % % % promsR = calcProm(xExtrema, yExtrema, iExtrema, [], 0, +1);
   % % % proms = abs(proms); % calcProm encodes left/right prominence info with +/- sign
   [~, sortIdx ] = sort(abs(proms), 'descend');
   idxExtrema = idxExtrema( sortIdx(1:min(end, abs(mostProminent))) );
end



% possibly remove non-strict extrema
if onlyStrict
   tol = 0.0;
   idxExtrema = removeNonStrictExtrema(signal, idxExtrema, tol);
end

% get wanted peaks
idxPeaks = idxExtrema;


% include first and last point
if includeBoundary
   idxPeaks = unique( [1 , idxPeaks , length(signal)] );
end


% make second output arg if requested
if calculate_valPeaks || calculate_peakInfo
   valPeaks = signal(idxPeaks);
end

% make info output argument if requested
if calculate_peakInfo
   peakInfo = struct();
   peakInfo.idxMax = idxMax;
   peakInfo.idxMin = idxMin;
   peakInfo.idxPeaks = idxPeaks;
   peakInfo.valPeaks = valPeaks;
   peakInfo.linidx_falling       = linidx_falling;
   peakInfo.linidx_falling_start = linidx_falling_start;
   peakInfo.linidx_falling_end   = linidx_falling_end;
   peakInfo.linidx_rising        = linidx_rising;
   peakInfo.linidx_rising_start  = linidx_rising_start;
   peakInfo.linidx_rising_end    = linidx_rising_end;
end

% sorting
switch lower(sortOrder)
   case {'','signal'}     % do nothing
   case 'ascend'      ,  [valPeaks, srtIdx] = sort(valPeaks, 'ascend');     idxPeaks = idxPeaks(srtIdx);
   case 'descend'     ,  [valPeaks, srtIdx] = sort(valPeaks, 'descend');    idxPeaks = idxPeaks(srtIdx);
   case 'absascend'   ,  [valPeaks, srtIdx] = sort(valPeaks, 'absascend');  idxPeaks = idxPeaks(srtIdx);
   case 'absdescend'  ,  [valPeaks, srtIdx] = sort(valPeaks, 'absdescend'); idxPeaks = idxPeaks(srtIdx);
   otherwise
      warning('Unknown sort order: %s - Keeping default order', sortOrder);
end


end % of function



%% HELPERS
function idx = detectSlope(sig, dir, slope)
   if (dir > 0)
      idx = sig > slope;   % this detects all rising points, but not the last point in the sequence
   else
      idx = sig < -slope;  % same with falling points
   end
   incidx = [diff(idx)<0 , false];  % add last point of rising/falling sequence
   idx(incidx) = true;
end


function idxStrictExtrema = removeNonStrictExtrema(signal, idxExtrema, tol)
   % check if left or right of extremum is same value
   slen = numel(signal);
   idxStrictExtrema = zeros(size(idxExtrema));  % no more to be expected
   idx = 1;
   for i = 1:numel(idxExtrema)
      iE = idxExtrema(i);
      if     (iE == 1   ), svals = signal(iE + [   0 +1]);  % first boundary point
      elseif (iE  < slen), svals = signal(iE + [-1 0 +1]);
      else               , svals = signal(iE + [-1 0   ]);  % last boundary point
      end
      if all( abs(diff(svals)) > tol )
         idxStrictExtrema(idx) = iE;
         idx = idx + 1;
      end
   end
   idxStrictExtrema = idxStrictExtrema(1:idx-1);  % cut length
end


% 
% function [prom] = getAbsProminence(xvals, signal, idx, dir)
%    % if xvals was not given, use numbered indices
%    if isempty(xvals), xvals = 1:length(signal); end
%    % determine prominences
%    prom = calcProm(xvals, signal, idx, [], dir);
%    prom = abs(prom);  % calcProms gives left/right prominence info with +/- sign
% end
% 
% 


