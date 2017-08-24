function fgt(Action)
% FGT - Fold Geometry Toolbox
%
% Original author:    Schmid
% Last committed:     $Revision: 141 $
% Last changed by:    $Author: martaada $
% Last changed date:  $Date: 2012-12-18 12:58:15 +0100 (Tue, 18 Dec 2012) $
%--------------------------------------------------------------------------

%% INPUT CHECK
if nargin==0
    Action = 'initialize';
end

%% FIND GUI
fgt_gui_handle = findobj(0, 'tag', 'fgt_gui_handle');  

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Add required folders
        if ~isdeployed
            fgt_path    =  fileparts(mfilename('fullpath'));
            addpath(fullfile(fgt_path));
            addpath(fullfile(fgt_path, 'int'));
            addpath(fullfile(fgt_path, 'hlp'));
            addpath(fullfile(fgt_path, 'ext', 'gaimc'));
            addpath(fullfile(fgt_path, 'ext', 'GUILayoutToolbox', 'layout'));
            addpath(fullfile(fgt_path, 'ext', 'mesh2D'));
            addpath(fullfile(fgt_path, 'ext', 'selfintersect'));
        end
        
        %  Delete figure if it already exists
        if ~isempty(fgt_gui_handle)
            delete(fgt_gui_handle);
        end
        
        %  Figure Setup
        Screensize      = get(0, 'ScreenSize');
        x_res           = Screensize(3);
        y_res           = Screensize(4);
        gui_width       = 0.85*x_res;
        gui_height      = 0.85*y_res;
        gui_x           = (x_res-gui_width)/2;
        gui_y           = (y_res-gui_height)/2;
        
        fgt_gui_handle = figure(...
            'Units', 'pixels','position', round([gui_x gui_y gui_width  gui_height]),...
            'Name', 'Fold Geometry Toolbox by M. Adamuszek, D. W. Schmid, & M. Dabrowski', 'tag', 'fgt_gui_handle',...
            'NumberTitle', 'off', 'ToolBar', 'none',  'DockControls', 'off','MenuBar', 'none', ...
            'Color', get(0, 'DefaultUipanelBackgroundColor'),...
            'WindowButtonDownFcn', @(a,b) fgt('step_1_load'), ...
            'Renderer', 'zbuffer'); %zbuffer so that contour plots work
        
        %  File
        h1  = uimenu('Parent',fgt_gui_handle, 'Label','File');
        %  Load
        uimenu('Parent',h1, 'Label', 'Load Data', ...
            'Callback', @(a,b) fgt('step_1_load'), 'Separator','off', 'enable', 'on', 'Accelerator', 'L');
        %  Save
        uimenu('Parent',h1, 'Label', 'Save Data', ...
            'Callback', @(a,b) fgt('save'), 'Separator','off', 'enable', 'on', 'Accelerator', 'S');
        %  Export
        uimenu('Parent',h1, 'Label', 'Export Data', ...
            'Callback', @(a,b) fgt('export_workspace'), 'Separator','off', 'enable', 'on', 'Accelerator', 'E');
        %  Print
        uimenu('Parent',h1, 'Label', 'Save Figure', ...
            'Callback', @(a,b) filemenufcn(gcbf,'FileSaveAs'), 'Separator','on', 'enable', 'on', 'Accelerator', 'P');
        %  Exit
        uimenu('Parent',h1, 'Label', 'Exit', ...
            'Callback', @(a,b) close(gcf), 'Separator','on', 'enable', 'on', 'Accelerator', 'Q');
        
        %  Edit
        h2  = uimenu('Parent',fgt_gui_handle, 'Label','Edit');
        
        %  Figure Setting
        uimenu('Parent',h2, 'Label', 'Plotting Options', ...
            'Callback', @(a,b) plotting_options, 'Separator','off', 'enable', 'on', 'Accelerator', 'O');
        
        %  Help
        h3  = uimenu('Parent',fgt_gui_handle, 'Label','Help');
        uimenu('Parent',h3, 'Label', 'Help', ...
            'Callback', @(a,b) fgt('help'), 'Separator','off', 'enable', 'on', 'Accelerator', 'H');
        
        %  Default Uicontrol Size
        DefaultUicontrolPosition = get(0, 'DefaultUicontrolPosition');
        b_height                 = DefaultUicontrolPosition(4) + 2;
        b_width                  = DefaultUicontrolPosition(3);
        
        %  Gap
        gap                    	= 5;
        
        %  Save default sizes in figure
        setappdata(fgt_gui_handle, 'b_height', b_height);
        setappdata(fgt_gui_handle, 'b_width',  b_width);
        setappdata(fgt_gui_handle, 'gap',      gap);
        
        %  Lower Part is 4 buttons heigh + gap, upper part rest
        lpanel_height          	= 4*b_height + 5*gap + 3*gap;
        
        %  Uipanel Top
        Position_fig          	= get(fgt_gui_handle, 'Position');
        uipanel('Parent', fgt_gui_handle, 'Tag', 'fgt_upanel_top',     'Title', 'Fold Geometry Toolbox', 'Units', 'Pixels', 'Position', [gap, lpanel_height+gap, Position_fig(3)-2*gap, Position_fig(4)-lpanel_height-gap]);
        
        % Uipanel Comment
        fgt_upanel_comment     	= uipanel('Parent', fgt_gui_handle, 'Tag', 'fgt_upanel_comment', 'Title', 'Comment',               'Units', 'Pixels', 'Position', [gap, gap, Position_fig(3)/5*3-1.5*gap, lpanel_height]);
        
        % Uipanel Controls
        fgt_upanel_control     	= uipanel('Parent', fgt_gui_handle, 'Tag', 'fgt_upanel_control', 'Title', 'Controls',              'Units', 'Pixels', 'Position', [Position_fig(3)/5*3+gap, gap, Position_fig(3)/5*2-2*gap, lpanel_height]);
        
        % Add Comment Field
        uicontrol('Parent', fgt_upanel_comment, 'style', 'edit', 'HorizontalAlignment', 'Left', ...
            'tag', 'uc_comment',...
            'callback',  @(a,b) fgt('comment'), ....
            'Units', 'normalized', 'Position', [0 0 1 1], ...
            'BackGroundColor', 'w', ...
            'Max', 2, 'Min', 0); %Enables multi lines
        
        % Set Units to Normalized - Resizing
        % TODO: Do we need this?
        % units_normalized;
        
        %  Default values
        fgt('default_values')
        
        % Put FGT into step_1 mode
        fgt('step_1');
       
    case 'default_values'
        %% DEFAULT VALUES
        
        %  Set the possible values of nodes used for curvature calculations
        setappdata(fgt_gui_handle, 'Order', [3,5,7]);
        
        %  Set the correction mode
        setappdata(fgt_gui_handle, 'Manual', 0);
        
        %  Set the plotting values
        load('popts.mat');
        
        %  Set the plotting options parameters
        setappdata(fgt_gui_handle, 'popts', popts);
        
        
    case 'save'
        %% SAVE
        %  Get data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        
        if isempty(Fold)
            warndlg('No data to save!', 'Fold Geometry Toolbox');
            return;
        end
        
        [Filename, Pathname] = uiputfile(...
            {'*.mat'},...
            'Save as');
        
        if ~(length(Filename)==1 && Filename==0)
            save([Pathname, Filename], 'Fold');
        end
        
    case 'export_workspace'
        %% EXPORT
        %  Get data
        Fold        = getappdata(fgt_gui_handle, 'Fold');
        
        % Export into workspace
        checkLabels = {'Save data named:'};
        varNames    = {'Fold'};
        items       = {Fold};
        export2wsdlg(checkLabels,varNames,items,...
            'Save FGT Data to Workspace');
        
    case 'help'
        %% HELP
        Path_fgt_help   = which('fgt_help.pdf');
        web(Path_fgt_help, '-browser'); 
        
    case 'comment'
        %% COMMENT
        %  Update comment field of Fold
        Comment             = get(gco, 'String');
        Fold                = getappdata(fgt_gui_handle, 'Fold');
        Fold(1).Comment     = Comment;
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        
    case 'step_1'
        %% STEP_1
        
        % Put FGT into step_1 mode
        setappdata(fgt_gui_handle, 'mode', 1);
        set(fgt_gui_handle,'windowbuttonmotionfcn',[]);
        
        %  Delete all axes and UIContainers that may exist
        delete(findobj(fgt_gui_handle, 'type', 'axes'));
        delete(findobj(fgt_gui_handle, 'type', 'UIContainer'));
        
        %  Find and update top panel
        fgt_upanel_top  =  findobj(fgt_gui_handle, 'tag', 'fgt_upanel_top');
        set(fgt_upanel_top, 'Title', 'Input Data');
        
        %  Setup new axes
        achse = axes('Parent', fgt_upanel_top);
        box(achse,'on')
        
        %  Find the control panel
        fgt_upanel_control  = findobj(fgt_gui_handle, 'Tag', 'fgt_upanel_control');
        
        %  Delete all children
        uc_handles   = findobj(fgt_upanel_control, 'Type', 'uicontrol');
        delete(uc_handles);
        
        %  Default sizes
        b_height    = getappdata(fgt_gui_handle, 'b_height');
        b_width     = getappdata(fgt_gui_handle, 'b_width');
        gap         = getappdata(fgt_gui_handle, 'gap');
        
        %  Size of panel
        set(fgt_upanel_control, 'Units', 'Pixels');
        Position    = get(fgt_upanel_control, 'Position');
        
        %  Next Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Next', ...
            'tag', 'next', ...
            'callback', @(a,b) fgt('step_1_next'), ... %Digitization may be going on
            'position', [Position(3)-gap-b_width, gap, b_width, b_height], ...
            'enable', 'off');
        
        %  Load Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Load', ...
            'callback',  @(a,b) fgt('step_1_load'), ...
            'position', [Position(3)-gap-b_width, 2*gap+b_height, b_width, b_height]);
        
        % Set Units to Normalized - Resizing
        units_normalized;
        
        %  Update GUI in case we already have data (Back...)
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        if ~isempty(Fold)
            fgt('step_1_update_gui');
        end
        
    case 'step_1_update_gui'
        %% - step_1_update_gui

        %  Activate next button
        set(findobj(fgt_gui_handle, 'tag', 'next'), 'enable', 'on');

        %  Get data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        popts   = getappdata(fgt_gui_handle, 'popts');
        
        %  Check if fold has comment data
        if ~isfield(Fold, 'Comment') || isempty(Fold(1).Comment)
            Fold(1).Comment    = 'Leave your comments here';
        end
        set(findobj(fgt_gui_handle, 'tag', 'uc_comment'), 'String', Fold(1).Comment);
        
        %  Find plotting axes
        achse   = findobj(fgt_gui_handle, 'type', 'axes');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        cla(achse, 'reset');
        hold(achse, 'on');
        
        if ~isfield(Fold, 'PICTURE')
            %  SVG or MAT
            % Check if fold self intersects
            for fold = 1:length(Fold)
                
                % Plot interfaces
                plot([Fold(fold).Face(1).X.Ori fliplr(Fold(fold).Face(2).X.Ori)], [Fold(fold).Face(1).Y.Ori fliplr(Fold(fold).Face(2).Y.Ori)],...
                     'o','Color', popts.face_color_active,'MarkerSize',2, 'Parent', achse);
                
                x0 = selfintersect( [Fold(fold).Face(1).X.Ori fliplr(Fold(fold).Face(2).X.Ori) ] , [Fold(fold).Face(1).Y.Ori fliplr(Fold(fold).Face(2).Y.Ori) ] );
                
                if ~isempty(x0)
                    
                    % Flip data of one fold interface
                    Fold(fold).Face(2).X.Ori = fliplr(Fold(fold).Face(2).X.Ori);
                    Fold(fold).Face(2).Y.Ori = fliplr(Fold(fold).Face(2).Y.Ori);
                    
                    [x0, y0] = selfintersect( [Fold(fold).Face(1).X.Ori fliplr(Fold(fold).Face(2).X.Ori)] , [Fold(fold).Face(1).Y.Ori fliplr(Fold(fold).Face(2).Y.Ori)] );
                    
                    % Save data
                    setappdata(fgt_gui_handle, 'Fold', Fold);
                    
                    if ~isempty(x0)
                        plot(x0,y0,'or')
                        warndlg('The fold interface self intersects.', 'Next not possible!', 'modal');
                        break;
                    end
                    
                end
            end
            
            %  Plot
            for i=1:length(Fold)
                fh  = fill([Fold(i).Face(1).X.Ori fliplr(Fold(i).Face(2).X.Ori)], [Fold(i).Face(1).Y.Ori fliplr(Fold(i).Face(2).Y.Ori)], 'k', 'Parent', achse);
                set(fh, 'EdgeColor', popts.face_color_active, 'FaceColor', popts.fold_color_active);
            end
            axis(achse, 'equal');
            box(achse,  'on');
            zoom(fgt_gui_handle, 'off');
            
        else
            % PICTURE
            % Need to flip image for normal axes convention
            image([1, size(Fold(1).PICTURE,2)], [1, size(Fold(1).PICTURE,1)], flip(Fold(1).PICTURE), 'Parent', achse);
            set(achse,  'YDir', 'normal');
            box(achse,  'on');
            axis(achse, 'equal');
            axis(achse, 'tight');
            zoom(fgt_gui_handle, 'off');
            title(achse, {'Digitize even number of fold interfaces with at least 7 points each.', '(Enter = Done, Delete = Remove Point, +/- = Zoom In/Out, Spacebar+Mouse Move = Pan, Escape = Discard Digitization)'})
            
            % Already digitized layers
            for fold=1:length(Fold)
                if isfield(Fold(fold), 'Face')
                    for face=1:length(Fold(fold).Face)
                        plot( Fold(fold).Face(face).X.Ori, Fold(fold).Face(face).Y.Ori, 'LineStyle', '-', 'Color', 'k', 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
                    end
                end
            end
            
            mode    = 1;
            fold    = length(Fold);
            if isfield(Fold(fold), 'Face')
                face    = length(Fold(fold).Face);
            else
                face    = 0;
            end
            while mode==1 && isfield(Fold, 'PICTURE') % It could be that we are back in mode 1 but have loaded non-picture data
                [X,Y, Status]   = dwsdt();
               
                % It is possible that the Next button was pressed and the
                % GUI is on the second page
                % Only process if still on first page
                mode = getappdata(fgt_gui_handle, 'mode');
                
                if mode == 1
                    if ~isempty(X) && strcmp(Status, 'Done')
                        % Add new interface
                        face = face + 1;
                        if face>2
                            face    = 1;
                            fold    = fold+1;
                        end

                        Fold(fold).Face(face).X.Ori = X;
                        Fold(fold).Face(face).Y.Ori = Y;
                        
                        %  Adding more points requires recalculation of NIP
                        %  Empty corresponding variable 
                        if isfield(Fold(1).Face(1), 'WindowSizes')                            
                            Fold(1).Face(1).WindowSizes = [];
                        end
                        
                        %  Appdate Storage
                        setappdata(fgt_gui_handle, 'Fold', Fold);
                        
                        %  Plot the
                        hold on;
                        plot(X,Y, 'LineStyle', '-', 'Color', 'k', 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
                        
                        % Check if fold self intersects
                        if face == 2
                            for fold = 1:length(Fold)
                                x0 = selfintersect( [Fold(fold).Face(1).X.Ori fliplr(Fold(fold).Face(2).X.Ori)] , [Fold(fold).Face(1).Y.Ori fliplr(Fold(fold).Face(2).Y.Ori)] );
                                if ~isempty(x0)
                                    warndlg('The fold interface self intersects. Please digitize the fold once more.', 'Error!', 'modal');
                                    Fold = rmfield(Fold, 'Face');
                                    setappdata(fgt_gui_handle, 'Fold', Fold);
                                    fgt('step_1_update_gui');
                                    break;
                                end
                            end
                        end
                        
                    elseif strcmp(Status, 'Abort')
                        % Remove all previously digitized data
                        if isfield(Fold, 'Face')
%                             Fold = rmfield(Fold, 'Face');
%                             setappdata(fgt_gui_handle, 'Fold', Fold);
%                             fgt('step_1_update_gui');
                            break;
                        end                        
                        
                    end                    
                end                
            end
        end
        

    case 'step_1_load'
        %% - step_1_load
        
        %  Check if FGT in mode 1 - otherwise put it there
        if ~(getappdata(fgt_gui_handle, 'mode')==1)
            fgt('step_1');
        end
        
        %  Load in files
        [filename, pathname] = uigetfile({'*.mat;*.svg;*.jpg;*.png', 'FGT Input Files'},'Pick a file');
        
        if length(filename)==1 && filename==0
            return;
        end
  
        try
            switch filename(end-2:end)
                case 'mat'
                    Input_data  = load([pathname,filename]);
                    Fold        = Input_data.Fold;
                    
                case 'svg'
                    Fold        = load_fgt_svg([pathname,filename]);
                    
                otherwise
                    % Picture Format
                    Fold.PICTURE    = imread([pathname,filename]);
            end
        catch err
            errordlg(err.message, 'Fold Load Error');
            return;
        end
        
        %  Write data into storage
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        %  Non-Picture stuff
        if ~isfield(Fold, 'PICTURE')
            % Normalize data and initialize rest
            norminitialize_fold_structure;
        
            %    Enforce finish of digitization
            dwsdt('Finish');
            
            % Set figure into normal mode (non-picture), 
            % case we are coming back from picture digitization 
            set(fgt_gui_handle, 'WindowButtonDownFcn', []);
            set(fgt_gui_handle, 'Pointer', 'arrow');
        end
        
        %  Update GUI
        fgt('step_1_update_gui');
                
        %  Deactivate WindowButtonDownFcn
        set(fgt_gui_handle, 'WindowButtonDownFcn', []);
        
    case 'step_1_next'
        %% - step_1_next
        %    This is required because the GUI may be in digitization mode
        
        %    Enforce finish of digitization
        dwsdt('Finish');
        
        % Check if enough interfaces are digitized
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        if ~isempty(Fold) && isfield(Fold, 'Face') && length(Fold(end).Face)==2
            norminitialize_fold_structure;
        else
            warndlg('Digitize even number of fold interfaces.', 'Next not possible!', 'modal');
            return;
        end
        
        % Make sure that every interface has 7 points
        for fold=1:length(Fold)
            for face=1:2
                if length(Fold(fold).Face(face).X.Ori)<7
                    warndlg('Every fold interface must consist of at least 7 points.', 'Next not possible!', 'modal');
                    return;
                end
            end
        end
              
        % Put Pointer Back 
        set(fgt_gui_handle, 'Pointer', 'arrow');
        
        % Next Panel
        fgt('step_2');
        
    case 'step_2'
        %% STEP_2: Curvature smoothing
        
        % Put FGT into step_2 mode
        setappdata(fgt_gui_handle, 'mode', 2);
        
        %  Delete all axes and UIContainers that may exist
        delete(findobj(fgt_gui_handle, 'type', 'axes'));
        delete(findobj(fgt_gui_handle, 'type', 'UIContainer'));
        
        %  Setup new axes
        fgt_upanel_top  = findobj(fgt_gui_handle, 'tag', 'fgt_upanel_top');
        set(fgt_upanel_top, 'Title', 'Hinge & Inflection Points');
        
        %Fold
        uc_1            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.0 1/2 2/3 1/2]);
        axes('Parent', uc_1, 'tag', 'axes_1');
        box on;
        
        %Curvature
        uc_2            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.0 0/2 2/3 1/2]);
        axes('Parent', uc_2, 'tag', 'axes_2');
        box on;
        
        %CLICK
        uc_3            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [2/3 0 1/3 1]);
        axes('Parent', uc_3, 'tag', 'axes_3');
        box on;
        
        %  Find the control panel
        fgt_upanel_control  = findobj(fgt_gui_handle, 'Tag', 'fgt_upanel_control');
        
        % Delete all children
        uc_handles   = findobj(fgt_upanel_control, 'Type', 'uicontrol');
        delete(uc_handles);
        
        %  Default sizes
        b_height    = getappdata(fgt_gui_handle, 'b_height');
        b_width     = getappdata(fgt_gui_handle, 'b_width');
        gap         = getappdata(fgt_gui_handle, 'gap');
        
        % Size of panel
        set(fgt_upanel_control, 'Units', 'Pixels');
        Position    = get(fgt_upanel_control, 'Position');
        
        %  Create an 'Up' and a 'Down' button
        if isempty(getappdata(fgt_gui_handle, 'buttonUp'))
            
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
            
            setappdata(fgt_gui_handle, 'buttonUp',   buttonUp);
            setappdata(fgt_gui_handle, 'buttonDown', buttonDown);
        end
        
        
        % FOLD SELECTION
        % Default fold number
        fold = 1;
        setappdata(fgt_gui_handle, 'fold_number', fold);
        
        %  Get button icons
        buttonUp         = getappdata(fgt_gui_handle, 'buttonUp');
        buttonDown       = getappdata(fgt_gui_handle, 'buttonDown');
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Fold', ...
            'position', [Position(2)+gap, 4*gap+3*b_height-2, b_height, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','fold_number_up',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','fold_number_down',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 1*gap,            b_height, b_height],...
            'enable', 'off');
        % Set fold number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
            'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
        
        
        % INTERFACE SELECTION
        % Default fold number
        face = 1;
        setappdata(fgt_gui_handle, 'face_number', face);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Face', ...
            'position', [Position(2)+3*gap+b_height, 4*gap+3*b_height-2, b_height+gap, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','face_number_down',...
            'callback',  @f_number, ...
            'position', [Position(2)+3*gap+b_height, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','face_number_up',...
            'callback',  @f_number, ...
            'position', [Position(2)+3*gap+b_height, 1*gap,   b_height, b_height],...
            'enable', 'off');
        
        % Set face number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(face),...
            'position', [Position(2)+3*gap+b_height, 2*gap+1*b_height,  b_height, b_height]);
        
        
        %  Get Data
        Fold        = getappdata(fgt_gui_handle, 'Fold');
        
        % HINGE METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Hinge', ...
            'position', [Position(3)-2*gap-2*b_width, 2*gap+b_height, b_width, b_height]);
        
        % Button
        ibutton = sprintf('1-curvature extreme\n2-polynomial extreme');
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2'}, 'value', Fold(1).hinge_method, ...
            'callback',  @(a,b)  fgt('step_2_update_gui'), ...
            'tag', 'step_2_hinge', 'BackgroundColor','w', ...
            'tooltipstring', ibutton,...
            'position', [Position(3)-gap-b_width, 2*gap+b_height, b_width, b_height]);
        
        
        % 'SMALL AREAS'
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Small area (%)', ...
            'position', [Position(3)-8*gap-2*b_width, 3*gap+2*b_height, b_width+6*gap, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', num2str(Fold(1).fraction*100), ...
            'callback',  @(a,b)  fgt('step_2_update_gui'), ...
            'tag', 'step_2_small_area_fraction', 'BackgroundColor','w', ...
            'tooltipstring', 'Must be in interval 0..100',...
            'position', [Position(3)-gap-b_width, 3*gap+2*b_height, b_width, b_height]);
        
        
        % 'ORDER'
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Order', ...
            'position', [Position(3)-3*gap-2*b_width, 4*gap+3*b_height, b_width, b_height]);
        
        % Button
        Order = getappdata(fgt_gui_handle,'Order');
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'3';'5';'7'}, 'value', find(Fold(1).order == Order), ...
            'callback',  @(a,b)  fgt('step_2_update_gui'), ...
            'tag', 'step_2_order', 'BackgroundColor','w', ...
            'tooltipstring', 'Number of nodes needed for curvature calculation',...
            'position', [Position(3)-gap-b_width, 4*gap+3*b_height, b_width, b_height]);
        
        
        % ZOOM ON
        % Button
        izoom = sprintf('Mark the checkbox to activate zoom\nTo zoom in - click in the picture or use the mouse scroll\nTo zoom out - double click or use the mouse scroll');
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'Zoom on', 'Value', 0,...
            'callback',  @fgt_zoom, ...
            'tag', 'step_2_zoomon', ...
            'tooltipstring', izoom,...
            'position', [Position(2)+4*gap+2*b_height, gap, 2*b_width, b_height]);
        zoom off;
        
        % FILTER INDIVIDUAL INTERFACES
        % Button
        ifilter = sprintf('Mark the checkbox to assign a filter width for the individual interfaces');
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'Filter by Interface', 'Value', Fold(1).individual_filter,...
            'callback',  @f_individual, ...
            'tag', 'step_2_individual', ...
            'tooltipstring', ifilter,...
            'position', [Position(2)+6*gap+5*b_height, gap, 2*b_width, b_height]);
        
        % MANUAL
        Manual = getappdata(fgt_gui_handle, 'Manual');
        %User-defined button
        ifilter = sprintf('Mark the checkbox to define hinges and inflection points manually');
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'User-defined points', 'Value', Manual,...
           'callback',  @(a,b) fgt('step_2_choose'), ...
           'tag', 'step_2_manual', ...
           'tooltipstring', ifilter,...
           'position', [Position(2)+8*gap+10*b_height, gap, 2*b_width, b_height]);
        
        
        % BUTTONS
        % Back Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Back', ...
            'callback',  @(a,b) fgt('step_1'), ...
            'position', [Position(3)-2*gap-2*b_width, gap, b_width, b_height]);
        
        % Next Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Next', ...
            'tag', 'next', ...
            'callback',  @(a,b) fgt('step_3'), ...
            'position', [Position(3)-gap-b_width, gap, b_width, b_height], ...
            'enable', 'off');
        
        % Set Units to Normalized - Resizing
        units_normalized;
        
        %  Update GUI
        fgt('step_2_choose');
        
    case 'step_2_choose'
        %% - choose_step_2
        
        %  Get Data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        Manual  = get(findobj(fgt_gui_handle, 'tag', 'step_2_manual'),'value');
        setappdata(fgt_gui_handle, 'Manual', Manual); 
        
        %  Update GUI
        if Manual == 0
            % Modify callback on next button
            set(findobj(fgt_gui_handle, 'tag', 'next'),'callback',@(a,b) fgt('step_3'));
            % Choose step 2
            fgt('step_2_update_gui');
        else
            % Modify callback on next button
            set(findobj(fgt_gui_handle, 'tag', 'next'),'callback',@(a,b) fgt('step_22_curv_analysis'));
            % Choose step 2
            fgt('step_22_update_gui');
        end
        
    
    case 'step_2_update_gui'
        %% - step_2_update_gui
        
        % Put FGT into step_2 mode
        setappdata(fgt_gui_handle, 'mode', 2);
        
        %  Get Data
        Fold            = getappdata(fgt_gui_handle, 'Fold');
        fold            = getappdata(fgt_gui_handle, 'fold_number');
        face            = getappdata(fgt_gui_handle, 'face_number');
        Order           = getappdata(fgt_gui_handle, 'Order');
        Filt            = get(findobj(fgt_gui_handle, 'tag', 'step_2_individual'),'value');
        Manual          = get(findobj(fgt_gui_handle, 'tag', 'step_2_manual'),'value');
        popts           = getappdata(fgt_gui_handle, 'popts');
        
        %  Read data
        hinge_method    = get(findobj(fgt_gui_handle, 'tag', 'step_2_hinge'),  'value');
        fraction        = str2double(get(findobj(fgt_gui_handle, 'tag', 'step_2_small_area_fraction'),  'string'))/100;
        order           = Order(get(findobj(fgt_gui_handle, 'tag', 'step_2_order'),  'value'));
        
        
        % Check if thickness data exist or needs to be calculated
        if isfield(Fold,'Thickness')
            setappdata(fgt_gui_handle, 'Thickness_calculation', 0);
        else
            setappdata(fgt_gui_handle, 'Thickness_calculation', 1);
        end
        
        % Minimum size
        if fraction > 1 || fraction < 0
            eh = errordlg('Value of the fraction has to be in range from 0 to 100', 'FGT - Error', 'modal');
            uiwait(eh);
        end
        
        % Set a flag if the curvature needs to be (re)calculated
        flag = 0;
        if ~isfield(Fold(1).Face(1),'WindowSizes') || isempty(Fold(1).Face(1).WindowSizes)
            flag = 1;
        elseif Fold(1).fraction ~= fraction
            flag = 1;
        elseif Fold(1).order ~= order
            flag = 1;
        end
        
        % Assign new valuess to the structure
        Fold(1).hinge_method    = hinge_method;
        Fold(1).fraction        = fraction;
        Fold(1).order           = order;
        
        if flag == 1
            
            %  Calculate Effect of Filter Width
            h  = waitbar(0,'Calculate the NIP-FW diagram.');
            hw = findobj(h,'Type','Patch');
            set(hw,'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.4 0.4 0.4])
            for i = 1:length(Fold)
                for j = 1:2
                    [Fold(i).Face(j).WindowSizes, Fold(i).Face(j).NIP] = window_size(Fold(i).Face(j).X.Norm, Fold(i).Face(j).Y.Norm, Fold(1).fraction, size(Fold,2), i, j, Fold(1).order);
                end
            end
            close(h)
            
            % Note that thickness needs to be recalculated
            setappdata(fgt_gui_handle, 'Thickness_calculation', 1);
            
        end
        
        %  FILTER WIDTH PLOT (NIP-FW)
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_3');
        
        %  Only plot if this axes is empty, i.e. the data was not plotted yet
        h = getappdata(achse, 'handle_line');
        if isempty(h) || ( Manual == 0 && sum(get(achse,'XColor'))~=0 )
            flag = 1;
        end
        
        
        if flag == 1 || isempty(get(achse,'Children'))
            cla(achse);
            hold(achse, 'on');
            
            
            % Plot all as inactive
            count = 0;
            for i = 1:length(Fold)
                for j = 1:2
                    if i == fold && j == face
                        active = count;
                    end
                    
                    % - Plot analysis of the curvature without smoothing
                    ph(count+1) = plot(Fold(i).Face(j).WindowSizes, Fold(i).Face(j).NIP.Ori, 'o', 'MarkerSize', popts.NIPFW_size_marker_inactive,...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', popts.NIPFW_color_marker_inactive,...
                        'Parent', achse,'Hittest','off', 'PickableParts', 'none');
                    % - Plot anaysis of the smoothed curvature
                    ph(count+2) = plot(Fold(i).Face(j).WindowSizes, Fold(i).Face(j).NIP.Smoothed, 'o', 'MarkerSize', popts.NIPFW_thick_line_inactive,...
                        'MarkerEdgeColor', popts.NIPFW_color_marker_inactive,...
                        'Parent', achse,'Hittest','off', 'PickableParts', 'none');
                    count = count + 2;
                end
            end
            
            % Plot active
            % - Plot analysis of the curvature without smoothing
            set(ph(active+1), 'MarkerSize', popts.NIPFW_size_marker_active,'MarkerEdgeColor', 'k', 'MarkerFaceColor', popts.NIPFW_color_marker_active,...
                'Parent', achse,'Hittest','off', 'PickableParts', 'none');       
            % - Plot anaysis of the smoothed curvature
            set(ph(active+2), 'MarkerSize', popts.NIPFW_thick_line_active,'MarkerEdgeColor', popts.NIPFW_color_line_active,...
                'Parent', achse,'Hittest','off', 'PickableParts', 'none');
            
            % Set plot handle
            setappdata(achse, 'plot_handle',  ph);
            
            set(achse, 'xscale', 'log');
            axis(achse, 'square');
            xlabel(achse, 'Filter Width','Color', [0 0 0])
            ylabel(achse, '# Inflection Points','Color', [0 0 0])
            box(achse, 'on');
            set(achse,'XColor', [0 0 0],'YColor', [0 0 0])
            
            % % Add fake points and lines to the plot to used in the legend
            handle_legend(1)   = plot(0, -1, 'o', 'MarkerSize', popts.NIPFW_size_marker_inactive,'MarkerEdgeColor', 'k', 'MarkerFaceColor', popts.NIPFW_color_marker_inactive, 'Parent', achse);
            handle_legend(2)   = plot(0, -1, 'o', 'MarkerSize', popts.NIPFW_thick_line_inactive,'MarkerEdgeColor', popts.NIPFW_color_line_inactive, 'Parent', achse);
            handle_legend(3)   = plot(0, -1, 'o', 'MarkerSize', popts.NIPFW_size_marker_active,'MarkerEdgeColor', 'k', 'MarkerFaceColor', popts.NIPFW_color_marker_active, 'Parent', achse);
            handle_legend(4)   = plot(0, -1, 'o', 'MarkerSize', popts.NIPFW_thick_line_active,'MarkerEdgeColor', popts.NIPFW_color_line_active, 'Parent', achse);
        
            legend(handle_legend, {'Without Smoothing','With Smoothing','Current Face without Smoothing','Current Face with Smoothing'}, 'Location', 'NorthEast');
            
            %  Add Line
            if Filt == 0
                handle_line       = plot([Fold(1).Face(1).filter_width, Fold(1).Face(1).filter_width], get(achse, 'YLim'), '--k', 'parent', achse);
            else
                for i = 1:length(Fold)
                    for j = 1:2
                        hl = plot([Fold(i).Face(j).filter_width, Fold(i).Face(j).filter_width], get(achse, 'YLim'), '--','Color',0.8*[1 1 1], 'parent', achse);
                        
                        % Do not add to legend
                        set(get(get(hl,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off');
                    end
                end
                handle_line       = plot([Fold(fold).Face(face).filter_width, Fold(fold).Face(face).filter_width], get(achse, 'YLim'), 'k--', 'parent', achse);
            end
            % Do not add to legend
            set(get(get(handle_line,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off');
                    
            % Title
            if Filt == 0
                handle_title    = title(achse, ['NIP-FW diagram. Filter Width: ', num2str(Fold(1).Face(1).filter_width)],'Color', [0 0 0]);
            else
                handle_title    = title(achse, ['NIP-FW diagram. Filter Width: ', num2str(Fold(fold).Face(face).filter_width)],'Color', [0 0 0]);
            end
            
            % Store Handles for Update
            setappdata(achse, 'handle_line',  handle_line);
            setappdata(achse, 'handle_title', handle_title);
            
        else
            
            % Update NIP-FW
            handle_line     = getappdata(achse, 'handle_line');
            handle_title    = getappdata(achse, 'handle_title');
            
            % Get plot handle & legend handle
            ph = getappdata(achse, 'plot_handle');
            
            % Plot inactive
            % - Plot analysis of the curvature without smoothing
            count = 0;
            for i = 1:length(Fold)
                for j = 1:2
                    if i == fold && j == face
                        active = count;
                    end
                    % - Plot analysis of the curvature without smoothing
                    set(ph(count+1), 'MarkerSize', popts.NIPFW_size_marker_inactive,'MarkerEdgeColor', 'k', 'MarkerFaceColor', popts.NIPFW_color_marker_inactive, 'Parent', achse);
                    % - Plot anaysis of the smoothed curvature
                    set(ph(count+2), 'MarkerEdgeColor',popts.NIPFW_color_line_inactive,'MarkerSize',popts.NIPFW_thick_line_inactive, 'Parent', achse);
                    count = count + 2;
                end
            end
            
            
            % Plot active
            % - Plot analysis of the curvature without smoothing
            set(ph(active+1), 'MarkerSize', popts.NIPFW_size_marker_active,'MarkerEdgeColor', 'k', 'MarkerFaceColor', popts.NIPFW_color_marker_active, 'Parent', achse);       
            
            % - Plot anaysis of the smoothed curvature
            set(ph(active+2), 'MarkerEdgeColor',popts.NIPFW_color_line_active,'MarkerSize',popts.NIPFW_thick_line_active, 'Parent', achse);
            
            % Set legend handle
            setappdata(achse, 'plot_handle',  ph);
            
            if Filt == 0
                set(handle_line,  'XData',  [Fold(1).Face(1).filter_width, Fold(1).Face(1).filter_width]);
                set(handle_title, 'String', ['NIP-FW diagram. Filter Width: ', num2str(Fold(1).Face(1).filter_width)]);
            else
                set(handle_line,  'XData',  [Fold(fold).Face(face).filter_width, Fold(fold).Face(face).filter_width]);
                set(handle_title, 'String', ['NIP-FW diagram. Filter Width: ', num2str(Fold(fold).Face(face).filter_width)]);
            end
            
            % Note that thickness needs to be recalculated
            setappdata(fgt_gui_handle, 'Thickness_calculation', 1);
            
        end
        
        % Add clicker
        set(achse, 'ButtonDownFcn',  @(a,b) fgt('step_2_set_filter_width'));
        
        
        % CURVATURE ANALYSIS
        for i=1:length(Fold)
            for j=1:2
                if Filt == 0
                    [Fold(i).Face(j).X, Fold(i).Face(j).Y, Fold(i).Face(j).Arclength, Fold(i).Face(j).Curvature, Fold(i).Face(j).Inflection, Fold(i).Face(j).Hinge, ...
                        Fold(i).Face(j).Fold_arclength, Fold(i).Face(j).Wavelength, Fold(i).Face(j).Amplitude] = ...
                        curve_analysis(Fold(i).Face(j).X, Fold(i).Face(j).Y, Fold(1).Face(1).filter_width, Fold(1).fraction, Fold(1).hinge_method,Fold(1).order);
                else
                    [Fold(i).Face(j).X, Fold(i).Face(j).Y, Fold(i).Face(j).Arclength, Fold(i).Face(j).Curvature, Fold(i).Face(j).Inflection, Fold(i).Face(j).Hinge, ...
                        Fold(i).Face(j).Fold_arclength, Fold(i).Face(j).Wavelength, Fold(i).Face(j).Amplitude] = ...
                        curve_analysis(Fold(i).Face(j).X, Fold(i).Face(j).Y, Fold(i).Face(j).filter_width, Fold(1).fraction, Fold(1).hinge_method,Fold(1).order);
                end
            end
        end
        
        %  ARCLENGTH-CURVATURE PLOT
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_2');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        delete(allchild(achse));
        
        %  Remove potential marker point handle
        if ~isempty(getappdata(achse, 'point_h2'))
            rmappdata(achse, 'point_h2');
        end
        hold(achse, 'on');
                
        Legend_flag = logical([1 1 0 0 0]);
        
        %  Original
        plot(Fold(fold).Face(face).Arclength.Ori, Fold(fold).Face(face).Curvature.Ori, 'Color',popts.curve_color_ori, 'LineWidth', popts.curve_thick_ori, 'parent', achse);
        
        %  Smooth
        plot(Fold(fold).Face(face).Arclength.Full, Fold(fold).Face(face).Curvature.Full, 'Color',popts.curve_color_smoothed, 'LineWidth', popts.curve_thick_smoothed, 'parent', achse);
        
        %  Hinge
        if Fold(1).hinge_method == 1
            plot(Fold(fold).Face(face).Arclength.Full(Fold(fold).Face(face).Hinge.Index), Fold(fold).Face(face).Curvature.Full(Fold(fold).Face(face).Hinge.Index),...
                 'o','MarkerFaceColor',popts.hinge_color_active,'MarkerSize',popts.hinge_size_active, 'parent', achse);
            Legend_flag(3)  = [];
        end
        if Fold(1).hinge_method == 2
            plot(Fold(fold).Face(face).Hinge.Poly_Arc, Fold(fold).Face(face).Hinge.Poly_Cur,'Color', popts.curve_color_poly, 'LineWidth', popts.curve_thick_poly, 'parent', achse);
            Legend_flag(3)  = ~isempty(Fold(fold).Face(face).Hinge.Poly_Arc);
            plot(Fold(fold).Face(face).Arclength.Full(Fold(fold).Face(face).Hinge.Index), Fold(fold).Face(face).Curvature.Full(Fold(fold).Face(face).Hinge.Index),...
                 'o','MarkerFaceColor',popts.hinge_color_active,'MarkerSize',popts.hinge_size_active, 'parent', achse);
        end
        
        Legend_flag(4)  = ~isempty(Fold(fold).Face(face).Hinge.Index);
        
        %  Inflection
        plot(Fold(fold).Face(face).Arclength.Full(Fold(fold).Face(face).Inflection), Fold(fold).Face(face).Curvature.Full(Fold(fold).Face(face).Inflection),...
            'o','MarkerFaceColor',popts.inflection_color_active,'MarkerSize',popts.inflection_size_active, 'parent', achse);
        Legend_flag(5)  = ~isempty(Fold(fold).Face(face).Inflection);
        
        
        Legende = {'Original' 'Smoothed' 'Polynomial' 'Hinge' 'Inflection'};
        Title   = {'First Interface', 'Second Interface'};
        
        title(achse, Title{face});
        xlabel(achse,'Arc length');
        ylabel(achse,'Curvature');
        
        xlim(achse,[0 max(abs(Fold(fold).Face(face).Arclength.Ori))]);
        ylim(achse,[-max(abs(Fold(fold).Face(face).Curvature.Ori)) max(abs(Fold(fold).Face(face).Curvature.Ori))]);
        legend(achse,Legende(Legend_flag),'Orientation','Horizontal','Location', 'SouthEast');
        hold(achse, 'on');
        grid(achse, 'on')
        
        
        %  HINGE & INFLECTION POINTS ON FOLD
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        delete(allchild(achse));
      
        %  Remove potential marker point handle
        if ~isempty(getappdata(achse, 'point_h1'))
            rmappdata(achse, 'point_h1');
        end      
        if ~isempty(getappdata(achse, 'point_h3'))
            rmappdata(achse, 'point_h3');
        end 
      
        hold(achse, 'on');
        
        % Activate mouseover function
        set(fgt_gui_handle,'windowbuttonmotionfcn', @(a,b) mouseover);
        
        %  Fold
        for i=1:length(Fold)
            if i == fold
                fh  = fill([Fold(i).Face(1).X.Norm fliplr(Fold(i).Face(2).X.Norm)], [Fold(i).Face(1).Y.Norm fliplr(Fold(i).Face(2).Y.Norm)], 'k', 'parent', achse);
                set(fh, 'FaceColor', popts.fold_color_active);
            else
                fh  = fill([Fold(i).Face(1).X.Norm fliplr(Fold(i).Face(2).X.Norm)], [Fold(i).Face(1).Y.Norm fliplr(Fold(i).Face(2).Y.Norm)], 'k', 'parent', achse);
                set(fh, 'FaceColor', popts.fold_color_inactive);
            end
        end
        
        %  Face
        other_face          = [1 2];
        other_face(face)    = [];
        fold_line = plot(Fold(fold).Face(face).X.Full,       Fold(fold).Face(face).Y.Full,       'Color', popts.face_color_active,   'LineWidth', popts.face_thick_active,   'parent', achse);
                    plot(Fold(fold).Face(other_face).X.Full, Fold(fold).Face(other_face).Y.Full, 'Color', popts.face_color_inactive, 'LineWidth', popts.face_thick_inactive, 'parent', achse);
                      
        setappdata(fgt_gui_handle, 'fold_line', fold_line);              
        
        for i = 1:length(Fold)
            for j=1:2
                
                if i ~= fold || j ~= face
                    %  Hinge
                    plot(Fold(i).Face(j).X.Full(Fold(i).Face(j).Hinge.Index), Fold(i).Face(j).Y.Full(Fold(i).Face(j).Hinge.Index),...
                        'o','MarkerSize',popts.hinge_size_inactive,'MarkerFaceColor',popts.hinge_color_inactive, 'parent', achse);
                    
                    %  Inflection
                    plot(Fold(i).Face(j).X.Full(Fold(i).Face(j).Inflection), Fold(i).Face(j).Y.Full(Fold(i).Face(j).Inflection),...
                        'o','MarkerSize',popts.inflection_size_inactive,'MarkerFaceColor',popts.inflection_color_inactive, 'parent', achse);
                end
            end
        end
        
        %  Hinge
        plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index),...
            'o','MarkerFaceColor',popts.hinge_color_active,'MarkerSize',popts.hinge_size_active, 'parent', achse);
        %  Inflection
        plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection),...
            'o','MarkerFaceColor',popts.inflection_color_active,'MarkerSize',popts.inflection_size_active, 'parent', achse);
        
        axis(achse,'equal')
        box(achse, 'on');
        
        
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        %  Activate next button
        set(findobj(fgt_gui_handle, 'tag', 'next'), 'enable', 'on');
        
        % Deactivete fold buttons
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'),   'enable', 'off');
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'off');
        
        % Activatie fold number button
        if fold < size(Fold,2)
            fold_number = ['Fold number ',num2str(fold+1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'), 'enable', 'on','tooltipstring',fold_number);
        end
        if fold > 1
            fold_number = ['Fold number ',num2str(fold-1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'on','tooltipstring',fold_number);
        end
        
        % Activate appropreate face button
        if face > 1
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),   'enable', 'on' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'), 'enable', 'off');
        else
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'), 'enable', 'on' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),   'enable', 'off');
        end
        
        % (De)activate buttons and windows if the manual selection is on/off
        set(findobj(fgt_gui_handle, 'tag', 'step_2_individual'),        'enable','on');
        set(findobj(fgt_gui_handle, 'tag', 'step_2_order'),             'enable','on');
        set(findobj(fgt_gui_handle, 'tag', 'step_2_small_area_fraction'), 'enable','on');
        set(findobj(fgt_gui_handle, 'tag', 'step_2_hinge'),             'enable','on');
        
        % Set Units to Normalized - Resizing
        units_normalized;
        
    case 'step_2_set_filter_width'
        %% - step_2_set_filter_width
        
        CURRENT_POINT = get(gca,'CurrentPoint');

        %  Update Data
        Fold        = getappdata(fgt_gui_handle, 'Fold');
        Filt        = get(findobj(fgt_gui_handle, 'tag', 'step_2_individual'),  'value');
        
        % Assign filter width to all the interfaces unless the selection is
        % interface specific
        if Filt == 0
            for i = 1:length(Fold)
                for j = 1:2
                    Fold(i).Face(j).filter_width    = CURRENT_POINT(1);
                end
            end
        else
            fold    = getappdata(fgt_gui_handle, 'fold_number');
            face    = getappdata(fgt_gui_handle, 'face_number');
            
            Fold(fold).Face(face).filter_width    = CURRENT_POINT(1);
        end
        
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        fgt('step_2_update_gui');
        
    case 'step_22_update_gui'
        %% - step_22_update_gui
        
        % Put FGT into step_22 mode
        setappdata(fgt_gui_handle, 'mode', 22);
        
        %  Get Data
        Fold            = getappdata(fgt_gui_handle, 'Fold');
        fold            = getappdata(fgt_gui_handle, 'fold_number');
        face            = getappdata(fgt_gui_handle, 'face_number');
        Filt            = get(findobj(fgt_gui_handle, 'tag', 'step_2_individual'),'value');
        popts           = getappdata(fgt_gui_handle, 'popts');                 
        
        %  FILTER WIDTH PLOT (NIP-WW)
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_3');
        
        h = getappdata(achse, 'handle_line');
        
        if isempty(get(achse,'Children')) || sum(get(h,'Color')) == 0
            cla(achse);
            hold(achse, 'on');
            
            % Plot all as inactive
            for i = 1:length(Fold)
                for j = 1:2
                    % - Plot analysis of the curvature without smoothing
                    handle_legend(1) = plot(Fold(i).Face(j).WindowSizes, Fold(i).Face(j).NIP.Ori, 'o', 'MarkerSize', popts.NIPFW_size_marker_inactive,...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', popts.NIPFW_color_marker_inactive, 'Parent', achse);
                    % - Plot anaysis of the smoothed curvature
                    handle_legend(2) = plot(Fold(i).Face(j).WindowSizes, Fold(i).Face(j).NIP.Smoothed, 'Color', popts.NIPFW_color_line_inactive, 'Parent', achse);
                end
            end
                        
            set(achse, 'xscale', 'log');
            axis(achse, 'square');
            xlabel(achse, 'Filter Width','Color', 0.5*[1 1 1])
            ylabel(achse, '# Inflection Points','Color', 0.5*[1 1 1])
            box(achse, 'on');
            set(achse,'XColor', 0.5*[1 1 1],'YColor', 0.5*[1 1 1])
            legend(handle_legend, {'A','B'}, 'Location', 'NorthEast');
            
            % Set legend handle
            setappdata(achse, 'handle_legend',  handle_legend);
            
            %  Add Line
            for i = 1:length(Fold)
                for j = 1:2
                    if ~(i==fold && j==face)
                        hl = plot([Fold(i).Face(j).filter_width, Fold(i).Face(j).filter_width], get(achse, 'YLim'), '--','Color',0.8*[1 1 1], 'parent', achse);
                        
                        % Do not add to legend
                        set(get(get(hl,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off');
                    end
                end
            end
            handle_line       = plot([Fold(fold).Face(face).filter_width, Fold(fold).Face(face).filter_width], get(achse, 'YLim'),'--', 'Color', 0.8*[1 1 1], 'parent', achse);
            
            % Do not add to legend
            set(get(get(handle_line,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off');
            
            % Title
            if Filt == 0
                handle_title    = title(achse, ['NIP-FW diagram. Filter Width: ', num2str(Fold(1).Face(1).filter_width)], 'Color', 0.5*[1 1 1]);
            else
                handle_title    = title(achse, ['NIP-FW diagram. Filter Width: ', num2str(Fold(fold).Face(face).filter_width)], 'Color', 0.5*[1 1 1]);
            end
            
            % Store Handles for Update
            setappdata(achse, 'handle_line',  handle_line);
            setappdata(achse, 'handle_title', handle_title);
            
            %  Remove clicker
            set(achse, 'ButtonDownFcn',  []);
            
        end
        
        %  ARCLENGTH-CURVATURE PLOT
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_2');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        delete(allchild(achse));
        
        %  Remove potential marker point handle
        if ~isempty(getappdata(achse, 'point_h2'))
            rmappdata(achse, 'point_h2');
        end
        hold(achse, 'on');
        
        % Activate mouseover function
        %set(fgt_gui_handle,'windowbuttonmotionfcn', @(a,b) mouseover);
        set(fgt_gui_handle,'windowbuttonmotionfcn', []);
        
        %  Original
        plot(Fold(fold).Face(face).Arclength.Ori, Fold(fold).Face(face).Curvature.Ori, 'Color',[0.7 0.7 0.7],'Hittest','off','parent', achse);
        
        %  Smooth
        plot(Fold(fold).Face(face).Arclength.Full, Fold(fold).Face(face).Curvature.Full, 'k','Hittest','off','parent', achse);
        
        %  Hinge
        plot(Fold(fold).Face(face).Arclength.Full(Fold(fold).Face(face).Hinge.Index), Fold(fold).Face(face).Curvature.Full(Fold(fold).Face(face).Hinge.Index), 'ob','MarkerSize',4,'parent', achse);
        
        %  Inflection
        plot(Fold(fold).Face(face).Arclength.Full(Fold(fold).Face(face).Inflection), Fold(fold).Face(face).Curvature.Full(Fold(fold).Face(face).Inflection), 'or','MarkerSize',4,'parent', achse);

        
        Legend_flag = logical([1 1 0 0]);
        Legend_flag(3) = ~isempty(Fold(fold).Face(face).Hinge.Index);
        Legend_flag(4) = ~isempty(Fold(fold).Face(face).Inflection);
            
        
        Legende = {'Original' 'Smoothed' 'Hinge' 'Inflection'};
        Title   = {'First Interface', 'Second Interface'};
        
        title(achse,Title{face});
        xlabel(achse,'Arc length');
        ylabel(achse,'Curvature');
        
        xlim(achse,[0 max(abs(Fold(fold).Face(face).Arclength.Ori))]);
        ylim(achse,[-max(abs(Fold(fold).Face(face).Curvature.Ori)) max(abs(Fold(fold).Face(face).Curvature.Ori))]);
        legend(achse,Legende(Legend_flag),'Orientation','Horizontal','Location', 'SouthEast');
        box(achse, 'on');
        grid(achse,'on');
        
        
        %  HINGE & INFLECTION POINTS ON FOLD
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        delete(allchild(achse));
      
        %  Remove potential marker point handle
        if ~isempty(getappdata(achse, 'point_h1'))
            rmappdata(achse, 'point_h1');
        end      
        if ~isempty(getappdata(achse, 'point_h3'))
            rmappdata(achse, 'point_h3');
        end 
      
        hold(achse, 'on');
        
        % Activate 
        set(achse,         'ButtonDownFcn',  @(a,b) mark_point);
        set(fgt_gui_handle,'KeyPressFcn',    @(a,b) add_point);
        set(fgt_gui_handle,'KeyReleaseFcn',  @(a,b) deactivate_action);
        
        %  Fold
        for i=1:length(Fold)
            fh  = fill([Fold(i).Face(1).X.Norm fliplr(Fold(i).Face(2).X.Norm)], [Fold(i).Face(1).Y.Norm fliplr(Fold(i).Face(2).Y.Norm)], 'k','parent', achse);
            set(fh, 'EdgeColor', [0.9 0.9 0.9], 'FaceColor', [.97 .97 .97],'Hittest','off');
        end
        
        %  Face
        other_face          = [1 2];
        other_face(face)    = [];
        fold_line = plot(Fold(fold).Face(face).X.Full,       Fold(fold).Face(face).Y.Full,       'Color','k','Hittest','off','parent', achse);
                    plot(Fold(fold).Face(other_face).X.Full, Fold(fold).Face(other_face).Y.Full, 'Color',[0.7 0.7 0.7],'Hittest','off','parent', achse);
                      
        setappdata(fgt_gui_handle, 'fold_line', fold_line);  
        
        for i = 1:length(Fold)
            for j=1:2
                if ~(i==fold && j==face)
                    %  Hinge
                    plot(Fold(i).Face(j).X.Full(Fold(i).Face(j).Hinge.Index), Fold(i).Face(j).Y.Full(Fold(i).Face(j).Hinge.Index), 'o','MarkerSize',2,'Color',[0.2 0.2 0.2],'Hittest','off','parent', achse);
                    
                    %  Inflection
                    plot(Fold(i).Face(j).X.Full(Fold(i).Face(j).Inflection), Fold(i).Face(j).Y.Full(Fold(i).Face(j).Inflection), 'o','MarkerSize',2,'Color',[0.5 0.5 0.5],'Hittest','off','parent', achse);
                end
            end
        end
        
        %  Hinge
        for ih = 1:length(Fold(fold).Face(face).Hinge.Index)
            hp(ih) = plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(ih)), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(ih)), 'ob','MarkerSize',3,'parent', achse);
            set(hp(ih),'ButtonDownFcn',@(a,b) mark_point(hp(ih)),'Hittest','on','Tag',num2str(Fold(fold).Face(face).Hinge.Index(ih)));
        end
        %  Inflection
        for in = 1:length(Fold(fold).Face(face).Inflection)
            hi(in) = plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(in)), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(in)), 'or','MarkerSize',3,'parent', achse);
            set(hi(in),'ButtonDownFcn',@(a,b) mark_point(hi(in)),'Hittest','on','Tag',num2str(Fold(fold).Face(face).Inflection(in)));
        end
        
        axis(achse, 'equal');
        box(achse, 'on');
        
        
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        %  Activate next button
        set(findobj(fgt_gui_handle, 'tag', 'next'), 'enable', 'on');
        
        % Deactivete fold buttons
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'),   'enable', 'off');
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'off');
        
        % Activatie fold number button
        if fold < size(Fold,2)
            fold_number = ['Fold number ',num2str(fold+1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'), 'enable', 'on','tooltipstring',fold_number);
        end
        if fold > 1
            fold_number = ['Fold number ',num2str(fold-1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'on','tooltipstring',fold_number);
        end
        
        % Activate appropreate face button
        if face > 1
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),           'enable', 'on' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'),         'enable', 'off');
        else
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'),         'enable', 'on' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),           'enable', 'off');
        end
        
         % (De)activate buttons and windows if the manual selection is on/off
         set(findobj(fgt_gui_handle, 'tag', 'step_2_individual'),           'enable','off');
         set(findobj(fgt_gui_handle, 'tag', 'step_2_order'),                'enable','off');
         set(findobj(fgt_gui_handle, 'tag', 'step_2_small_area_fraction'),  'enable','off');
         set(findobj(fgt_gui_handle, 'tag', 'step_2_hinge'),                'enable','off');
        
        % Set Units to Normalized - Resizing
        units_normalized;
        
    case 'step_22_curv_analysis'
        %% - step_22_curv_analysis
        
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        
        % Remove first and last hinge point if it is not bounded by two
        % inflection points
        for fold=1:length(Fold)
            for face=1:2
                if Fold(fold).Face(face).Hinge.Index(1)<Fold(fold).Face(face).Inflection(1)
                    warndlg('Each hinge point must be confined between two inflection points. Please modify your analysis.', 'Error!', 'modal');
                    fgt('step_22_update_gui')
                    return;
                end
                if Fold(fold).Face(face).Hinge.Index(end)>Fold(fold).Face(face).Inflection(end)
                    warndlg('Each hinge point must be confined between two inflection points. Please modify your analysis.', 'Error!', 'modal');
                    fgt('step_22_update_gui')
                    return;
                end
            end
        end
        
        % Check if the hinge points alternate with inflection points
        for fold=1:length(Fold)
            for face=1:2
                for in = 1:length(Fold(fold).Face(face).Inflection)-1
                    findhinge = find( Fold(fold).Face(face).Hinge.Index > Fold(fold).Face(face).Inflection(in) & Fold(fold).Face(face).Hinge.Index < Fold(fold).Face(face).Inflection(in+1));
                    
                    if length(findhinge) ~= 1
                        warndlg('Each hinge point must be confined between two inflection points. Please modify your analysis.', 'Error!', 'modal');
                        fgt('step_22_update_gui')
                        return;
                    end
                end
            end
        end
        
        % Curvature analysis
        for fold=1:length(Fold)
            for face=1:2
                [Fold(fold).Face(face).Fold_arclength, Fold(fold).Face(face).Wavelength, Fold(fold).Face(face).Amplitude] = ...
                    curve_analysis2(Fold(fold).Face(face).X, Fold(fold).Face(face).Y, Fold(fold).Face(face).Arclength, Fold(fold).Face(face).Hinge,Fold(fold).Face(face).Inflection);
            end
        end
        
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        % Step 3
        fgt('step_3')
        
    case 'step_3'
        %% STEP_3: Amplitude & Wavelegnth
        
        % Put FGT into step_3 mode
        setappdata(fgt_gui_handle, 'mode', 3);
        set(fgt_gui_handle,'windowbuttonmotionfcn',[]);
        
        %  Delete all axes and UIContainers that may exist
        delete(findobj(fgt_gui_handle, 'type', 'axes'));
        delete(findobj(fgt_gui_handle, 'type', 'UIContainer'));
        
        %  Setup new axes
        fgt_upanel_top  = findobj(fgt_gui_handle, 'tag', 'fgt_upanel_top');
        set(fgt_upanel_top, 'Title', 'Amplitude & Wavelength');
        
        uc_1            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.0 0.5 0.5 0.5]);
        axes('Parent', uc_1, 'tag', 'axes_1');
        box on;
        
        uc_2            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.5 0.5 0.5 0.5]);
        axes('Parent', uc_2, 'tag', 'axes_2');
        box on;
        
        uc_3            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.0 0.0 0.5 0.5]);
        axes('Parent', uc_3, 'tag', 'axes_3');
        box on;
        
        uc_4            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.5 0.0 0.5 0.5]);
        axes('Parent', uc_4, 'tag', 'axes_4');
        box on;
        
        %  Find the control panel
        fgt_upanel_control  = findobj(fgt_gui_handle, 'Tag', 'fgt_upanel_control');
        
        % Delete all children
        uc_handles   = findobj(fgt_upanel_control, 'Type', 'uicontrol');
        delete(uc_handles);
        
        %  Default sizes
        b_height    = getappdata(fgt_gui_handle, 'b_height');
        b_width     = getappdata(fgt_gui_handle, 'b_width');
        gap         = getappdata(fgt_gui_handle, 'gap');
        
        % Size of panel
        set(fgt_upanel_control, 'Units', 'Pixels');
        Position    = get(fgt_upanel_control, 'Position');
        
        %  Get button icons
        buttonUp         = getappdata(fgt_gui_handle, 'buttonUp');
        buttonDown       = getappdata(fgt_gui_handle, 'buttonDown');
        
        % FOLD SELECTION
        % Default fold number
        fold = 1;
        setappdata(fgt_gui_handle, 'fold_number', fold);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Fold', ...
            'position', [Position(2)+gap, 4*gap+3*b_height-2, b_height, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','fold_number_up',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','fold_number_down',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 1*gap,            b_height, b_height],...
            'enable', 'off');
        
        % Set fold number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
            'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
        
        %  Get data
        Fold        = getappdata(fgt_gui_handle, 'Fold');
        
        % SLIDERS
        % Text Upper
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String','First interface', ...
            'position', [Position(3)+1/2*gap-4*b_width, 4*gap+3*b_height, 2*b_width+2*gap, b_height]);
        
        % Slider Upper
        if ~isempty(Fold(fold).Face(1).Amplitude(1).Value)
        uicontrol('Parent', fgt_upanel_control, 'style', 'slider','Min',0,'Max',max([1 length(Fold(fold).Face(1).Amplitude(1).Value)]),'Value',0,...
            'Sliderstep',[1/length(Fold(fold).Face(1).Amplitude(1).Value) 1/length(Fold(fold).Face(1).Amplitude(1).Value)],...
            'callback',  @(a,b)  fgt('step_3_update_gui'), ...
            'tag', 'step_3_slider_up', 'BackgroundColor','w', ...
            'position', [Position(3)-2*gap-2*b_width, 4*gap+3*b_height, 2*b_width+gap, b_height]);
        else
        uicontrol('Parent', fgt_upanel_control, 'style', 'slider','Min',0,'Max',1,'Value',0,...
            'tag', 'step_3_slider_up', ...
            'position', [Position(3)-2*gap-2*b_width, 4*gap+3*b_height, 2*b_width+gap, b_height],...
            'enable', 'off');  
        end
        
        % Text Lower
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String','Second interface', ...
            'position', [Position(3)-gap-4*b_width, 3*gap+2*b_height, 2*b_width+2*gap, b_height]);
        
        % Slider Lower
        if ~isempty(Fold(fold).Face(2).Amplitude(1).Value)
        uicontrol('Parent', fgt_upanel_control, 'style', 'slider', 'Min',0,'Max',length(Fold(fold).Face(2).Amplitude(1).Value),'Value',0, ...
            'Sliderstep',[1/length(Fold(fold).Face(2).Amplitude(1).Value) 1/length(Fold(fold).Face(2).Amplitude(1).Value)],...
            'callback',  @(a,b)  fgt('step_3_update_gui'), ...
            'tag', 'step_3_slider_low', 'BackgroundColor','w', ...
            'position', [Position(3)-2*gap-2*b_width, 3*gap+2*b_height, 2*b_width+gap, b_height]);
        else
        uicontrol('Parent', fgt_upanel_control, 'style', 'slider', 'Min',0,'Max',1,'Value',0, ...
            'tag', 'step_3_slider_low', ...
            'position', [Position(3)-2*gap-2*b_width, 3*gap+2*b_height, 2*b_width+gap, b_height],...
            'enable', 'off');
        end
        
        % AMPLITUDE METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Amplitude', ...
            'position', [Position(3)-4*gap-4*b_width, 2*gap+1*b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2';'3'}, 'value', 1, ...
            'callback',  @(a,b)  fgt('step_3_update_gui'), ...
            'tag', 'step_3_amplitude', 'BackgroundColor','w', ...
            'position', [Position(3)-3*gap-3*b_width, 2*gap+1*b_height, b_width, b_height]);
        
        
        % WAVELENGTH METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Wavelength', ...
            'position', [Position(3)-2*gap-2*b_width, 2*gap+1*b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2';'3';'4'}, 'value', 1, ...
            'callback',  @(a,b)  fgt('step_3_update_gui'), ...
            'tag', 'step_3_wavelength', 'BackgroundColor','w', ...
            'position', [Position(3)-gap-b_width, 2*gap+1*b_height, b_width, b_height]);
        
        
        % ZOOM ON
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'Zoom on', 'Value', 0,...
            'callback',   @fgt_zoom, ...
            'tag', 'step_3_zoomon', ...
            'position', [Position(2)+4*gap+2*b_height, gap, 2*b_width, b_height]);
        zoom off;
        
        
        % AXIS EQUAL
        % Axis equal button
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'Axis equal', 'Value', 1,...
            'callback',  @(a,b) fgt('step_3_update_gui'), ...
            'tag', 'step_3_axisequal', ...
            'position', [Position(2)+6*gap+2*b_height+b_width, gap, 2*b_width, b_height]);
        
        % BUTTONS
        % Back Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Back', ...
            'callback',  @(a,b) fgt('step_2'), ...
            'position', [Position(3)-2*gap-2*b_width, gap, b_width, b_height]);
        
        % Next Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Next', ...
            'tag', 'next', ...
            'callback',  @(a,b) fgt('step_4'), ...
            'position', [Position(3)-gap-b_width, gap, b_width, b_height], ...
            'enable', 'off');
        
        %  Update GUI
        fgt('step_3_update_gui');
        
    case 'step_3_update_gui'
        %% - step_3_update_gui
        
        %  Get data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        fold    = getappdata(fgt_gui_handle, 'fold_number');
        popts   = getappdata(fgt_gui_handle, 'popts'); 
        
        %  Read data
        amplitude_method    = get(findobj(fgt_gui_handle, 'tag', 'step_3_amplitude'),  'value');
        wavelength_method   = get(findobj(fgt_gui_handle, 'tag', 'step_3_wavelength'), 'value');
        slider(1)           = round(get(findobj(fgt_gui_handle, 'tag', 'step_3_slider_up'),  'value'));
        slider(2)           = round(get(findobj(fgt_gui_handle, 'tag', 'step_3_slider_low'), 'value'));
        axis_equal          = get(findobj(fgt_gui_handle, 'tag', 'step_3_axisequal'),  'value');
        
        %  AMPLITUDE
        for face=1:2
            if face==1
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
            else
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_3');
            end
            
            set(fgt_gui_handle, 'CurrentAxes', achse);
            delete(allchild(achse));
            hold(achse, 'on');
            
            % Set axis equal
            if axis_equal == 1
                axis(achse,'equal')
            else
                axis(achse,'normal')
            end
            
            if face==1
                if slider(face)>0
                    title(achse, {['Amplitude after ',num2str(Fold(fold).Face(face).Amplitude(amplitude_method).Name)]...
                        [' First interface \color[rgb]{',num2str(popts.ampl_color_active),'}    mean(A)=',num2str(mean([Fold(fold).Face(face).Amplitude(amplitude_method).Value]),3 ),'    A=',num2str(Fold(fold).Face(face).Amplitude(amplitude_method).Value(slider(face)),3 )]});
                else
                    title(achse,{['Amplitude after ',num2str(Fold(fold).Face(face).Amplitude(amplitude_method).Name)]...
                        [' First interface \color[rgb]{',num2str(popts.ampl_color_active),'}    mean(A)=',num2str(mean([Fold(fold).Face(face).Amplitude(amplitude_method).Value]),3 )]});
                end
            else
                if slider(face)>0
                    title(achse,{'   '...
                        [' Second interface \color[rgb]{',num2str(popts.ampl_color_active),'}    mean(A)=',num2str(mean([Fold(fold).Face(face).Amplitude(amplitude_method).Value]),3 ),'    A=',num2str(Fold(fold).Face(face).Amplitude(amplitude_method).Value(slider(face)),3 )]});
                else
                    title(achse,{'   '...
                        [' Second interface \color[rgb]{',num2str(popts.ampl_color_active),'}    mean(A)=',num2str(mean([Fold(fold).Face(face).Amplitude(amplitude_method).Value]),3 )]});
                end
            end
            
            if isempty(Fold(fold).Face(face).Amplitude)
                error('At least 2 inflection points have to be defined on each layer in order to calculate amplitude and wavelength')
            end
            
            
            %  Fold
            for i=1:length(Fold)
                fh  = fill([Fold(i).Face(1).X.Norm fliplr(Fold(i).Face(2).X.Norm)], [Fold(i).Face(1).Y.Norm fliplr(Fold(i).Face(2).Y.Norm)], 'k','parent',achse);
                set(fh, 'FaceColor', popts.fold_color_inactive,'EdgeColor','none');
            end
            %  Plot analyzed interface
            plot(Fold(fold).Face(face).X.Full, Fold(fold).Face(face).Y.Full, 'Color',popts.face_color_active,'parent',achse);
            
            if slider(face)>0
                plot(Fold(fold).Face(face).X.Full( Fold(fold).Face(face).Inflection(slider(face)) : Fold(fold).Face(face).Inflection(slider(face)+1) ),...
                     Fold(fold).Face(face).Y.Full( Fold(fold).Face(face).Inflection(slider(face)) : Fold(fold).Face(face).Inflection(slider(face)+1) ),...
                     'Color',popts.face_color_active,'LineWidth',popts.face_thick_active+0.5,'parent',achse);
            end
            
            %  Hinge
            plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index),...
                        'o','MarkerSize',popts.hinge_size_inactive,'MarkerFaceColor',popts.hinge_color_inactive, 'parent', achse);
            
            %  Inflection
            plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection),...
                        'o','MarkerSize',popts.inflection_size_inactive,'MarkerFaceColor',popts.inflection_color_inactive, 'parent', achse);
            
            
            if amplitude_method==1
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Amplitude(1).PP(1,:)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Amplitude(1).PP(2,:)']', ...
                    ':k', 'parent', achse);
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Amplitude(1).PP(1,:)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Amplitude(1).PP(2,:)']', ...
                    ':k', 'parent', achse);
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Amplitude(1).Index)', Fold(fold).Face(face).Amplitude(1).PP(1,:)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Amplitude(1).Index)', Fold(fold).Face(face).Amplitude(1).PP(2,:)']', ...
                    'Color',popts.ampl_color_inactive,'LineWidth',popts.ampl_thick_inactive, 'parent', achse);
                
                if slider(face)>0
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Amplitude(1).Index(slider(face)))', Fold(fold).Face(face).Amplitude(1).PP(1,slider(face))']', ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Amplitude(1).Index(slider(face)))', Fold(fold).Face(face).Amplitude(1).PP(2,slider(face))']', ...
                        'Color',popts.ampl_color_active,'LineWidth',popts.ampl_thick_active, 'parent', achse);
                end

            end
            
            if amplitude_method==2
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Amplitude(2).PP(1,:)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Amplitude(2).PP(2,:)']', ...
                    ':k', 'parent', achse);
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Amplitude(2).PP(1,:)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Amplitude(2).PP(2,:)']', ...
                    ':k', 'parent', achse);
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index)', Fold(fold).Face(face).Amplitude(2).PP(1,:)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index)', Fold(fold).Face(face).Amplitude(2).PP(2,:)']', ...
                    'Color',popts.ampl_color_inactive,'LineWidth',popts.ampl_thick_inactive, 'parent', achse);
                
                if slider(face)>0
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(slider(face)))', Fold(fold).Face(face).Amplitude(2).PP(1,slider(face))']', ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(slider(face)))', Fold(fold).Face(face).Amplitude(2).PP(2,slider(face))']', ...
                        'Color',popts.ampl_color_active,'LineWidth',popts.ampl_thick_active, 'parent', achse);
                end
                
            end
            
            if amplitude_method==3
                
                plot(...
                    [Fold(fold).Face(face).Amplitude(3).PP(1,1:2:end-1)', Fold(fold).Face(face).Amplitude(3).PP(1,2:2:end)']', ...
                    [Fold(fold).Face(face).Amplitude(3).PP(2,1:2:end-1)', Fold(fold).Face(face).Amplitude(3).PP(2,2:2:end)']', ...
                    ':k', 'parent', achse);
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Amplitude(3).PP(1,1:2:end)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Amplitude(3).PP(2,1:2:end)']', ...
                    'Color',popts.ampl_color_inactive,'LineWidth',popts.ampl_thick_inactive, 'parent', achse);
                
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Amplitude(3).PP(1,2:2:end)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Amplitude(3).PP(2,2:2:end)']', ...
                    'Color',popts.ampl_color_inactive,'LineWidth',popts.ampl_thick_inactive, 'parent', achse);
                
                if slider(face)>0
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)))', Fold(fold).Face(face).Amplitude(3).PP(1,2*slider(face)-1)']', ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)))', Fold(fold).Face(face).Amplitude(3).PP(2,2*slider(face)-1)']', ...
                        'Color',popts.ampl_color_active,'LineWidth',popts.ampl_thick_active, 'parent', achse);
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)+1))', Fold(fold).Face(face).Amplitude(3).PP(1,2*slider(face))']', ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)+1))', Fold(fold).Face(face).Amplitude(3).PP(2,2*slider(face))']', ...
                        'Color',popts.ampl_color_active,'LineWidth',popts.ampl_thick_active, 'parent', achse);
                end
                
            end
            
        end
        
        %  WAVELENGTH
        for face=1:2
            
            if face==1
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_2');
            else
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_4');
            end
            
            set(fgt_gui_handle, 'CurrentAxes', achse);
            delete(allchild(achse));
            hold(achse,'on');
            
            % Set axis equal
            if axis_equal == 1
                axis(achse,'equal')
            else
                axis(achse,'normal')
            end
            
            if face==1
                if slider(face)>0
                    title(achse,{['Wavelength after ',num2str(Fold(fold).Face(face).Wavelength(wavelength_method).Name)]...
                        [' First interface  \color[rgb]{',num2str(popts.wave_color_active),'}   mean(W)=', num2str( mean([Fold(fold).Face(face).Wavelength(wavelength_method).Value]),3 ),'   W=', num2str( Fold(fold).Face(face).Wavelength(wavelength_method).Value(slider(1)),3 )]});
                else
                    title(achse,{['Wavelength after ',num2str(Fold(fold).Face(face).Wavelength(wavelength_method).Name)]...
                        [' First interface  \color[rgb]{',num2str(popts.wave_color_active),'}   mean(W)=', num2str( mean([Fold(fold).Face(face).Wavelength(wavelength_method).Value]),3 )]});
                end
            else
                if slider(face)>0
                    title(achse,{'   '...
                        [' Second interface  \color[rgb]{',num2str(popts.wave_color_active),'}   mean(W)=',num2str(mean([Fold(fold).Face(face).Wavelength(wavelength_method).Value]),3 ),'    W=', num2str( Fold(fold).Face(face).Wavelength(wavelength_method).Value(slider(2)),3 )]});
                else
                    title(achse,{'   '...
                        [' Second interface  \color[rgb]{',num2str(popts.wave_color_active),'}   mean(W)=',num2str(mean([Fold(fold).Face(face).Wavelength(wavelength_method).Value]),3 )]});
                end
            end
            
            
            %  Fold
            for i=1:length(Fold)
                fh  = fill([Fold(i).Face(1).X.Norm fliplr(Fold(i).Face(2).X.Norm)], [Fold(i).Face(1).Y.Norm fliplr(Fold(i).Face(2).Y.Norm)], 'k','parent',achse);
                set(fh, 'FaceColor', popts.fold_color_inactive,'EdgeColor','none');
            end
            %  Plot analyzed interface
            plot(Fold(fold).Face(face).X.Full, Fold(fold).Face(face).Y.Full, 'Color',popts.face_color_active,'parent',achse);
            
            if slider(face)>0
                plot(Fold(fold).Face(face).X.Full( Fold(fold).Face(face).Inflection(slider(face)) : Fold(fold).Face(face).Inflection(slider(face)+1) ),...
                     Fold(fold).Face(face).Y.Full( Fold(fold).Face(face).Inflection(slider(face)) : Fold(fold).Face(face).Inflection(slider(face)+1) ),...
                     'Color',popts.face_color_active,'LineWidth',popts.face_thick_active+0.5,'parent',achse);
            end
            
            %  Hinge
            plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index),...
                        'o','MarkerSize',popts.hinge_size_inactive,'MarkerFaceColor',popts.hinge_color_inactive, 'parent', achse);
            
            %  Inflection
            plot(Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection), Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection),...
                        'o','MarkerSize',popts.inflection_size_inactive,'MarkerFaceColor',popts.inflection_color_inactive, 'parent', achse);
                    
                    
            if wavelength_method==1 
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(2:end))']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(2:end))']', ...
                    'Color',popts.wave_color_inactive,'LineWidth',popts.wave_thick_inactive,'parent', achse);
                
                if slider(face)>0
                    plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)+1))']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)+1))']', ...
                    'Color',popts.wave_color_active,'LineWidth',popts.wave_thick_active+0.5,'parent', achse);
                end
            end
            
            if wavelength_method==2
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(1:end-2))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(3:end))']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(1:end-2))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(3:end))']', ...
                    'Color',popts.wave_color_inactive,'LineWidth',popts.wave_thick_inactive,'parent', achse);
                
                if slider(face)>0 && slider(face)<=length(Fold(fold).Face(face).Amplitude(amplitude_method).Value)-2
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(slider(face)))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(slider(face)+2))']', ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(slider(face)))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(slider(face)+2))']', ...
                        'Color',popts.wave_color_active,'LineWidth',popts.wave_thick_active+0.5,'parent', achse);
                end
                if slider(face)>2
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(slider(face)-2))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Hinge.Index(slider(face)))']', ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(slider(face)-2))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Hinge.Index(slider(face)))']', ...
                        'Color',popts.wave_color_active,'LineWidth',popts.wave_thick_active+0.5,'parent', achse);
                end
            end
            
            if wavelength_method==3
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Wavelength(3).PP(1,1:2:end)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(1:end-1))', Fold(fold).Face(face).Wavelength(3).PP(2,1:2:end)']', ...
                    ':k', 'parent', achse);
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Wavelength(3).PP(1,2:2:end)']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(2:end))', Fold(fold).Face(face).Wavelength(3).PP(2,2:2:end)']', ...
                    ':k', 'parent', achse);
                plot(...
                    [Fold(fold).Face(face).Wavelength(3).PP(1,1:2:end-1)', Fold(fold).Face(face).Wavelength(3).PP(1,2:2:end)']', ...
                    [Fold(fold).Face(face).Wavelength(3).PP(2,1:2:end-1)', Fold(fold).Face(face).Wavelength(3).PP(2,2:2:end)']', ...
                    'Color',popts.wave_color_inactive,'LineWidth',popts.wave_thick_inactive,'parent', achse);
                
                if slider(face)>0
                    plot(...
                        [Fold(fold).Face(face).Wavelength(3).PP(1,2*slider(face)-1)', Fold(fold).Face(face).Wavelength(3).PP(1,2*slider(face))']', ...
                        [Fold(fold).Face(face).Wavelength(3).PP(2,2*slider(face)-1)', Fold(fold).Face(face).Wavelength(3).PP(2,2*slider(face))']', ...
                        'Color',popts.wave_color_active,'LineWidth',popts.wave_thick_active+0.5,'parent', achse);
                end
            end
            
            if wavelength_method==4
                plot(...
                    [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(1:end-2))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(3:end))']', ...
                    [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(1:end-2))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(3:end))']', ...
                    'Color',popts.wave_color_inactive,'LineWidth',popts.wave_thick_inactive,'parent', achse);
                
                if slider(face)>0 && slider(face)<=length(Fold(fold).Face(face).Amplitude(amplitude_method).Value)-1
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)+2))'], ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)+2))'], ...
                        'Color',popts.wave_color_active,'LineWidth',popts.wave_thick_active+0.5,'parent', achse);
                end
                if slider(face)>1
                    plot(...
                        [Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)-1))', Fold(fold).Face(face).X.Full(Fold(fold).Face(face).Inflection(slider(face)+1))'], ...
                        [Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)-1))', Fold(fold).Face(face).Y.Full(Fold(fold).Face(face).Inflection(slider(face)+1))'], ...
                        'Color',popts.wave_color_active,'LineWidth',popts.wave_thick_active+0.5,'parent', achse);
                end
            end
        end
        
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        %  Activate next button
        set(findobj(fgt_gui_handle, 'tag', 'next'), 'enable', 'on');
        
        % Deactivete fold buttons
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'),   'enable', 'off');
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'off');
        
        % Activatie fold number button
        if fold < size(Fold,2)
            fold_number = ['Fold number ',num2str(fold+1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'), 'enable', 'on','tooltipstring',fold_number);
        end
        if fold > 1
            fold_number = ['Fold number ',num2str(fold-1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'on','tooltipstring',fold_number);
        end
        
        % Set Units to Normalized - Resizing
        units_normalized;
        
    case 'step_4'
        %% STEP_4: Thickness
        
        % Put FGT into step_4 mode
        setappdata(fgt_gui_handle, 'mode', 4);
        
        %  Delete all axes and UIContainers that may exist
        delete(findobj(fgt_gui_handle, 'type', 'axes'));
        delete(findobj(fgt_gui_handle, 'type', 'UIContainer'));
        
        %  Setup new axes
        fgt_upanel_top  = findobj(fgt_gui_handle, 'tag', 'fgt_upanel_top');
        set(fgt_upanel_top, 'Title', 'Thickness');
        
        uc_1            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.0 0.5 0.7 0.5]);
        axes('Parent', uc_1, 'tag', 'axes_1');
        box on;
        
        uc_2            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.7 0.5 0.3 0.5]);
        axes('Parent', uc_2, 'tag', 'axes_2');
        box on;
        
        uc_3            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.0 0.0 0.7 0.5]);
        axes('Parent', uc_3, 'tag', 'axes_3');
        box on;
        
        uc_4            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.7 0.0 0.3 0.5]);
        axes('Parent', uc_4, 'tag', 'axes_4');
        box on;
        
        %  Find the control panel
        fgt_upanel_control  = findobj(fgt_gui_handle, 'Tag', 'fgt_upanel_control');
        
        % Delete all children
        uc_handles   = findobj(fgt_upanel_control, 'Type', 'uicontrol');
        delete(uc_handles);
        
        %  Default sizes
        b_height    = getappdata(fgt_gui_handle, 'b_height');
        b_width     = getappdata(fgt_gui_handle, 'b_width');
        gap         = getappdata(fgt_gui_handle, 'gap');
        
        %  Size of panel
        set(fgt_upanel_control, 'Units', 'Pixels');
        Position    = get(fgt_upanel_control, 'Position');
        
        %  Get button icons
        buttonUp         = getappdata(fgt_gui_handle, 'buttonUp');
        buttonDown       = getappdata(fgt_gui_handle, 'buttonDown');
        
        % FOLD SELECTION
        % Default fold number
        fold = 1;
        setappdata(fgt_gui_handle, 'fold_number', fold);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Fold', ...
            'position', [Position(2)+gap, 4*gap+3*b_height-2, b_height, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','fold_number_up',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','fold_number_down',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 1*gap,            b_height, b_height],...
            'enable', 'off');
        
        % Set fold number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
            'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
        
        % ZOOM ON
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'Zoom on', 'Value', 0,...
            'callback',   @fgt_zoom, ...
            'tag', 'step_4_zoomon', ...
            'position', [Position(2)+4*gap+2*b_height, gap, 2*b_width, b_height]);
        zoom off;
        
        % BUTTONS
        % Back Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Back', ...
            'callback',  @(a,b) fgt('step_3'), ...
            'position', [Position(3)-2*gap-2*b_width, gap, b_width, b_height]);
        
        % Next Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Next', ...
            'tag', 'next', ...
            'callback',  @(a,b) fgt('step_5'), ...
            'position', [Position(3)-gap-b_width, gap, b_width, b_height], ...
            'enable', 'off');
        
        %  Update GUI
        fgt('step_4_update_gui');
        
    case 'step_4_update_gui'
        %% - step_4_update_gui
        
        %  Get data
        Fold        = getappdata(fgt_gui_handle, 'Fold');
        fold        = getappdata(fgt_gui_handle, 'fold_number');
        popts       = getappdata(fgt_gui_handle, 'popts'); 
        flag        = getappdata(fgt_gui_handle, 'Thickness_calculation');
        
        if flag == 1 || isfield(Fold(1),'Thickness')==0
            % Calculate thickness: average thicknesses, local thicknesses, and average local thicknesses
            h = helpdlg('Calculating thickness - please be patient.', 'FGT - Thickness Calculation');
            for i = 1:length(Fold)
                
                % Calculate average thickness
                Fold(i).Thickness.Average	= thickess_aver(Fold(i).Face(1).X.Full,          Fold(i).Face(1).Y.Full,...
                    fliplr(Fold(i).Face(2).X.Full),  fliplr(Fold(i).Face(2).Y.Full));
                
                % Calculate local thickness
                [Fold(i).Thickness.Local(1).Value,       Fold(i).Thickness.Local(2).Value, ...
                 Fold(i).Thickness.Local(1).Polygon,     Fold(i).Thickness.Local(2).Polygon] = ...
                    thickness(Fold(i).Face(1).X.Full,    Fold(i).Face(1).Y.Full, ...
                              Fold(i).Face(2).X.Full,    Fold(i).Face(2).Y.Full,...
                              Fold(i).Face(1).Inflection,Fold(i).Face(2).Inflection);
                
            end
            delete(h);
            
            % Average local thickness
            for i = 1:length(Fold)
                for j = 1:2
                    Fold(i).Thickness.Local(j).Average = mean( Fold(i).Thickness.Local(j).Value );
                end
            end
            
            % Change the flag, so the thickness is not recalculated
            setappdata(fgt_gui_handle, 'Thickness_calculation', 0);
        end
        
        for j = 1:2
            % Ploting the thickness on the fold with the equal distance along
            % the upper interface
            
            if j ==1
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
            else
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_3');
            end
            
            set(fgt_gui_handle, 'CurrentAxes', achse);
            delete(allchild(achse));
            hold(achse, 'on');
            axis(achse,'equal');
            
            %  Fold
            for i = 1:length(Fold)
                %  Plot fold
                fh  = fill([Fold(i).Face(1).X.Norm fliplr(Fold(i).Face(2).X.Norm)], [Fold(i).Face(1).Y.Norm fliplr(Fold(i).Face(2).Y.Norm)], 'k', 'parent', achse);
                set(fh, 'FaceColor', popts.fold_color_inactive);
            end
            
            % Loop over the fold parts
            for k = 1:length(Fold(fold).Thickness.Local(j).Polygon)
                
                % Extract data
                Polygons = Fold(fold).Thickness.Local(j).Polygon{k};
                
                % Fill the fold with different colours
                if ismember(k,j:2:size(Fold(fold).Thickness.Local(j).Polygon,2))
                    fh  = fill(Polygons(1,:),Polygons(2,:), 'k', 'parent', achse);
                    set(fh, 'EdgeColor', [0.1 0.1 0.1], 'FaceColor', popts.thick_color_inactive1);
                else
                    fh  = fill(Polygons(1,:),Polygons(2,:), 'k', 'parent', achse);
                    set(fh, 'EdgeColor', [0.1 0.1 0.1], 'FaceColor', popts.thick_color_inactive2);
                end
            end
               
            % Plot inflection points
            i = 1:length(Fold);
            i(fold) = [];
            for i = i
                for k = 1:2
                    plot(Fold(i).Face(k).X.Full(Fold(i).Face(k).Inflection), Fold(i).Face(k).Y.Full(Fold(i).Face(k).Inflection),...
                        'o','MarkerSize',popts.inflection_size_inactive,'MarkerFaceColor',popts.inflection_color_inactive, 'parent', achse);
                end
            end
            for k = 1:2
                plot(Fold(fold).Face(k).X.Full(Fold(fold).Face(k).Inflection), Fold(fold).Face(k).Y.Full(Fold(fold).Face(k).Inflection),...
                    'o','MarkerSize',popts.inflection_size_active,'MarkerFaceColor',popts.inflection_color_active, 'parent', achse);
            end
            
            if j == 1
                title(achse,'Fold division based on first interface inflection points')
            else
                title(achse,'Fold division based on second interface inflection points')
            end
            
            % Thickness histogram
            if j == 1
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_2');
            else
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_4');
            end
            
            set(fgt_gui_handle, 'CurrentAxes', achse);
            delete(allchild(achse));
            hold(achse, 'on');
            
            % Histogram plot
            bar(Fold(fold).Thickness.Local(j).Value,'FaceColor',[0.7 0.7 0.7],'EdgeColor','k','BarWidth',0.5, 'parent', achse);
            xlabel(achse,'Fold number')
            ylabel(achse,'Thickness')
            title(achse,['Mean local thickness:  ',num2str(Fold(fold).Thickness.Local(j).Average,3),'  Average thickness:  ',num2str(Fold(fold).Thickness.Average,3)])
            xlim(achse,[0 length(Fold(fold).Thickness.Local(j).Value)+1])
            ylim(achse,[0 1.2*max(Fold(fold).Thickness.Local(j).Value)])
            
        end
        
        % Activate mouse over function
        set(fgt_gui_handle,'windowbuttonmotionfcn', @(a,b) mouseover_thickness);
            
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        %  Activate next button
        set(findobj(fgt_gui_handle, 'tag', 'next'), 'enable', 'on');
        
        % Deactivete fold buttons
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'),   'enable', 'off');
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'off');
        
        % Activatie fold number button
        if fold < size(Fold,2)
            fold_number = ['Fold number ',num2str(fold+1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'), 'enable', 'on','tooltipstring',fold_number);
        end
        if fold > 1
            fold_number = ['Fold number ',num2str(fold-1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'on','tooltipstring',fold_number);
        end
        
        units_normalized;
        
    case 'step_5'
        %% STEP_5: Equations
        
        % Put FGT into step_5 mode
        setappdata(fgt_gui_handle, 'mode', 5);
        set(fgt_gui_handle,'windowbuttonmotionfcn',[]);
        
        %  Delete all axes and UIContainers that may exist
        delete(findobj(fgt_gui_handle, 'type', 'axes'));
        delete(findobj(fgt_gui_handle, 'type', 'UIContainer'));
        
        %  Setup new axes
        fgt_upanel_top  = findobj(fgt_gui_handle, 'tag', 'fgt_upanel_top');
        set(fgt_upanel_top, 'Title', 'Viscosity Ratio');
        
        uc_1            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.00 0.66 0.33 0.33]);
        axes('Parent', uc_1, 'tag', 'axes_1');
        box on;
        
        uc_2            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.00 0.33 0.33 0.33]);
        axes('Parent', uc_2, 'tag', 'axes_2');
        box on;
        
        uc_3            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.00 0.00 0.33 0.33]);
        axes('Parent', uc_3, 'tag', 'axes_3');
        box on;
        
        uc_4            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.33 0.66 0.33 0.33]);
        axes('Parent', uc_4, 'tag', 'axes_4');
        box on;
        
        uc_5            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.33 0.33 0.33 0.33]);
        axes('Parent', uc_5, 'tag', 'axes_5');
        box on;
        
        uc_6            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.33 0.00 0.33 0.33]);
        axes('Parent', uc_6, 'tag', 'axes_6');
        box on;
        
        uc_7            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.66 0.66 0.33 0.33]);
        axes('Parent', uc_7, 'tag', 'axes_7');
        box on;
        
        uc_8            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.66 0.33 0.33 0.33]);
        axes('Parent', uc_8, 'tag', 'axes_8');
        box on;
        
        uc_9            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.66 0.00 0.33 0.33]);
        axes('Parent', uc_9, 'tag', 'axes_9');
        box on;
        
        %  Find the control panel
        fgt_upanel_control  = findobj(fgt_gui_handle, 'Tag', 'fgt_upanel_control');
        
        % Delete all children
        uc_handles   = findobj(fgt_upanel_control, 'Type', 'uicontrol');
        delete(uc_handles);
        
        %  Default sizes
        b_height    = getappdata(fgt_gui_handle, 'b_height');
        b_width     = getappdata(fgt_gui_handle, 'b_width');
        gap         = getappdata(fgt_gui_handle, 'gap');
        
        % Size of panel
        set(fgt_upanel_control, 'Units', 'Pixels');
        Position    = get(fgt_upanel_control, 'Position');
        
        % Get button icons
        buttonUp         = getappdata(fgt_gui_handle, 'buttonUp');
        buttonDown       = getappdata(fgt_gui_handle, 'buttonDown');
        
        
        % FOLD SELECTION
        % Default fold number
        fold = 1;
        setappdata(fgt_gui_handle, 'fold_number', fold);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Fold', ...
            'position', [Position(2)+gap, 4*gap+3*b_height-2, b_height, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','fold_number_up',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','fold_number_down',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 1*gap,            b_height, b_height],...
            'enable', 'off');
        
        % Set fold number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
            'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
        
        
        %  Get data
        Fold        = getappdata(fgt_gui_handle, 'Fold');
        
        % POISSON and STRETCH RATIOS
        % Poisson ratio
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'nu','HorizontalAlignment','left', ...
            'position', [Position(3)-4*gap-4*b_width, 4*gap+3*b_height-2, b_width, b_height]);
        
        % Edit
        if isfield(Fold,'poisson')==0
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', '0.25',...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tooltipstring','Poisson ratio',...
                'tag', 'step_5_poisson', 'BackgroundColor','w', ...
                'position', [Position(3)-3*gap-3*b_width, 4*gap+3*b_height, b_width, b_height]);
        else
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', num2str(Fold(1).poisson),...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tooltipstring','Poisson ratio',...
                'tag', 'step_5_poisson', 'BackgroundColor','w', ...
                'position', [Position(3)-3*gap-3*b_width, 4*gap+3*b_height, b_width, b_height]);
        end
        
        % Stetching ratio
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'S','HorizontalAlignment','left', ...
            'position', [Position(3)-2*gap-2*b_width, 4*gap+3*b_height-2, b_width, b_height]);
        
        % Edit
        if isfield(Fold,'poisson')==0
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', '1', ...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tag', 'step_5_stretch', 'BackgroundColor','w', ...
                'tooltipstring','Stretching ratio',...
                'position', [Position(3)-gap-b_width, 4*gap+3*b_height, b_width, b_height]);
        else
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', num2str(Fold(1).stretch), ...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tag', 'step_5_stretch', 'BackgroundColor','w', ...
                'tooltipstring','Stretching ratio',...
                'position', [Position(3)-gap-b_width, 4*gap+3*b_height, b_width, b_height]);
        end
        
        % POWER LAW EXPONENTS
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Power Law of: ','HorizontalAlignment','right', ...
            'position', [Position(3)-6*gap-6*b_width, 3*gap+2*b_height-2, 2*b_width, b_height]);
        
        % Power Law for layer
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Layer','HorizontalAlignment','left', ...
            'position', [Position(3)-4*gap-4*b_width, 3*gap+2*b_height-2, b_width, b_height]);
        % Edit
        if isfield(Fold,'power_law_layer')==0
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', '1',...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tag', 'step_5_power_law_layer', 'BackgroundColor','w', ...
                'tooltipstring','Power law exponent of layer',...
                'position', [Position(3)-3*gap-3*b_width, 3*gap+2*b_height, b_width, b_height]);
        else
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', num2str(Fold(1).power_law_layer,3),...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tag', 'step_5_power_law_layer', 'BackgroundColor','w', ...
                'tooltipstring','Power law exponent of layer',...
                'position', [Position(3)-3*gap-3*b_width, 3*gap+2*b_height, b_width, b_height]);
        end
        
        % Power Law for matrix
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Matrix','HorizontalAlignment','left', ...
            'position', [Position(3)-2*gap-2*b_width, 3*gap+2*b_height-2, b_width, b_height]);
        
        % Edit
        if isfield(Fold,'power_law_matrix')==0
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', '1', ...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tag', 'step_5_power_law_matrix', 'BackgroundColor','w', ...
                'tooltipstring','Power law exponent of matrix',...
                'position', [Position(3)-gap-b_width, 3*gap+2*b_height, b_width, b_height]);
        else
            uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', num2str(Fold(1).power_law_matrix,3), ...
                'callback',  @(a,b)  fgt('step_5_update_gui'), ...
                'tag', 'step_5_power_law_matrix', 'BackgroundColor','w', ...
                'tooltipstring','Power law exponent of matrix',...
                'position', [Position(3)-gap-b_width, 3*gap+2*b_height, b_width, b_height]);
        end
        
        % THICKNESS METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Thickness','HorizontalAlignment','left', ...
            'position', [Position(3)-2*gap-2*b_width, 2*gap+b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2'}, 'value', 1, 'HorizontalAlignment','center', ...
            'callback',  @(a,b)  fgt('step_5_update_gui'), ...
            'tag', 'step_5_thickness', 'BackgroundColor','w', ...
            'position', [Position(3)-gap-b_width, 2*gap+b_height, b_width, b_height]);
        
        % BUTTONS
        % Back Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Back', ...
            'callback',  @(a,b) fgt('step_4'), ...
            'position', [Position(3)-2*gap-2*b_width, gap, b_width, b_height]);
        
        % Next Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Next', ...
            'tag', 'next', ...
            'callback',  @(a,b) fgt('step_6'), ...
            'position', [Position(3)-gap-b_width, gap, b_width, b_height], ...
            'enable', 'off');
        
        units_normalized;
        
        %  Update GUI
        fgt('step_5_update_gui');
        
    case 'step_5_update_gui'
        %% - step_5_update_gui
        
        %  Get Data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        fold    = getappdata(fgt_gui_handle, 'fold_number');
        popts   = getappdata(fgt_gui_handle, 'popts');
        
        %  Read data
        thickness_method       	    = get(findobj(fgt_gui_handle, 'tag', 'step_5_thickness'),        'value');  
        Fold(1).power_law_layer  	= str2double(get(findobj(fgt_gui_handle, 'tag', 'step_5_power_law_layer'),  'string'));
        Fold(1).power_law_matrix  	= str2double(get(findobj(fgt_gui_handle, 'tag', 'step_5_power_law_matrix'), 'string'));
        Fold(1).poisson           	= str2double(get(findobj(fgt_gui_handle, 'tag', 'step_5_poisson'),          'string'));
        Fold(1).stretch           	= str2double(get(findobj(fgt_gui_handle, 'tag', 'step_5_stretch'),          'string'));
        
        % Display warning messages if necessary
        if Fold(1).poisson > 0.5 || Fold(1).poisson < -1
            eh = errordlg('The Poisson''s ratio of an isotropic, linear elastic material cannot be less than -1.0 nor greater than 0.5.', 'FGT - Error', 'modal');
            uiwait(eh);
        end
        if Fold(1).stretch < 0
            eh = errordlg('The streching ratio cannot be less than 0.', 'FGT - Error', 'modal');
            uiwait(eh);
        end
        
        % Equations
        Equations = {'$$\frac{L}{h} = 2 \pi \sqrt[3]{\frac{\mu_l}{6 \mu_m}} $$',...
            '$$\frac{L}{h} = 2 \pi \sqrt[3]{\frac{E_l}{6 E_m}} $$',...
            '$$\frac{L}{h} = \pi \sqrt{\frac{E_l}{P (1- \nu_l^2)}} $$',...
            '$$\frac{L}{h} = 2 \pi \sqrt[3]{\frac{N \mu_l}{6 \mu_m}} $$',...
            '',...
            '$$\frac{L}{h} = 2 \pi \sqrt[3]{\frac{\mu_l}{6 \mu_m} \frac{S_x^2(S_x^2+1)}{2}} $$',...
            '$$\frac{L}{h} = 2 \pi \sqrt[3]{\frac{\mu_l}{6 \mu_m} \frac{\sqrt{n_m}}{n_l}} $$',...
            '$$\frac{\mu_l}{\mu_m} = \frac{1+e^{2 \frac{\pi h}{L_d}} \sqrt{ \frac{1-2\frac{\pi h}{L_d}}{1+2\frac{\pi h}{L_d}}} }{1-e^{2\frac{\pi h}{L_d}} \sqrt{ \frac{1-2\frac{\pi h}{L_d}}{1+2\frac{\pi h}{L_d}}}} $$',...
            '$$\frac{\mu_l}{\mu_m} = \frac{1+cosh(2 \frac{\pi h}{L_d})-2k_d sinh(2\frac{\pi h}{L_d})}{2\frac{\pi h}{L_d} cosh(2\frac{\pi h}{L_d})-sinh(2\frac{\pi h}{L_d})} $$'};
        
        % Unknown ratio
        Unknown = {'$$ \frac{\mu_l}{\mu_m} = $$',...
            '$$ \frac{E_l}{E_m} = $$',...
            '$$ \frac{E_l}{P} = $$',...
            '$$ \frac{\mu_l}{\mu_m} = $$',...
            '',...
            '$$ \frac{\mu_l}{\mu_m} = $$',...
            '$$ \frac{\mu_l}{\mu_m} = $$',...
            '$$ \frac{\mu_l}{\mu_m} = $$',...
            '$$ \frac{\mu_l}{\mu_m} = $$'};
        
        % Authors
        Authors = {'Linear viscous (Biot, 1961)',...
            'Linear elastic (Currie et al., 1962)',...
            'Visco-elastic (Biot, 1961)',...
            'Multilayer linear viscous (Biot, 1965)',...
            ''...
            'Thickening correction (Sherwin and Chapple, 1968)',...
            'Non-linear viscous (Fletcher, 1974)',...
            'Thick plate, no slip bc. (Fletcher, 1977)',...
            'Thick plate, free slip bc. (Fletcher, 1977)'};
        
        
       % Calculate an average arc length
        Arclength = mean(2*[(Fold(fold).Face(1).Arclength.Full(Fold(fold).Face(1).Inflection(2:end))-Fold(fold).Face(1).Arclength.Full(Fold(fold).Face(1).Inflection(1:end-1)))...
                            (Fold(fold).Face(2).Arclength.Full(Fold(fold).Face(2).Inflection(2:end))-Fold(fold).Face(2).Arclength.Full(Fold(fold).Face(2).Inflection(1:end-1)))]);
                   
        % Define thickness
        if thickness_method == 1
            Thickness   = mean([Fold(fold).Thickness.Local(1).Value Fold(fold).Thickness.Local(2).Value]);
        end
        if thickness_method == 2
            Thickness   = Fold(fold).Thickness.Average;
        end
        
        % Calculate the unknown ratio
        kd        = pi*Thickness./Arclength;
        Solutions = [...
            6*(Arclength./(2*pi*Thickness)).^3; ...
            6*(Arclength./(2*pi*Thickness)).^3; ...
            (Arclength./(pi*Thickness)).^2*(1-Fold(1).poisson^2);...
            (6/size(Fold,2))*(Arclength./(2*pi*Thickness)).^3;...
            NaN*ones(1,max([length(Arclength),length(Thickness)]));...
            12*(Arclength./(2*pi*Thickness)).^3/( (Fold(1).stretch)^2 * (Fold(1).stretch^2 + 1) );...
            6*(Arclength./(2*pi*Thickness)).^3*Fold(1).power_law_layer/sqrt(Fold(1).power_law_matrix);...
            abs( 1+exp(2*kd).* sqrt( (1-2*kd)./(1+2*kd) ) ./( 1-exp(2*kd).* sqrt( (1-2*kd)./(1+2*kd) ) ));...
            ( 1+cosh(2*kd)-2*kd.*sin(2*kd) )./( 2*kd.*cosh(2*kd)-sinh(2*kd) )];
        
        
        for i = [1:4, 6:9]
            % Remove Imaginary Numbers
            Solution            = Solutions(i,imag(Solutions(i,:))==0);
            
            achse  = findobj(fgt_gui_handle, 'tag', ['axes_',num2str(i)]);
            set(fgt_gui_handle, 'CurrentAxes', achse);
            delete(allchild(achse));
            hold(achse, 'on');
            
            % Display equation and solution to the equation 
            text('position',[.5 .6], 'fontsize',12,'HorizontalAlignment','Center',...
                'interpreter','latex','string',Equations{i}, 'parent', achse);
            text('position',[.5 .2], 'fontsize',12,'HorizontalAlignment','Center',...
                'interpreter','latex','string',[Unknown{i},num2str(mean(Solution),'%2.1f')], ...
                'parent', achse);
            
            set(achse, 'XTick', [], 'YTick', []);
            title(achse, [Authors{i}]);
            
        end
        
        %  5. Fold
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_5');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        hold(achse, 'on');
        
        for j=1:length(Fold)
            fh  = fill([Fold(j).Face(1).X.Norm fliplr(Fold(j).Face(2).X.Norm)], [Fold(j).Face(1).Y.Norm fliplr(Fold(j).Face(2).Y.Norm)], 'k');
            set(fh, 'FaceColor', popts.fold_color_inactive);
        end
        fh  = fill([Fold(fold).Face(1).X.Norm fliplr(Fold(fold).Face(2).X.Norm)], [Fold(fold).Face(1).Y.Norm fliplr(Fold(fold).Face(2).Y.Norm)], 'k');
        set(fh, 'FaceColor', popts.fold_color_active);
        title(achse,['Average L/h:  ', num2str(mean(Arclength./Thickness),'%2.2f')]);
        axis(achse,'equal');
        axis(achse,'on');
        set(gca,'XTick',[],'YTick',[])
        zoom(achse,'off');
        
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        %  Activate next button
        set(findobj(fgt_gui_handle, 'tag', 'next'), 'enable', 'on');
        
        % Deactivete fold buttons
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'),   'enable', 'off');
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'off');
        
        % Activatie fold number button
        if fold < size(Fold,2)
            fold_number = ['Fold number ',num2str(fold+1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'), 'enable', 'on','tooltipstring', fold_number);
        end
        if fold > 1
            fold_number = ['Fold number ',num2str(fold-1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'on','tooltipstring', fold_number);
        end
        
        units_normalized;

    case 'step_6'
        %% STEP_6: Surface Plots
        
        % Put FGT into step_6 mode
        setappdata(fgt_gui_handle, 'mode', 6);
        set(fgt_gui_handle,'windowbuttonmotionfcn',[]);
        
        %  Delete all axes and UIContainers and uitable that may exist
        delete(findobj(fgt_gui_handle, 'type', 'axes'));
        delete(findobj(fgt_gui_handle, 'type', 'UIContainer'));
        delete(findobj(fgt_gui_handle, 'type', 'uitable'));
        
        %  Setup new axes
        fgt_upanel_top  = findobj(fgt_gui_handle, 'tag', 'fgt_upanel_top');
        set(fgt_upanel_top, 'Title', 'Strain & Viscosity Ratio');
        
        uc_1            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.0 0.0 0.5 1]);
        axes('Parent', uc_1, 'tag', 'axes_1');
        box on;
        
        uc_2            = uicontainer('Parent', fgt_upanel_top, 'Units', 'Normalized', 'Position', [0.5 0.0 0.5 1]);
        axes('Parent', uc_2, 'tag', 'axes_2');
        box on;
        
        %  Find the control panel
        fgt_upanel_control  = findobj(fgt_gui_handle, 'Tag', 'fgt_upanel_control');
        
        % Delete all children
        uc_handles   = findobj(fgt_upanel_control, 'Type', 'uicontrol');
        delete(uc_handles);
        
        %  Default sizes
        b_height    = getappdata(fgt_gui_handle, 'b_height');
        b_width     = getappdata(fgt_gui_handle, 'b_width');
        gap         = getappdata(fgt_gui_handle, 'gap');
        
        % Size of panel
        set(fgt_upanel_control, 'Units', 'Pixels');
        Position    = get(fgt_upanel_control, 'Position');
        
        % Get button icons
        buttonUp         = getappdata(fgt_gui_handle, 'buttonUp');
        buttonDown       = getappdata(fgt_gui_handle, 'buttonDown');
        
        
        % FOLD SELECTION
        % Default fold number
        fold = 0;
        setappdata(fgt_gui_handle, 'fold_number', fold);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Fold', ...
            'position', [Position(2)+gap, 4*gap+3*b_height-2, b_height, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','fold_number_up',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','fold_number_down',...
            'callback',  @f_number, ...
            'position', [Position(2)+gap, 1*gap,            b_height, b_height],...
            'enable', 'off');
        
        % Set fold number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
            'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
        
        % Default fold number
        face = 0;
        setappdata(fgt_gui_handle, 'face_number', face);
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Face', ...
            'position', [Position(2)+3*gap+b_height, 4*gap+3*b_height-2, b_height+gap, b_height]);
        
        % Up Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonUp,'units','pixels',...
            'tag','face_number_down',...
            'callback',  @f_number, ...
            'position', [Position(2)+3*gap+b_height, 3*gap+2*b_height, b_height, b_height],...
            'enable', 'off');
        
        % Down Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton',...
            'cdata',buttonDown,'units','pixels',...
            'tag','face_number_up',...
            'callback',  @f_number, ...
            'position', [Position(2)+3*gap+b_height, 1*gap,   b_height, b_height],...
            'enable', 'off');
        
        % Set face number
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(face),...
            'position', [Position(2)+3*gap+b_height, 2*gap+1*b_height,  b_height, b_height]);
        
        
        %  Get data
        Fold        = getappdata(fgt_gui_handle, 'Fold');
        
        % RAY C. FLETCHER AND JO-ANN SHERWIN METHOD
        
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Power Law of: ','HorizontalAlignment','left', ...
            'position', [Position(3)-6*gap-6*b_width, 3*gap+2*b_height-2, 2*b_width, b_height]);
        
        % Power Law of layer
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Layer','HorizontalAlignment','left', ...
            'position', [Position(3)-4*gap-4*b_width, 3*gap+2*b_height-2, b_width, b_height]);
        
        % Edit
        uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', num2str(Fold(1).power_law_layer,3),...
            'callback',  @(a,b)  fgt('step_6_update_gui'), ...
            'tag', 'step_6_power_law_layer', 'BackgroundColor','w', ...
            'position', [Position(3)-3*gap-3*b_width, 3*gap+2*b_height, b_width, b_height]);
        
        % Power Law of matrix
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Matrix','HorizontalAlignment','left', ...
            'position', [Position(3)-2*gap-2*b_width, 3*gap+2*b_height-2, b_width, b_height]);
        
        % Edit
        uicontrol('Parent', fgt_upanel_control, 'style', 'edit', 'String', num2str(Fold(1).power_law_matrix,3), ...
            'callback',  @(a,b)  fgt('step_6_update_gui'), ...
            'tag', 'step_6_power_law_matrix', 'BackgroundColor','w', ...
            'position', [Position(3)-gap-b_width, 3*gap+2*b_height, b_width, b_height]);
        
        
        % STEFAN M. SCHMALHOLZ & YURI Y. PODLADCHIKOV METHOD
        
        % AMPLITUDE METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Amplitude','HorizontalAlignment','left', ...
            'position', [Position(3)-6*gap-6*b_width, 2*gap+b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2';'3'}, 'value', 1, ...
            'callback',  @(a,b)  fgt('step_6_update_gui'), ...
            'tag', 'step_6_amplitude', 'BackgroundColor','w', ...
            'position', [Position(3)-5*gap-5*b_width, 2*gap+b_height, b_width, b_height]);
        
        % WAVELENGTH METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Wavelength','HorizontalAlignment','left', ...
            'position', [Position(3)-4*gap-4*b_width, 2*gap+b_height-2, b_width, b_height]);
        
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2';'3';'4'}, 'value', 1, ...
            'callback',  @(a,b)  fgt('step_6_update_gui'), ...
            'tag', 'step_6_wavelength', 'BackgroundColor','w', ...
            'position', [Position(3)-3*gap-3*b_width, 2*gap+b_height, b_width, b_height]);
        
        % THICKNESS METHOD
        % Text
        uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String', 'Thickness','HorizontalAlignment','left', ...
            'position', [Position(3)-2*gap-2*b_width, 2*gap+b_height-2, b_width, b_height]);
        
        % BUTTONS
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'popupmenu', 'String', {'1';'2'}, 'value', 1, ...
            'callback',  @(a,b)  fgt('step_6_update_gui'), ...
            'tag', 'step_6_thickness', 'BackgroundColor','w', ...
            'position', [Position(3)-gap-b_width, 2*gap+b_height, b_width, b_height]);
        
        % Back Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Back', ...
            'callback',  @(a,b) fgt('step_5'), ...
            'position', [Position(3)-2*gap-2*b_width, gap, b_width, b_height]);
        
        % Table Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'pushbutton', 'String', 'Table', ...
            'tag', 'table', ...
            'callback',  @(a,b) fgt_data, ...
            'position', [Position(3)-gap-b_width, gap, b_width, b_height], ...
            'enable', 'off');
        
        % GRID on
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'Grid on', 'Value', 1,...
            'callback',   @fgt_grid, ...
            'tag', 'step_6_grid', ...
            'position', [Position(2)+4*gap+2*b_height, gap, 2*b_width, b_height]);
        zoom off;
        
        % Individual data
        % Button
        uicontrol('Parent', fgt_upanel_control, 'style', 'checkbox', 'String', 'Individual Data', 'Value', 1,...
            'callback',    @(a,b)  fgt('step_6_update_gui'), ...
            'tag', 'step_6_individual_data', ...
            'position', [Position(2)+3*gap+2*b_height+b_width, gap, 2*b_width, b_height]);
        
        units_normalized;
        
        %  Update GUI
        fgt('step_6_update_gui');
        
    case 'step_6_update_gui'
        %% - step_6_update_gui
        
        %  Get Data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        fold  	= getappdata(fgt_gui_handle, 'fold_number');
        face  	= getappdata(fgt_gui_handle, 'face_number');
        popts   = getappdata(fgt_gui_handle, 'popts');
        
        % Whoiscalling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        %  Read data
        amplitude_method    = get(findobj(fgt_gui_handle, 'tag', 'step_6_amplitude'),        'value');
        wavelength_method   = get(findobj(fgt_gui_handle, 'tag', 'step_6_wavelength'),       'value');
        thickness_method    = get(findobj(fgt_gui_handle, 'tag', 'step_6_thickness'),        'value');
        indivudual_data     = get(findobj(fgt_gui_handle, 'tag', 'step_6_individual_data'),  'value');
        Fold(1).power_law_layer 	= str2double(get(findobj(fgt_gui_handle, 'tag', 'step_6_power_law_layer'),  'string'));
        Fold(1).power_law_matrix  	= str2double(get(findobj(fgt_gui_handle, 'tag', 'step_6_power_law_matrix'), 'string'));
        
        
        % RAY C. FLETCHER AND JO-ANN SHERWIN METHOD
        % Calculate contours for viscosity ratio and strain plot
        Fold(1).power_law_layer  = max([1.0001, Fold(1).power_law_layer]);
        Fold(1).power_law_matrix = max([1.0001, Fold(1).power_law_matrix]);
        
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        %  Calculate strain and viscosity ratio
        if isempty(Whoiscalling) || strcmp(Whoiscalling,'step_6_power_law_matrix') || strcmp(Whoiscalling,'step_6_power_law_matrix')
            [lohs, bees, RRR, SSS] = fletcher_sherwin(Fold(1).power_law_layer, Fold(1).power_law_matrix);
            Fold(1).FS_plot.lohs = lohs;
            Fold(1).FS_plot.bees = bees;
            Fold(1).FS_plot.RRR  = RRR;
            Fold(1).FS_plot.SSS  = SSS;
        end
        
        % Plotting
        
        % Set axes
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        
        delete(allchild(achse));
        hold(achse, 'on');
        axis(achse,'square');
        fgt_grid(findobj(fgt_gui_handle, 'tag', 'step_6_grid'));
        
        % Define and plot the viscosity ratio contours
        rcon = [10:10:100 150 200];
        [C,h]  = contour(Fold(1).FS_plot.lohs,Fold(1).FS_plot.bees,Fold(1).FS_plot.RRR,rcon,...
            'Color',popts.FS_vis_color,'LineWidth',popts.FS_vis_thick,'parent',achse);
        clabel(C, h, 'Color', popts.FS_vis_color);
        
        % Define and plot the strain contours
        escon = [0.1:0.1:0.9 0.95];
        [C,h] = contour(Fold(1).FS_plot.lohs,Fold(1).FS_plot.bees,Fold(1).FS_plot.SSS,escon,...
            'Color',popts.FS_stretch_color,'LineWidth',popts.FS_stretch_thick,'parent',achse);
        clabel(C, h, 'Color', popts.FS_stretch_color);
        
        %Limit axes
        axis(achse,[popts.FS_xmin popts.FS_xmax popts.FS_ymin popts.FS_ymax])
        
        xlabel(achse,'L_P/H');
        ylabel(achse,'{\beta}^*');
        title(achse,'Fletcher & Sherwin (1978)')
        
        
        % SCHMALHOLZ & PODLADCHIKOV METHOD
        
        %  Generate plot
        
        % Load numerical data
        if isempty(Whoiscalling)
            Fold(1).SP_plot.Vis = load('schmalholz_podladchikov.mat');
        end
        
        % Set axes
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_2');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        
        delete(allchild(achse));
        hold(achse, 'on');
        % Plot viscosity contours
        % The actual data is plotted with the plot statement below. The
        % contour labels are generated with a low resolution (fast) data
        % grid of the same data. Of this only the labels are needed and
        % therefore they are copyied with the copyobj and assigned to the
        % axes. The original countours and their labels are then deleted.
        [co_sp, ch_sp] = contour(Fold(1).SP_plot.Vis.XX,Fold(1).SP_plot.Vis.YY,Fold(1).SP_plot.Vis.ZZ,[10 10, 25 25, 50 50, 100 100, 250 250],'-w');
        clabel(co_sp, ch_sp,'LabelSpacing',150,'Color',popts.SP_vis_color, 'BackGroundColor', 'w');
        plot(Fold(1).SP_plot.Vis.H2L_num10, Fold(1).SP_plot.Vis.A2L_num10, 'Color',popts.SP_vis_color,'LineWidth',popts.SP_vis_thick,'parent',achse);
        plot(Fold(1).SP_plot.Vis.H2L_num25, Fold(1).SP_plot.Vis.A2L_num25, 'Color',popts.SP_vis_color,'LineWidth',popts.SP_vis_thick,'parent',achse);
        plot(Fold(1).SP_plot.Vis.H2L_num50, Fold(1).SP_plot.Vis.A2L_num50, 'Color',popts.SP_vis_color,'LineWidth',popts.SP_vis_thick,'parent',achse);
        plot(Fold(1).SP_plot.Vis.H2L_num100,Fold(1).SP_plot.Vis.A2L_num100,'Color',popts.SP_vis_color,'LineWidth',popts.SP_vis_thick,'parent',achse);
        plot(Fold(1).SP_plot.Vis.H2L_num250,Fold(1).SP_plot.Vis.A2L_num250,'Color',popts.SP_vis_color,'LineWidth',popts.SP_vis_thick,'parent',achse);
        % We finish the clabel trick as the last thing, when the plot is
        % basically done as we need a drawnow statement.
        
        % Plot strain contours
        [co, ch] = contour(Fold(1).SP_plot.Vis.H2L_map,Fold(1).SP_plot.Vis.A2L_map,Fold(1).SP_plot.Vis.Strain_map',[0.10,0.20,0.30,0.40,0.50,0.60,0.65,0.70],...
            'Color',popts.SP_short_color,'LineWidth',popts.SP_short_thick,'parent',achse);
        clabel(co,ch,'LabelSpacing',150,'Color',popts.SP_short_color);
        
        % Limit Axis
        axis(achse,[0 popts.SP_xmax 0 popts.SP_ymax])
        
        axis(achse,'square');
        grid(achse,'on');
        xlabel(achse,'H / \lambda')
        ylabel(achse,'A / \lambda')
        title(achse,'Schmalholz & Podladchikov (2001)')
        
        % clabel trick
        drawnow; % Needed so that we can get the TextPrims
        copyobj(ch_sp.TextPrims, achse); % Undocumented. See http://undocumentedmatlab.com/blog/customizing-contour-plots
        delete(ch_sp);
        
        %  Plot FGT data points
        if fold == 0
            ifold = 1:length(Fold);
        else
            ifold = fold;
        end
        if face == 0
            jface = 1:2;
        else
            jface = face;
        end
        
        for ii = ifold
            
            achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
            set(fgt_gui_handle, 'CurrentAxes', achse);
            
            %  Arc length between the two neighbouring inflection points of
            %  the upper and lower interface
            for jj = jface
                Arc = 2*(Fold(ii).Face(jj).Arclength.Full(Fold(ii).Face(jj).Inflection(2:end))-Fold(ii).Face(jj).Arclength.Full(Fold(ii).Face(jj).Inflection(1:end-1)));
                
                %  Calculate data distribution
                L2H     = mean(Arc./Fold(ii).Thickness.Local(jj).Value);
                delta   = std(Arc./Fold(ii).Thickness.Local(jj).Value)/mean(Arc./Fold(ii).Thickness.Local(jj).Value);
                betas   = 4.1*delta.^2 + 0.8*delta;
                
                if length(Arc) > 4
                    %  Plot points on the diagram
                    h1 = plot(L2H,betas,'o','MarkerSize',popts.FS_data_size,'MarkerEdgeColor','k','MarkerFaceColor',popts.FS_data_color,'Parent',achse);
                else
                    helpdlg('Too little data to do statistics used in Fletcher and Sherwin method.', 'Error message');
                end
            end
            
            %  Plot data
            achse  = findobj(fgt_gui_handle, 'tag', 'axes_2');
            set(fgt_gui_handle, 'CurrentAxes', achse);
            
            for jj = jface
                
                if amplitude_method == 1
                    Amplitude   = Fold(ii).Face(jj).Amplitude(1).Value;
                elseif amplitude_method == 2
                    Amplitude   = Fold(ii).Face(jj).Amplitude(2).Value;
                else
                    Amplitude   = Fold(ii).Face(jj).Amplitude(3).Value;
                end
                
                if wavelength_method ==1
                    Wavelength = Fold(ii).Face(jj).Wavelength(1).Value;
                elseif wavelength_method ==2
                    Wavelength = Fold(ii).Face(jj).Wavelength(2).Value;
                elseif wavelength_method ==3
                    Wavelength = Fold(ii).Face(jj).Wavelength(3).Value;
                else
                    Wavelength = Fold(ii).Face(jj).Wavelength(4).Value;
                end
                
                if thickness_method == 1
                    Thickness   = Fold(ii).Thickness.Local(jj).Value;
                else
                    Thickness   = Fold(ii).Thickness.Average;
                end
                
                if indivudual_data == 1
                    % All values
                    h2(1) = plot(Thickness./Wavelength, Amplitude./Wavelength,...
                        'o','MarkerSize',popts.SP_data2_size,'MarkerEdgeColor','k','MarkerFaceColor',popts.SP_data2_color,'Parent',achse);
                    % Mean values
                    h2(2) = plot(mean(Thickness./Wavelength), mean(Amplitude./Wavelength),...
                        'o','MarkerSize',popts.SP_data1_size,'MarkerEdgeColor','k','MarkerFaceColor',popts.SP_data1_color,'Parent',achse);
                else
                    % Mean values
                    h2(1) = plot(mean(Thickness./Wavelength), mean(Amplitude./Wavelength),...
                        'o','MarkerSize',popts.SP_data1_size,'MarkerEdgeColor','k','MarkerFaceColor',popts.SP_data1_color,'Parent',achse);
                end
            end
        end
        
        % Legend
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
        set(fgt_gui_handle, 'CurrentAxes', achse);
        
        % Add two fake lines to the plot so that not the standard contour
        % symbol is used in the legend
        ll(1)   = plot([0 0], [0 0], 'Color',popts.FS_stretch_color,'Parent',achse);
        ll(2)   = plot([0 0], [0 0], 'Color',popts.FS_vis_color,'Parent',achse);
        
        % Together with the last two plot statements this can be used to
        % make the legend
        if exist('h1','var')
            legend([ll, h1],'Stretch', 'Viscosity Ratio', 'Data');
        end
        
        % Legend
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_2');
        set(fgt_gui_handle, 'CurrentAxes', achse);
              
        % Add two fake lines to the plot so that not the standard contour
        % symbol is used in the legend
        ll(1)   = plot([0 0], [0 0], 'Color',popts.SP_short_color,'Parent',achse);
        ll(2)   = plot([0 0], [0 0], 'Color',popts.SP_vis_color,'Parent',achse);
        
        % Together with the last two plot statements this can be used to
        % make the legend
        if indivudual_data == 1
            legend([ll, h2],'Shortening', 'Viscosity Ratio', 'Individual Data', 'Average Data');
        else
            legend([ll, h2],'Shortening', 'Viscosity Ratio', 'Average Data');
        end
        
        %  Update data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        % Deactivete i buttons
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'),   'enable', 'off');
        set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'off');
        
        % Activatie fold & face number button
        if fold < size(Fold,2)
            fold_number = ['Fold number ',num2str(fold+1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_up'), 'enable', 'on','tooltipstring', fold_number);
        end
        if fold > 0
            fold_number = ['Fold number ',num2str(fold-1)];
            set(findobj(fgt_gui_handle, 'tag', 'fold_number_down'), 'enable', 'on','tooltipstring', fold_number);
        end
        if fold>0 && face == 2
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),   'enable', 'on' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'), 'enable', 'off');
        elseif fold>0 && face == 1
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),   'enable', 'on' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'), 'enable', 'on');
        elseif fold>0 && face ==0
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'), 'enable', 'on' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),   'enable', 'off');
        elseif fold == 0
            set(findobj(fgt_gui_handle, 'tag', 'face_number_down'), 'enable', 'off' );
            set(findobj(fgt_gui_handle, 'tag', 'face_number_up'),   'enable', 'off');
        end
        
	    %  Activate table button
        set(findobj(fgt_gui_handle, 'tag', 'table'), 'enable', 'on');
        
        
end

%% fun subdir_add
    function subdir_add(Subdir)
        % Add this subdirectory
        addpath(Subdir);
        
        % Check if subdirectories exist - Recursion
        Files   = dir(Subdir);
        for ff=1:length(Files)
            if Files(ff).isdir && ~strcmp(Files(ff).name, '.') && ~strcmp(Files(ff).name, '..')
                subdir_add([Subdir, filesep, Files(ff).name])                
            end
        end
    end

%% fun norminitialize_fold_structure
    function norminitialize_fold_structure()
        
        % Get Data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        
        %  Find the arc length of the fold's first interface
        Arc_length  = sqrt( (Fold(1).Face(1).X.Ori(2:end)-Fold(1).Face(1).X.Ori(1:end-1)).^2 + (Fold(1).Face(1).Y.Ori(2:end)-Fold(1).Face(1).Y.Ori(1:end-1)).^2 );
        Arc_length  = [0 cumsum(Arc_length)];
        
        Shift   = Fold(1).Face(1).X.Ori(1);
            
        %  Normalize the fold
        for i = 1:length(Fold)
            for j = 1:2
                Fold(i).Face(j).X.Norm = (Fold(i).Face(j).X.Ori - Shift)/Arc_length(end);
                Fold(i).Face(j).Y.Norm = (Fold(i).Face(j).Y.Ori        )/Arc_length(end);
            end
        end
        
        %  Set Default Filter Width if not exist
        if isfield(Fold(1).Face(1),'filter_width') == 0
            for i = 1:length(Fold)
                for j = 1:2
                    Fold(i).Face(j).filter_width    = 0.01;
                end
            end
        end
        
        %  Set Default Fraction
        if isfield(Fold(1),'fraction') == 0
            Fold(1).fraction            = 0.10;
        end
        
        %  Set Default Hinge Method
        if isfield(Fold(1),'hinge_method') == 0
            Fold(1).hinge_method            = 1;
        end
        
        %  Set Numer of Nodes used for Curvature Calculations
        if isfield(Fold(1),'order') == 0
            Fold(1).order               = 3;
        end
        
        %  Set Default Global Filtering Mode
        if isfield(Fold(1),'individual_filter') == 0
            Fold(1).individual_filter            = 0;
        end
        
        % Put Data
        setappdata(fgt_gui_handle, 'Fold', Fold);
    end

%% fun units_normalized
    function units_normalized
        % For the layout pixel untis are used. For the resizing to work
        % normalized has to be used
        % 'tag', 'fgt_gui_handle'
        Ui  = findobj(0, 'type', 'uipanel', '-or', 'type', 'uicontrol');
        %set(fgt_gui_handle, 'Unit', 'normalized');
        set(Ui, 'Unit', 'normalized');
        
    end

%% fun fgt_zoom
    function fgt_zoom(obj, ~)
        zoom_status     = {'off', 'on'};
        zoom(fgt_gui_handle, zoom_status{get(obj,'value')+1});
    end

%% fun fgt_grid
    function fgt_grid(obj, ~)
                        
        % Get axis form step 6
        achse_1  = findobj(fgt_gui_handle, 'tag', 'axes_1');
        achse_2  = findobj(fgt_gui_handle, 'tag', 'axes_2');
        
        grid_status     = {'off', 'on'};
        grid(achse_1, grid_status{get(obj,'value')+1});
        grid(achse_2, grid_status{get(obj,'value')+1});
    end

%% fun f_individual
    function f_individual(obj, event_obj)
        
        % Get Data
        Fold    = getappdata(fgt_gui_handle, 'Fold');
        
        if isfield(Fold(1).Face(1),'WindowSizes')
            Fold(1).Face(1).WindowSizes = [];
            Fold(1).individual_filter   = mod(Fold(1).individual_filter+1,2);
        end
        
        % Put Data
        setappdata(fgt_gui_handle, 'Fold', Fold);
        
        % Go back to the proper step mode
        fgt(['step_2_update_gui']);
    end

%% fun f_number
    function f_number(obj, event_obj)
        
        % Gets currently active fold interface
        % Get data
        fold    = getappdata(fgt_gui_handle, 'fold_number');
        face    = getappdata(fgt_gui_handle, 'face_number');
        
        %  Find the control panel
        fgt_upanel_control  = findobj(fgt_gui_handle, 'Tag', 'fgt_upanel_control');
        
        %  Default sizes
        b_height    = getappdata(fgt_gui_handle, 'b_height');
        gap         = getappdata(fgt_gui_handle, 'gap');
        
        % Size of panel
        set(fgt_upanel_control, 'Units', 'Pixels');
        Position    = get(fgt_upanel_control, 'Position');
        
        if strcmp(get(gco,'Tag'),'fold_number_up')
            fold    = fold + 1;
        elseif strcmp(get(gco,'Tag'),'fold_number_down')
            fold    = fold - 1;
        elseif strcmp(get(gco,'Tag'),'face_number_up')
            face    = face - 1;
        elseif strcmp(get(gco,'Tag'),'face_number_down')
            face    = face + 1;
        end          
        
        setappdata(fgt_gui_handle, 'fold_number', fold);
        setappdata(fgt_gui_handle, 'face_number', face);
        
        % Get fgt step mode
        mode = getappdata(fgt_gui_handle, 'mode');
        
        % Set fold or face number
        if mode == 2 || mode == 22 || mode == 6
            if fold == 0
                uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String','All',...
                'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
            else
                uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
                    'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
            end
            if face == 0
                uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String','All',...
                    'position', [Position(2)+3*gap+b_height, 2*gap+1*b_height,  b_height, b_height]);
            else
                uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(face),...
                    'position', [Position(2)+3*gap+b_height, 2*gap+1*b_height,  b_height, b_height]);
            end
        else
            uicontrol('Parent', fgt_upanel_control, 'style', 'text', 'String',num2str(fold),...
                'position', [Position(2)+gap, 2*gap+1*b_height,  b_height, b_height]);
        end
        
        if mode == 2 || mode == 22
            Filt       = get(findobj(fgt_gui_handle, 'tag', 'step_2_individual'),  'value');
            % Clear the axis of NIP-FW diagram
            if Filt == 1
                achse  = findobj(fgt_gui_handle, 'tag', 'axes_3');
                %cla(achse);
            end
        end
        
        % Go back to the proper step mode
        fgt(['step_',num2str(mode),'_update_gui']);
        
    end

%%  fun mouseover
    function mouseover()
        
        % Need to make sure that root unit is pixels
        set(0, 'Units', 'Pixels');
        
        % Handles to the two axes
        axes_1      = findobj(fgt_gui_handle, 'tag', 'axes_1');
        axes_2      = findobj(fgt_gui_handle, 'tag', 'axes_2');
        
        % Get pointer location w.r.t. Fold plot (axes_1)
        Screen_xy 	= get(0,'PointerLocation');
        Figure_xy  	= getpixelposition(fgt_gui_handle);
        Axes_xy    	= getpixelposition(axes_1, true);
        Xlim        = get(axes_1, 'XLim');
        Ylim        = get(axes_1, 'YLim');
        axes_x      = Screen_xy(1) - Axes_xy(1) - Figure_xy(1);
        axes_x      = axes_x/Axes_xy(3)*(Xlim(2)-Xlim(1)) + Xlim(1);
        axes_y      = Screen_xy(2) - Axes_xy(2) - Figure_xy(2);
        axes_y      = axes_y/Axes_xy(4)*(Ylim(2)-Ylim(1)) + Ylim(1);
        
        % Analyse further - only if pointer inside axes_1
        if Xlim(1)<axes_x && axes_x<Xlim(2) && Ylim(1)<axes_y && axes_y<Ylim(2)
            
            % Get fold data
            Fold  	= getappdata(fgt_gui_handle, 'Fold');
            fold  	= getappdata(fgt_gui_handle, 'fold_number');
            face   	= getappdata(fgt_gui_handle, 'face_number');
            
            % Get current fold data
            xx = Fold(fold).Face(face).X.Full;
            yy = Fold(fold).Face(face).Y.Full;
            
            % Get current point location
            %P = get(gca, 'CurrentPoint');
            P = get(axes_1, 'CurrentPoint');
            
            % Find the closest point between the current point and the interface
            dist = sqrt( (xx-P(1,1)).^2 + (yy-P(1,2)).^2);
            [min_dist,idx] = min(dist);
            
            % In case there is more then one point with the same distance take the first one
            idx =idx(1);
            
            % Plot only when pointer is close enough
            if min_dist < 0.05
                
                % Define the exact point on the x-y and Curvature-Arclength length
                % plots for the pointer position
                xy_x = Fold(fold).Face(face).X.Full(idx);
                xy_y = Fold(fold).Face(face).Y.Full(idx);
                ac_x = Fold(fold).Face(face).Arclength.Full(idx);
                ac_y = Fold(fold).Face(face).Curvature.Full(idx);
                
                % Try to get handels to the marker points
                point_h1= getappdata(axes_1, 'point_h1');
                point_h2= getappdata(axes_2, 'point_h2');
                
                % Plot marker points - move if already exist
                if isempty(point_h1)
                    % Plot marker points
                    point_h1 = plot(xy_x, xy_y, 'Parent', axes_1, 'Marker','o','MarkerFaceColor','y','MarkerSize',6,'MarkerEdgeColor','k','Hittest','off','tag','Yellow point');
                    point_h2 = plot(ac_x, ac_y, 'Parent', axes_2, 'Marker','o','MarkerFaceColor','y','MarkerSize',6,'MarkerEdgeColor','k','Hittest','off','tag','Yellow point');
                    
                    % Do not add to legend
                    set(get(get(point_h1,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off');
                    set(get(get(point_h2,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off');
                    
                    % Store handles
                    setappdata(axes_1, 'point_h1', point_h1);
                    setappdata(axes_2, 'point_h2', point_h2);
                else
                    % Move marker points
                    set(point_h1, 'XData', xy_x, 'YData', xy_y);
                    set(point_h2, 'XData', ac_x, 'YData', ac_y);
                end
            end
            
        else
            % Try to get handels to the marker points
            point_h1= getappdata(axes_1, 'point_h1');
            point_h2= getappdata(axes_2, 'point_h2');
            
            % Remove marker points if pointer is outside the axes
            if ~isempty(getappdata(axes_1, 'point_h1'))
                set(point_h1, 'XData', [], 'YData', []);
                rmappdata(axes_1, 'point_h1');
            end
            if ~isempty(getappdata(axes_2, 'point_h2'))
                set(point_h2, 'XData', [], 'YData', []);
                rmappdata(axes_2, 'point_h2');
            end
        end
        
    end


%%  fun mouseover_thickness
    function mouseover_thickness()
        
        % Need to make sure that root unit is pixels
        set(0, 'Units', 'Pixels');
        
        % Handles to the four axes
        axes_1      = findobj(fgt_gui_handle, 'tag', 'axes_1');
        axes_2      = findobj(fgt_gui_handle, 'tag', 'axes_2');
        axes_3      = findobj(fgt_gui_handle, 'tag', 'axes_3');
        axes_4      = findobj(fgt_gui_handle, 'tag', 'axes_4');
        
        % Get pointer location w.r.t. Thickness plot (axes_2 and axes_4)
        Screen_xy 	= get(0,'PointerLocation');
        Figure_xy  	= getpixelposition(fgt_gui_handle);
        
        Axes_xy2   	= getpixelposition(axes_2, true);
        Axes_xy4   	= getpixelposition(axes_4, true);
        
        Xlim2       = get(axes_2, 'XLim');
        Ylim2       = get(axes_2, 'YLim');
        Xlim4       = get(axes_4, 'XLim');
        Ylim4       = get(axes_4, 'YLim');
        
        axes_x2     = Screen_xy(1) - Axes_xy2(1) - Figure_xy(1);
        axes_x2     = axes_x2/Axes_xy2(3)*(Xlim2(2)-Xlim2(1)) + Xlim2(1);
        axes_y2     = Screen_xy(2) - Axes_xy2(2) - Figure_xy(2);
        axes_y2     = axes_y2/Axes_xy2(4)*(Ylim2(2)-Ylim2(1)) + Ylim2(1);
        
        axes_x4     = Screen_xy(1) - Axes_xy4(1) - Figure_xy(1);
        axes_x4     = axes_x4/Axes_xy4(3)*(Xlim4(2)-Xlim4(1)) + Xlim4(1);
        axes_y4     = Screen_xy(2) - Axes_xy4(2) - Figure_xy(2);
        axes_y4     = axes_y4/Axes_xy4(4)*(Ylim4(2)-Ylim4(1)) + Ylim4(1);
        
        % Plot - only if pointer inside axes_2
        if Xlim2(1)<axes_x2 && axes_x2<Xlim2(2) && Ylim2(1)<axes_y2 && axes_y2<Ylim2(2)
          
            % Get fold data
            Fold  	= getappdata(fgt_gui_handle, 'Fold');
            fold  	= getappdata(fgt_gui_handle, 'fold_number');
            
            % Point on interface that is closest to pointer x (arclength) position
            [~, indx]   = min(abs( axes_x2 - (1:length(Fold(fold).Thickness.Local(1).Value)) ));
            
            % Try to get handels 
            fill_h2 = getappdata(axes_1, 'fill_h2');
            bar_h2  = getappdata(axes_2, 'bar_h2');
            
            % Fill bar and fold - move if already exist
            if isempty(bar_h2)
                
                % Plot marked bar
                bar_h2 = bar(indx,Fold(fold).Thickness.Local(1).Value(indx),'Parent', axes_2,'FaceColor',popts.thick_color_active,'EdgeColor','k','BarWidth',0.5);
                
                %Fill the marked fold
                P        = Fold(fold).Thickness.Local(1).Polygon{indx};
                fill_h2  = fill(P(1,:),P(2,:),popts.thick_color_active,'Parent', axes_1);
                
                % Store handles
                setappdata(axes_1, 'fill_h2', fill_h2);  
                setappdata(axes_2, 'bar_h2' , bar_h2);   
                
            else
                % Move the highlighted bar
                set(bar_h2, 'XData', indx, 'YData', Fold(fold).Thickness.Local(1).Value(indx));
                
                 %Move the highlighted fold
                P = Fold(fold).Thickness.Local(1).Polygon{indx};
                set(fill_h2, 'XData', P(1,:), 'YData', P(2,:));
            end     
        else
            % Try to get handels
            fill_h2 = getappdata(axes_1, 'fill_h2');
            bar_h2  = getappdata(axes_2, 'bar_h2');
            
            % Remove marker points if pointer is outside the axes
            if ~isempty(fill_h2)
                set(fill_h2, 'XData', [], 'YData', []);
                rmappdata(axes_1, 'fill_h2');
            end
            if ~isempty(getappdata(axes_2, 'bar_h2'))
                set(bar_h2, 'XData', [], 'YData', []);
                rmappdata(axes_2, 'bar_h2');
            end
        end
        
        % Plot - only if pointer inside axes_4
        if Xlim4(1)<axes_x4 && axes_x4<Xlim4(2) && Ylim4(1)<axes_y4 && axes_y4<Ylim4(2)
          
            % Get fold data
            Fold  	= getappdata(fgt_gui_handle, 'Fold');
            fold  	= getappdata(fgt_gui_handle, 'fold_number');
            
            % Point on interface that is closest to pointer x (arclength) position
            [~, indx]   = min(abs( axes_x4 - (1:length(Fold(fold).Thickness.Local(2).Value)) ));
            
            % Try to get handels to the marker points
            fill_h4 = getappdata(axes_3, 'fill_h4');
            bar_h4  = getappdata(axes_4, 'bar_h4');
            
            % Plot marker points - move if already exist
            if isempty(bar_h4)
                
                % Plot marked bar
                bar_h4 = bar(indx, Fold(fold).Thickness.Local(2).Value(indx), 'Parent', axes_4, 'FaceColor',popts.thick_color_active, 'EdgeColor','k', 'BarWidth',0.5);
                
                %Fill the marked fold
                P        = Fold(fold).Thickness.Local(2).Polygon{indx};
                fill_h4  = fill(P(1,:),P(2,:),popts.thick_color_active,'Parent', axes_3);
                
                % Store handles
                setappdata(axes_3, 'fill_h4', fill_h4);  
                setappdata(axes_4, 'bar_h4' , bar_h4);   
                
            else
                % Move the highlighted bar
                set(bar_h4, 'XData', indx, 'YData', Fold(fold).Thickness.Local(2).Value(indx));
                
                 %Move the highlighted fold
                P = Fold(fold).Thickness.Local(2).Polygon{indx};
                set(fill_h4, 'XData', P(1,:), 'YData', P(2,:));
            end  
        else
            % Try to get handels
            fill_h4 = getappdata(axes_3, 'fill_h4');
            bar_h4  = getappdata(axes_4, 'bar_h4');
            
            % Remove marker points if pointer is outside the axes
            if ~isempty(fill_h4)
                set(fill_h4, 'XData', [], 'YData', []);
                rmappdata(axes_3, 'fill_h4');
            end
            if ~isempty(getappdata(axes_4, 'bar_h4'))
                set(bar_h4, 'XData', [], 'YData', []);
                rmappdata(axes_4, 'bar_h4');
            end
        end
    end

    function add_point(obj, event_obj)
        %% f_add_point
        
        key = get(fgt_gui_handle, 'CurrentCharacter');
        
        % Find axis
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
        
        if strcmp(key,'h')
            
            % Call the pushbutton callback
            set(achse, 'ButtonDownFcn',  @(a,b) add_hinge);
            
        elseif strcmp(key,'i')
            
            % Call the pushbutton callback
            set(achse, 'ButtonDownFcn',  @(a,b) add_inflection);
            
        end
        
        
        function add_hinge(obj, event_obj)
            % - f_add_hinge
            
            % Get fold data
            Fold  	= getappdata(fgt_gui_handle, 'Fold');
            fold  	= getappdata(fgt_gui_handle, 'fold_number');
            face  	= getappdata(fgt_gui_handle, 'face_number');
            
            % Get coordinates of the current point
            CURRENT_POINT = get(achse,'CurrentPoint');
            
            % Current coordinates of the active fold interface
            xx = Fold(fold).Face(face).X.Full;
            yy = Fold(fold).Face(face).Y.Full;
            
            % Get current point data
            P = get(gca, 'CurrentPoint');
            
            % Find the closest point between the current point and the interface
            dist = sqrt( (xx-P(1,1)).^2 + (yy-P(1,2)).^2);
            [min_dist,idx] = min(dist);
            % In case there is more then one point with the same distance take the first one
            idx =idx(1);
            
            % Check if the point is already hinge or inflection point
            indexes = [Fold(fold).Face(face).Hinge.Index Fold(fold).Face(face).Inflection];
            if isempty(find(indexes==idx, 1))
                flag = 1;
            else
                flag = 0;
            end
            
            % Consider adding point only if the distance is close enough
            if min_dist < 0.05 && flag == 1
                disp('Add a hinge point')
                
                % Add hinge point
                Fold(fold).Face(face).Hinge.Index = sort([Fold(fold).Face(face).Hinge.Index idx]);
                
                % Update Fold data
                setappdata(fgt_gui_handle, 'Fold' , Fold);
                
                % Note that thickness needs to be recalculated
                setappdata(fgt_gui_handle, 'Thickness_calculation', 1);
                
                % Update gui
                fgt('step_22_update_gui');
                
            end
            
        end
        
        function add_inflection(obj, event_obj)
            % - f_add_inflection
            
            % Get fold data
            Fold  	= getappdata(fgt_gui_handle, 'Fold');
            fold  	= getappdata(fgt_gui_handle, 'fold_number');
            face  	= getappdata(fgt_gui_handle, 'face_number');
            
            % Get coordinates of the current point
            CURRENT_POINT = get(achse,'CurrentPoint');
            
            % Current coordinates of the active fold interface
            xx = Fold(fold).Face(face).X.Full;
            yy = Fold(fold).Face(face).Y.Full;
            
            % Get current point data
            P = get(gca, 'CurrentPoint');
            
            % Find the closest point between the current point and the interface
            dist = sqrt( (xx-P(1,1)).^2 + (yy-P(1,2)).^2);
            [min_dist,idx] = min(dist);
            % In case there is more then one point with the same distance take the first one
            idx =idx(1);
            
            % Check if the point is already hinge or inflection point
            indexes = [Fold(fold).Face(face).Hinge.Index Fold(fold).Face(face).Inflection];
            if isempty(find(indexes==idx, 1))
                flag = 1;
            else
                flag = 0;
            end
            
            % Consider adding point only if the distance is close enough
            if min_dist < 0.05 && flag == 1
                disp('Add an inflection point')
                
                % Add inflection point
                Fold(fold).Face(face).Inflection = sort([Fold(fold).Face(face).Inflection idx]);
                
                % Update Fold data
                setappdata(fgt_gui_handle, 'Fold' , Fold);
                
                % Note that thickness needs to be recalculated
                setappdata(fgt_gui_handle, 'Thickness_calculation', 1);
                
                % Update gui
                fgt('step_22_update_gui');
                
            end
            
        end
        
    end

    function deactivate_action(obj, event_obj)
        %% f_deactivate_action
        disp('Stop')
        
        achse  = findobj(fgt_gui_handle, 'tag', 'axes_1');
        
        % Deactivate pushbutton callback
        set(achse, 'ButtonDownFcn',  []);
        set(achse, 'ButtonDownFcn',  @(a,b) mark_point);
        
    end

    function mark_point(obj, event_obj)
        %% f_mark_point
        
        % Get data
        achse   	= findobj(fgt_gui_handle, 'tag', 'axes_1');
        
        % Get info about previous call and demark the point if needed
        ph     	    = getappdata(achse, 'ph');
        try
            set(ph,'MarkerSize',4,'MarkerFaceColor','none','parent',achse);
        catch
        end
        
        % Who is calling
        wcbo        = gcbo;
        
        try
            % Mark selected point on Fold plot
            set(wcbo,'MarkerSize',6,'MarkerFaceColor',get(wcbo,'Color'));
            
            % Store info about the selected point
            setappdata(achse, 'ph', wcbo);
            
            % Get info about current interface
            fl = getappdata(fgt_gui_handle, 'fold_line');
            
            % Attach uicontext menu
            uic = uicontextmenu;
            uimenu(uic, 'Label','Move point',  'callback',@(a,b) move_object(wcbo,fl));
            uimenu(uic, 'Label','Remove point','callback',@(a,b) remove_point);
            set(wcbo,'uicontextmenu',uic)
        catch
        end
        
        function move_object(hp,hl)
            %% f_move_point
            
            % Interface coordinates
            xx = get(hl,'XData');
            yy = get(hl,'YData');
            
            % Current point index
            point_id    = str2double(get(hp,'tag'));
            
            % Store info about the new point index
            setappdata(achse,'new_index',point_id);
            
            set(gcf, 'WindowButtonMotionFcn', @(a,b) start_moving);
            set(gca, 'ButtonDownFcn',   @(a,b) stop_moving);
            
            
            function start_moving(obj, event_obj)
                
                % Get fold data
                Fold  	= getappdata(fgt_gui_handle, 'Fold');
                fold  	= getappdata(fgt_gui_handle, 'fold_number');
                face  	= getappdata(fgt_gui_handle, 'face_number');
                
                % Current point position
                P = get(gca, 'CurrentPoint');
                
                % Find the closest point between the current point and the interface
                dist = sqrt( (xx-P(1,1)).^2 + (yy-P(1,2)).^2);
                [min_dist,idx] = min(dist);
                
                % In case there is more then one point with the same distance take the first one
                idx =idx(1);
                
                % Check if the point is already hinge or inflection point
                indexes = [Fold(fold).Face(face).Hinge.Index Fold(fold).Face(face).Inflection];
                if isempty(find(indexes==idx, 1))
                    flag = 1;
                else
                    flag = 0;
                end
                
                if min_dist < 0.05 && flag == 1
                    disp('Move point')
                    
                    % Switch off hittest of the point for the time moving
                    set(hp,'Hittest','off')
                    
                    % Update point position
                    set(hp,'XData',xx(idx));
                    set(hp,'YData',yy(idx));
                    
                    % Store info about the new point index
                    setappdata(achse,'new_index',idx);
                    
                end
            end
            
            function stop_moving(obj, event_obj)
                disp('Stop')
                
                set(gcf, 'WindowButtonMotionFcn', []);
                set(gca, 'ButtonDownFcn',         @(a,b) mark_point);
                
                % Switch on hittest
                set(hp,'Hittest','on')
                
                % Get new point index
                idx = getappdata(achse,'new_index');
                
                % Update index
                if ~isempty(find(Fold(fold).Face(face).Hinge.Index==point_id,1))
                    % Substitute hinge point idx
                    Fold(fold).Face(face).Hinge.Index(Fold(fold).Face(face).Hinge.Index==point_id) = [];
                    Fold(fold).Face(face).Hinge.Index = sort([Fold(fold).Face(face).Hinge.Index idx]);
                else
                    % Substitute inflection point idx
                    Fold(fold).Face(face).Inflection(Fold(fold).Face(face).Inflection==point_id) = [];
                    Fold(fold).Face(face).Inflection = sort([Fold(fold).Face(face).Inflection idx]);
                end
                
                % Update Fold data
                setappdata(fgt_gui_handle, 'Fold' , Fold);
                
                % Note that thickness needs to be recalculated
                setappdata(fgt_gui_handle, 'Thickness_calculation', 1);
                
                % Update gui
                fgt('step_22_update_gui');
            end
        end
        
        function remove_point(obj, event_obj)
            %% f_remove_point
            
            % Get fold data
            Fold  	= getappdata(fgt_gui_handle, 'Fold');
            fold  	= getappdata(fgt_gui_handle, 'fold_number');
            face  	= getappdata(fgt_gui_handle, 'face_number');
            
            % Get coordinates of the current point
            P = [get(wcbo,'XData') get(wcbo,'YData')];
            
            % Current coordinates of the hinges and inflection points on the active fold interface
            indexes = [Fold(fold).Face(face).Hinge.Index, Fold(fold).Face(face).Inflection];
            xx = Fold(fold).Face(face).X.Full(indexes);
            yy = Fold(fold).Face(face).Y.Full(indexes);
            
            % Find the closest point between the current point and the interface
            dist = sqrt( (xx-P(1,1)).^2 + (yy-P(1,2)).^2);
            [min_dist,idx] = min(dist);
            % In case there is more then one point with the same distance take the first one
            idx =idx(1);
            
            % Consider adding point only if the distance is close enough
            if min_dist < 0.05
                disp('Remove point')
                
                % Check if the point it is a hinge point
                temp = find(Fold(fold).Face(face).Hinge.Index==indexes(idx), 1);
                if ~isempty(temp)
                    Fold(fold).Face(face).Hinge.Index(idx) = [];
                end
                
                % Check if the point it is an inflection point
                temp = find(Fold(fold).Face(face).Inflection==indexes(idx),1);
                if ~isempty(temp)
                    Fold(fold).Face(face).Inflection(temp) = [];
                end
                
                % Update Fold data
                setappdata(fgt_gui_handle, 'Fold' , Fold);
                
                % Note that thickness needs to be recalculated
                setappdata(fgt_gui_handle, 'Thickness_calculation', 1);
                
                % Update gui
                fgt('step_22_update_gui');
                
            end
        end
    end
end