function [options, varargout] = olKeepOption(optionlist, varargin)
   % options = olKeepOption(optionlist, name1, name2, ...)
   % [options, removedOptions] = olKeepOption(optionlist, name1, name2, ...)
   %
   % Keeps only specified properties/options (and the associated value) from optionlist.
   %
   % INPUT:     optionlist --> a cell array of key-value-pairs
   %                 nameN --> keys to be keps
   %
   % OUTPUT:       options --> processed optionlist
   %        removedOptions --> optionlist with removed options and valued
   %
   %
   % Author: Andreas Sommer, Sep2025
   % code@andreas-sommer.eu
   %
   %
   % History:  
   %      Jul2024 --> renamed to ol* scheme

   % check if user requested removedOptions
   removedOptionsRequested = (nargout >= 2);

   % no named arguments? keep noting, return empty set.
   if (nargin==1)
      options = {};
      if removedOptionsRequested
         varargout{1} = optionlist;
      end
      return
   end

   % ensure optionlist is a valid optionlist
   olAssertOptionlist(optionlist);
   
   % assert that varargin is a cell array of strings
   if ~iscellstr(varargin)        %#ok<ISCLSTR>  % really check for *cell* string
      disp('Problem detected:')
      disp(varargin)
      error('Invalid key list!')
   end
   
   % prepare new optionlist
   options = {};
   removedOptions = {};
   keepKeys = varargin;
   
   % just check the keys in optionlist, keep what's needed in new list, possibly store 
   for j = 1:2:length(optionlist)
      keepit = false;
      
      % walk through the keys to keep
      for k = 1:length(keepKeys)
         if strcmpi(optionlist{j},keepKeys{k})
            keepit = true;  % marker that we remove something
            break;
         end
      end
      
      % keep or remove it - performance relies on matlab's copy-on-write
      if keepit
         options{end+1} = optionlist{j};   % copy key
         options{end+1} = optionlist{j+1}; % copy value
         continue % do nothing
      else %#ok<*AGROW>
         if removedOptionsRequested
            removedOptions{end+1} = optionlist{j};    % transfer key
            removedOptions{end+1} = optionlist(j+1);  % transfer value
         end
      end
   end

   % prepare output variable
   if removedOptionsRequested
      varargout{1} = removedOptions;
   end

% finito   
end % of function