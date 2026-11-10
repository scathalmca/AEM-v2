function [Conversion] = Check_CriticalDim(Project, critical_dim)


length_unit = Project.DimensionBlock.LengthUnit;

xBoxSize = Project.GeometryBlock.xBoxSize;
yBoxSize = Project.GeometryBlock.yBoxSize;

%need to check what critical dimension is required first. Then check the
%length unit

if critical_dim >= 1 && mod(critical_dim, 1) == 0 % If micron precision

    if length_unit == "UM"
        % Do nothing


    elseif length_unit == "NM"
        % Change all polygons to micron

        Project.GeometryBlock.changeBoxSizeXY(xBoxSize/1000,yBoxSize/1000)

        % Change all polygons to um
        for i = 1:length(Project.GeometryBlock.ArrayOfPolygons)

            XCoords = Project.GeometryBlock.ArrayOfPolygons{1,i}.XCoordinateValues;
            YCoords = Project.GeometryBlock.ArrayOfPolygons{1,i}.YCoordinateValues;

            XCoords = cellfun(@(x) (x >= 1) .* x /1000, XCoords, 'UniformOutput', false);
            YCoords = cellfun(@(x) (x >= 1) .* x /1000, YCoords, 'UniformOutput', false);

            Project.GeometryBlock.ArrayOfPolygons{1,i}.XCoordinateValues = XCoords;
            Project.GeometryBlock.ArrayOfPolygons{1,i}.YCoordinateValues = YCoords;

        end

        % Change units to nm
        Project.DimensionBlock.LengthUnit = "UM";


    end
    Conversion = 1;
else
    % Convert um to nm
    critical_dim = critical_dim * 1000;

    % Check if original project units are in UM or NM
    if length_unit == "UM"


        % Origins fixed after if statements

        Project.GeometryBlock.changeBoxSizeXY(xBoxSize*1000,yBoxSize*1000)

        % Change all polygons to nm
        for i = 1:length(Project.GeometryBlock.ArrayOfPolygons)

            XCoords = Project.GeometryBlock.ArrayOfPolygons{1,i}.XCoordinateValues;
            YCoords = Project.GeometryBlock.ArrayOfPolygons{1,i}.YCoordinateValues;

            XCoords = cellfun(@(x) (x >= 1) .* x * 1000, XCoords, 'UniformOutput', false);
            YCoords = cellfun(@(x) (x >= 1) .* x * 1000, YCoords, 'UniformOutput', false);

            Project.GeometryBlock.ArrayOfPolygons{1,i}.XCoordinateValues = XCoords;
            Project.GeometryBlock.ArrayOfPolygons{1,i}.YCoordinateValues = YCoords;

        end

        % Change units to nm
        Project.DimensionBlock.LengthUnit = "NM";



    elseif length_unit == "NM"
        % Do nothing
        
        critical_dim = critical_dim*1000;
    end

    Conversion = 1000;
end


Project.changeNumberOfCells(xBoxSize/critical_dim, xBoxSize/critical_dim);
Project.changeCellSizeUsingNumberOfCellsXY(critical_dim, critical_dim);
% X origin should be 0, Y origin should be max yBoxSize
Project.GeometryBlock.LocalOrigin.Y = Project.GeometryBlock.yBoxSize;
Project.GeometryBlock.LocalOrigin.X = 0;

Project.save();


end