function [Project, Sweep_Matrix, All_GND_Coords] = Param_GND(Project,Sweep_Matrix, Q_Range, All_GND_Coords, All_MKID_Coords)
%  PARAM_GND2 Function to parameterise the GND plane polygons surrounding an MKID until 
% the structure's Qc value fits within a user defined range.
Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
Q_Factor = Sweep_Matrix{1, 6}(2,1);
prev_filename = Project.Filename;
prev_resonance = Resonance;
BotMKID_YCoords = All_MKID_Coords{6};
BotGND_YCoords = All_GND_Coords{1,4}(2,:);
Q_Lowerbound = Q_Range(1);
Q_Upperbound = Q_Range(2);
if (BotGND_YCoords(1)-1) <= BotMKID_YCoords(3) || Q_Factor > (Q_Upperbound)
    % Begin moving the GND plane away from the MKID (i.e. reducing surface
    % area) to lower the Qc factor s.t. it is between (Q_Lowerbound -1000) & (Q_Upperbound +1000)
    i=0;
    while true
        i = i+1;
        try
            [All_GND_Coords] = Param_GNDPoly(Project, -i);
        catch ME
            % If any errors occur with Param_GNDPoly, it is most likely
            % that the parameterisation has run out and the GND plane can
            % no longer be varied.
            % Let the user know the geometry needs to be readjusted and AEM
            % repeated
            msg = "The Ground Plane can no longer be varied to solve for Q Factor! Please adjust the initial starting geometry and re-run AEM.";
            f = msgbox(msg);
            error(msg)
        end
        % Name the new structure
        str=append("Test", num2str(i),"_GND_", num2str(i),".son");
        % Save the file as "String".son
        Project.saveAs(str);
        % Set upper and lower frequency sweep bounds .
        upperbound = Resonance+0.05;
        lowerbound = Resonance-0.05;
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
        if Q_Factor >= (Q_Lowerbound) && Q_Factor <= (Q_Upperbound)
            % Append new values to the current Sweep_Matrix and return the
            % function
            % New Resonant Frequency
            Sweep_Matrix{1, 4}(1,1) = Resonance;
            % New .son Filename
            Sweep_Matrix{1, 4}(2,1) = str_son;
            % New Qc Factor
            Sweep_Matrix{1, 6}(2,1) = Q_Factor;
            return
        end
        % We need to monitor the thickness of the BotGND_Polygon.
        % If the thickness is 1 block wide, we need to stop the
        % parameterisation and no more variations can take place without
        % major errors.
        BotGND_YCoords = All_GND_Coords{1,4}(2,:);
        if BotGND_YCoords(3) - BotGND_YCoords(1) <= 1
            % No more GND plane parameterisation can be performed and the
            % MKID geometry can't reach the desired Qc Factor.
            warning("This MKID structure can not reach the desired Qc Range! Please adjust the Qc range or the MKID structure itself and re-run AEM.")
            return
        end
        % Append new prev_filename & prev_resonance for next loop
        prev_resonance = Resonance;
        prev_filename = str_son;
    end
elseif (BotGND_YCoords(1)-2) >= BotMKID_YCoords(3) && Q_Factor < (Q_Lowerbound)
    % Begin moving the GND plane toward the MKID (i.e. increasing surface
    % area) to higher the Qc factor s.t. it is between (Q_Lowerbound -1000) & (Q_Upperbound +1000)
    i=0;
    while true
        i = i+1;
        [All_GND_Coords] = Param_GNDPoly(Project, i);
        % Name the new structure
        str=append("Test", num2str(i),"_GND_", num2str(i),".son");
        % Save the file as "String".son
        Project.saveAs(str);
        % Set upper and lower frequency sweep bounds .
        % Since we are adding capacitance in large sections, the lower
        % bound is set to the previous resonant frequency -1.
        upperbound = Resonance+0.05;
        lowerbound = Resonance-0.05;
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
        if Q_Factor >= (Q_Lowerbound) && Q_Factor <= (Q_Upperbound)
            % The structure has a Qc factor close to the desired range.
            % Append new values to the current Sweep_Matrix and return the
            % function
            % New Resonant Frequency
            Sweep_Matrix{1, 4}(1,1) = Resonance;
            % New .son Filename
            Sweep_Matrix{1, 4}(2,1) = str_son;
            % New Qc Factor
            Sweep_Matrix{1, 6}(2,1) = Q_Factor;
            return
        end
        % We need to monitor the thickness of the BotGND_Polygon.
        % If the thickness is 1 block wide, we need to stop the
        % parameterisation and no more variations can take place without
        % major errors.
        BotGND_YCoords = All_GND_Coords{1,4}(2,:);
        if (BotGND_YCoords(1)-2) <= BotMKID_YCoords(3)
            % No more GND plane parameterisation can be performed and the
            % MKID geometry can't reach the desired Qc Factor.
            warning("This MKID structure can not reach the desired Qc Range! Please adjust the Qc range or the MKID structure itself and re-run AEM.")
            return
        end
        % Append new prev_filename & prev_resonance for next loop
        prev_resonance = Resonance;
        prev_filename = str_son;
    end
end
end