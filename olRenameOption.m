function cellarray = olRenameOption(cellarray, oldOption, newOption)
   % function cellarray = olHasOption(cellarray, oldOption, newOption)
   %
   % Renames option with name oldOption to newOption
   %
   % Copyright (c) 2009,2010,2011,2016,2024,2025 Andreas Sommer
   % code@andreas-sommer.eu

   % History: Mar2025 --> first version
   
   % initialize
   olAssertOptionlist(cellarray);
   
   % cycle through properties and substitute
   for k = 1:2:length(cellarray)
      propertyName = cellarray{k};
      if strcmpi(propertyName,oldOption)
         cellarray{k} = newOption;
      end
   end

end
