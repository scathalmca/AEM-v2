function [Sweep_Matrix] = Frequency_Block(Sweep_Matrix)
%  FREQUENCY_BLOCK 
User_Frequency = Sweep_Matrix{1, 6}(1,1);
% We need to check if the frequency bounds needs to be reset if f1
% falls outside of f2<=User_Frequency<=f1
% If this condition is still satisfied, nothing will happen and
% the function will return
Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
prev_resonance = str2double(cell2mat(Sweep_Matrix{1, 5}(1,1)));
if (Resonance < User_Frequency) || (prev_resonance > User_Frequency)
    [Project, Sweep_Matrix] = Reset_Coords(Sweep_Matrix);
end
% Initialise project
Filename = Sweep_Matrix{1, 4}(2,1);
Project = SonnetProject(Filename);
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
% Perform Binary Sweep iterations of halfing capacitor finger length until
% the closest possible resonant frequency is achieved.
[Sweep_Matrix] = Binary_Block(Project, Sweep_Matrix);
end