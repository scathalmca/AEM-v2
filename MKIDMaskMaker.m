function [] = MKIDMaskMaker(directory)
%  MKIDMASKMAKER Function that takes all .son files from a directory, renames the files to
% contain the kinetic inductance in the filename (e.g. 5pH_5500MHz.son)
%
% and places a single polygon over the cavity in the GND plane in which the
% MKID sits in.
%
% This makes it easier to determine how far the MKID sits from the feedline
% when design a prototype mask with a CAD software.
MaskFiles_dir = append(directory, '\All Mask Files');
% If the folder 'AllMaskFiles' doesn't exist, create a new folder.
% This folder will contain all the finished files
if ~exist(MaskFiles_dir)
    mkdir(MaskFiles_dir);
end

current_dir = pwd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section of the script was produced with ChatGPT
% Function to find all file names in folders called "FinishedMKIDs"
% Input: directory - The root directory to start the search
% Output: fileNames - A cell array containing the names of all files found
% Get a list of all folders and subfolders within the directory
% Progress bar
f = waitbar(0, "Cooking MKIDs...");


% Get a list of all folders named 'FinishedMKIDs' in the directory and its subdirectories
folderList = dir(fullfile(directory, '**', 'FinishedMKIDs'));

% Initialize an empty cell array to hold the file paths
fileList = {};

% Loop through each 'FinishedMKIDs' folder
for i = 1:length(folderList)
    if folderList(i).isdir
        % Get the path of the current 'FinishedMKIDs' folder
        folderPath = fullfile(folderList(i).folder, folderList(i).name);

        % Get a list of all .son files in the current 'FinishedMKIDs' folder
        sonFiles = dir(fullfile(folderPath, '*.son'));

        % Loop through each .son file and add its full path to the fileList array
        for j = 1:length(sonFiles)
            filePath = fullfile(sonFiles(j).folder, sonFiles(j).name);
            fileList{end+1} = filePath; %#ok<AGROW>
        end
    end
end

% If no .son files are found, display a message
if isempty(fileList)
    disp('No .son files found in any FinishedMKIDs folders.');
else
    % Display the list of found files
    disp('List of .son files found:');
    disp(fileList');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%


for i = 1:numel(fileList)

    % Script progress bar
    waitbar(i/numel(fileList),f, sprintf(append("Cooking MKIDs... ", num2str(i), "/", num2str(numel(fileList)))));

    % Force the waitbar to update
    drawnow;

    % Extract the filepath, filename and extension of each file in
    % 'FinishedMKIDs'
    [filePath, fileName, fileExt] = fileparts(fileList(i));
    
    % Change the file names of all the .son files from cell to string
    Sonnet_File = append(fileName, fileExt);

    % Change path to make sure we are editting the correct Sonnet file
    cd(filePath{1});

    % Initialise each .son file one at a time
    Project = SonnetProject(Sonnet_File{1});
    % Extract the kinetic inductance value of each project file (used for
    % renaming files)
    Lk_Value = append(num2str(Project.GeometryBlock.ArrayOfMetalTypes{1}.KineticInductance),"pH ");
    % Folder name for each kinetic inductance group
    Feedline_FolderName = append(Lk_Value,"Files");
    % Path
    Feedline_pathName = append(MaskFiles_dir, filesep, Feedline_FolderName);
    % If the path doesn't already exist, create a new folder 
    if ~exist(Feedline_pathName)
       mkdir(Feedline_pathName)
    end
    % Determine the coordinates for the cavity in the ground plane
    [X1Coord,Y1Coord,X2Coord,Y2Coord] = Determine_MKID_Box(Project);
    % X coordinate of the polygon being placed.
    X_Array = [X1Coord  X2Coord  X2Coord  X1Coord];
    % Y coordinate of the polygon being placed.
    Y_Array = [Y1Coord  Y1Coord  Y2Coord  Y2Coord];
    % Place polygon in the GND plane
    Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    % New filename containing the kinetic inductance value
    New_Filename = append(Lk_Value, Sonnet_File{1});
    % Replace spaces with underscores
    New_Filename= strrep(New_Filename, ' ', '_');
    % Replace full stops with underscores
    New_Filename = strrep(New_Filename, '.', '_');
    % Return the extension
    New_Filename = strrep(New_Filename, '_son', '.son');
    % Save the new file
    Project.saveAs(New_Filename);
    % Move the file to the correct folder
    movefile(New_Filename, Feedline_pathName);
    
    
end

% return to the original path set by the user
cd(current_dir)
% Close the progress bar
close(f);
disp("MKIDs are finished cooking!");


end