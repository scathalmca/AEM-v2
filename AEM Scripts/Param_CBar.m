function [Project, Sweep_Matrix, All_MKID_Coords, CBar_Fail] = Param_CBar(Project, Sweep_Matrix, Q_Range, All_GND_Coords, All_MKID_Coords)

Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
Q_Factor = Sweep_Matrix{1, 6}(2,1);

prev_filename = Project.Filename;
prev_resonance = Resonance;

Q_Lowerbound = Q_Range(1);
Q_Upperbound = Q_Range(2);

Thickness_Variation = 0;
CBar_Fail = 0;
run = 0;

% Increasing thickness & length reduces Q

if Q_Factor < Q_Lowerbound
    % If Q_Factor is too low, we want to decrease the surface area of the
    % coupling bar.
    % I.e., we reduce Coupling Bar Length & Thickness
    i=-1;
elseif Q_Factor > Q_Upperbound
    % If Q_Factor is too high, we want to increase the surface area of the
    % coupling bar.
    % I.e., we increase Coupling Bar Length & Thickness
    i=1;
end

while true
    % Used for naming the projects.
    run = run + 1;

    [Project, All_MKID_Coords, Thickness_Variation] = CBar_Length(Project, All_MKID_Coords, i*1);

    if Thickness_Variation ~= 1

        % Name the new structure
        str=append("Test","_CBar_", num2str(run),".son");

        % Save the file as "String".son
        Project.saveAs(str);

        % Set upper and lower frequency sweep bounds .
        % Since we are adding capacitance in large sections, the lower
        % bound is set to the previous resonant frequency -0.5.
        upperbound = Resonance+0.5;
        lowerbound = Resonance-0.5;

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

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Need to perform a smaller frequency sweep now for accuracy in Q_Factor 
        % The first Auto_Sim is just to find the resonant frequency for
        % large variations of the coupling bar.]


        Project = SonnetProject(str_son);
        % Set closer frequency bounds;

        upperbound = Resonance + 0.01;
        lowerbound = Resonance - 0.01;

        % New str name
        str=append("CBar_Accuracy_", num2str(run),".son"); 

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

        
        
    end

    if (Q_Factor >= Q_Lowerbound) && (Q_Factor <= Q_Upperbound)
        % Q Factor is within correct range and goemetry can be
        % returned.
        % Append new values to the current Sweep_Matrix and return the
        % function
        % New Resonant Frequency
        Sweep_Matrix{1, 4}(1,1) = Resonance;
        % New .son Filename
        Sweep_Matrix{1, 4}(2,1) = str_son;
        % New Qc Factor
        Sweep_Matrix{1, 6}(2,1) = Q_Factor;
        % New previous resonant frequency
        Sweep_Matrix{1, 5}(1,1) = prev_resonance;
        % New previous filename
        Sweep_Matrix{1, 5}(2,1) = prev_filename;
        return
    end

    if Thickness_Variation == 1
        % If Thickness_Variation == 1, the Coupling Bar length can no
        % longer be adjusted and the Bar thickness must be
        % parameterised
        [Project, All_MKID_Coords, CBar_Fail] = CBar_Thickness(Project, All_MKID_Coords, All_GND_Coords, i*2);

        if (CBar_Fail == 1) && (Thickness_Variation == 1)
            % If both conditions are satisfied, this means that the
            % coupling bar has reached it's maximum length and maximum
            % thickness before reaching the surrounding GND plane.
            % Therefore, we need to parameterise the GND plane before
            % varying the coupling bar again.

            [Project, Sweep_Matrix, All_GND_Coords] = Param_GND(Project, Sweep_Matrix, Q_Range, All_GND_Coords, All_MKID_Coords);

            return

        else
            % Need to reinitialise between thickness variations

            % Name the new structure
            str=append("Test","_BarThickness_", num2str(run),".son");

            % Save the file as "String".son
            Project.saveAs(str);

            % Set upper and lower frequency sweep bounds .
            % Since we are adding capacitance in large sections, the lower
            % bound is set to the previous resonant frequency -0.5.
            upperbound = Resonance+0.5;
            lowerbound = Resonance-0.5;

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


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Need to perform a smaller frequency sweep now for accuracy in Q_Factor
            % The first Auto_Sim is just to find the resonant frequency for
            % large variations of the coupling bar.]

            Project = SonnetProject(str_son);

            % Set closer frequency bounds;

            upperbound = Resonance + 0.01;
            lowerbound = Resonance - 0.01;

            % New str name
            str=append("BarThickness_Accuracy", num2str(run),".son");

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

            if (Q_Factor >= Q_Lowerbound) && (Q_Factor <= Q_Upperbound)

                % Q Factor is within correct range and goemetry can be
                % returned.
                % Append new values to the current Sweep_Matrix and return the
                % function
                % New Resonant Frequency
                Sweep_Matrix{1, 4}(1,1) = Resonance;
                % New .son Filename
                Sweep_Matrix{1, 4}(2,1) = str_son;
                % New Qc Factor
                Sweep_Matrix{1, 6}(2,1) = Q_Factor;
                % New previous resonant frequency
                Sweep_Matrix{1, 5}(1,1) = prev_resonance;
                % New previous filename
                Sweep_Matrix{1, 5}(2,1) = prev_filename;
                return
            end


        end

        % Reset Thickness_Variation
        Thickness_Variation = 0;

    end

end





end