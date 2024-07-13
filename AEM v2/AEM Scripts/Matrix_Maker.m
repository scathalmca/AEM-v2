function [Sweep_Matrix] = Matrix_Maker(User_Freq, x1_coords, x2_coords, y_coords, f1, f1_name, Qfactor, f2, f2_name, Side)

% If X1_Co > X3_Co
if contains(Side, "Right")
    % Finger starts on the right side of the IDC
  
    % Forming arrays to append to Sweep_Matrix
   
    x1= [round(x1_coords(1)) y_coords(1) ; round(x1_coords(1))  y_coords(4)];
    x2= [round(x1_coords(2)) y_coords(1) ; round(x1_coords(2))  y_coords(4)];
    x3= [round(x2_coords(1)) y_coords(1) ; round(x2_coords(1))  y_coords(4)];
    x4 = [f1 ; f1_name];
    x5 = [f2 ; f2_name];
    x6= [User_Freq ; Qfactor];

% If X1_Co <= X3_Co
elseif contains(Side, "Left")
    % Finger starts on the left side of the IDC
  
    % Forming arrays to append to Sweep_Matrix
    x1= [round(x1_coords(1)) y_coords(1) ; round(x1_coords(1))  y_coords(4)];
    x2= [round(x1_coords(2)) y_coords(1) ; round(x1_coords(2))  y_coords(4)];
    x3= [round(x2_coords(2)) y_coords(1) ; round(x2_coords(2))  y_coords(4)];
    x4 = [f1 ; f1_name];
    x5 = [f2 ; f2_name];
    x6= [User_Freq ; Qfactor];

end

% Creating Sweep_Matrix
Sweep_Matrix=cell(1,6);
Sweep_Matrix{1, 1} = x1;
Sweep_Matrix{1, 2} = x2;
Sweep_Matrix{1, 3} = x3;
Sweep_Matrix{1, 4} = x4;
Sweep_Matrix{1, 5} = x5;
Sweep_Matrix{1, 6} = x6;



%Index
%{
%row, column
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
%}
end