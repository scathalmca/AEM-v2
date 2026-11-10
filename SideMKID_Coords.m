function [Left_X, Left_Y, Right_X, Right_Y] = SideMKID_Coords(Project, xmin, xmax, ymin, ymax)
%  SIDEMKID_COORDS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to find the coordinates of the vertical polygon that forms the 
% sides of the MKID geometry provided by the user in AEM.
% This is achieved by scanning through points from the bottom of the box in
% which the MKID sits in the ground plane until the function detects a
% polygon in Sonnet.
% The "scan" of points starts at x1,y2 and scans in the vertical direction to find
% the first polygon (i.e. the left & right sides of the MKID IDC).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend, F_Thickness & F_Spacing are only used at the start of AEM for the
% construction of a coupling bar. They are ignored at all other points in
% the automation.

global Bar_Thickness F_Spacing


% Starting Left side k=0
% Starting Right side k=1
Polygons = Project.GeometryBlock.ArrayOfPolygons;

indx = [];
Max_X = [];
Max_Y = [];

% Find all polygons within search area
for i = 1:numel(Polygons)

    X = cell2mat(Polygons{i}.XCoordinateValues);
    Y = cell2mat(Polygons{i}.YCoordinateValues);

    if all(X >= xmin & X <= xmax) && all(Y >= ymin & Y <= ymax)

        indx(end+1) = i;
        Max_X(end+1) = max(X);
        Max_Y(end+1) = max(Y);

    end
end

% Extract MKID polygons
MKID_Polygons = Polygons(indx);

% Find polygons sharing the maximum Y coordinate
maxY = max(Max_Y);
Side_Polygons = find(Max_Y == maxY);

% Retrieve matching polygons
Selected_Polygons = MKID_Polygons(Side_Polygons);
% Find minimum X coordinate of each selected polygon
Min_X = cellfun(@(p) min(cell2mat(p.XCoordinateValues)), Selected_Polygons);

% Identify leftmost and rightmost polygons
[~, left_idx] = min(Min_X);
[~, right_idx] = max(Min_X);

% Extract polygons
Right_Polygon = Selected_Polygons{right_idx};
Left_Polygon = Selected_Polygons{left_idx};


% Finding X and Y Coords of Left MKID Polygon
Right_X = cell2mat(Right_Polygon.XCoordinateValues);
Right_Y = cell2mat(Right_Polygon.YCoordinateValues);

Right_X =round([min(Right_X)  max(Right_X)  max(Right_X)  min(Right_X)]);
Right_Y =round([min(Right_Y)  min(Right_Y)  max(Right_Y)  max(Right_Y)]);

% Finding X and Y Coords of Left MKID Polygon
Left_X = cell2mat(Left_Polygon.XCoordinateValues);
Left_Y = cell2mat(Left_Polygon.YCoordinateValues);

Left_X =round([min(Left_X)  max(Left_X)  max(Left_X)  min(Left_X)]);
Left_Y =round([min(Left_Y)  min(Left_Y)  max(Left_Y)  max(Left_Y)]);



%{
    % We want to build the Coupling Bar starting from the right side of
    % the MKID, so we must change the polygon that forms the right side of the
    % resonator such that it is + F_Spacing longer
    % Remove old polygon
    Polygon=answer.DebugId;
    % Delete that polygon using its DebugID
    Project.deletePolygonUsingId(Polygon);
    % New Y coordinates since we are increasing the length (y-direction)
    RightY = round([min(RightY)  min(RightY)  (max(RightY)+F_Spacing+Bar_Thickness)  (max(RightY)+F_Spacing+Bar_Thickness)]);
    % Place polygon.
    Project.addMetalPolygonEasy(0, RightX ,RightY, 1);
    
    Project.save();

%}

Right_Y = round([max(Right_Y)  max(Right_Y)  (max(Right_Y)+F_Spacing+Bar_Thickness)  (max(Right_Y)+F_Spacing+Bar_Thickness)]);

Project.addMetalPolygonEasy(0, Right_X, Right_Y, 1);

end