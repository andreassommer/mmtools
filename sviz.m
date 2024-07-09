function sviz(datstruct, fignum, figname)
% sviz(datstruct, fignum, figname)
%
% Simple visualizer.
%
% INPUT:    datstruct --> Matlab struct whose fields will be used as data source.
%              fignum --> figure number to use
%             figname --> name for the figure window [optional]
%
% OUTPUT:   none.
%
% No error or consistency checks are done.
%
% Andreas Sommer, Apr2024
% code@andreas-sommer.eu
%


% check args
if ( (nargin<1) || ~isstruct(datstruct) ), error('No data structure provided.'); end
if (nargin<2), fignum = 3432; end
if (nargin<3), figname = '';  end

% get the data fields
datnames = fieldnames(datstruct);

% make a figure, add plot button and choose
handles.figure = figure(fignum);
set(handles.figure, 'Defaultuicontrolunits','normalized','Defaultaxesunits','normalized','Defaultuipanelunits','normalized');
if ~isempty(figname)
   set(handles.figure, 'Name', figname);
end

% setup panels
handles.panel1 = uipanel(handles.figure, 'Title', '', 'Background', 'white', 'Position', [0.0 0.0 1.0 0.5] );
handles.panel2 = uipanel(handles.figure, 'Title', '', 'Background', 'white', 'Position', [0.0 0.5 1.0 0.5] );

% link axes if same x
handles.h1 = addVisualizerToPanel(handles.panel1, datnames, handles);
handles.h2 = addVisualizerToPanel(handles.panel2, datnames, handles);

% finito
return


%% HELPERS

function h = addVisualizerToPanel(parent, datnames, handles)
   % generate controls
   units = {'units','normalized'};
   h.ax    = uiaxes (parent, units{:}, 'Position', [0.0  0.1  1.00  0.90], 'FontName', 'Monospaced');
   h.panel = uipanel(parent, units{:}, 'Position', [0.0  0.0  1.00  0.10] );
   set(h.panel, 'units', 'pixels'); pos = h.panel.Position; pos(4) = 25; h.panel.Position = pos;
   h.btn   = uicontrol(h.panel, units{:}, 'Position', [0.8  0.0  0.15  1.0], 'Style', 'pushbutton', 'String', 'Plot', 'Callback', @plotbutton_callback);
   h.xmenu = uicontrol(h.panel, units{:}, 'Position', [0.1  0.0  0.30  1.0], 'Style', 'popupmenu' , 'String', datnames);
   h.ymenu = uicontrol(h.panel, units{:}, 'Position', [0.45 0.0  0.30  1.0], 'Style', 'popupmenu' , 'String', datnames);
   % transfer the handles to all controls
   set(h.ax   , 'UserData', h);
   set(h.btn  , 'UserData', h);
   set(h.xmenu, 'UserData', h);
   set(h.ymenu, 'UserData', h);
   % remove axis toolbar
   h.axtb = axtoolbar('default'); 
   h.axtb.Visible = 'off';
   h.ax.Toolbar = h.axtb;
end

%button callback
function plotbutton_callback(h, event)
   hlist = h.UserData;
   xName = hlist.xmenu.String{hlist.xmenu.Value};
   yName = hlist.xmenu.String{hlist.ymenu.Value};
   ax = hlist.ax;
   x = datstruct.(xName);
   y = datstruct.(yName);
   plot(hlist.ax, x, y, 'b.');
   ytickformat(hlist.ax, '%9.3g');
   % link axes 
   linkaxes([handles.h1.ax handles.h2.ax], 'x')
end



end % of function
