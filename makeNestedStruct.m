function s = makeNestedStruct(s, names, values, splitter)
% s = makeNestedStruct(s, names, values, splitter)
%
% Transforms tokenizable strings in nested structure and assigns values.
%
% INPUT:    s --> initial struct to be modified or []
%       names --> cell array of tokenizable strings to be processed
%      values --> cell array of values to be assigned
%    splitter --> string used as splitter to tokenize
%
% OUTPUT    s --> modified structure with nested structs/fields
%
% Example: 
%     names = { "aaa::bbb::ccc", "aaa::bbb:ddd", "aaa::ddd", "eee" };
%    values = {              42, 'hi there'    , 'hello'   , pi    };
%         s = makeNestedStruct([], names, values, '::');
%
% This will create a structure with the following layout:
%    s.aaa.bbb.ccc = 42
%    s.aaa.bbb.ddd = 'hi there'
%    s.aaa.ddd     = 'hello'
%    s.eee         = 3.141569
%
% Note that a value field must not have a subfield:
%
% 1) The following leads to an ERROR:
%        names = { "aaa::bbb", "aaa::bbb::ccc" }
%       values = {       42  ,          100  }
%            s = makeNestedStruct([], names, values, '::')
%    Error using makeNestedStruct
%    Unable to perform assignment because dot indexing is not supported for variables of this type.
%
% 2) The following SILENTLY OVERWRITES an existing substructure:
%        names = { "aaa::bbb::ccc", "aaa::bbb" }
%       values = {            42  ,       100  }
%             s = makeNestedStruct([], names, values, '::')
%    gives a structure s with layout
%             s.aaa.bbb = 100
%    as s.aaa.bbb.ccc got overwritten.
%
% Andreas Sommer, Oct2025
% code@andreas-sommer.eu


% allow using [] als initializer
if ~isstruct(s) && isempty(s)
   s = struct();
end
% walk through names
for i = 1:numel(names)
   parts = strsplit(names{i}, splitter);
   currStruct = s;
   sref = struct('type', '.', 'subs', '');
   for j = 1:numel(parts)-1
      sref(j).type = '.';
      sref(j).subs = parts{j};
      if ~isfield(currStruct, parts{j})
         currStruct.(parts{j}) = struct();
      end
      currStruct = currStruct.(parts{j});
   end
   % assign value to deepest field
   sref(numel(parts)).type = '.';
   sref(numel(parts)).subs = parts{end};
   s = subsasgn(s, sref, values{i});
end


end % of function