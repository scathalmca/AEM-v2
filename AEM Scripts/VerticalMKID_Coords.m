function [TopX, TopY, BotX, BotY] = VerticalMKID_Coords(Project, All_GND_Coords)
%  VERTICALMKID_COORDS Function to find the top and bottom edges of the MKID resonator. This function 
% is used to define the coordinates of the edge polygons such that when parameterising 
% the GND planes around the MKID, there is no overlap in structures, causing a 
% short.
LeftGND_XCoords = All_GND_Coords{1,2}(1,:);
RightGND_XCoords = All_GND_Coords{1,3}(1,:);
RightGND_YCoords = All_GND_Coords{1,3}(2,:);
for k = 0:1
    % k = 0 - Looking for top of MKID coordinates
    % k = 1 - Looking for bottom (coupling bar) of MKID coordinates
    
    if k==0
        Start = RightGND_YCoords(1)+1;
        Step = 1;
        End = RightGND_YCoords(3)-1;
    else
        Start = RightGND_YCoords(3)-1;
        Step = -1;
        End = RightGND_YCoords(1)+1;
    end
    for j = Start : Step : End
        % Start scanning left until a polygon is detected
        for i=LeftGND_XCoords(2)+1 : 1 : RightGND_XCoords(1)-1
            % Check to see if a polygon exists that point (i,j,0)
            answer=Project.findPolygonUsingPoint(i, j, 0);
            if isempty(answer)~=1
                % If answer is not empty, a polygon exists at those coordinates
                XCoords=answer.XCoordinateValues;
                YCoords=answer.YCoordinateValues;
                % Finding X Coords
                XCoords = [XCoords{2}  XCoords{3}  XCoords{4}  XCoords{5}];
                XCoords =[min(XCoords)  max(XCoords)  max(XCoords)  min(XCoords)];
                % Finding Y Coords
                YCoords = [YCoords{2}  YCoords{3}  YCoords{4}  YCoords{5}];
                YCoords =[min(YCoords)  min(YCoords)  max(YCoords)  max(YCoords)];
                if k == 0
                    % Append Values for Top of MKID
                    TopX = XCoords;
                    TopY = YCoords;
                else
                    % Append Values for Bottom (Coupling Bar) of MKID
                    BotX = XCoords;
                    BotY = YCoords;
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
end