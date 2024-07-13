function [max_Resonance,min_Resonance, FirstLogProject, Time_Limit] = min_Structure(Project, F_Spacing, F_Thickness, Bar_Thickness, Mesh_Level)
%  MIN_STRUCTURE Constructs the minimum structure for a LEKID (i.e. a lumped inductor and capacitor).
% 
% The script will then build interdigitated capcaitor fingers to find the resonant 
% structure that has a resonant frequency close to the maximum resonant frequency 
% given by the user.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global FirstLogProject Int_Cap_Coords
Starting_Project = Project.Filename;
Cap_x1 = Int_Cap_Coords(1);
Cap_y1 = Int_Cap_Coords(2);
Cap_x2 = Int_Cap_Coords(3);
Cap_y2 = Int_Cap_Coords(4);
% If files with the names below already exist, delete them to avoid reading
% from the wrong project files.
if isfile('maxFrequency.son')
    delete('maxFrequency.son');
elseif isfile('maxFrequency.csv')
    delete('maxFrequency.csv');
elseif isfile('minFrequency.son')
    delete('minFrequency.son');
elseif isfile('minFrequency.csv')
    delete('minFrequency.csv');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete all existing File-Output and Frequency Sweeps to clean file.
delFileOutput(Project);
delFreqSweeps(Project);
% Set the upper and lower frequency sweep bounds to a very broad range for
% initial simulations to test for beginning resonant frequency.
% i.e. 1-10GHz
lowerbound=1;
upperbound = 10;
% Calculate the maximum number of possible interdigitated fingers given the
% capacitor area, spacing between fingers & F_Thickness of fingers.
y_total=(Cap_y2-(Bar_Thickness+F_Spacing)-Cap_y1);
max_NumFingers=floor(y_total/(F_Spacing+F_Thickness))-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                  Finding the minimum            %%%%%
%%%%%                   Resonant Frequency            %%%%%
%%%%%                        First                    %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill the capacitor area with IDC fingers to find the lowest possible
% resonant frequency.
for i= 0 : 1 : max_NumFingers
    s=(-1)^i; % Move construction from left to right side of capacitor
    % Reset y coordinates each iteration to place new fingers moving
    % downwards.
    y2_co = Cap_y2-(Bar_Thickness+F_Spacing)-i*(F_Thickness+F_Spacing);
    y1_co = y2_co - F_Thickness;
    if s==-1
        % Build finger connecting to the right side of capacitor.
        % X coordinates of new polygon
        X_Array = [(Cap_x1+F_Spacing)   Cap_x2  Cap_x2  (Cap_x1+F_Spacing)];
        % Y coordinates of new polygon
        Y_Array = [y1_co   y1_co  y2_co  y2_co];
        % Place polygon with new coordinates
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    else
        % Build finger connecting to the left side of capacitor.
        % X coordinates of new polygon
        X_Array = [Cap_x1   (Cap_x2-F_Spacing)  (Cap_x2-F_Spacing)  Cap_x1];
        % Y coordinates of new polygon
        Y_Array = [y1_co   y1_co  y2_co  y2_co];
        % Place polygon with new coordinates
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    end
end
% Place full-length capacitor coupling bar
ArrayXValues=[Cap_x1  Cap_x2   Cap_x2   Cap_x1];
ArrayYValues=[(Cap_y2-Bar_Thickness)  (Cap_y2-Bar_Thickness)  Cap_y2  Cap_y2];
Project.addMetalPolygonEasy(0,ArrayXValues,ArrayYValues,1);
% Select lowest simulation resolution as we are doing very large sweeps
% and only using these structures to determine limits of MKID resonance
% 2 = Lowest Mesh type
Project.ControlBlock.Speed=2;
% Rename the new geometry file.
str_min = 'minFrequency.son';
Project.saveAs(str_min);
% After renaming a .son file, must re-decompile into MATLAB everytime.
Project = SonnetProject(str_min);
% Simulate and analyse data with Auto_Sim
% Since we are finding the lowest resonant frequency, we add as
% much capacitance as possible.
% This means this project (in most cases) will have the most
% polygons and hence, take the longest to simulate.
% The SimulationStatus.log file that is used to monitor Sonnet in
% Matlab unfortunately does not always update to show a simulation
% is finished.
% Hence, we can assume that the maximum amount of time needed to
% simulate is given by minFrequency.son
% If any simulations fail this time, Auto_Sim will attempt to
% extract data from the .csv file anyways.
% Start counting time
t_Start = tic;
[min_Resonance, ~] = Auto_Sim(Project, upperbound, lowerbound);
% Determine the maximum time allowed per simulation
Time_Limit = toc(t_Start);
% Rename .son and .csv files to resonant frequency and delete old
% files.
old_son_file=str_min;
str_son=num2str(min_Resonance*1000)+"MHz.son";
str_csv_old=erase(str_min,".son")+".csv";
str_csv_new=num2str(min_Resonance*1000)+"MHz.csv";
Project.saveAs(str_son);
movefile(str_csv_old, str_csv_new);
delete(old_son_file);
FirstLogProject = str_min;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                  Finding the maximum            %%%%%
%%%%%                   Resonant Frequency            %%%%%
%%%%%                        First                    %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decompile the original starting geometry
Project = SonnetProject(Starting_Project);
% Place 2 IDC fingers in starting geoemtry
for i=0:1:1
    s=(-1)^i; % Move construction from left to right side of capacitor
    % Reset y coordinates each iteration to place new fingers moving
    % downwards.
    y2_co = Cap_y2-(Bar_Thickness+F_Spacing)-i*(F_Thickness+F_Spacing);
    y1_co = y2_co - F_Thickness;
    if s==-1
        % Build finger connecting to the right side of capacitor.
        % X coordinates of new polygon
        X_Array = [(Cap_x1+F_Spacing)   Cap_x2  Cap_x2  (Cap_x1+F_Spacing)];
        % Y coordinates of new polygon
        Y_Array = [y1_co   y1_co  y2_co  y2_co];
        % Place new polygon
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    else
        % Build finger connecting to the left side of capacitor.
        X_Array = [Cap_x1   (Cap_x2-F_Spacing)  (Cap_x2-F_Spacing)  Cap_x1];
        % Y coordinates of new polygon
        Y_Array = [y1_co   y1_co  y2_co  y2_co];
        % Place new polygon
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    end
end
% Place 1/2 capacitor coupling bar
% This length is just from experience as to the minimum length of coupling
% bar at such low capacitance before causing an increase in errors in data.
ArrayXValues=[round(mean([Cap_x1 Cap_x2]))  Cap_x2   Cap_x2   round(mean([Cap_x1 Cap_x2]))];
ArrayYValues=[(Cap_y2-Bar_Thickness)  (Cap_y2-Bar_Thickness)  Cap_y2  Cap_y2];
Project.addMetalPolygonEasy(0,ArrayXValues,ArrayYValues,1);
% Rename the new geometry file.
str_max="maxFrequency.son";
% Select the user desired mesh levl now
Project.ControlBlock.Speed=Mesh_Level;
Project.saveAs(str_max);
% After renaming a .son file, must re-decompile into MATLAB everytime.
Project=SonnetProject(str_max);
% New frequency sweep bounds from the previous minimum resonant frequency
% to a larger frequency (i.e. 20GHz).
lowerbound=min_Resonance;
upperbound = 20;
% Simulate and analyse data with Auto_Sim
[max_Resonance, ~] = Auto_Sim(Project, upperbound, lowerbound);
% Rename .son and .csv files to resonant frequency and delete old
% files.
old_son_file=str_max;
str_son=num2str(max_Resonance*1000)+"MHz.son";
str_csv_old=erase(str_max, ".son")+".csv";
str_csv_new=num2str(max_Resonance*1000)+"MHz.csv";
Project.saveAs(str_son);
movefile(str_csv_old, str_csv_new);
delete(old_son_file);
%Kill any cmd display windows
[~,~]=system('taskkill /F /IM cmd.exe');
end