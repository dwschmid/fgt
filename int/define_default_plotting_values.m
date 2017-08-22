%  Set the plotting options

% Fold
popts.fold_color_active             = [0.7843 0.8275 0.8902];
popts.fold_color_inactive           = [0.9294 0.9412 0.9725];

% Interface
popts.face_color_active             = 0.3*[1 1 1];
popts.face_thick_active             = 2;
popts.face_color_inactive        	= 0.6*[1 1 1];
popts.face_thick_inactive          	= 1;

% Hinge point
popts.hinge_color_active            = [0.3059 0.3961 0.5804];
popts.hinge_size_active             = 4;
popts.hinge_color_inactive       	= [0.7294 0.8314 0.9569];
popts.hinge_size_inactive          	= 3;

% Inflection point
popts.inflection_color_active     	= [1 0.4000 0];
popts.inflection_size_active     	= 4;
popts.inflection_color_inactive  	= [1 0.8000 0.4000];
popts.inflection_size_inactive   	= 3;

% Curvature
popts.curve_color_ori               = [0.8078 0.8235 0.8235];
popts.curve_thick_ori               = 1.3;
popts.curve_color_smoothed          = [0.5137 0.3804 0.4824];
popts.curve_thick_smoothed          = 2;
popts.curve_color_poly              = [0.9255 0.6235 0.1922];
popts.curve_thick_poly              = 2;

% NIP-FW diagram
popts.NIPFW_color_marker_active     = [0.2039 0.3020 0.4941];
popts.NIPFW_size_marker_active      = 6;
popts.NIPFW_color_marker_inactive  	= [0.7294 0.8314 0.9569];
popts.NIPFW_size_marker_inactive  	= 5;
popts.NIPFW_color_line_active       = [0.2039 0.3020 0.4941];
popts.NIPFW_thick_line_active       = 6;
popts.NIPFW_color_line_inactive     = [0.7294 0.8314 0.9569];
popts.NIPFW_thick_line_inactive     = 5;

% Amplitude
popts.ampl_color_active             = [0.3059 0.3961 0.5804];
popts.ampl_thick_active             = 3;
popts.ampl_color_inactive           = [0.7294 0.8314 0.9569];
popts.ampl_thick_inactive           = 2;

% Wavelength
popts.wave_color_active             = [0.8000 0 0.2000];
popts.wave_thick_active             = 3;
popts.wave_color_inactive           = [1 0.4000 0.4000];
popts.wave_thick_inactive           = 2;

% Thickness
popts.thick_color_active            = [0.8471 0.1608 0];
popts.thick_color_inactive1         = [0.5294 0.6118 0.6588];
popts.thick_color_inactive2         = [0.8980 0.7412 0.5412];

% Fletcher and Scherwin diagram
popts.FS_stretch_color              = [0.7647 0.5608 0.3216];
popts.FS_stretch_thick              = 1;
popts.FS_vis_color                  = [0.2824 0.2745 0.2863];
popts.FS_vis_thick                  = 1;
popts.FS_data_color               	= [0.4039 0.3882 0.5059];
popts.FS_data_size                  = 10;
popts.FS_xmin                       = 2;
popts.FS_xmax                       = 17;
popts.FS_ymin                       = 0.5;
popts.FS_ymax                       = 3;

% Schmalholz and Podladchikov diagram
popts.SP_short_color                = [0.7647 0.5608 0.3216];
popts.SP_short_thick                = 1;
popts.SP_vis_color                  = [0.2824 0.2745 0.2863];
popts.SP_vis_thick                  = 1;
popts.SP_data1_color                = [0.4039 0.3882 0.5059];
popts.SP_data1_size                 = 10;
popts.SP_data2_color                = [0.7765 0.7843 0.8549];
popts.SP_data2_size                 = 6;
popts.SP_xmax                       = 0.7;
popts.SP_ymax                       = 0.9;

% Save data
save(['int',filesep,'popts.mat'],'popts')