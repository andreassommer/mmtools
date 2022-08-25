function value = getSetting(settingStruct, settingName, defaultValue)
   % function value = getSetting(settingStruct, settingName, defaultValue)
   %
   % Retrieves the value of the field settingName in settingStruct, if existant. 
   % Otherwise returns the defaultValue, if given, or signals an error.
   %
   % INPUT:  settingStruct --> struct with settings stored as fields
   %           settingName --> field name to search for
   %          defaultValue --> value if no field suitable field is found (optional)
   %                           If not specified, getSetting signals an error if the 
   %                           requested setting does not exist.
   %
   % OUTPUT:  value --> value of specified setting
   %
   %
   % Author:  Andreas Sommer, Aug2022
   % andreas.sommer@iwr.uni-heidelberg.de
   % code@andreas-sommer.eu
   %
   
   % determine if a default is given
   defaultProvided = (nargin >= 3);
   
   if isfield(settingStruct, settingName)
      value = settingStruct.(settingName);    % field exists, so return its value
   else
      if defaultProvided
         value = defaultValue;                % field does not exist, default value provided
      else
         error('Requested setting %s does not exist.', settingName); % signal error otherwise
      end
   end
   
   %finito
   return 
   
end