%% Script for creating 3D plots of oxygen sinks and surges

% All subsequent scripts from Antonis Asiminas, PhD
% Center for Translational Neuromedicine
% University of Copenhagen, August 2023

%%
close all;
clear;

%% Choose the data and colour
uiwait(msgbox("Select a tif file with the masks for sinks or surges", 'Select tiff file'));
[filename, filepath] = uigetfile('*.*', 'Select a File');

c = uisetcolor([0 0.4470 0.7410]);

answer1 = questdlg('Do you want to save a vector? (takes long time)',...
    'Vector graphics?',...
    'Yes', 'No','No');


%% Load the data

DIR = fullfile(filepath,'\', filename);
[RecordingBW,~,~]=loadtiff(DIR);

% Dimensions of the matrix
[M, N, P] = size(RecordingBW);
%%
Epoch = questdlg('Do you want a different colour for a portion of the recording',...
    'What data',...
    'Yes', 'No','No');


switch Epoch
    case 'Yes'

        c2 = uisetcolor([1 0.4470 0.7410]);

        % Ask for user input for start and end along the z-axis
        prompt = 'Enter the start and end of the period with different colour in seconds (e.g. 6301,600).';
        dlgTitle = 'Epoch start-end';
        numLines = 2;
        defaultInput = {'301,600'};  % Default values in the input fields

        userInput = inputdlg(prompt, dlgTitle, numLines, defaultInput);

        % Check if the user clicked Cancel or entered an empty value
        if isempty(userInput)
            disp('Operation canceled or no value entered.');
        else
            % Convert the user input to numerical values
            Epochs_Limits = str2double(strsplit(userInput{1}, ','));
    
            % Check if the input is valid
            if ~any(isnan(Epochs_Limits))
                disp('You entered the following numerical values:');
                disp(Epochs_Limits);

                % Convert user input to numerical values
                startZ=Epochs_Limits(1:2:end);
                endZ=Epochs_Limits(2:2:end);

                if startZ>endZ
                    error('Invalid input. Start index should be < than end index.');
                elseif startZ<1
                    error('Invalid input. Start index should be > 1.');
                elseif endZ>size(RecordingBW,3)
                    error('Invalid input. End index should be < than length of recording.');
                end

            else
               
                error('Invalid input. Please enter numerical values.');
            end
  
        end

        
        
end



%% Generating and plotting 

newMatrix = single(zeros(M, N, 2*P - 1));
% Fill the new matrix with the original matrix and duplicates
for i = 1:P
    newMatrix(:, :, 2*i - 1) = RecordingBW(:, :, i); % Odd-indexed pages
    if i < P
        newMatrix(:, :, 2*i) = RecordingBW(:, :, i); % Even-indexed pages (except the last one)
    end
end
%%
% Define coordinates for the vertices of the cubes

[X, Y, Z] = meshgrid(1:N, 1:M, 1:0.5:P);
fig = figure('Visible', 'off');
% Define the aspect ratio. We can adapt this to what we want
aspect_ratio = [1 1 1];
% Set the aspect ratio of the axes
daspect(aspect_ratio);
s=isosurface(X, Y, Z, newMatrix,0.1);
p = patch(s);
isonormals(X, Y, Z, newMatrix,p)
% By typing this on comand line while looking at the figure
% [caz,cel] = view
% Get the azimuth (caz) and elevation (cel) angles for this plot.
view(3); % This can be updated to view(caz cel) to get a consistent point of view for the vector graphics

switch Epoch
    case 'No'
        
        set(p,'FaceColor',c);  
        set(p,'EdgeColor','none');
        camlight;
        lighting gouraud;
        zlabel('Time (s)');

    case 'Yes'
        %This code sets a different color for the specified section of the isosurface plot along the z-axis while leaving the rest of the isosurface with the default color.
        % Set the default color for the entire isosurface
        set(p, 'FaceColor', 'flat');
        set(p, 'EdgeColor', 'none');
        camlight;
        lighting gouraud;
        zlabel('Time (s)');

        % Get the isosurface vertices
        vertices = p.Vertices;

        % Get the faces of the isosurface
        faces = p.Faces;

        % Compute the z-values of the vertices
        zValues = vertices(:, 3);

        % Find the vertices within the specified z-range
        indices = find(zValues >= startZ & zValues <= endZ);

        % Create a color matrix for the vertices based on their Z-values
        vertexColors = repmat(c, size(vertices, 1), 1);

        % Set the different color for the specified section
        vertexColors(indices, :) = repmat(c2, length(indices), 1);

        % Update the 'FaceVertexCData' property to apply the specified colors
        p.FaceVertexCData = vertexColors;

        % Set the 'FaceColor' property to 'interp' to use FaceVertexCData
        set(p, 'FaceColor', 'interp');

end





%%
exportgraphics(fig,[filename(1:end-4),'.png'],'Resolution',1200)
save([filename(1:end-4),'.mat'], 'fig');
% You can load the interactive figure and replot it by typing this on the
% command window 
% loadedData = load('3D_sinks_interactive.mat');
% loadedFig = loadedData.fig;
% figure(loadedFig);


switch answer1

    case 'Yes'

        exportgraphics(fig,[filename(1:end-4),'.pdf'],'ContentType','vector')
end


%%clearvars -except RecordingBW
%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%%%%%%%

%% Function to load tiff files

