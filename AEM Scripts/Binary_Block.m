function [Sweep_Matrix] = Binary_Block(Project, Sweep_Matrix)
%  BINARY_BLOCK Function to solve for the MKID geometry with the closest resonant frequency 
% to the user's designed resonance by performing a binary search algorithm on 
% the capacitor finger length
% Geometries produced after Binary_Block has finished should be the closest
% to the user's desired frequency as possible 
% Initialise other variables from Sweep_Matrix
Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
User_Frequency = Sweep_Matrix{1, 6}(1,1);
Accuracy = 0.002;
prev_X1 = Sweep_Matrix{1, 1}(1,1);
prev_X2 = Sweep_Matrix{1, 2}(1,1);
while true
    Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
    X1_Co = Sweep_Matrix{1, 1}(1,1);
    X2_Co = Sweep_Matrix{1, 2}(1,1);
    X3_Co = Sweep_Matrix{1, 3}(1,1);
    % If the user's resonant frequency lies within 3 blocks, perform a
    % 1 block iteration instrad of a binary sweep
    if abs(X3_Co - X2_Co) <= 3 || abs(X1_Co - X3_Co) <= 3 || ((Resonance <= User_Frequency+Accuracy) && (Resonance >= User_Frequency-Accuracy))  
        [Sweep_Matrix] = Sense_Sweep(Project, Sweep_Matrix);
        % Sometimes the previous resonance f2 and current resonance f1 can
        % be the same after Sense_Sweep, so if this occurs, set previous
        % resonance to Resonance - 0.5;
        return
    end
    % Perform large binary search operation by half the capacitor finger length intervals between
    % f1 and f2
    % Call LargeBinarySweep to change the geometry
    [X1_Co, X2_Co, X3_Co] = BinarySweep(Project, Sweep_Matrix);
    % Name the new structure with temporary name
    str=append("Test_", num2str(Resonance*1000), ".son");
    % Save the file as "String".son
    Project.saveAs(str);
    % Set the upper and lower frequency sweep bounds.
    % Since we are adding capacitance, the new resonant frequency will be
    % below the previous resonance
    % Also increase the upperbound slightly (Just to allow a large enough
    % bounds, reduces number of "no resonance" simulations
    upperbound = Resonance + 0.01;
    lowerbound = Resonance - 0.7;
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
        
        % Right Side Finger
        if X1_Co > X3_Co
            % Reset Coordinates
            % Set X3_Co as new X1_Co
            Sweep_Matrix{1, 3}(1,1) = X1_Co;
            Sweep_Matrix{1, 1}(1,1) = prev_X1;
        % Left Side Finger    
        elseif X1_Co < X3_Co
            % Reset Coordinates
            % Set X3_Co as new X2_Co
            Sweep_Matrix{1, 3}(1,1) = X2_Co;
            Sweep_Matrix{1, 2}(1,1) = prev_X2;
        end
        
        X1_Co = Sweep_Matrix{1, 1}(1,1);
        X2_Co = Sweep_Matrix{1, 2}(1,1);
        X3_Co = Sweep_Matrix{1, 3}(1,1);
        
        if Resonance <= User_Frequency
            % Reset f2 for prev_resonance & prev_filename
            Sweep_Matrix{1, 5}(1,1) = Resonance;
            Sweep_Matrix{1, 5}(2,1) = str_son;
        end
        
        % If Resonance < User_Frequency, reset coordinates and repeat
        % binary sweep
    else
        
        % Finger starting from the left side
        if X3_Co > X1_Co
            % Reset X2_Co to the new X2_Co
            Sweep_Matrix{1, 2}(1,1) = X2_Co;
        % Finger starting from the right side
        elseif X3_Co < X1_Co
            % Reset X1_Co to the new X1_Co
            Sweep_Matrix{1, 1}(1,1) = X1_Co;
        end
        % Set f1 as the current resonant frequency
        Sweep_Matrix{1, 4}(1,1) = Resonance;
        % Set Qc Factor
        Sweep_Matrix{1, 6}(2,1) = Q_Factor;
        % Set f1 filename as the current geometry filename.
        Sweep_Matrix{1, 4}(2,1) = str_son;
        prev_X1 = Sweep_Matrix{1, 1}(1,1);
        prev_X2 = Sweep_Matrix{1, 2}(1,1);
        
    end
end
end