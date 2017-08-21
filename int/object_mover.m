function object_mover(Action)

% Original author:    2014-09-15, Dani Schmid, Builds up on patch mover from 2. October, 2000, Dani Schmid
% Last committed:     $Revision: 116 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2010-06-24 22:55:57 +0200 (Thu, 24 Jun 2010)$
%--------------------------------------------------------------------------

switch(Action)
    case 'start'
        %% START
        % Store the moving object
        moving_object    = gco;
        setappdata(0, 'moving_object', moving_object);
        
        % Store the start point
        %setappdata(0, 'Startpoint', get(gca,'CurrentPoint'));
        
        % Problem: The y-limits rescale permanently. So even if we did not
        % move the pointer very much we are in a totally different
        % position. 
        % Solution: Store the location as a fraction of the height. This
        % can be restored when the movement is analysed and will give the
        % true shift
        Currentpoint    = get(gca,'CurrentPoint');
        Ylim            = get(gca, 'YLim');
        frac            = (Currentpoint(1,2)-Ylim(1))/(Ylim(2)-Ylim(1));
        
        setappdata(moving_object, 'frac', frac);
        
        % Change display
        %set(gco, 'selected', 'on');
        
        % Set the button down functions properly
        set(gcbf,'WindowButtonMotionFcn','object_mover_gravity move')
        set(gcbf,'WindowButtonUpFcn','object_mover_gravity stop')
        
    case 'move'
        %% MOVE
        %% - Move Selected Object
        % Find object again
        moving_object   = getappdata(0, 'moving_object');
        
        %Extract the data
        YData           = get(moving_object, 'Ydata');
        
        % Previous position
        frac            = getappdata(moving_object, 'frac');
        Ylim            = get(gca, 'YLim');
        y_old           = Ylim(1) + frac*(Ylim(2)-Ylim(1));
        
        % Current point on the gca
        Currentpoint = get(gca,'CurrentPoint');
        
        % Incremental distance
        uy   = Currentpoint(1,2) - y_old;

        % Move 
        set(moving_object, 'Ydata', YData + uy);
        
        % Figure out how much shift_ui is
        % Note: original average was set to 0
        y_av_old    = getappdata(moving_object, 'y_av');
        shift_ui    = mean(YData)-y_av_old;
        
        % Update GUI entry
        tecmod_gui_gravity_fig = findobj(0,'tag','tecmod_gui_gravity_fig', '-depth', 1);
        set(findobj(tecmod_gui_gravity_fig, 'tag', 'shift_ui'), 'string', sprintf('%0.2f', shift_ui));
        
        % Update object
        setappdata(moving_object, 'shift_ui',  shift_ui);
        
        % Store location
        frac            = (Currentpoint(1,2)-Ylim(1))/(Ylim(2)-Ylim(1));
        setappdata(moving_object, 'frac', frac);
                
        %% - Move Sibling
        % Find which one was not moved yet
        P_handles   = findobj(tecmod_gui_gravity_fig, 'tag', 'gravity_tecmod');
        sibling     = setdiff(P_handles, moving_object);
        
        YData           = get(sibling, 'Ydata');
        
        set(sibling, 'Ydata', YData + uy);
        
         % Update object
        setappdata(sibling, 'shift_ui',  shift_ui);
        
    case 'stop'
        %% STOP
        %Set everything back to normal
        set(gcbf,'WindowButtonMotionFcn','')
        set(gcbf,'WindowButtonUpFcn','')
        
        % Find object again
        moving_object    = getappdata(0, 'moving_object');
        set(moving_object, 'selected','off')
        
        % Remove data from root appdata
        rmappdata(0, 'moving_object');
end