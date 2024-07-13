function [Project, Sweep_Matrix] = Reset_Coords(Sweep_Matrix)
%  RESET_COORDS2 
global Int_Cap_Coords  F_Spacing Bar_Thickness
Filename = Sweep_Matrix{1, 4}(2,1);
Project = SonnetProject(Filename);
Y1_Co = Sweep_Matrix{1, 1}(1,2);
Y2_Co = Sweep_Matrix{1, 1}(2,2);
X1_Co = Sweep_Matrix{1, 1}(1,1);
X3_Co = Sweep_Matrix{1, 3}(1,1);
Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
Q_Factor = Sweep_Matrix{1, 6}(2,1);
prev_resonance = str2double(cell2mat(Sweep_Matrix{1, 5}(1,1)));
prev_filename = convertCharsToStrings(char(Sweep_Matrix{1, 5}(2,1)));
prev_Q = Q_Factor;
User_Frequency = Sweep_Matrix{1, 6}(1,1);
% Identify current finger polygon
if X1_Co >= X3_Co
    % Right Side Finger
    Side = "Right";
    F_Polygon=Project.findPolygonUsingPoint(Int_Cap_Coords(3)-1, mean([Y1_Co  Y2_Co]), 0);
else
    % Left Side Finger
    Side = "Left";
    F_Polygon=Project.findPolygonUsingPoint(Int_Cap_Coords(1)+1, mean([Y1_Co  Y2_Co]), 0);
end
% If answer is not empty, a polygon exists at those coordinates
Poly_XCoords=F_Polygon.XCoordinateValues;
Poly_YCoords=F_Polygon.YCoordinateValues;
% Finding Finger X Coords
Poly_XCoords = [Poly_XCoords{2}  Poly_XCoords{3}  Poly_XCoords{4}  Poly_XCoords{5}];
Poly_XCoords =[min(Poly_XCoords)  max(Poly_XCoords)  max(Poly_XCoords)  min(Poly_XCoords)];
% Finding Finger Y Coords
Poly_YCoords = [Poly_YCoords{2}  Poly_YCoords{3}  Poly_YCoords{4}  Poly_YCoords{5}];
Poly_YCoords =[min(Poly_YCoords)  min(Poly_YCoords)  max(Poly_YCoords)  max(Poly_YCoords)];
% Append New Coordinates
X1_Co = Poly_XCoords(1)
X2_Co = Poly_XCoords(2)
Y1_Co = Poly_YCoords(1)
Y2_Co = Poly_YCoords(3)
F_Thickness = Y2_Co - Y1_Co;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate how many fingers have been constructed so far
Y_total=(Int_Cap_Coords(4)-(Bar_Thickness+F_Spacing)-Y2_Co)
% Starting finger
Start = floor(Y_total/(F_Spacing+F_Thickness))+1;
Cap = Int_Cap_Coords(4)
Bar_Thickness
F_Spacing
F_Thickness
% Length of a single IDC finger.
Length = round(Int_Cap_Coords(3)-(Int_Cap_Coords(1)+F_Spacing));
% Calculate the maximum number of possible interdigitated fingers given the
% capacitor area, spacing between fingers & F_Thickness of fingers.
Y_total=(Int_Cap_Coords(4)-(Int_Cap_Coords(5)+F_Spacing)-Int_Cap_Coords(2));
max_NumFingers=floor(Y_total/(F_Spacing+F_Thickness))-1;
Project.Filename
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
% Remove capacitance
if Resonance < User_Frequency 
    % Starting Y2_Co for the for loop
    Y2_Co = Y2_Co - (F_Thickness + F_Spacing);
    prev_resonance = Resonance;
    prev_X_Array = Poly_XCoords;
    prev_filename = convertCharsToStrings(Project.Filename);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % User_Frequency lies outside the frequency bounds f1 & f2 and is
    % larger than Resonance (f1).
    % Therefore, to achieve User_Frequency, we need to remove capacitance
    % Remove whole fingers until we satisfy f2<=f_user<=f1
    for i= Start : -1 : 3
        Y2_Co = Y2_Co + (F_Thickness + F_Spacing);
        Y1_Co = Y2_Co - F_Thickness;
        s=(-1)^i; % Clock to go from left side to right side of capacitor
        % Reset y1 and y2 coordinates every iteration
        if s == -1
            % Left Side Finger
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Delete the existing finger
            removex = Int_Cap_Coords(1)+1;
            removey = mean([Y1_Co  Y2_Co]);
            Polygon = Project.findPolygonUsingPoint(removex, removey).DebugId;
            % Remove the polygon using the DebugID
            Project.deletePolygonUsingId(Polygon);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Place small section of length +2
            X_Array = [Int_Cap_Coords(1)  Int_Cap_Coords(1)+2  Int_Cap_Coords(1)+2  Int_Cap_Coords(1)];
            Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
            % Place length = 2 polygon.
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
            Side = "Left";
        elseif s==1
            % Right Side Finger
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Delete the existing finger
            removex = Int_Cap_Coords(3)-1;
            removey = mean([Y1_Co  Y2_Co]);
            Polygon = Project.findPolygonUsingPoint(removex, removey).DebugId;
            % Remove the polygon using the DebugID
            Project.deletePolygonUsingId(Polygon);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Place small section of length +2
            X_Array = [Int_Cap_Coords(3)-2  Int_Cap_Coords(3)  Int_Cap_Coords(3)  Int_Cap_Coords(3)-2];
            Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
            % Place length = 2 polygon.
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
            Side = "Right";
        end
        % Simulate
        % Name the new structure
        str=append("TestBackwards", num2str(i),".son");
        % Save the file as "String".son
        Project.saveAs(str);
        % Set upper and lower frequency sweep bounds .
        % Since we are adding capacitance in large sections, the lower
        % bound is set to the previous resonant frequency -1.
        Upperbound = Resonance+1;
        Lowerbound = Resonance-0.01;
        % Reinitialize the project.
        Project = SonnetProject(str);
        % Simulate and analyse data with Auto_Sim
        [Resonance, Q_Factor] = Auto_Sim(Project, Upperbound, Lowerbound);
        % Rename .son and .csv files to resonant frequency and delete old
        % files.
        old_son_file=str;
        str_son=num2str(Resonance*1000)+"MHz.son";
        str_csv_old=erase(str, ".son")+".csv";
        str_csv_new=num2str(Resonance*1000)+"MHz.csv";
        Project.saveAs(str_son);
        movefile(str_csv_old, str_csv_new);
        delete(old_son_file);
        if prev_resonance <= User_Frequency && User_Frequency <= Resonance
            Sweep_Matrix = Matrix_Maker(User_Frequency, X_Array, prev_X_Array, Y_Array, Resonance, str_son , Q_Factor, prev_resonance, prev_filename, Side);
            return
        end
        % If the User_Frequency is still above Resonance, remove small
        % piece and move onto next finger
        if s==-1
            removex = Int_Cap_Coords(1)+1;
            prev_X_Array = [(Int_Cap_Coords(1)+F_Spacing)  Int_Cap_Coords(3)  Int_Cap_Coords(3)  (Int_Cap_Coords(1)+F_Spacing)];
        elseif s==1
            removex = Int_Cap_Coords(3)-1;
            prev_X_Array = [Int_Cap_Coords(1)  (Int_Cap_Coords(3)-F_Spacing)  (Int_Cap_Coords(3)-F_Spacing)  Int_Cap_Coords(1)];
        end
        removey = mean([Y1_Co  Y2_Co]);
        Polygon = Project.findPolygonUsingPoint(removex, removey).DebugId;
        % Remove the polygon using the DebugID
        Project.deletePolygonUsingId(Polygon);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        prev_resonance = Resonance;
        prev_filename = str_son;
    end
% Build more capacitance
elseif User_Frequency < prev_resonance
    prev_resonance = Resonance;
    prev_filename = convertCharsToStrings(Project.Filename);
    prev_Q = Q_Factor;
    prev_X_Array = Poly_XCoords;
    % Starting Y2_Co for the for loop
    Y2_Co = Y2_Co + (F_Thickness + F_Spacing);
    % Begin iteration through all capacitor fingers
    for i=Start : 1 : max_NumFingers
        if i == Start
            Y2_Co = (Y1_Co + F_Thickness);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Delete the existing finger
            if contains(Side, "Right")
                removex = Int_Cap_Coords(3)-1;
                X_Array = [(Int_Cap_Coords(1)+F_Spacing)  Int_Cap_Coords(3)  Int_Cap_Coords(3)  (Int_Cap_Coords(1)+F_Spacing)];
            else
                removex = Int_Cap_Coords(1)+1;
                X_Array = [Int_Cap_Coords(1)  (Int_Cap_Coords(3)-F_Spacing)  (Int_Cap_Coords(3)-F_Spacing)  Int_Cap_Coords(1)];
            end
            
            removey = mean([Y1_Co  Y2_Co]);
            Polygon = Project.findPolygonUsingPoint(removex, removey).DebugId;
            % Remove the polygon using the DebugID
            Project.deletePolygonUsingId(Polygon);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Place full length capacitor finger
            Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
            % Name the new structure
            str=append("TestForward", num2str(i),".son");
            % Save the file as "String".son
            Project.saveAs(str);
            % Set upper and lower frequency sweep bounds .
            % Since we are adding capacitance in large sections, the lower
            % bound is set to the previous resonant frequency -1.
            Upperbound = Resonance+0.01;
            Lowerbound = Resonance-1;
            % Reinitialize the project.
            Project = SonnetProject(str);
            % Simulate and analyse data with Auto_Sim
            [Resonance, Q_Factor] = Auto_Sim(Project, Upperbound, Lowerbound);
            % Rename .son and .csv files to resonant frequency and delete old
            % files.
            old_son_file=str;
            str_son=num2str(Resonance*1000)+"MHz.son";
            str_csv_old=erase(str, ".son")+".csv";
            str_csv_new=num2str(Resonance*1000)+"MHz.csv";
            Project.saveAs(str_son);
            movefile(str_csv_old, str_csv_new);
            delete(old_son_file);
            if (prev_resonance >= User_Frequency) && (Resonance <= User_Frequency)
                Sweep_Matrix = Matrix_Maker(User_Frequency, prev_X_Array, X_Array, Y_Array, prev_resonance, prev_filename , prev_Q, Resonance, str_son, Side);
                return
            end
            prev_resonance = Resonance;
            prev_filename = str_son;
            prev_Q = Q_Factor;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        s=(-1)^i; % Clock to go from left side to right side of capacitor
        % Reset y1 and y2 coordinates every iteration
        Y2_Co = Y2_Co - (F_Thickness + F_Spacing);
        Y1_Co = Y2_Co - F_Thickness;
        if s==1  % If clock=-1, start on Left side of interdigitated capacitor.
            Side = "Left";
            % Begin iteration through a single capacitor finger length
            for b=Length/4:Length/4:Length
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % If placing a full length finger, remove the previous half
                % length finger.
                if b~= Length/4
                    % Half finger x coordinates
                    removex=Int_Cap_Coords(1)+1;
                    % Half finger y coordinates
                    removey=round(mean([Y1_Co  Y2_Co]));
                    % Find the DebugID of the polygon we want to remove
                    Polygon=Project.findPolygonUsingPoint(removex, removey).DebugId;
                    % Delete that polygon using its DebugID
                    Project.deletePolygonUsingId(Polygon);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % X coordinate of the polygon being placed.
                X_Array = [Int_Cap_Coords(1)   Int_Cap_Coords(1)+round(b)  Int_Cap_Coords(1)+round(b)  Int_Cap_Coords(1)];
                % Y coordinate of the polygon being placed.
                Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
                % Place polygon.
                Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
                % Name the new structure
                str=append("TestF", num2str(i),"_", num2str(round(b)),".son");
                % Save the file as "String".son
                Project.saveAs(str);
                % Set upper and lower frequency sweep bounds .
                % Since we are adding capacitance in large sections, the lower
                % bound is set to the previous resonant frequency -1.
                Upperbound = Resonance;
                Lowerbound = Resonance-1;
                % Reinitialize the project.
                Project = SonnetProject(str);
                % Simulate and analyse data with Auto_Sim
                [Resonance, Q_Factor] = Auto_Sim(Project, Upperbound, Lowerbound);
                % Rename .son and .csv files to resonant frequency and delete old
                % files.
                old_son_file=str;
                str_son=num2str(Resonance*1000)+"MHz.son";
                str_csv_old=erase(str, ".son")+".csv";
                str_csv_new=num2str(Resonance*1000)+"MHz.csv";
                Project.saveAs(str_son);
                movefile(str_csv_old, str_csv_new);
                delete(old_son_file);
                % If the current structure produces a resonant frequency that
                % satisfies the inequality: (f_current<=User_Frequency<=f_previous),
                % produce the Sweep_Matrix and return.
                if (prev_resonance >= User_Frequency) && (Resonance<=User_Frequency)
                    if (i == Start) && (b == Length/4)
                        % If the resonant frequency lies between a full
                        % length finger and a Length/4 finger, we need to
                        % place a small piece of +2 length capacitance onto
                        % the next line to allow the automation to
                        % continue.
                        Project = SonnetProject(prev_filename);
                        prev_X_Array = [Int_Cap_Coords(1)  Int_Cap_Coords(1)+2  Int_Cap_Coords(1)+2  Int_Cap_Coords(1)];
                        Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
                        % Place polygon.
                        Project.addMetalPolygonEasy(0, prev_X_Array ,Y_Array, 1);
                        Project.save();
                    end
                    % Create Sweep_Matrix with variables
                    Sweep_Matrix = Matrix_Maker(User_Frequency, prev_X_Array, X_Array, Y_Array, prev_resonance, prev_filename, prev_Q, Resonance, str_son, Side);
                    return
                end
                % If the resonant frequency does not satisfy the condition,
                % reset values as new "previous" values and continue placing
                % new polygons.
                %Previous X coordinate array.
                prev_X_Array=X_Array;
                % Previous filename
                prev_filename = str_son;
                % Previous Resonant Frequency
                prev_resonance = Resonance;
            end
        elseif s==-1 % If clock=1, begin on Right side of interdigitated capacitor.
            % Begin iteration through a single capacitor finger length
            Side = "Right";
            for b=Length/4:Length/4:Length
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % If placing a full length finger, remove the previous half
                % length finger.
                if b~= Length/4
                    % Half finger x coordinates
                    removex=Int_Cap_Coords(3)-1;
                    % Half finger y coordinates
                    removey=round(mean([Y1_Co  Y2_Co]));
                    % Find the DebugID of the polygon we want to remove
                    Polygon=Project.findPolygonUsingPoint(removex, removey).DebugId;
                    % Delete that polygon using its DebugID
                    Project.deletePolygonUsingId(Polygon);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % X coordinate of the polygon being placed.
                X_Array = [(Int_Cap_Coords(3)-round(b))  Int_Cap_Coords(3)  Int_Cap_Coords(3)  (Int_Cap_Coords(3)-round(b))];
                % Y coordinate of the polygon being placed.
                Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
                % Place polygon.
                Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
                % Name the new structure
                str=append("TestF", num2str(i),"_", num2str(round(b)),".son");
                % Save the file as "String".son
                Project.saveAs(str);
                % Set upper and lower frequency sweep bounds .
                % Since we are adding capacitance in large sections, the lower
                % bound is set to the previous resonant frequency -1.
                Upperbound = Resonance;
                Lowerbound = Resonance-1;
                % Reinitialize the project.
                Project = SonnetProject(str);
                % Simulate and analyse data with Auto_Sim
                [Resonance, Q_Factor] = Auto_Sim(Project, Upperbound, Lowerbound);
                % Rename .son and .csv files to resonant frequency and delete old
                % files.
                old_son_file=str;
                str_son=num2str(Resonance*1000)+"MHz.son";
                str_csv_old=erase(str, ".son")+".csv";
                str_csv_new=num2str(Resonance*1000)+"MHz.csv";
                Project.saveAs(str_son);
                movefile(str_csv_old, str_csv_new);
                delete(old_son_file);
                % If the current structure produces a resonant frequency that
                % satisfies the inequality: (f_current<=User_Frequency<=f_previous),
                % produce the Sweep_Matrix and return.
                if (prev_resonance >=User_Frequency) && (Resonance<=User_Frequency)
                    if (i == Start) && (b == Length/4)
                        % If the resonant frequency lies between a full
                        % length finger and a Length/4 finger, we need to
                        % place a small piece of +2 length capacitance onto
                        % the next line to allow the automation to
                        % continue.
                        Project = SonnetProject(prev_filename);
                        prev_X_Array = [Int_Cap_Coords(3)-2  Int_Cap_Coords(3)  Int_Cap_Coords(3)  Int_Cap_Coords(3)-2];
                        Y_Array = [Y1_Co  Y1_Co  Y2_Co  Y2_Co];
                        % Place polygon.
                        Project.addMetalPolygonEasy(0, prev_X_Array ,Y_Array, 1);
                        Project.save();
                        
                    end
                    % Create Sweep_Matrix with variables
                    Sweep_Matrix = Matrix_Maker(User_Frequency, prev_X_Array, X_Array, Y_Array, prev_resonance, prev_filename, prev_Q, Resonance, str_son, Side);
                    return
                end
                % If the resonant frequency does not satisfy the condition,
                % reset values as new "previous" values and continue placing
                % new polygons.
                %Previous X coordinate array.
                prev_X_Array=X_Array;
                % Previous filename
                prev_filename = str_son;
                % Previous Resonant Frequency
                prev_resonance = Resonance;
            end
        end
    end
end
end