function plotting_options(Action)

%% input check
if nargin==0
    Action = 'initialize';
end

%% find gui
popts_gui_handle = findobj(0, 'tag', 'popts_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(popts_gui_handle)
            delete(popts_gui_handle);
        end
        
        %% Initialize
        DefaultUicontrolPosition = get(0, 'DefaultUicontrolPosition');
        b_height                 = DefaultUicontrolPosition(4)+2;
        b_width                  = DefaultUicontrolPosition(3)+15;
        gap                      = 5;
        
        Screensize      = get(0, 'ScreenSize');
        text_width      = 2*b_width+gap;
        
        fig_width       = text_width+gap+4*(b_width+gap)+gap;
        fig_height      = 12*(b_height+gap)+6*gap;
        
        % Create dialog window
        popts_gui_handle = figure( ...
            'Name' ,'Plotting Option', 'Units','pixels', 'tag','popts_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/8, (Screensize(4)-fig_height)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
       
        %  File
        h1  = uimenu('Parent',popts_gui_handle, 'Label','File');
        
        %  Save current options as default
        uimenu('Parent',h1, 'Label', 'Save options', ...
            'Callback', @(a,b) plotting_options('save'), 'Separator','off', 'enable', 'on');
        %  Restore 
        uimenu('Parent',h1, 'Label', 'Restore default options', ...
            'Callback', @(a,b) plotting_options('restore'), 'Separator','off', 'enable', 'on');
        
        p                       = uiextras.TabPanel('Parent', popts_gui_handle);
        
        % General
        popts_upanel_general    = uipanel('Parent', p);
        popts_upanel_curvature  = uipanel('Parent', p);
        popts_upanel_parameters = uipanel('Parent', p);
        popts_upanel_diagrams   = uipanel('Parent', p);
        
        p.TabNames = {'General', 'Curvature', 'Parameters','Diagrams'};
        p.TabSize  = 90;
        p.SelectedChild = 1;
        
        
        %% - General
        % Layer
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Layer','HorizontalAlignment', 'left', ...
            'position', [gap, 11*(b_height+gap)+gap, text_width, b_height]);
        
        % - active
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 10*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Fill Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_fold_color_active', ...
            'position', [text_width+gap+1*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        
        % - inactive
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Inactive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 9*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Fill Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_fold_color_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        
        
        % Interface
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Interface','HorizontalAlignment', 'left', ...
            'position', [gap, 8*(b_height+gap)+gap, text_width, b_height]);
        
        % - active
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 7*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_face_color_active', ...
            'position', [text_width+gap+1*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_face_thick_active', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        
        % - inactive
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Inactive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 6*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_face_color_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_face_thick_inactive', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        
        
        % Hinge Pint
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Hinge Point','HorizontalAlignment', 'left', ...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height]);
        
        % - active
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 4*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_hinge_color_active', ...
            'position', [text_width+gap+1*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_hinge_size_active', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        % - inactive
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Inactive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 3*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_hinge_color_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_hinge_size_inactive', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        
        
        % Inflection Pint
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Inflection Point','HorizontalAlignment', 'left', ...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height]);
        
        % - active
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 1*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_inflection_color_active', ...
            'position', [text_width+gap+1*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_inflection_size_active', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % - inactive
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', '- Inactive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 0*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_inflection_color_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_general, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_general,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_inflection_size_inactive', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        %% - Curvature & NIP-FW
        % Curvature Analysis
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Curvature Analysis','HorizontalAlignment', 'left', ...
            'position', [gap, 11*(b_height+gap)+gap, text_width, b_height]);
        
        % - original
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', '- Original','HorizontalAlignment', 'left', ...
            'position', [3*gap, 10*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_curve_color_ori', ...
            'position', [text_width+gap+1*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_curve_thick_ori', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        
        % - smoothed
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', '- Smoothed','HorizontalAlignment', 'left', ...
            'position', [3*gap, 9*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_curve_color_smoothed', ...
            'position', [text_width+gap+1*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_curve_thick_smoothed', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        
        
        % - polynomial fit
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', '- Smoothed','HorizontalAlignment', 'left', ...
            'position', [3*gap, 8*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_curve_color_poly', ...
            'position', [text_width+gap+1*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_curve_thick_poly', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        
        
        % NIP-FW diagram
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'NIP-FW diagram','HorizontalAlignment', 'left', ...
            'position', [gap, 7*(b_height+gap)+gap, text_width, b_height]);
        
        % - without small area (markers)
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', '* Smoothing without small area','HorizontalAlignment', 'left', ...
            'position', [3*gap, 6*(b_height+gap)+gap, 4*b_width, b_height]);
        % -- active
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', ' - Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 5*(b_height+gap)+gap, b_width, b_height]);
        
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 5*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_color_marker_active', ...
            'position', [text_width+gap+1*(b_width+gap), 5*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 5*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_size_marker_active', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 5*(b_height+gap)+gap, b_width, b_height]);
        
        % -- passive
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', ' - Passive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 4*(b_height+gap)+gap, 2*b_width, b_height]);
        
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_color_marker_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_size_marker_inactive', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        % - with small area (lines)
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', '* Smoothing with small area','HorizontalAlignment', 'left', ...
            'position', [3*gap, 3*(b_height+gap)+gap, 4*b_width, b_height]);
        
        % -- active
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', ' - Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 2*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_color_line_active', ...
            'position', [text_width+gap+1*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_thick_line_active', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        
        % -- passive
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', ' - Passive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 1*(b_height+gap)+gap, 2*b_width, b_height]);
        
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_color_line_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_curvature, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_curvature,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_NIPFW_thick_line_inactive', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        
        %% - Parameters
        % Amplitude
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Amplitude','HorizontalAlignment', 'left', ...
            'position', [gap, 11*(b_height+gap)+gap, text_width, b_height]);
        
        % - active
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', '- Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 10*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_ampl_color_active', ...
            'position', [text_width+gap+1*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_ampl_thick_active', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        
        % - inactive
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', '- Inactive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 9*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_ampl_color_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_ampl_thick_inactive', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        
        
        % Wavelength
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Wavelength','HorizontalAlignment', 'left', ...
            'position', [gap, 8*(b_height+gap)+gap, text_width, b_height]);
        
        % - active
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', '- Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 7*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_wave_color_active', ...
            'position', [text_width+gap+1*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_wave_thick_active', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        
        % - inactive
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', '- Inactive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 6*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_wave_color_inactive', ...
            'position', [text_width+gap+1*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_wave_thick_inactive', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        
        
        % Thickness
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Thickness','HorizontalAlignment', 'left', ...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height]);
        
        % - active
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', '- Active','HorizontalAlignment', 'left', ...
            'position', [3*gap, 4*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Fill Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_thick_color_active', ...
            'position', [text_width+gap+1*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        % - inactive
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', '- Inactive','HorizontalAlignment', 'left', ...
            'position', [3*gap, 3*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Fill Color 1','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_thick_color_inactive1', ...
            'position', [text_width+gap+1*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_parameters, 'style', 'text', 'String', 'Fill Color 2','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_parameters,'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_thick_color_inactive2',...
            'position', [text_width+gap+3*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        
        
        %% - Diagrams
        % Fletcher & Sherwin
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Fletcher & Sherwin Map','HorizontalAlignment', 'left', ...
            'position', [gap, 11*(b_height+gap)+gap, text_width, b_height]);
        
        % - stretch
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Stretch Contour','HorizontalAlignment', 'left', ...
            'position', [3*gap, 10*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_stretch_color', ...
            'position', [text_width+gap+1*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_stretch_thick', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 10*(b_height+gap)+gap, b_width, b_height]);
        
        % - viscosity ratio
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Vis. Ratio Contour','HorizontalAlignment', 'left', ...
            'position', [3*gap, 9*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_vis_color', ...
            'position', [text_width+gap+1*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_vis_thick', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 9*(b_height+gap)+gap, b_width, b_height]);
        
        
        % - data
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Data','HorizontalAlignment', 'left', ...
            'position', [3*gap, 8*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_data_color', ...
            'position', [text_width+gap+1*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_data_size', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 8*(b_height+gap)+gap, b_width, b_height]);
        
        % - axis
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Axis','HorizontalAlignment', 'left', ...
            'position', [3*gap, 7*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'xmin','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_xmin', 'BackgroundColor','w',...
            'position', [text_width+gap+1*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'xmax','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_xmax', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 7*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'ymin','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_ymin', 'BackgroundColor','w',...
            'position', [text_width+gap+1*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'ymax','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_FS_ymax', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 6*(b_height+gap)+gap, b_width, b_height]);
        
        % Schmalholz & Podladchikov Map
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Schmalholz & Podladchikov Map','HorizontalAlignment', 'left', ...
            'position', [gap, 5*(b_height+gap)+gap, 2*text_width, b_height]);
        
        % - stretch
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Shortening Contour','HorizontalAlignment', 'left', ...
            'position', [3*gap, 4*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_short_color', ...
            'position', [text_width+gap+1*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_short_thick', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        % - viscosity ratio
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Vis. Ratio Contour','HorizontalAlignment', 'left', ...
            'position', [3*gap, 3*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_vis_color', ...
            'position', [text_width+gap+1*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Line Width','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_vis_thick', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 3*(b_height+gap)+gap, b_width, b_height]);
        
        
        % - data 1
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Data','HorizontalAlignment', 'left', ...
            'position', [3*gap, 2*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_data1_color', ...
            'position', [text_width+gap+1*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_data1_size', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        
        % - data 2
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Data','HorizontalAlignment', 'left', ...
            'position', [3*gap, 1*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Marker Color','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'pushbutton',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_data2_color', ...
            'position', [text_width+gap+1*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'Marker Size','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams,'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_data2_size', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % - axis
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', '- Axis','HorizontalAlignment', 'left', ...
            'position', [3*gap, 0*(b_height+gap)+gap, text_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'xmax','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+0*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_xmax', 'BackgroundColor','w',...
            'position', [text_width+gap+1*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'text', 'String', 'ymax','HorizontalAlignment', 'left', ...
            'position', [text_width+gap+2*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        uicontrol('Parent', popts_upanel_diagrams, 'style', 'edit','String','',...
            'callback',  @(a,b)  plotting_options('uicontrol_callback'),...
            'tag', 'popts_SP_ymax', 'BackgroundColor','w',...
            'position', [text_width+gap+3*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        % - Folder Default Values
        plotting_options('default_values');
        
        % - Update Uicontrols
        plotting_options('uicontrol_update');
        
        
    case 'default_values'
        %% Default values
        
        fgt_gui_handle = findobj(0, 'tag', 'fgt_gui_handle', 'type', 'figure');
        
        if ~isempty(fgt_gui_handle)
            
            popts    = getappdata(fgt_gui_handle, 'popts');
            
        else
            
            load(['popts.mat'])
            
        end
        
        setappdata(popts_gui_handle, 'popts', popts);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        popts = getappdata(popts_gui_handle, 'popts');
        
        % General
        set(findobj(popts_gui_handle, 'tag', 'popts_fold_color_active'),        'Backgroundcolor',  popts.fold_color_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_fold_color_inactive'),      'Backgroundcolor',  popts.fold_color_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_face_color_active'),        'Backgroundcolor',  popts.face_color_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_face_thick_active'),        'string', num2str(popts.face_thick_active));
        set(findobj(popts_gui_handle, 'tag', 'popts_face_color_inactive'),      'Backgroundcolor',  popts.face_color_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_face_thick_inactive'),      'string', num2str(popts.face_thick_inactive));
        set(findobj(popts_gui_handle, 'tag', 'popts_hinge_color_active'),       'Backgroundcolor',  popts.hinge_color_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_hinge_size_active'),        'string', num2str(popts.hinge_size_active));
        set(findobj(popts_gui_handle, 'tag', 'popts_hinge_color_inactive'),     'Backgroundcolor',  popts.hinge_color_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_hinge_size_inactive'),      'string', num2str(popts.hinge_size_inactive));
        set(findobj(popts_gui_handle, 'tag', 'popts_inflection_color_active'),  'Backgroundcolor',  popts.inflection_color_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_inflection_size_active'),   'string', num2str(popts.inflection_size_active));
        set(findobj(popts_gui_handle, 'tag', 'popts_inflection_color_inactive'),'Backgroundcolor',  popts.inflection_color_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_inflection_size_inactive'), 'string', num2str(popts.inflection_size_inactive));
        
        set(findobj(popts_gui_handle, 'tag', 'popts_curve_color_ori'),          'Backgroundcolor',  popts.curve_color_ori);
        set(findobj(popts_gui_handle, 'tag', 'popts_curve_thick_ori'),          'string', num2str(popts.curve_thick_ori));
        set(findobj(popts_gui_handle, 'tag', 'popts_curve_color_smoothed'),     'Backgroundcolor',  popts.curve_color_smoothed);
        set(findobj(popts_gui_handle, 'tag', 'popts_curve_thick_smoothed'),     'string', num2str(popts.curve_thick_smoothed));
        set(findobj(popts_gui_handle, 'tag', 'popts_curve_color_poly'),         'Backgroundcolor',  popts.curve_color_poly);
        set(findobj(popts_gui_handle, 'tag', 'popts_curve_thick_poly'),         'string', num2str(popts.curve_thick_poly));
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_color_marker_active'),'Backgroundcolor',  popts.NIPFW_color_marker_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_size_marker_active'), 'string', num2str(popts.NIPFW_size_marker_active));
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_color_marker_inactive'),'Backgroundcolor',  popts.NIPFW_color_marker_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_size_marker_inactive'),'string', num2str(popts.NIPFW_size_marker_inactive));
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_color_line_active'),  'Backgroundcolor',  popts.NIPFW_color_line_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_thick_line_active'),   'string', num2str(popts.NIPFW_thick_line_active));
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_color_line_inactive'),'Backgroundcolor',  popts.NIPFW_color_line_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_NIPFW_thick_line_inactive'),'string', num2str(popts.NIPFW_thick_line_inactive));
        
        set(findobj(popts_gui_handle, 'tag', 'popts_ampl_color_active'),        'Backgroundcolor',  popts.ampl_color_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_ampl_thick_active'),        'string', num2str(popts.ampl_thick_active));
        set(findobj(popts_gui_handle, 'tag', 'popts_ampl_color_inactive'),      'Backgroundcolor',  popts.ampl_color_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_ampl_thick_inactive'),      'string', num2str(popts.ampl_thick_inactive));
        set(findobj(popts_gui_handle, 'tag', 'popts_wave_color_active'),        'Backgroundcolor',  popts.wave_color_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_wave_thick_active'),        'string', num2str(popts.wave_thick_active));
        set(findobj(popts_gui_handle, 'tag', 'popts_wave_color_inactive'),      'Backgroundcolor',  popts.wave_color_inactive);
        set(findobj(popts_gui_handle, 'tag', 'popts_wave_thick_inactive'),      'string', num2str(popts.wave_thick_inactive));
        set(findobj(popts_gui_handle, 'tag', 'popts_thick_color_active'),       'Backgroundcolor',  popts.thick_color_active);
        set(findobj(popts_gui_handle, 'tag', 'popts_thick_color_inactive1'),    'Backgroundcolor',  popts.thick_color_inactive1);
        set(findobj(popts_gui_handle, 'tag', 'popts_thick_color_inactive2'),    'Backgroundcolor',  popts.thick_color_inactive2);
        
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_stretch_color'),         'Backgroundcolor',  popts.FS_stretch_color);
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_stretch_thick'),         'string', num2str(popts.FS_stretch_thick));
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_vis_color'),             'Backgroundcolor',  popts.FS_vis_color);
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_vis_thick'),             'string', num2str(popts.FS_vis_thick));
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_data_color'),            'Backgroundcolor',  popts.FS_data_color);
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_data_size'),             'string', num2str(popts.FS_data_size));
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_xmin'),                  'string', num2str(popts.FS_xmin));
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_xmax'),                  'string', num2str(popts.FS_xmax));
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_ymin'),                  'string', num2str(popts.FS_ymin));
        set(findobj(popts_gui_handle, 'tag', 'popts_FS_ymax'),                  'string', num2str(popts.FS_ymax));
        
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_short_color'),           'Backgroundcolor',  popts.SP_short_color);
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_short_thick'),           'string', num2str(popts.SP_short_thick));
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_vis_color'),             'Backgroundcolor',  popts.SP_vis_color);
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_vis_thick'),             'string', num2str(popts.SP_vis_thick));
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_data1_color'),           'Backgroundcolor',  popts.SP_data1_color);
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_data1_size'),            'string', num2str(popts.SP_data1_size));
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_data2_color'),           'Backgroundcolor',  popts.SP_data2_color);
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_data2_size'),            'string', num2str(popts.SP_data2_size));
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_xmax'),                  'string', num2str(popts.SP_xmax));
        set(findobj(popts_gui_handle, 'tag', 'popts_SP_ymax'),                  'string', num2str(popts.SP_ymax));
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        popts = getappdata(popts_gui_handle, 'popts');
            
        
        switch Whoiscalling
            
            %% - Fold
            case 'popts_fold_color_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.fold_color_active = col;
                end
                
            case 'popts_fold_color_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.fold_color_inactive = col;
                end
                
            %% - Face
            case 'popts_face_color_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.face_color_active = col;
                end
                
            case 'popts_face_thick_active'
                popts.face_thick_active = str2double(get(wcbo,  'string'));
                
            case 'popts_face_color_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.face_color_inactive = col;
                end
                
            case 'popts_face_thick_inactive'
                popts.face_thick_inactive = str2double(get(wcbo,  'string'));
                
            case 'popts_hinge_color_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.hinge_color_active = col;
                end
                
                
            %% - Hinge    
            case 'popts_hinge_size_active'
                popts.hinge_size_active = str2double(get(wcbo,  'string'));
                
            case 'popts_hinge_color_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.hinge_color_inactive = col;
                end
                
            case 'popts_hinge_size_inactive'
                popts.hinge_size_inactive = str2double(get(wcbo,  'string'));
                
            %% - Inflection    
            case 'popts_inflection_color_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.inflection_color_active = col;
                end
                
            case 'popts_inflection_size_active'
                popts.inflection_size_active = str2double(get(wcbo,  'string'));
                
            case 'popts_inflection_color_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.inflection_color_inactive = col;
                end
                
            case 'popts_inflection_size_inactive'
                popts.inflection_size_inactive = str2double(get(wcbo,  'string'));
                
            %% - Curvature
            case 'popts_curve_color_ori'
                col = uisetcolor;
                if size(col,2)>1
                    popts.curve_color_ori = col;
                end
                
            case 'popts_curve_thick_ori'
                popts.curve_thick_ori = str2double(get(wcbo,  'string'));
                
            case 'popts_curve_color_smoothed'
                col = uisetcolor;
                if size(col,2)>1
                    popts.curve_color_smoothed = col;
                end
                
            case 'popts_curve_thick_smoothed'
                popts.curve_thick_smoothed = str2double(get(wcbo,  'string'));
                
            case 'popts_curve_color_poly'
                col = uisetcolor;
                if size(col,2)>1
                    popts.curve_color_poly = col;
                end
                
            case 'popts_curve_thick_poly'
                popts.curve_thick_poly = str2double(get(wcbo,  'string'));
                
                
            %% - NIP-FW    
            case 'popts_NIPFW_color_marker_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.NIPFW_color_marker_active = col;
                end
                
            case 'popts_NIPFW_size_marker_active'
                popts.NIPFW_size_marker_active = str2double(get(wcbo,  'string'));
                
            case 'popts_NIPFW_color_marker_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.NIPFW_color_marker_inactive = col;
                end
                
            case 'popts_NIPFW_size_marker_inactive'
                popts.NIPFW_size_marker_inactive = str2double(get(wcbo,  'string'));
                
            case 'popts_NIPFW_color_line_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.NIPFW_color_line_active = col;
                end
            case 'popts_NIPFW_thick_line_active'
                popts.NIPFW_thick_line_active = str2double(get(wcbo,  'string'));
                
            case 'popts_NIPFW_color_line_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.NIPFW_color_line_inactive = col;
                end
                
            case 'popts_NIPFW_thick_line_inactive'
                popts.NIPFW_thick_line_inactive = str2double(get(wcbo,  'string'));
                
            %% - Amplitude
            case 'popts_ampl_color_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.ampl_color_active = col;
                end
                
            case 'popts_ampl_thick_active'
                popts.ampl_thick_active = str2double(get(wcbo,  'string'));
                
            case 'popts_ampl_color_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.ampl_color_inactive = col;
                end
                
            case 'popts_ampl_thick_inactive'
                popts.ampl_thick_inactive = str2double(get(wcbo,  'string'));
                
                
            %% - Wavelength    
            case 'popts_wave_color_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.wave_color_active = col;
                end
                
            case 'popts_wave_thick_active'
                popts.wave_thick_active = str2double(get(wcbo,  'string'));
                
            case 'popts_wave_color_inactive'
                col = uisetcolor;
                if size(col,2)>1
                    popts.wave_color_inactive = col;
                end
                
            case 'popts_wave_thick_inactive'
                popts.wave_thick_inactive = str2double(get(wcbo,  'string'));
                
                
            %% - Thickness    
            case 'popts_thick_color_active'
                col = uisetcolor;
                if size(col,2)>1
                    popts.thick_color_active = col;
                end
                
            case 'popts_thick_color_inactive1'
                col = uisetcolor;
                if size(col,2)>1
                    popts.thick_color_inactive1 = col;
                end
                
            case 'popts_thick_color_inactive2'
                col = uisetcolor;
                if size(col,2)>1
                    popts.thick_color_inactive2 = col;
                end
                
            %% Fletcher & Sherwin
            case 'popts_FS_stretch_color'
                col = uisetcolor;
                if size(col,2)>1
                    popts.FS_stretch_color = col;
                end
                
            case 'popts_FS_stretch_thick'
                popts.FS_stretch_thick = str2double(get(wcbo,  'string'));
                
            case 'popts_FS_vis_color'
                col = uisetcolor;
                if size(col,2)>1
                    popts.FS_vis_color = col;
                end
                
            case 'popts_FS_vis_thick'
                popts.FS_vis_thick = str2double(get(wcbo,  'string'));
                
            case 'popts_FS_data_color'
                col = uisetcolor;
                if size(col,2)>1
                    popts.FS_data_color = col;
                end
                
            case 'popts_FS_data_size'
                popts.FS_data_size = str2double(get(wcbo,  'string'));
                
            case 'popts_FS_xmin'
                popts.FS_xmin  = str2double(get(wcbo,  'string'));
                
            case 'popts_FS_xmax'
                popts.FS_xmax  = str2double(get(wcbo,  'string'));
                
            case 'popts_FS_ymin'
                popts.FS_ymin  = str2double(get(wcbo,  'string'));
                
            case 'popts_FS_ymax'
                popts.FS_ymax  = str2double(get(wcbo,  'string'));
                
            %% - Schmalholz & Podladchikov    
            case 'popts_SP_short_color'
                col = uisetcolor;
                if size(col,2)>1
                    popts.SP_short_color = col;
                end
                
            case 'popts_SP_short_thick'
                popts.SP_short_thick = str2double(get(wcbo,  'string'));
                
            case 'popts_SP_vis_color'
                col = uisetcolor;
                if size(col,2)>1
                    popts.SP_vis_color = col;
                end
                
            case 'popts_SP_vis_thick'
                popts.SP_vis_thick = str2double(get(wcbo,  'string'));
                
            case 'popts_SP_data1_color'
                col = uisetcolor;
                if size(col,2)>1
                    popts.SP_data1_color = col;
                end
                
            case 'popts_SP_data1_size'
                popts.SP_data1_size = str2double(get(wcbo,  'string'));
                
            case 'popts_SP_data2_color'
                col = uisetcolor;
                if size(col,2)>1
                    popts.SP_data2_color = col;
                end
                
            case 'popts_SP_data2_size'
                popts.SP_data2_size = str2double(get(wcbo,  'string'));
                
            case 'popts_SP_xmax'
                popts.SP_xmax  = str2double(get(wcbo,  'string'));
                
            case 'popts_SP_ymax'
                popts.SP_ymax  = str2double(get(wcbo,  'string'));
        end
        
        % - Update data
        setappdata(popts_gui_handle, 'popts', popts);
        
        % - Update Uicontrols
        plotting_options('uicontrol_update');
        
        % - Update Main GUI
        plotting_options('opts_apply');
        
    case 'opts_apply'
        %% Apply 
        
        % Get data
        popts = getappdata(popts_gui_handle, 'popts');
        
        % Check if the main figure exist
        fgt_gui_handle = findobj(0, 'tag', 'fgt_gui_handle',        'type', 'figure');
        
        % Update the FGT GUI
        try
            
            % Update plotting options
            setappdata(fgt_gui_handle, 'popts', popts);
            
            mode = getappdata(fgt_gui_handle, 'mode');
            
            % Update Main Plot
            fgt(['step_',num2str(mode),'_update_gui']);
            
%         catch
%           errordlg('Main figure gone.');
        end
        
    case 'save'
        %% Save
        
        % Get data
        popts = getappdata(popts_gui_handle, 'popts');
        
        % Save data
        save(['int',filesep,'popts.mat'],'popts')
        
    case 'restore'
        %% Restore
        
        define_default_plotting_values;
        
        % Load file
        load(['int',filesep,'popts.mat'])
        
        % - Update data
        setappdata(popts_gui_handle, 'popts', popts);
        
        % Update uicontrols
        plotting_options('uicontrol_update');
        
        % - Update Main GUI
        plotting_options('opts_apply');
        
end
end


