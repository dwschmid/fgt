function fgt_data(Action)

%% input check
if nargin==0
    Action = 'initialize';
end

%% find gui
table_gui_handle = findobj(0, 'tag', 'table_gui_handle', 'type', 'figure');


switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(table_gui_handle)
            delete(table_gui_handle);
        end
        
        DefaultUicontrolPosition = get(0, 'DefaultUicontrolPosition');
        b_height                 = DefaultUicontrolPosition(4);
        b_width                  = DefaultUicontrolPosition(3);
        gap                      = 5;
        
        Screensize      = get(0, 'ScreenSize');
        fig_width       = 775;
        fig_height      = 400;%242;
        lpanel_height   = 4*b_height + 4*gap + 3*gap;
       
        % Create dialog window
        table_gui_handle = figure( ...
            'Name' ,'FGT Data Statistics', 'Units','pixels', 'tag','table_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, Screensize(4)/3, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        % Uipanel Table
        Position_fig          	= get(table_gui_handle, 'Position');
        fgt_upanel_table        = uipanel('Parent', table_gui_handle, 'Tag', 'fgt_upanel_table','Title', 'Data Statistics',...
                                          'Units', 'Pixels', 'Position', [gap, lpanel_height+gap, Position_fig(3)-2*gap, fig_height-lpanel_height-gap]);
        
        % Uipanel Controls
        fgt_upanel_control     	= uipanel('Parent', table_gui_handle,   'Tag', 'fgt_upanel_control',   'Title', 'Controls',...
                                          'Units', 'Pixels', 'Position', [gap, gap, fig_width-2*gap, lpanel_height]);
        
        %% -Menu Entries
        %  File
        h1  = uimenu('Parent',table_gui_handle, 'Label','File');
        
        %  Export to Workspace
        uimenu('Parent',h1, 'Label', 'Export to Workspace', 'tag', 'export_workspace', ...
            'Callback', @(a,b) fgt_data('export_workspace'), 'Separator','off', 'enable', 'on', 'Accelerator', 'E');
       
        
        %% -Table
        cnames = {'L','<html>&lambda</html>','A','H','L/H','<html>A/&lambda</html>','<html>H/&lambda</html>'};
                
        % Draw table
        htable = uitable('Parent', fgt_upanel_table,'Tag','table',...
                         'ColumnName', cnames, 'ColumnWidth', {100}, 'FontSize',10,...
                         'Units', 'normalized','Position',[0 0 1 1]);
                     
        uic = uicontextmenu;
        uimenu (uic, 'Label','Copy Table','callback',@copy_table);
        set(htable,'uicontextmenu',uic)
        
        %% -Controls
        
        % Create an 'Up' and a 'Down' button
        % Load the button icon
        icon        = fullfile(matlabroot,'/toolbox/matlab/icons/greenarrowicon.gif');
        [cdata,map] = imread(icon);
        
        % Convert white pixels into a transparent background and black
        map(map(:,1)+map(:,2)+map(:,3)==3) = NaN;
        % Convert into 3D RGB-space
        buttonDown          = ind2rgb(cdata',map);
        buttonDown(:,:,1)   = buttonDown(:,:,2);
        buttonDown(:,:,3)   = buttonDown(:,:,2);
        buttonUp            = ind2rgb(flipud(cdata'),map);
        buttonUp(:,:,1)     = buttonUp(:,:,2);
        buttonUp(:,:,3)     = buttonUp(:,:,2);
        
        % FOLD SELECTION
        % Default fold number
        fold = 1;
        setappdata(table_gui_handle, 'fold_number', fold);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Fold', ...
            'position', [gap, 4*gap+3*b_height-2, b_height+gap, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','fold_number_up',...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'position', [gap, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','fold_number_down',...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'position', [gap, 1*gap,   b_height, b_height],...
            'enable', 'off');
        
        % Set face number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
            'tag','fold_number_text',...
            'position', [gap, 2*gap+1*b_height,  b_height, b_height]);
        
        % INTERFACE SELECTION
        % Default fold number
        face = 1;
        setappdata(table_gui_handle, 'face_number', face);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Face', ...
            'position', [3*gap+b_height, 4*gap+3*b_height-2, b_height+gap, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','face_number_up',...
            'tooltipstring','Upper Interface',...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'position', [3*gap+b_height, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','face_number_down',...
            'tooltipstring','Lower Interface',...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'position', [3*gap+b_height, 1*gap,   b_height, b_height],...
            'enable', 'off');
        
        % Set face number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(face),...
            'tag','face_number_text',...
            'position', [3*gap+b_height, 2*gap+1*b_height,  b_height, b_height]);
        
        % DATA SELECTION
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Data Type','HorizontalAlignment','left', ...
            'position', [fig_width-2*gap-4*gap-3*b_width, lpanel_height-4*gap-b_height, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'Statistical Data';'Individual Folds Data'}, 'value', 1, ...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'tag', 'data_type', 'BackgroundColor','w', ...
            'position', [fig_width-2*gap-2*gap-2*b_width, lpanel_height-3*gap-b_height, 2*b_width, b_height]);
        
        
        % AMPLITUDE METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Amplitude','HorizontalAlignment','left', ...
            'position', [fig_width-2*gap-6*gap-6*b_width, 2*gap+b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2';'3'}, 'value', 1, ...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'tag', 'amplitude_method', 'BackgroundColor','w', ...
            'position', [fig_width-2*gap-5*gap-5*b_width, 2*gap+b_height, b_width, b_height]);
        
        % WAVELENGTH METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Wavelength','HorizontalAlignment','left', ...
            'position', [fig_width-2*gap-4*gap-4*b_width, 2*gap+b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2';'3';'4'}, 'value', 1, ...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'tag', 'wavelength_method', 'BackgroundColor','w', ...
            'position', [fig_width-2*gap-3*gap-3*b_width, 2*gap+b_height, b_width, b_height]);
        
        % THICKNESS METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Thickness','HorizontalAlignment','left', ...
            'position', [fig_width-2*gap-2*gap-2*b_width, 2*gap+b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2'}, 'value', 1, ...
            'callback',  @(a,b)  fgt_data('uicontrol_callback'), ...
            'tag', 'thickness_method', 'BackgroundColor','w', ...
            'position', [fig_width-2*gap-gap-b_width, 2*gap+b_height, b_width, b_height]);

        % Done Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'fgt_data_exit', ...
            'callback',  @(a,b)  close(gcf),...
            'position', [fig_width-2*gap-gap-b_width, gap, b_width, b_height]);
        
        % - Deafault values
        fgt_data('load_values')
        
        % - Buttons enable
        fgt_data('uicontrol_update')
        
    case 'load_values'
        %% DEFAULT VALUES
        
        % Find main gui
        fgt_gui_handle = findobj(0, 'tag', 'fgt_gui_handle', 'type', 'figure');

        % Check if data exists otherwise load a file
        if ~isempty(fgt_gui_handle)
            
            data.Fold    = getappdata(fgt_gui_handle, 'Fold');
            data.amplitude_method  = 1;
            data.wavelength_method = 1;
            data.thickness_method  = 1;
            data.data_type         = 1;
            
        else
            data.Fold  = [];      
        end
        
        % - Update data
        setappdata(table_gui_handle, 'data', data);
        
        
    case 'export_workspace'
        %% EXPORT TO WORKSPACE
        
        %  Get data
        data        = getappdata(table_gui_handle, 'data');
        
        % Export into workspace
        checkLabels = {'Save data named:'};
        varNames    = {'data'};
        items       = {data};
        export2wsdlg(checkLabels,varNames,items,...
            'Save Data to Workspace');    
    
    case 'uicontrol_callback'
        %% UICONTROL CALLBACK
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        if isempty(Whoiscalling)
            return;
        end
        
        %  Get data
        data        = getappdata(table_gui_handle, 'data');
        fold            = getappdata(table_gui_handle, 'fold_number');
        face            = getappdata(table_gui_handle, 'face_number');
        
        switch Whoiscalling
            
            case 'amplitude_method'
                data.amplitude_method      = get(wcbo,  'value');
                
            case 'wavelength_method'
                data.wavelength_method     = get(wcbo,  'value');
                
            case 'thickness_method'
                data.thickness_method      = get(wcbo,  'value');
                
            case 'fold_number_up'
                fold    = fold + 1;
                
            case 'fold_number_down'
                fold    = fold - 1;
                
            case 'face_number_up'
                face    = face + 1;
                
            case 'face_number_down'
                face    = face - 1;
                
            case 'data_type'
                data.data_type              = get(wcbo,  'value');
        end
        
        setappdata(table_gui_handle, 'data', data);
        setappdata(table_gui_handle, 'face_number', face);
        setappdata(table_gui_handle, 'fold_number', fold);
        
        % Controls update
        fgt_data('uicontrol_update')
        
    case 'uicontrol_update'
        %% UICONTROL UPDATE
        
        %  Get data
        data            = getappdata(table_gui_handle, 'data');
        
        if ~isempty(data.Fold)
            
            Fold            = data.Fold;
            fold            = getappdata(table_gui_handle, 'fold_number');
            face            = getappdata(table_gui_handle, 'face_number');
            
            set(findobj(table_gui_handle, 'tag', 'data_statistics'),           'value',  data.data_type);
            set(findobj(table_gui_handle, 'tag', 'fold_number_text'),          'string', num2str(fold));
            set(findobj(table_gui_handle, 'tag', 'face_number_text'),          'string', num2str(face));
            set(findobj(table_gui_handle, 'tag', 'amplitude_method'),          'value',  data.amplitude_method);
            set(findobj(table_gui_handle, 'tag', 'wavelength_method'),         'value',  data.wavelength_method);
            set(findobj(table_gui_handle, 'tag', 'thickness_method'),          'value',  data.thickness_method);
            
            % Data
            data.L   = 2*(Fold(fold).Face(face).Arclength.Full(Fold(fold).Face(face).Inflection(2:end))-Fold(fold).Face(face).Arclength.Full(Fold(fold).Face(face).Inflection(1:end-1)));
            data.lam = Fold(fold).Face(face).Wavelength(data.wavelength_method).Value;
            data.A   = Fold(fold).Face(face).Amplitude(data.amplitude_method).Value;
            
            if data.thickness_method ==1
                data.H   = Fold(fold).Thickness.Local(face).Value;
            elseif data.thickness_method ==2
                data.H   = Fold(fold).Thickness.Average;
            end
            
            data.stat = [min(data.L)  min(data.lam)  min(data.A)  min(data.H)  min(data.L./data.H)  min(data.A./data.lam)  min(data.H./data.lam);...
                max(data.L)  max(data.lam)  max(data.A)  max(data.H)  max(data.L./data.H)  max(data.A./data.lam)  max(data.H./data.lam);...
                mean(data.L) mean(data.lam) mean(data.A) mean(data.H) mean(data.L./data.H) mean(data.A./data.lam) mean(data.H./data.lam);...
                std(data.L)  std(data.lam)  std(data.A)  std(data.H)  std(data.L./data.H)  std(data.A./data.lam)  std(data.H./data.lam)];
            
            data.indi = [data.L; data.lam; data.A;  data.H;  data.L./data.H; data.A./data.lam; data.H./data.lam]';
            
            % Update table
            if data.data_type==1
                
                rnames = {'min','max','mean','std'};
                set(findobj(table_gui_handle,'tag','table'),'RowName', rnames);
                set(findobj(table_gui_handle,'tag','table'),'Data',data.stat);
            else
                rnames = num2cell(1:size(data.indi,1));
                set(findobj(table_gui_handle,'tag','table'),'RowName', rnames);
                set(findobj(table_gui_handle,'tag','table'),'Data',data.indi);
            end
            
            % Setup data
            setappdata(table_gui_handle, 'data', data);

        end
        
        % - Buttons enable
        fgt_data('buttons_enable')
        
    case 'buttons_enable'
        %% BUTTONS ENABLE
        
        %  Get data
        data            = getappdata(table_gui_handle, 'data');
        fold            = getappdata(table_gui_handle, 'fold_number');
        face            = getappdata(table_gui_handle, 'face_number');
        
        if ~isempty(data.Fold)
            
            Fold            = data.Fold;
            
            set(findobj(table_gui_handle, 'tag', 'fold_number_up'),         'enable', 'off');
            set(findobj(table_gui_handle, 'tag', 'fold_number_down'),       'enable', 'off');
            
            if fold < size(Fold,2)
                fold_number = ['Fold number ',num2str(fold+1)];
                set(findobj(table_gui_handle, 'tag', 'fold_number_up'),   'enable', 'on');
            end
            if fold > 1
                fold_number = ['Fold number ',num2str(fold-1)];
                set(findobj(table_gui_handle, 'tag', 'fold_number_down'), 'enable', 'on');
            end
            
            if face == 1
                set(findobj(table_gui_handle, 'tag', 'face_number_up'),   'enable', 'on' );
                set(findobj(table_gui_handle, 'tag', 'face_number_down'), 'enable', 'off');
            else
                set(findobj(table_gui_handle, 'tag', 'face_number_down'), 'enable', 'on' );
                set(findobj(table_gui_handle, 'tag', 'face_number_up'),   'enable', 'off');
            end
            
        else
            set(findobj(table_gui_handle, 'tag', 'amplitude_method'),       'enable', 'off');
            set(findobj(table_gui_handle, 'tag', 'wavelength_method'),      'enable', 'off');
            set(findobj(table_gui_handle, 'tag', 'thickness_method'),       'enable', 'off');
            
        end
end

    function copy_table(obj, event_obj)
        %% f_copy_table
        
        % Get data
        table_data = get(findobj(table_gui_handle,'tag','table'), 'Data');
        data       = getappdata(table_gui_handle, 'data');
        
        if data.data_type == 1
            % Statistical data
            str = sprintf ( '\t L\t lam\t A\t H\t L/H\t A/lam\t H/lam');
            str = sprintf( '%s\n', str );
            
            rnames = {'min','max','mean','std'};
            for i = 1:size(table_data,1)
                str = sprintf ( '%s', str, rnames{i});
                str = sprintf( '%s\t', str );
                for j = 1:size(table_data,2)
                    str = sprintf ( '%s%f\t', str, table_data(i,j) );
                end
                str = sprintf( '%s\n', str );
            end
            
        else
            % Individual data
            str = sprintf ( '\t L\t lam\t A\t H\t L/H\t A/lam\t H/lam\t');
            str = sprintf( '%s\n', str );
            for i = 1:size(table_data,1)
                str = sprintf ( '%s%f\t', str, i);
                for j = 1:size(table_data,2)
                    str = sprintf ( '%s%f\t', str, table_data(i,j) );
                end
                str = sprintf( '%s\n', str );
            end
        end
        
        clipboard('copy', str)
        
    end
end