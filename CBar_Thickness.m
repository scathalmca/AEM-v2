function [Project, All_MKID_Coords, CBar_Fail] = CBar_Thickness(Project, All_MKID_Coords,All_GND_Coords, Change)
%  CBAR_THICKNESS Function for changing the thickness of the Coupling Bar in the y-direction
RightMKID_XCoords = All_MKID_Coords{3};
RightMKID_YCoords = All_MKID_Coords{4};
Bar_XCoords = All_MKID_Coords{5};
Bar_YCoords = All_MKID_Coords{6};
BotGND_YCoords = All_GND_Coords{1,4}(2,:);
CBar_Fail = 0;
% Current Coupling Bar Thickness
Bar_Thickness = Bar_YCoords(3) - Bar_YCoords(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test if thickness of coupling bar can be varied.
% Always want to make sure than the coupling bar is atleast 1 block in
% thickness and 1 block in distance from the Bot GND plane polygon.
if Bar_Thickness <= 2
    % Thickness can no longer be reduced without large errors
    % Want to vary the GND dimensions again
    CBar_Fail = 1;
    return
elseif Bar_YCoords(3) + 2 >= BotGND_YCoords(1)
    % Thickness can no longer be increased without large errors
    % Want to vary the GND dimensions again
    CBar_Fail = 1;
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the polygons have passed the checks, begin parameterisation.
% Identifying old Polygons to be deleted
meanXCoord = mean([Bar_XCoords(1)  Bar_XCoords(2)]);
meanYCoord = mean([Bar_YCoords(1)  Bar_YCoords(3)]);
% As we want to adjust the dimensions of the Coupling bar polygon, we must
% first remove it.
% Find the DebugID of the coupling bar polygon and the RightSideMKID polygon.
CBar_Polygon=Project.findPolygonUsingPoint(meanXCoord, meanYCoord).DebugId;
RightSide_Polygon = Project.findPolygonUsingPoint(Bar_XCoords(2)+1, Bar_YCoords(1)).DebugId;
% Delete the existing (old) polygons
Project.deletePolygonUsingId(CBar_Polygon);
Project.deletePolygonUsingId(RightSide_Polygon);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if Change == 2
% Increase the thickness by 2 blocks
%elseif Change == -2
% Decrease the thickness by 2 blocks.
% Increase Coupling Bar thickness by 2
Bar_YCoords = [Bar_YCoords(1)   Bar_YCoords(2)   Bar_YCoords(3)+Change   Bar_YCoords(4)+Change];
% Increase Side MKID polygon length by 2
RightMKID_YCoords = [RightMKID_YCoords(1)   RightMKID_YCoords(2)   RightMKID_YCoords(3)+Change   RightMKID_YCoords(4)+Change];
% Place new polygons
% Place new Coupling Bar
Project.addMetalPolygonEasy(0, Bar_XCoords ,Bar_YCoords, 1);
% Place new Side MKID polygon
Project.addMetalPolygonEasy(0, RightMKID_XCoords ,RightMKID_YCoords, 1);
All_MKID_Coords{4} = RightMKID_YCoords;
All_MKID_Coords{6} = Bar_YCoords;
end