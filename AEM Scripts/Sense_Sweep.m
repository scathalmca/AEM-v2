function [Sweep_Matrix] = Sense_Sweep(Project, Sweep_Matrix)
%  SENSE_SWEEP5 
global Int_Cap_Coords F_Spacing
% Importing values from each row of Sweep_Matrix
X1_Co = Sweep_Matrix{1, 1}(1,1);
X2_Co = Sweep_Matrix{1, 2}(1,1);
X3_Co = Sweep_Matrix{1, 3}(1,1);
Y1_Co =Sweep_Matrix{1, 1}(1,2);
Y2_Co = Sweep_Matrix{1, 1}(2,2);
% Import resonant frequencies from Sweep_Matrix
% Current MKID Resonant Frequency
Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
User_Frequency = Sweep_Matrix{1, 6}(1,1);
% Previous MKID Resonant Frequency
prev_resonance = Resonance;
Q_Factor = Sweep_Matrix{1, 6}(2,1);
Filename = convertCharsToStrings(char(Sweep_Matrix{1, 4}(2,1)));
prev_Q = Q_Factor;
prev_filename = Filename;
y1_co = Sweep_Matrix{1, 1}(1,2)
y2_co = Sweep_Matrix{1, 1}(2,2)
x1_co=Sweep_Matrix{1, 1}(1,1)
x2_co = Sweep_Matrix{1, 2}(1,1)
x3_co = Sweep_Matrix{1, 3}(1,1)
f1 = Sweep_Matrix{1, 4}(1,1)
f1_name = Sweep_Matrix{1, 4}(2,1)
f2 = Sweep_Matrix{1, 5}(1,1)
f2_name = Sweep_Matrix{1, 5}(2,1)
user_frequency = Sweep_Matrix{1, 6}(1,1)
Qfactor = Sweep_Matrix{1, 6}(2,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build from f1
if X1_Co > X3_Co
    % Right Side Finger
    while true
        % While iterating, we need to check if we have gone too far and
        % completed a full length of capacitor finger without reaching the
        % user's resonant frequency
        if round(X1_Co - 1) < round(Int_Cap_Coords(1)+F_Spacing)
            % We have reached the limit and thus move iterate on the next
            % finger.
            % Can do this by placing a small piece on the next leg up,
            % resetting coordintes and running recursion
            % Place small piece of capacitor on next leg (LEFT)
            X_Array = [Int_Cap_Coords(1)  Int_Cap_Coords(1)+2  Int_Cap_Coords(1)+2  Int_Cap_Coords(1)];
            F_Thickness = round(Y2_Co - Y1_Co);
            Y2_Co = Y2_Co - (F_Spacing + F_Thickness);
            Y1_Co = Y2_Co - F_Thickness;
            Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
            % Place new polygon
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
            % Reset new bounds
            % Importing values from each row of Sweep_Matrix
            Sweep_Matrix{1, 1}(1,1) = Int_Cap_Coords(1);
            Sweep_Matrix{1, 2}(1,1) = Int_Cap_Coords(1)+2;
            Sweep_Matrix{1, 3}(1,1) = Int_Cap_Coords(3)-F_Spacing;
            Sweep_Matrix{1, 1}(1,2) = Y1_Co;
            Sweep_Matrix{1, 1}(2,2) = Y2_Co;
            Sweep_Matrix{1, 4}(1,1) = prev_resonance;
            Sweep_Matrix{1, 6}(2,1) = prev_Q;
            Sweep_Matrix{1, 4}(2,1) = prev_filename;
            % Perform recursion
            [Sweep_Matrix] = Sense_Sweep(Project, Sweep_Matrix);
            return
        end
        % Remove capacitor finger polygon closest to the inductor.
        removex=round(mean([Int_Cap_Coords(3) (Int_Cap_Coords(3)-2)]));
        removey=round(mean([Y1_Co Y2_Co]));
        % Find the polygons DebugID
        first_Polygon=Project.findPolygonUsingPoint(removex, removey).DebugId;
        % Remove the polygon using the DebugID
        Project.deletePolygonUsingId(first_Polygon);
        X1_Co = X1_Co - 1;
        X_Array = [X1_Co  Int_Cap_Coords(3)  Int_Cap_Coords(3)  X1_Co];
        Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
        % Place new polygon
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
        % Name the new structure with temporary name
        str=append("Test_", num2str(Resonance*1000), ".son");
        % Save the file as "String".son
        Project.saveAs(str);
        % Set the upper and lower frequency sweep bounds.
        % Since we are adding capacitance, the new resonant frequency will be
        % below the previous resonance
        % Also increase the upperbound slightly (Just to allow a large enough
        % bounds, reduces number of "no resonance" simulations
        upperbound = Resonance + 0.05;
        lowerbound = Resonance - 0.5;
        % Since file was renamed, decompile new file as SonnetProject
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
        if Resonance <= User_Frequency
            % Check which resonant frequency is closest
            near_f1 =abs(User_Frequency - Resonance);
            near_f2 = abs(User_Frequency - prev_resonance);
            if near_f1 < near_f2
                % User_Frequency is closest to the current Resonance
                Sweep_Matrix{1, 4}(1,1) = Resonance;
                % Since this will be the last function called before a
                % resonator is complete, we can set f1=f2 and if any
                % adjustments need to be made, Reset_Coords will handle this
                Sweep_Matrix{1, 5}(1,1) = Resonance;
                Sweep_Matrix{1, 6}(2,1) = Q_Factor;
                Sweep_Matrix{1, 4}(2,1) = str_son;
                Sweep_Matrix{1, 1}(1,1) = X1_Co;
                Sweep_Matrix{1, 2}(1,1) = Int_Cap_Coords(3);
                Sweep_Matrix{1, 3}(1,1) = Int_Cap_Coords(1) + F_Spacing;
            else
                % User_Frequency is closer to the previous Resonant frequency
                Sweep_Matrix{1, 4}(1,1) = prev_resonance;
                % Since this will be the last function called before a
                % resonator is complete, we can set f1=f2 and if any
                % adjustments need to be made, Reset_Coords will handle this
                Sweep_Matrix{1, 5}(1,1) = prev_resonance;
                Sweep_Matrix{1, 6}(2,1) = prev_Q;
                Sweep_Matrix{1, 4}(2,1) = prev_filename;
                Sweep_Matrix{1, 1}(1,1) = X1_Co+1;
                Sweep_Matrix{1, 2}(1,1) = Int_Cap_Coords(3);
                Sweep_Matrix{1, 3}(1,1) = Int_Cap_Coords(1) + F_Spacing;
            end
            % Append new values to Sweep_Matrix and return
            return
        end
        % If the resonant frequency has not been found, reinitise previous
        % values and repeat while loop
        prev_resonance = Resonance;
        prev_Q = Q_Factor;
        prev_filename = str_son;
    end
else
    % Left Side Finger
    while true
        % While iterating, we need to check if we have gone too far and
        % completed a full length of capacitor finger without reaching the
        % user's resonant frequency
        if round(X2_Co + 1) > round(Int_Cap_Coords(3)-F_Spacing)
            % We have reached the limit and thus move iterate on the next
            % finger.
            % Can do this by placing a small piece on the next leg up,
            % resetting coordintes and running recursion
            % Place small piece of capacitor on next leg (RIGHT)
            X_Array = [Int_Cap_Coords(3)-2  Int_Cap_Coords(3)  Int_Cap_Coords(3)  Int_Cap_Coords(3)-2];
            F_Thickness = round(Y2_Co - Y1_Co);
            Y2_Co = Y2_Co - (F_Spacing + F_Thickness);
            Y1_Co = Y2_Co - F_Thickness;
            Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
            % Place new polygon
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
            % Reset new bounds
            % Importing values from each row of Sweep_Matrix
            Sweep_Matrix{1, 1}(1,1) = Int_Cap_Coords(3)-2;
            Sweep_Matrix{1, 2}(1,1) = Int_Cap_Coords(3);
            Sweep_Matrix{1, 3}(1,1) = Int_Cap_Coords(1)+F_Spacing;
            Sweep_Matrix{1, 1}(1,2) = Y1_Co;
            Sweep_Matrix{1, 1}(2,2) = Y2_Co;
            Sweep_Matrix{1, 4}(1,1) = prev_resonance;
            Sweep_Matrix{1, 6}(2,1) = prev_Q;
            Sweep_Matrix{1, 4}(2,1) = prev_filename;
            % Perform recursion
            [Sweep_Matrix] = Sense_Sweep(Project, Sweep_Matrix);
            return
        end
        % Remove capacitor finger polygon closest to the inductor.
        removex=round(mean([Int_Cap_Coords(1) (Int_Cap_Coords(1)+2)]));
        removey=round(mean([Y1_Co Y2_Co]));
        % Find the polygons DebugID
        first_Polygon=Project.findPolygonUsingPoint(removex, removey).DebugId;
        % Remove the polygon using the DebugID
        Project.deletePolygonUsingId(first_Polygon);
        X2_Co = X2_Co + 1;
        X_Array = [Int_Cap_Coords(1)  X2_Co  X2_Co  Int_Cap_Coords(1)];
        Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
        % Place new polygon
        Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
        % Name the new structure with temporary name
        str=append("Test_", num2str(Resonance*1000), ".son");
        % Save the file as "String".son
        Project.saveAs(str);
        % Set the upper and lower frequency sweep bounds.
        % Since we are adding capacitance, the new resonant frequency will be
        % below the previous resonance
        % Also increase the upperbound slightly (Just to allow a large enough
        % bounds, reduces number of "no resonance" simulations
        upperbound = Resonance + 0.05;
        lowerbound = Resonance - 0.5;
        % Since file was renamed, decompile new file as SonnetProject
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
        if Resonance <= User_Frequency
            % Check which resonant frequency is closest
            near_f1 =abs(User_Frequency - Resonance);
            near_f2 = abs(User_Frequency - prev_resonance);
            if near_f1 < near_f2
                % User_Frequency is closest to the current Resonance
                Sweep_Matrix{1, 4}(1,1) = Resonance;
                % Since this will be the last function called before a
                % resonator is complete, we can set f1=f2 and if any
                % adjustments need to be made, Reset_Coords will handle this
                Sweep_Matrix{1, 5}(1,1) = Resonance;
                Sweep_Matrix{1, 6}(2,1) = Q_Factor;
                Sweep_Matrix{1, 4}(2,1) = str_son;
                Sweep_Matrix{1, 1}(1,1) = Int_Cap_Coords(1);
                Sweep_Matrix{1, 2}(1,1) = X2_Co;
                Sweep_Matrix{1, 3}(1,1) = Int_Cap_Coords(3) - F_Spacing;
            else
                % User_Frequency is closer to the previous Resonant frequency
                Sweep_Matrix{1, 4}(1,1) = prev_resonance;
                % Since this will be the last function called before a
                % resonator is complete, we can set f1=f2 and if any
                % adjustments need to be made, Reset_Coords will handle this
                Sweep_Matrix{1, 5}(1,1) = prev_resonance;
                Sweep_Matrix{1, 6}(2,1) = prev_Q;
                Sweep_Matrix{1, 4}(2,1) = prev_filename;
                Sweep_Matrix{1, 1}(1,1) = Int_Cap_Coords(1);
                Sweep_Matrix{1, 2}(1,1) = X2_Co-1;
                Sweep_Matrix{1, 3}(1,1) = Int_Cap_Coords(3) - F_Spacing;
            end
            % Append new values to Sweep_Matrix and return
            return
        end
        % If the resonant frequency has not been found, reinitise previous
        % values and repeat while loop
        prev_resonance = Resonance;
        prev_Q = Q_Factor;
        prev_filename = str_son;
    end
end
end