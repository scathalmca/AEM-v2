function [X1_Co, X2_Co, X3_Co] = BinarySweep(Project, Sweep_Matrix)
%  BINARYSWEEP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Int_Cap_Coords
% This function takes in coordinates of two MKID geometries that satisfy
% the condition:  f1 <= User_Frequency <= f2.
% When this condition is satisfied, a geometry exists within a capacitor
% finger length (closest to the inductor) between f1 and f2.
% LargeBinarySweep places a polygon of half the length of (x1 and x3 - Right) or (x2 and x3 - Left)
% For further description, please see the GitHub repository for AEM.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializing IDC finger coordinates & values from Sweep_Matrix
X1_Co = Sweep_Matrix{1, 1}(1,1)
X2_Co = Sweep_Matrix{1, 2}(1,1)
X3_Co = Sweep_Matrix{1, 3}(1,1)
Y1_Co = Sweep_Matrix{1, 1}(1,2)
Y2_Co = Sweep_Matrix{1, 1}(2,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%                    Building Capacitor              %%%%%%%%
%%%%%%%%                        Fingers                     %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% After importing coordinates from Sweep_Matrix, we can deduce whether the
% capacitor finger closest to the inductor is connected to either the left
% or right side of the capacitor with the x coordinates.
% Remove capacitor finger polygon closest to the inductor.
if X1_Co > X3_Co
    removex = Int_Cap_Coords(3)-1;
else
    removex = Int_Cap_Coords(1)+1;
end
removey=round(mean([Y1_Co Y2_Co]));
% Find the polygons DebugID
first_Polygon=Project.findPolygonUsingPoint(removex, removey).DebugId;
% Remove the polygon using the DebugID
Project.deletePolygonUsingId(first_Polygon);
% Finger starting from the left side
if X3_Co > X1_Co
    % Since User_Frequency lies between MKID geometries with resonances f1
    % and f2 and the capacitor finger closest to the inductor is connected
    % to the left side of the MKID, place a capacitor finger with length
    % X1_Co to mean(X2_Co and X3_Co)
    X2_Co = floor(round((X2_Co + X3_Co)/2));
% Finger starting from the right side
elseif X3_Co < X1_Co
    % Since User_Frequency lies between MKID geometries with resonances f1
    % and f2 and the capacitor finger closest to the inductor is connected
    % to the right side of the MKID, place a capacitor finger with length
    % X2_Co to mean(X1_Co and X3_Co)
    X1_Co = floor(round((X1_Co + X3_Co)/2));
end
% New X coordinate Array
X_Array= [X1_Co  X2_Co   X2_Co  X1_Co];
% Y coordinate
Y_Array = [Y1_Co  Y1_Co   Y2_Co  Y2_Co];
% Place new polygon
Project.addMetalPolygonEasy(0, X_Array ,Y_Array, 1);
end