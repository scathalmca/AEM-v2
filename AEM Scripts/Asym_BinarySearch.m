function [Sweep_Matrix] = Asym_BinarySearch(Project, User_Frequencies, Starting_Point, F_Spacing, F_Thickness, Bar_Thickness)
%  ASYM_BINARYSEARCH Function to place "half-interval" sections of interdigitated capacitor fingers
% within the MKID IDC.
%
% The automation will continue constructing and simulating each interval structure
% until the User_Frequency given by
%
% the user lies between two intervals (i.e. f_current <= Max_Frequency <= f_previous).
%
% The coordinates of the finger polygons, resonant frequencies, Q factor & filenames
% are then appended to the Sweep_Matrix and returned.

global Int_Cap_Coords

Cap_x1 = Int_Cap_Coords(1);
Cap_y1 = Int_Cap_Coords(2);
Cap_x2 = Int_Cap_Coords(3);
Cap_y2 = Int_Cap_Coords(4);

Max_Frequency = max(User_Frequencies);

% Extract Resonant Frequency and Qc Factor from already existing .csv data
% file.

[Resonance, ~]=Auto_Extract(Project);

% Clean project from any already existing file outputs or frequency sweeps.
delFileOutput(Project);
delFreqSweeps(Project);

% Length of a single IDC finger.
Length = Cap_x2-Cap_x1-F_Spacing;

% Calculate the maximum number of possible interdigitated fingers given the
% capacitor area, spacing between fingers & F_Thickness of fingers.
y_total=(Cap_y2-(Bar_Thickness+F_Spacing)-Cap_y1);

max_NumFingers=floor(y_total/(F_Spacing+F_Thickness))-1;

% Initialize previous resonance value
prev_resonance = Resonance;

% Random Q-Factor to start automation with.
prev_Q = 3e4;

% Initialize previous filename
prev_filename = convertCharsToStrings(Project.Filename);

Sweep_Matrix = [];


% Begin iteration through all capacitor fingers
for i=Starting_Point+1:1:max_NumFingers

    s=(-1)^i; % Clock to go from left side to right side of capacitor
    % Reset y1 and y2 coordinates every iteration

    y2_co = Cap_y2-(Bar_Thickness+F_Spacing)-i*(F_Thickness+F_Spacing);

    y1_co = y2_co - F_Thickness;

    if s==1  % If clock=1, start on Left side of interdigitated capacitor.

        % Begin iteration through a single capacitor finger length

        for b=Length/2:Length/2:Length

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % If placing a full length finger, remove the previous half
            % length finger.

            if b~= Length/2
                % Half finger x coordinates
                removex=round(mean([Cap_x1 Cap_x1+round(Length/2)]));

                % Half finger y coordinates
                removey=round(mean([y1_co  y2_co]));

                % Find the DebugID of the polygon we want to remove
                Polygon=Project.findPolygonUsingPoint(removex, removey).DebugId;

                % Delete that polygon using its DebugID
                Project.deletePolygonUsingId(Polygon);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % X coordinate of the polygon being placed.
            X_Array = [Cap_x1   Cap_x1+round(b)  Cap_x1+round(b)  Cap_x1];

            % Y coordinate of the polygon being placed.
            Y_Array = [y1_co  y1_co  y2_co  y2_co];

            % Place polygon.
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);

            % Name the new structure
            str=append("Test", num2str(i),"_", num2str(round(b)),".son");

            % Save the file as "String".son
            Project.saveAs(str);

            % Set upper and lower frequency sweep bounds .
            % Since we are adding capacitance in large sections, the lower
            % bound is set to the previous resonant frequency -1.
            upperbound = Resonance;

            lowerbound = Resonance-1;

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



            % If the current structure produces a resonant frequency that
            % satisfies the inequality: (f_current<=Max_Frequency<=f_previous),
            % produce the Sweep_Matrix and return.
            if (prev_resonance >= Max_Frequency) && (Resonance <= Max_Frequency)

                if b == (Length/2)
                    % If the user's resonant frequency lies on a
                    % half-length capacitor finger, we append the previous
                    % X coordinates to be of length 2 instead of the
                    % coordinates of the previous finger
                    prev_X_Array = [Cap_x1  (Cap_x1+2)  (Cap_x1+2)  Cap_x1];

                    Project = SonnetProject(prev_filename);

                    % Place length = 2 polygon.
                    Project.addMetalPolygonEasy(0, prev_X_Array ,Y_Array, 1);

                    Project.save();
                end
                % Create Sweep_Matrix with variables
                Sweep_Matrix = Matrix_Maker(Max_Frequency, prev_X_Array, X_Array, Y_Array, prev_resonance, prev_filename , prev_Q, Resonance, str_son, "Left");
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

            prev_Q = Q_Factor;
        end
    elseif s==-1 % If clock=-1, begin on Right side of interdigitated capacitor.
        % Begin iteration through a single capacitor finger length
        for b=Length/2:Length/2:Length

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % If placing a full length finger, remove the previous half
            % length finger.
            if b~= Length/2
                % Half finger x coordinates
                removex=round(mean([Cap_x2-round(Length/2) Cap_x2]));

                % Half finger y coordinates
                removey=round(mean([y1_co  y2_co]));

                % Find the DebugID of the polygon we want to remove
                Polygon=Project.findPolygonUsingPoint(removex, removey).DebugId;

                % Delete that polygon using its DebugID
                Project.deletePolygonUsingId(Polygon);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % X coordinate of the polygon being placed.
            X_Array = [(Cap_x2-round(b))   Cap_x2  Cap_x2  (Cap_x2-round(b))];

            % Y coordinate of the polygon being placed.
            Y_Array = [y1_co  y1_co  y2_co  y2_co];

            % Place polygon.
            Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);

            % Name the new structure
            str=append("Test", num2str(i),"_", num2str(round(b)),".son");

            % Save the file as "String".son
            Project.saveAs(str);

            % Set upper and lower frequency sweep bounds .
            % Since we are adding capacitance in large sections, the lower
            % bound is set to the previous resonant frequency -1.
            upperbound = Resonance;
            lowerbound = Resonance-1;

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


            % If the current structure produces a resonant frequency that
            % satisfies the inequality: (f_current<=Max_Frequency<=f_previous),
            % produce the Sweep_Matrix and return.

            if (prev_resonance >= Max_Frequency) && (Resonance<= Max_Frequency)

                if b == (Length/2)
                    % If the user's resonant frequency lies on a
                    % half-length capacitor finger, we append the previous
                    % X coordinates to be of length 2 instead of the
                    % coordinates of the previous finger
                    prev_X_Array = [(Cap_x2-2)  Cap_x2  Cap_x2  (Cap_x2-2)];

                    Project = SonnetProject(prev_filename);

                    % Place length = 2 polygon.
                    Project.addMetalPolygonEasy(0, prev_X_Array ,Y_Array, 1);

                    Project.save();
                end

                % Create Sweep_Matrix with variables
                Sweep_Matrix = Matrix_Maker(Max_Frequency, prev_X_Array,X_Array, Y_Array,prev_resonance, prev_filename , prev_Q, Resonance, str_son, "Right");

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

            prev_Q = Q_Factor;

        end

    end
end



end