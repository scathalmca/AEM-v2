function [All_GND_Coords] = Param_GNDPoly(Project, Change)
%  PARAM_GNDPOLY Function to increase or decrease the square area of the top most ground polygon 
% in Sonnet.
% Identify all current GND polygon coordinates
[All_GND_Coords] = GNDPoly_Coords(Project);
TopGND_XCoords = All_GND_Coords{1,1}(1,:);
TopGND_YCoords = All_GND_Coords{1,1}(2,:);
LeftGND_XCoords = All_GND_Coords{1,2}(1,:);
LeftGND_YCoords = All_GND_Coords{1,2}(2,:);
RightGND_XCoords = All_GND_Coords{1,3}(1,:);
RightGND_YCoords = All_GND_Coords{1,3}(2,:);
BotGND_XCoords = All_GND_Coords{1,4}(1,:);
BotGND_YCoords = All_GND_Coords{1,4}(2,:);
% As we want to adjust the dimensions of all polygons, we must first remove
% them.
% Find the DebugID of all polygons we want to remove
TopPolygon=Project.findPolygonUsingPoint(1, 1).DebugId;
LeftPolygon = Project.findPolygonUsingPoint(1, TopGND_YCoords(3)+1).DebugId;
RightPolygon = Project.findPolygonUsingPoint(TopGND_XCoords(2)-1, TopGND_YCoords(3)+1).DebugId;
BotPolygon = Project.findPolygonUsingPoint(LeftGND_XCoords(2)+1, LeftGND_YCoords(3)+1).DebugId;
% Delete polygons using their DebugIDs
Project.deletePolygonUsingId(TopPolygon);
Project.deletePolygonUsingId(LeftPolygon);
Project.deletePolygonUsingId(RightPolygon);
Project.deletePolygonUsingId(BotPolygon);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjusting new dimensions
% If Change = +1, we add +1 to the TopGND & BotGND polygon in the
% y-direction, while -1 to the Left & Right polygons in the y-direction on
% the top and bottom of the polygons (& -1 to the Left & Right polygons in
% the x-direction)
% If Change = -1, we add -1 to the TopGND & BotGND polygon in the
% y-direction, while +1 to the Left & Right polygons in the y-direction on
% the top and bottom of the polygons (& -1 to the Left & Right polygons in
% the x-direction)
% Adding +1 to the TopGND polygon
TopGND_YCoords = [TopGND_YCoords(1)  TopGND_YCoords(2)  (TopGND_YCoords(3)+Change)  (TopGND_YCoords(4)+Change)];
% Adding +1 to the BotGND polygon
BotGND_YCoords = [(BotGND_YCoords(1)-Change)   (BotGND_YCoords(2)-Change)   BotGND_YCoords(3)   BotGND_YCoords(4)];
% Adding +1 to the LeftGND polygon in the +x-direction
LeftGND_XCoords = [LeftGND_XCoords(1)   (LeftGND_XCoords(2)+Change)    (LeftGND_XCoords(3)+Change)   LeftGND_XCoords(4)];
% We must also adjust the Y coordinates of the LeftGND polygon as the Top
% and Bottom GND polygons have now changed.
LeftGND_YCoords = [(LeftGND_YCoords(1)+Change)   (LeftGND_YCoords(2)+Change)   (LeftGND_YCoords(3)-Change)   (LeftGND_YCoords(4)-Change)];
% Adding -1 to the RightGND polygon in the -x-direction
RightGND_XCoords = [(RightGND_XCoords(1)-Change)   RightGND_XCoords(2)   RightGND_XCoords(3)   (RightGND_XCoords(4)-Change)];
% We must also adjust the Y coordinates of the RightGND polygon as the Top
% and Bottom GND polygons have now changed.
RightGND_YCoords = [(RightGND_YCoords(1)+Change)   (RightGND_YCoords(2)+Change)   (RightGND_YCoords(3)-Change)   (RightGND_YCoords(4)-Change)];
% Place all GND polygons with new coordinates
% Add TopGND Polygon
Project.addMetalPolygonEasy(0, TopGND_XCoords ,TopGND_YCoords, 1);
% Add BotGND Polygon
Project.addMetalPolygonEasy(0, BotGND_XCoords ,BotGND_YCoords, 1);
% Add LeftGND Polygon
Project.addMetalPolygonEasy(0, LeftGND_XCoords ,LeftGND_YCoords, 1);
% Add RightGND Polygon
Project.addMetalPolygonEasy(0, RightGND_XCoords ,RightGND_YCoords, 1);
% Add new grounding ports to the left and right side of the BOTGND_Polygon
% Debug_ID of BotGND_Polygon
BotPolygon = Project.findPolygonUsingPoint(LeftGND_XCoords(2)+1, LeftGND_YCoords(3)+1).DebugId;
Right_Port=Project.addPortStandard(BotPolygon, 2, 50, 0, 0, 0, -1);
Left_Port=Project.addPortStandard(BotPolygon, 4, 50, 0, 0, 0, -1);
% Retrieve new All_GND_Coords and return function
[All_GND_Coords] = GNDPoly_Coords(Project);
end