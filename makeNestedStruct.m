function s = makeNestedStruct(s, splitter, varargin)
% 1) s = makeNestedStruct(s, splitter, names, values )
% 2) s = makeNestedStruct(s, splitter[, nameX, valueX]* )
%
% Transforms tokenizable strings in nested structure and assigns values.
%
% INPUT SYNTAX 1)
%           s --> initial struct to be modified or []
%    splitter --> string used as splitter to tokenize
%       names --> cell array of tokenizable strings to be processed
%      values --> cell array of values to be assigned
%
% INPUT SYNTAX 2)
%                  s --> initial struct to be modified or []
%           splitter --> string used as splitter to tokenize
%   [nameX, valueX]* --> name-value-pairs of tokenizable strings and associated value
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


% quick return if nothing to do
if (nargin <= 2), return; end

% check which syntax is used
if iscell(varargin{1})
   names  = varargin{1};
   values = varargin{2};
else
   names  = varargin(1:2:end);
   values = varargin(2:2:end);
end

% error if not having right format
if ~iscell(names) || ~iscell(values)
   error('Invalid call. See documentation for proper usage.')
end

% quick return if nothing to do
if length(names) == 0, return; end

% allow using [] als initializer
if ~isstruct(s) && isempty(s)
   s = struct();
end

% DO THE WORK: walk through names
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