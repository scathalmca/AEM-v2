function [Project, Sweep_Matrix, All_MKID_Coords, All_GND_Coords] = Q_Block(Project, Sweep_Matrix, Q_Range, All_GND_Coords, All_MKID_Coords)
%  Q_BLOCK 
Q_Factor = Sweep_Matrix{1, 6}(2,1);
Q_Lowerbound = Q_Range(1);
Q_Upperbound = Q_Range(2);
CBar_Fail = 0;
Accuracy = 0.001;
User_Frequency = Sweep_Matrix{1, 6}(1,1);
while true
    Filename = Sweep_Matrix{1, 4}(2,1);
    Project = SonnetProject(Filename);
    if ((Q_Factor >= (Q_Lowerbound - 1000)) && (Q_Factor <= (Q_Upperbound + 1000))) && CBar_Fail == 0
        % Parameterise Coupling Bar
        [Project, Sweep_Matrix, All_MKID_Coords, CBar_Fail] = Param_CBar(Project, Sweep_Matrix, Q_Range, All_GND_Coords, All_MKID_Coords);

        % Test new Q_Factor to determine if it lies within the user's range
        Q_Factor = Sweep_Matrix{1, 6}(2,1);
        if (Q_Factor >= Q_Lowerbound) && (Q_Factor <= Q_Upperbound)
            % Q Factor is within correct range and goemetry can be
            return
        end
    elseif Q_Factor < Q_Lowerbound || Q_Factor > Q_Upperbound || CBar_Fail == 1
        % Parameterise GND plane polygons
        [Project, Sweep_Matrix, All_GND_Coords] = Param_GND(Project, Sweep_Matrix, Q_Range, All_GND_Coords, All_MKID_Coords);
        % Test new Q_Factor to determine if it lies within the user's range
        Q_Factor = Sweep_Matrix{1, 6}(2,1);
        if (Q_Factor >= Q_Lowerbound) && (Q_Factor <= Q_Upperbound)
            return
        end
        % Reset CBar_Fail = 0;
        CBar_Fail = 0;
    end
end
end