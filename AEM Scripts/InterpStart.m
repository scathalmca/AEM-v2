function [Project, User_Frequencies, Starting_Point] = InterpStart(Project,User_Frequencies, F_Thickness)
%  MIN_STRUCTURE Constructs the minimum structure for a LEKID (i.e. a lumped inductor and capacitor).
%
% The script will then build interdigitated capcaitor fingers to find the resonant
% structure that has a resonant frequency close to the maximum resonant frequency
% given by the user.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Int_Cap_Coords F_Spacing Bar_Thickness Mesh_Level
Starting_Project = Project.Filename;
Cap_X1 = Int_Cap_Coords(1);
Cap_Y1 = Int_Cap_Coords(2);
Cap_X2 = Int_Cap_Coords(3);
Cap_Y2 = Int_Cap_Coords(4);
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
y_total=(Cap_Y2-(Bar_Thickness+F_Spacing)-Cap_Y1);
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
    Y2_co = Cap_Y2-(Bar_Thickness+F_Spacing)-i*(F_Thickness+F_Spacing);
    Y1_co = Y2_co - F_Thickness;
    if s==-1
        % Build finger connecting to the right side of capacitor.
        % X coordinates of new polygon
        X_Array = [(Cap_X1+F_Spacing)   Cap_X2  Cap_X2  (Cap_X1+F_Spacing)];
        % Y coordinates of new polygon
        Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
        % Place polygon with new coordinates
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    else
        % Build finger connecting to the left side of capacitor.
        % X coordinates of new polygon
        X_Array = [Cap_X1   (Cap_X2-F_Spacing)  (Cap_X2-F_Spacing)  Cap_X1];
        % Y coordinates of new polygon
        Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
        % Place polygon with new coordinates
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    end
end
% Place full-length capacitor coupling bar
ArrayXValues=[Cap_X1  Cap_X2   Cap_X2   Cap_X1];
ArrayYValues=[(Cap_Y2-Bar_Thickness)  (Cap_Y2-Bar_Thickness)  Cap_Y2  Cap_Y2];
Project.addMetalPolygonEasy(0,ArrayXValues,ArrayYValues,1);
Project.ControlBlock.Speed=Mesh_Level;
% Rename the new geometry file.
str_min = 'minFrequency.son';
Project.saveAs(str_min);
% After renaming a .son file, must re-decompile into MATLAB everytime.
Project = SonnetProject(str_min);
% Simulate and analyse data with Auto_Sim
% Since we are finding the lowest resonant frequency, we add as
% much capacitance as possible.
[min_Resonance, ~] = Auto_Sim(Project, upperbound, lowerbound);
% Rename .son and .csv files to resonant frequency and delete old
% files.
old_son_file=str_min;
str_son=num2str(min_Resonance*1000)+"MHz.son";
str_csv_old=erase(str_min,".son")+".csv";
str_csv_new=num2str(min_Resonance*1000)+"MHz.csv";
Project.saveAs(str_son);
movefile(str_csv_old, str_csv_new);
delete(old_son_file);
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
    Y2_co = Cap_Y2-(Bar_Thickness+F_Spacing)-i*(F_Thickness+F_Spacing);
    Y1_co = Y2_co - F_Thickness;
    if s==-1
        % Build finger connecting to the right side of capacitor.
        % X coordinates of new polygon
        X_Array = [(Cap_X1+F_Spacing)   Cap_X2  Cap_X2  (Cap_X1+F_Spacing)];
        % Y coordinates of new polygon
        Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
        % Place new polygon
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    else
        % Build finger connecting to the left side of capacitor.
        X_Array = [Cap_X1   (Cap_X2-F_Spacing)  (Cap_X2-F_Spacing)  Cap_X1];
        % Y coordinates of new polygon
        Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
        % Place new polygon
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
    end
end
% Place 1/2 capacitor coupling bar
% This length is just from experience as to the minimum length of coupling
% bar at such low capacitance before causing an increase in errors in data.
ArrayXValues=[round(mean([Cap_X1 Cap_X2]))  Cap_X2   Cap_X2   round(mean([Cap_X1 Cap_X2]))];
ArrayYValues=[(Cap_Y2-Bar_Thickness)  (Cap_Y2-Bar_Thickness)  Cap_Y2  Cap_Y2];
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

% Perform check to see if the structure allows for the frequencies given by
% the user in the GUI
if min(User_Frequencies) < min_Resonance || max(User_Frequencies) > max_Resonance
    beep
    answer = questdlg("The user defined resonances do not lie within the maximum and minimum frequency for this particular geometry. Would you like to continue?") ;
    if answer == "Yes"
        %If user continues the automation after failing the check, reset
        %the list of user frequencies to possible resonances for the given
        %geometry and begin automation.
        User_Frequencies = User_Frequencies(User_Frequencies>min_Resonance);
        User_Frequencies = User_Frequencies(User_Frequencies<max_Resonance);
        if numel(User_Frequencies)==0
            %If no MKIDs lie within the user's given range, cancel
            %automation
            warning("No Resonances Found! Change the Maximum and Minimum Frequencies!");
            return
        end
    else
        return
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now we want to perform 3 simulations (1/4 filled, 1/2 filled and 3/4 filled IDC areas)
% to determine the optimal starting point for AEM to be iterating through MKID configurations

% Set the bounds to be the minimum and maximum frequency
upperbound = max_Resonance;
lowerbound = min_Resonance;

% Store all the frequencies in a list to interpolate a starting point later
% And store the number of legs used at each resonance
Frequencies = max_Resonance;
Num_Legs=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1 : 3
    % Decompile the original starting geometry
    Project = SonnetProject(Starting_Project);

    % Reset the End_Value each iteration
    End_Value = j*(floor(max_NumFingers/4));

    % Fill the capacitor area with IDC fingers to find the
    % resonant frequency.
    for i= 0 : 1 : End_Value
        s=(-1)^i; % Move construction from left to right side of capacitor
        % Reset y coordinates each iteration to place new fingers moving
        % downwards.
        Y2_co = Cap_Y2-(Bar_Thickness+F_Spacing)-i*(F_Thickness+F_Spacing);
        Y1_co = Y2_co - F_Thickness;
        if s==-1
            % Build finger connecting to the right side of capacitor.
            % X coordinates of new polygon
            X_Array = [(Cap_X1+F_Spacing)   Cap_X2  Cap_X2  (Cap_X1+F_Spacing)];
            % Y coordinates of new polygon
            Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
            % Place polygon with new coordinates
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
        else
            % Build finger connecting to the left side of capacitor.
            % X coordinates of new polygon
            X_Array = [Cap_X1   (Cap_X2-F_Spacing)  (Cap_X2-F_Spacing)  Cap_X1];
            % Y coordinates of new polygon
            Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
            % Place polygon with new coordinates
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
        end
    end

    % Place 1/2 capacitor coupling bar
    % This length is just from experience as to the minimum length of coupling
    % bar at such low capacitance before causing an increase in errors in data.
    ArrayXValues=[round(mean([Cap_X1 Cap_X2]))  Cap_X2   Cap_X2   round(mean([Cap_X1 Cap_X2]))];
    ArrayYValues=[(Cap_Y2-Bar_Thickness)  (Cap_Y2-Bar_Thickness)  Cap_Y2  Cap_Y2];
    Project.addMetalPolygonEasy(0,ArrayXValues,ArrayYValues,1);

    % Rename the new geometry file.
    str=append("InterpTest_", num2str(End_Value),".son");

    % Save the file as "String".son
    Project.saveAs(str);

    % Reinitialize the project.
    Project = SonnetProject(str);

    % Simulate and analyse data with Auto_Sim
    [Resonance, Q_Factor] = Auto_Sim(Project, upperbound, lowerbound);

    % Rename .son and .csv files to resonant frequency and delete old
    % files.
    old_son_file=str;

    str_son=num2str(Resonance*1000)+"MHz.son";

    str_csv_old=erase(str, ".son")+".csv";

    str_csv_new=num2str(Resonance*1000)+"MHz.csv";

    Project.saveAs(str_son);

    movefile(str_csv_old, str_csv_new);

    delete(old_son_file);

    Frequencies = [Frequencies  Resonance];

    Num_Legs = [Num_Legs  End_Value];

end

% Add the last two frequencies
Frequencies = [Frequencies  min_Resonance];
Num_Legs=[Num_Legs  max_NumFingers];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Now that we have 5 data points of resonant frequencies to Number of IDC
% legs, we can determine the closest starting point for AEM to begin
% iterating through geomeries.
% This imensely saves on simulation time

% Perform an approximate exponential fit to the 5 values

spline_fit = spline(Num_Legs, Frequencies);

Starting_Point = floor(ppval(spline_fit, max(User_Frequencies)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simulate the structure with the number of fingers interpolated with
% Starting_Point

while true
    % Decompile the original starting geometry
    Project = SonnetProject(Starting_Project);

    % Fill the capacitor area with IDC fingers to find the lowest possible
    % resonant frequency.
    for i= 0 : 1 : Starting_Point
        s=(-1)^i; % Move construction from left to right side of capacitor
        % Reset y coordinates each iteration to place new fingers moving
        % downwards.
        Y2_co = Cap_Y2-(Bar_Thickness+F_Spacing)-i*(F_Thickness+F_Spacing);
        Y1_co = Y2_co - F_Thickness;
        if s==-1
            % Build finger connecting to the right side of capacitor.
            % X coordinates of new polygon
            X_Array = [(Cap_X1+F_Spacing)   Cap_X2  Cap_X2  (Cap_X1+F_Spacing)];
            % Y coordinates of new polygon
            Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
            % Place polygon with new coordinates
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
        else
            % Build finger connecting to the left side of capacitor.
            % X coordinates of new polygon
            X_Array = [Cap_X1   (Cap_X2-F_Spacing)  (Cap_X2-F_Spacing)  Cap_X1];
            % Y coordinates of new polygon
            Y_Array = [Y1_co   Y1_co  Y2_co  Y2_co];
            % Place polygon with new coordinates
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
        end
    end

    % Place 1/2 capacitor coupling bar
    % This length is just from experience as to the minimum length of coupling
    % bar at such low capacitance before causing an increase in errors in data.
    ArrayXValues=[round(mean([Cap_X1 Cap_X2]))  Cap_X2   Cap_X2   round(mean([Cap_X1 Cap_X2]))];
    ArrayYValues=[(Cap_Y2-Bar_Thickness)  (Cap_Y2-Bar_Thickness)  Cap_Y2  Cap_Y2];
    Project.addMetalPolygonEasy(0,ArrayXValues,ArrayYValues,1);

    % Rename the new geometry file.
    str=append("InterpStart_", num2str(Starting_Point+2),".son");

    % Save the file as "String".son
    Project.saveAs(str);

    % Reinitialize the project.
    Project = SonnetProject(str);

    % Simulate and analyse data with Auto_Sim
    [Resonance, Q_Factor] = Auto_Sim(Project, upperbound, lowerbound);

    % Rename .son and .csv files to resonant frequency and delete old
    % files.
    old_son_file=str;

    str_son=num2str(Resonance*1000)+"MHz.son";

    str_csv_old=erase(str, ".son")+".csv";

    str_csv_new=num2str(Resonance*1000)+"MHz.csv";

    Project.saveAs(str_son);

    movefile(str_csv_old, str_csv_new);

    delete(old_son_file);

    if Resonance <= max(User_Frequencies)
        % Repeat the while loop with 1 less finger
        Starting_Point = (Starting_Point - 1);

    else
        break
    end

end

% Now we have found the ideal starting number of capacitor fingers and can
% pass this off to Asym_BinarySearch to begin parameterisation.


end