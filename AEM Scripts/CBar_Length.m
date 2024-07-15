function [Project, All_MKID_Coords, Thickness_Variation] = CBar_Length(Project, All_MKID_Coords, Change)
%  CBAR_LENGTH Function to increase the length (x-direction) of the Coupling bar.
LeftMKID_XCoords = All_MKID_Coords{2};
RightMKID_XCoords = All_MKID_Coords{3};
Bar_XCoords = All_MKID_Coords{5};
Bar_YCoords = All_MKID_Coords{6};
MaxBar_Length = RightMKID_XCoords(1)-LeftMKID_XCoords(2);
Quarter_Length = round((MaxBar_Length/4));
Thickness_Variation =0;
if (Bar_XCoords(1) <= LeftMKID_XCoords(2)) && Change == 1
    % The Coupling Bar length can no longer be increased as the Coupling Bar
    % thickness must be varied first.
    Thickness_Variation = 1;
    % We want to reset the Coupling Bar length to 1/4 Maximum Coupling Bar
    % length, before increasing the thickness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Identifying old Polygons to be deleted
    meanXCoord = mean([Bar_XCoords(1)   Bar_XCoords(2)]);
    meanYCoord = mean([Bar_YCoords(1)   Bar_YCoords(3)]);
    % As we want to adjust the dimensions of the Coupling bar polygon, we must
    % first remove it.
    % Find the DebugID of the coupling bar polygon.
    CBar_Polygon=Project.findPolygonUsingPoint(meanXCoord, meanYCoord).DebugId;
    % Delete the existing (old) polygons
    Project.deletePolygonUsingId(CBar_Polygon);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Minimum Coupling Bar length
    Bar_XCoords = [(Bar_XCoords(2)-Quarter_Length)   Bar_XCoords(2)   Bar_XCoords(3)   (Bar_XCoords(3)-Quarter_Length)];
    % Place new polygons
    % Place new Coupling Bar
    Project.addMetalPolygonEasy(0, Bar_XCoords ,Bar_YCoords, 1);
    % Return Corrected Coordinates
    All_MKID_Coords{5} = Bar_XCoords;
    return
elseif (Bar_XCoords(1) >= RightMKID_XCoords(1)-Quarter_Length) && Change == -1
    % The Coupling Bar length can no longer be decreased as the Coupling Bar
    % thickness must be varied first.
    Thickness_Variation = 1;
    % We want to reset the Coupling Bar length to the Maximum Coupling Bar
    % length, before decreasing the thickness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Identifying old Polygons to be deleted
    meanXCoord = mean([Bar_XCoords(1)   Bar_XCoords(2)]);
    meanYCoord = mean([Bar_YCoords(1)   Bar_YCoords(3)]);
    % As we want to adjust the dimensions of the Coupling bar polygon, we must
    % first remove it.
    % Find the DebugID of the coupling bar polygon.
    CBar_Polygon=Project.findPolygonUsingPoint(meanXCoord, meanYCoord).DebugId;
    % Delete the existing (old) polygons
    Project.deletePolygonUsingId(CBar_Polygon);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Maximum Coupling Bar length
    Bar_XCoords = [LeftMKID_XCoords(2)   Bar_XCoords(2)   Bar_XCoords(3)   LeftMKID_XCoords(2)];
    % Place new polygons
    % Place new Coupling Bar
    Project.addMetalPolygonEasy(0, Bar_XCoords ,Bar_YCoords, 1);
    % Return Corrected Coordinates
    All_MKID_Coords{5} = Bar_XCoords;
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the polygons have passed the checks, begin parameterisation.
% Identifying old Polygons to be deleted
meanXCoord = mean([Bar_XCoords(1)   Bar_XCoords(2)]);
meanYCoord = mean([Bar_YCoords(1)   Bar_YCoords(3)]);
% As we want to adjust the dimensions of the Coupling bar polygon, we must
% first remove it.
% Find the DebugID of the coupling bar polygon.
CBar_Polygon=Project.findPolygonUsingPoint(meanXCoord, meanYCoord).DebugId;
% Delete the existing (old) polygons
Project.deletePolygonUsingId(CBar_Polygon);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if Change == 1
    % Increase the Length by +1 Quarter_Length
if Change == -1
    % Decrease the Length by -1 Quarter_Length
    Quarter_Length = -Quarter_Length;
end
% New Coupling Bar Coordinates
Bar_XCoords = [(Bar_XCoords(1)-Quarter_Length)   Bar_XCoords(2)   Bar_XCoords(3)   (Bar_XCoords(4)-Quarter_Length)];
% Place new polygons
% Place new Coupling Bar
Project.addMetalPolygonEasy(0, Bar_XCoords ,Bar_YCoords, 1);
% Return Corrected Coordinates
All_MKID_Coords{5} = Bar_XCoords;
end