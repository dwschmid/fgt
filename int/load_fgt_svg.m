function Fold = load_fgt_svg(xmlfile)
% FGT - Fold Geometry Toolbox
%
% Original author:    Krotkiewski
% Last committed:     $Revision: 135 $
% Last changed by:    $Author: martaada $
% Last changed date:  $Date: 2011-06-01 14:15:19 +0200 (Wed, 01 Jun 2011) $
%--------------------------------------------------------------------------
%
% Converts *.svg files to *.mat data.
%
% input  - *.svg file generated in Adobe Illustrator (xmlfile)
% output - fold data stored in a matlab stucture - Fold


% Open the file
fd      = fopen(xmlfile, 'r');
if fd == -1
    error(['could not open file ' xmlfile]);
    return;
end

% Read data
fseek(fd, 0, 1);
fs   = ftell(fd);
fseek(fd, 0, -1);
data = fread(fd, fs, 'uint8=>char')';

% Choose model
[start_layer_idx, end_layer_idx] = regexp(data, 'Adobe Illustrator');
if ~isempty(start_layer_idx)
    model = 1;
end
    
[start_layer_idx, end_layer_idx] = regexp(data, 'inkscape');
if ~isempty(start_layer_idx)
    model = 2;
end

switch model
    
    case 1
        % Adobe Illustrator
        
        % Identify number of layers and find starting and ending indexes
        [start_layer_idx, end_layer_idx] = regexp(data, '<(\g id=").*?>.*?</\g>');
        if isempty(start_layer_idx)
            nlayers = 1;
        else
            nlayers = size(start_layer_idx,2);
        end
        
        % Count number of folds
        count = 0;
        
        for j = 1:nlayers
            
            % Extract data for each layer
            if isempty(start_layer_idx)
                data_layer = data;
            else
                data_layer = data(start_layer_idx(j):end_layer_idx(j));
            end
            
            % Extract data for the lines
            [start_idx, end_idx] = regexp(data_layer, '<polyline fill=[^>]+/>');
            
            if isempty(start_idx)
                continue;
            end
            
            % Change form string to a vector
            paths = {};
            for p = 1:length(start_idx)
                pdata    = data_layer(start_idx(p):end_idx(p));
                [tokens] = regexp(pdata, 'points=\"([^\"]+)\"', 'tokens');
                
                if isempty(tokens)
                    error('No data found in path');
                    return;
                end
                
                pdata = [tokens{1}{1}];
                [tokens] = regexp(pdata, '([^ ]+)', 'tokens');
                paths{p} = [];
                
                for i=1:length(tokens)
                    paths{p} = [paths{p}; str2num(tokens{i}{1})];
                end
                
            end
            
            % Assign the data to faces in the fold
            count      = count + 1;
            fold_up    = paths{1};
            fold_dn    = paths{2};
            
            % Define a horizontal axis to reflect fold data
            if count == 1
                Y1_max = max(fold_up(:,2:2:end));
            end
            
            Fold(count).Face(1).X.Ori = fold_up(:,1:2:end)';
            Fold(count).Face(1).Y.Ori = Y1_max-fold_up(:,2:2:end)';
            Fold(count).Face(2).X.Ori = fold_dn(:,1:2:end)';
            Fold(count).Face(2).Y.Ori = Y1_max-fold_dn(:,2:2:end)';
            
        end
        
    case 2
        % Inkscape
        
        % Find number of folds
        nfold = 0;
        
        [start_layer_idx, end_layer_idx] = regexp(data, '<(\g).*?>.*?</\g>');
        
        for j = 1:length(start_layer_idx)
            % Loop over number of layers
            
            % Extract data for each layer
            if length(start_layer_idx) == 1
                data_layer = data;
            else
                data_layer = data(start_layer_idx(j):end_layer_idx(j));
            end
            
            [start_idx, end_idx] = regexp(data_layer, '<path[^>]+/>');
            
            
            if length(start_idx)~=2
                error('The file does not consist of 2 lines');
                return;
            end
            
            paths = {};
            for p=1:length(start_idx)
                pdata = data_layer(start_idx(p):end_idx(p));
                [tokens] = regexp(pdata, 'd="m ([^\"]+)\"', 'tokens');
                if isempty(tokens)
                    error('No data found in path');
                    return;
                end
                pdata = [tokens{1}{1} ' '];
                [tokens] = regexp(pdata, '([^ ]+)', 'tokens');
                
                paths{p} = [];
                
                for i=1:length(tokens)
                    paths{p} = [paths{p}; str2num(tokens{i}{1})];
                end
                
            end
            
            nfold = nfold +1;
            fold_up = paths{1};
            Fold(nfold).Face(1).X.Ori = cumsum(fold_up(:,1:2:end)');
            Fold(nfold).Face(1).Y.Ori = cumsum(-fold_up(:,2:2:end)');
            fold_dn = paths{2};
            Fold(nfold).Face(2).X.Ori = cumsum(fold_dn(:,1:2:end)');
            Fold(nfold).Face(2).Y.Ori = cumsum(-fold_dn(:,2:2:end)');
            
            % Define the shift as the first point on the first interface
            if j == 1
                xs = Fold(1).Face(1).X.Ori(1);
                ys = Fold(1).Face(1).Y.Ori(1);
            end
            
            % Shift data
            Fold(nfold).Face(1).X.Ori = Fold(nfold).Face(1).X.Ori-xs;
            Fold(nfold).Face(1).Y.Ori = Fold(nfold).Face(1).Y.Ori-ys;
            fold_dn = paths{2};
            Fold(nfold).Face(2).X.Ori = Fold(nfold).Face(2).X.Ori-xs;
            Fold(nfold).Face(2).Y.Ori = Fold(nfold).Face(2).Y.Ori-ys;
            
        end

end
end

