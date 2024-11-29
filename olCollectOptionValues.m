function [result, invalid] = olCollectOptionValues(cellarray)
   % result = olCollectOptionValues(cellarray)
   % [result, invalid] = olCollectOptionValues(cellarray)
   %
   % Returns all option values in cellarray as a cell array.
   % If it is not a valid option list, an empty cell array is returned.
   %
   % INPUT:  cellarray --> optionlist cell array to be queried
   %
   % OUTPUT:    result --> cell array with all optionlist values
   %           invalid --> if true, cellarray is not a valid optionlist
   %
   % Copyright (c) 2024 Andreas Sommer
   % code@andreas-sommer.eu

   % History: Nov2024 --> initial version
   %
   
   % quick return if no option list
   isOptionList = olIsOptionlist(cellarray);
   if ~isOptionList
      result = [];
      invalid = true;
      return;
   end

   % so it's valid
   invalid = false;

   % collect every second element
   if isempty(cellarray)
      result = {};
   else
      result = cellarray(2:2:end);
   end

   
   end
