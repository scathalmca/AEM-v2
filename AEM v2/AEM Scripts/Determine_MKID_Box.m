function [X1,Y1,X2,Y2] = Determine_MKID_Box(Project)
%  DETERMINE_MKID_BOX Function determines the coordinates of the "box" in the GND plane that the 
% MKID sits in. If the user follows the instructions on GItHub, there should be 
% 4 polygons surrounding the MKID structure, denoted as; Top GND plane, Right 
% GND plane, Left GND plane and Bottom GND plane.
% 
% The coordinates can therefore be found by identifying the coordinates of the 
% Top, Left & Right GND plane surrounding the MKID.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the Coordinates of the polygon at the top of the project file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the Top GND polygon with a point
Top_GND_Coords=Project.findPolygonUsingPoint(1, 1, 0);
% Extract X and Y coordinates from Top_GND_Coords
% X Coords of polygon
XCoords=Top_GND_Coords.XCoordinateValues;
% Finding X Coords
XCoords = round([XCoords{2}  XCoords{3}  XCoords{4}  XCoords{5}]);
XCoords =[min(XCoords)  max(XCoords)  max(XCoords)  min(XCoords)];
% Y Coords of polygon
YCoords=Top_GND_Coords.YCoordinateValues;
% Finding Y Coords
YCoords = round([YCoords{2}  YCoords{3}  YCoords{4}  YCoords{5}]);
YCoords =[min(YCoords)  min(YCoords)  max(YCoords)  max(YCoords)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the Coordinates of the polygon to the left of the MKID 
% (Left GND Plane polygon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the Left GND polygon with a point
Left_GND_Coords = Project.findPolygonUsingPoint(1, max(YCoords)+1, 0);
% Extract X and Y coordinates from Left_GND_Coords
% X Coords of polygon
Left_XCoords=Left_GND_Coords.XCoordinateValues;
% Finding X Coords
Left_XCoords = round([Left_XCoords{2}  Left_XCoords{3}  Left_XCoords{4}  Left_XCoords{5}]);
Left_XCoords =[min(Left_XCoords)  max(Left_XCoords)  max(Left_XCoords)  min(Left_XCoords)];
% Y Coords of polygon
Left_YCoords=Left_GND_Coords.YCoordinateValues;
% Finding Y Coords
Left_YCoords = round([Left_YCoords{2}  Left_YCoords{3}  Left_YCoords{4}  Left_YCoords{5}]);
Left_YCoords =[min(Left_YCoords)  min(Left_YCoords)  max(Left_YCoords)  max(Left_YCoords)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the Coordinates of the polygon to the right of the MKID 
% (Right GND Plane polygon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Right_GND_Coords = Project.findPolygonUsingPoint(max(XCoords)-1, max(YCoords)+1, 0);
% Extract X and Y coordinates from Right_GND_Coords
% X Coords of polygon
Right_XCoords=Right_GND_Coords.XCoordinateValues;
% Finding X Coords
Right_XCoords = round([Right_XCoords{2}  Right_XCoords{3}  Right_XCoords{4}  Right_XCoords{5}]);
Right_XCoords =[min(Right_XCoords)  max(Right_XCoords)  max(Right_XCoords)  min(Right_XCoords)];
% Y Coords of polygon
Right_YCoords=Right_GND_Coords.YCoordinateValues;
% Finding Y Coords
Right_YCoords = round([Right_YCoords{2}  Right_YCoords{3}  Right_YCoords{4}  Right_YCoords{5}]);
Right_YCoords =[min(Right_YCoords)  min(Right_YCoords)  max(Right_YCoords)  max(Right_YCoords)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determing X1, Y1, X2 & Y2 for box in GND plane MKID sits in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Left GND plane polygon
X1 = max(Left_XCoords);
Y1 = min(Left_YCoords);
% Right GND plane polygon
X2 = min(Right_XCoords);
Y2 = max(Right_YCoords);
end