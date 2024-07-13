function [LeftX, LeftY, RightX, RightY] = SideMKID_Coords(Project, All_GND_Coords, Extend, Bar_Thickness, F_Spacing)
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
LeftGND_XCoords = All_GND_Coords{1,2}(1,:);
RightGND_XCoords = All_GND_Coords{1,3}(1,:);
RightGND_YCoords = All_GND_Coords{1,3}(2,:);
% Starting Left side k=0
% Starting Right side k=1
for k = 0 : 1
    for j = RightGND_YCoords(3)-1 : -1 : RightGND_YCoords(1)+1
        % Start scanning left until a polygon is detected
        if k == 0
            Start = LeftGND_XCoords(2) +1;
            Steps = 1;
            End = RightGND_XCoords(1) -1;
        else
            Start = RightGND_XCoords(1) -1;
            Steps = -1;
            End = LeftGND_XCoords(2) +1;
        end
        for i= Start : Steps : End
            % Check to see if a polygon exists that point (i,j,0)
            answer=Project.findPolygonUsingPoint(i, j, 0);
            if isempty(answer)~=1
                % If answer is not empty, a polygon exists at those coordinates
                XCoords=answer.XCoordinateValues;
                YCoords=answer.YCoordinateValues
                % Finding X Coords
                XCoords = [XCoords{2}  XCoords{3}  XCoords{4}  XCoords{5}];
                XCoords =round([min(XCoords)  max(XCoords)  max(XCoords)  min(XCoords)]);
                % Finding Y Coords
                YCoords = [YCoords{2}  YCoords{3}  YCoords{4}  YCoords{5}]
                YCoords =round([min(YCoords)  min(YCoords)  max(YCoords)  max(YCoords)])
                if k == 0
                    % Append Values for Left Side of MKID
                    LeftX = XCoords;
                    LeftY = YCoords;
                else
                    % Append Values for Right Side of MKID
                    RightX = XCoords;
                    RightY = YCoords;
                end
                break
            end
        end
        % Continue looping through y and x directions until a polygon is found
        if isempty(answer)~=1
            break
        end
    end
end
% If Extend == 1, the right vertical polygon will be extended for the
% beginning of the automation to make a connection between the MKID and the
% coupling bar
if Extend == 1
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
end
end