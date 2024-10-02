function [value, cellarray, foundOption] = olGetOption(cellarray, searchOption, defaultValue, evalDefault)
   % function [value, cellarray, found] = olGetOption(cellarray, searchOption)
   % function [value, cellarray, found] = olGetOption(cellarray, searchOption, defaultValue, evalDefault)
   %
   % Searches cellarray, which is expected to be a cell array of name/value pairs,
   % for specified option and returns the associated value.
   %
   % Only the first occurence is reported.
   % The searchOption strings are case insensitive.
   %
   % If the specified value cannot be found, and no default value is specified, the empty matrix [] is returned.
   % Try to check first via hasOption()-function, if the the cell array contains the desired name/value pair.
   % 
   %
   % INPUT:   cellarray --> cell array to process
   %       searchOption --> name of queried option
   %       defaultValue --> value to be used if queried option is not found
   %                        (optional, default is empty matrix [])
   %        evalDefault --> if specified, defaultValue is evaluated (without arguments)
   %                        and the result is taken to initialize default value
   %
   % OUTPUT:      value --> value associated with queried option name
   %          cellarray --> cell array with queried option removed
   %              found --> true if searchOption was found, false otherwise
   %
   %
   %
   % Author:  Andreas Sommer, 2009,2010,2011,2016,2017,2022,2024
   % andreas.sommer@iwr.uni-heidelberg.de
   % code@andreas-sommer.eu
   %
   % 
   % History:  Sep2016 --> renamed to getOption, assert optionlist
   %           Mar2017 --> cut the cell array, if two-arg-output
   %           Dec2022 --> add default value 
   %           Jul2024 --> renamed to olGetOption
   %           Sep2024 --> added found flag and possible evaluation of default
   
   % was a default value provided?
   if (nargin<3), defaultValue = []; end
   if (nargin<4), evalDefault = false; end
   
   % Initialize
   olAssertOptionlist(cellarray);
   foundOption = false;
   
   % cycle through properties
   for k = 1:2:length(cellarray)
      optionName = cellarray{k};
      if strcmpi(optionName,searchOption)
         if (length(cellarray) >= k+1)
            value = cellarray{k+1};
            foundOption = true;
            break
         end
      end
   end

   % if value was not fount, set it to default value
   if ~foundOption
      if evalDefault
         value = defaultValue();
      else
         value = defaultValue;
      end
   end

   % if more than one output argument, remove the queried option (if found)
   if (nargout >= 2) && foundOption
      cellarray = olRemoveOption(cellarray, searchOption);
   end
end
