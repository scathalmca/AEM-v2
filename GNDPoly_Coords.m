function [All_GND_Coords] = GNDPoly_Coords(Project)
%  GNDPOLY_COORDS Extracts the coordinates of the ground plane polygons that surround an MKID 
% in Sonnet 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determining the coordinates of the GND plane polygon above the MKID (Top
% GND plane)
TopGND_Coords = Project.findPolygonUsingPoint(1,0.5,0);
TopGND_XCoords = TopGND_Coords.XCoordinateValues;
TopGND_YCoords = TopGND_Coords.YCoordinateValues;
% Finding X Coords
TopGND_XCoords = round([TopGND_XCoords{2}  TopGND_XCoords{3}  TopGND_XCoords{4}  TopGND_XCoords{5}]);
TopGND_XCoords =[min(TopGND_XCoords)  max(TopGND_XCoords)  max(TopGND_XCoords)  min(TopGND_XCoords)];
% Finding Y Coords
TopGND_YCoords = round([TopGND_YCoords{2}  TopGND_YCoords{3}  TopGND_YCoords{4}  TopGND_YCoords{5}]);
TopGND_YCoords =[min(TopGND_YCoords)  min(TopGND_YCoords)  max(TopGND_YCoords)  max(TopGND_YCoords)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determining the coordinates of the GND plane polygon to the left of the
% MKID (Left GND plane)
LeftGND_Coords = Project.findPolygonUsingPoint(1,max(TopGND_YCoords)+0.5,0);
LeftGND_XCoords = LeftGND_Coords.XCoordinateValues;
LeftGND_YCoords = LeftGND_Coords.YCoordinateValues;
% Finding X Coords
LeftGND_XCoords = round([LeftGND_XCoords{2}  LeftGND_XCoords{3}  LeftGND_XCoords{4}  LeftGND_XCoords{5}]);
LeftGND_XCoords =[min(LeftGND_XCoords)  max(LeftGND_XCoords)  max(LeftGND_XCoords)  min(LeftGND_XCoords)];
% Finding Y Coords
LeftGND_YCoords = round([LeftGND_YCoords{2}  LeftGND_YCoords{3}  LeftGND_YCoords{4}  LeftGND_YCoords{5}]);
LeftGND_YCoords =[min(LeftGND_YCoords)  min(LeftGND_YCoords)  max(LeftGND_YCoords)  max(LeftGND_YCoords)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determining the coordinates of the GND plane polygon to the right of the
% MKID (Right GND plane)
RightGND_Coords = Project.findPolygonUsingPoint(max(TopGND_XCoords)-0.5,max(TopGND_YCoords)+0.5 ,0);
RightGND_XCoords = RightGND_Coords.XCoordinateValues;
RightGND_YCoords = RightGND_Coords.YCoordinateValues;
% Finding X Coords
RightGND_XCoords = round([RightGND_XCoords{2}  RightGND_XCoords{3}  RightGND_XCoords{4}  RightGND_XCoords{5}]);
RightGND_XCoords =[min(RightGND_XCoords)  max(RightGND_XCoords)  max(RightGND_XCoords)  min(RightGND_XCoords)];
% Finding Y Coords
RightGND_YCoords = round([RightGND_YCoords{2}  RightGND_YCoords{3}  RightGND_YCoords{4}  RightGND_YCoords{5}]);
RightGND_YCoords =[min(RightGND_YCoords)  min(RightGND_YCoords)  max(RightGND_YCoords)  max(RightGND_YCoords)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determining the coordinates of the GND plane polygon below the MKID (Bottom GND plane)
BotGND_Coords = Project.findPolygonUsingPoint(1, max(LeftGND_YCoords)+0.5 ,0);
BotGND_XCoords = BotGND_Coords.XCoordinateValues;
BotGND_YCoords = BotGND_Coords.YCoordinateValues;
% Finding X Coords
BotGND_XCoords = round([BotGND_XCoords{2}  BotGND_XCoords{3}  BotGND_XCoords{4}  BotGND_XCoords{5}]);
BotGND_XCoords =[min(BotGND_XCoords)  max(BotGND_XCoords)  max(BotGND_XCoords)  min(BotGND_XCoords)];
% Finding Y Coords
BotGND_YCoords = round([BotGND_YCoords{2}  BotGND_YCoords{3}  BotGND_YCoords{4}  BotGND_YCoords{5}]);
BotGND_YCoords =[min(BotGND_YCoords)  min(BotGND_YCoords)  max(BotGND_YCoords)  max(BotGND_YCoords)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combining all coordinates into a single cell matrix to access in any
% function
% Top GND plane coordinates
Cell_1 = [TopGND_XCoords ; TopGND_YCoords];
% Left GND plane coordinates
Cell_2 = [LeftGND_XCoords ; LeftGND_YCoords];
% Right GND plane coordinates
Cell_3 = [RightGND_XCoords ; RightGND_YCoords];
% Bottom GND plane coordinates
Cell_4 = [BotGND_XCoords ; BotGND_YCoords];
% Combining all cells into single matrix to return to function
All_GND_Coords =cell(1,4);
All_GND_Coords{1, 1} = Cell_1;
All_GND_Coords{1, 2} = Cell_2;
All_GND_Coords{1, 3} = Cell_3;
All_GND_Coords{1, 4} = Cell_4;
% Indexing for extracting coordinates
%{
TopGND_XCoords = All_GND_Coords{1,1}(1,:);
TopGND_YCoords = All_GND_Coords{1,1}(2,:);
LeftGND_XCoords = All_GND_Coords{1,2}(1,:);
LeftGND_YCoords = All_GND_Coords{1,2}(2,:);
RightGND_XCoords = All_GND_Coords{1,3}(1,:);
RightGND_YCoords = All_GND_Coords{1,3}(2,:);
BotGND_XCoords = All_GND_Coords{1,4}(1,:);
BotGND_YCoords = All_GND_Coords{1,4}(2,:);
%}
end