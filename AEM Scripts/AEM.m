function [] = AEM(Project, StartingVariables, GND_Input)
%  NEWAEM l function for running the automation software AEM.
% Clear all existing global variables
clear global

% Make global variables
global f Int_Cap_Coords F_Spacing Bar_Thickness G_Variation Mesh_Level
%                         f
% Stored window prompt to let the user know what stage AEM is currently on
% and how far it has progressed.
%                     G_Variation
% The user chooses whether AEM is allowed to perform any parameterisation
% on the surrounding GND polygons surrounding the MKID.
% This is usually required for specific geometries or for large array
% designs where it is not possible to vary the GND plane.
G_Variation = GND_Input;
warning off
[~,check] = system('tasklist');
if contains(check, 'sonnet.exe')
    system('TASKKILL /IM sonnet.exe');
end
if ~isfile("Simulation Log\")
    mkdir("Simulation Logs\");
end
warning on
% Extracting Variables from input list
User_Frequencies = StartingVariables{1,1};
Q_Range = StartingVariables{1,2};
Q_Lowerbound = Q_Range(1);
Q_Upperbound = Q_Range(2);
% Desired MKID geometry settings
F_Spacing = StartingVariables{1,7};
F_Thickness = StartingVariables{1,8};
Bar_Thickness = StartingVariables{1,9};
Mesh_Level = StartingVariables{1,10};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%    Automated Electromagnetic MKID simulations   %%%%%
        %%%%%                        AEM                      %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save a copy of the starting geometry given by user.
Project.saveAs('Starting_Geometry.son');
% Time automation
tic 
% Display waitbar 
f = waitbar(0, 'AEM Warming Up...');
% Count the number of simulations performed by Sonnet
SimCounter('new'); 
% Store resonant frequencies, Qc and filename of finished MKID structures
EndResonators(0, 0, 0, 'new');
[All_GND_Coords] = GNDPoly_Coords(Project);
[LeftX, LeftY, RightX, RightY] = SideMKID_Coords(Project, All_GND_Coords, 1, Bar_Thickness, F_Spacing);
% Coordinates of the internal area of the capacitor
Cap_x1 = round(LeftX(2));
Cap_y1 = round(LeftY(1));
Cap_x2 = round(RightX(1));
Cap_y2 = round(RightY(3));
Int_Cap_Coords = [Cap_x1 Cap_y1 Cap_x2 Cap_y2 Bar_Thickness];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%                  Store Variables                %%%%%      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Percentage error on resonant frequencies
Accuracy_Perc=[]; 
% Accuracy (abs(Chosen - Actual)) MHz
Accuracy_Freq=[];
% Counting number of simulations per resonator
simCounts =[];
% Initialize the number of correct resonator geometries found
Res_Num = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%                    :SECTION 2:                  %%%%%
        %%%%%                  Finding Geometry               %%%%%
        %%%%%                    With Largest                 %%%%%     
        %%%%%                 Resonant Frequency              %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
waitbar(0,f,"Checking Minimum & Maximum Resonant Frequencies...")
% Call function to perform large binary search construction to
% determine the possible resonant frequencies as well as the
% structure that matches the user's largest frequency.
[Project, User_Frequencies, Starting_Point] = InterpStart(Project, User_Frequencies, F_Thickness);

[TopX, TopY, BotX, BotY] = VerticalMKID_Coords(Project, All_GND_Coords);
All_MKID_Coords = {TopY, LeftX, RightX, RightY, BotX, BotY};

[Sweep_Matrix] = Asym_BinarySearch(Project, User_Frequencies, Starting_Point, F_Spacing, F_Thickness, Bar_Thickness);
Filename = Sweep_Matrix{1, 4}(2,1);
Project = SonnetProject(Filename);
% After finding two geometries that have the User_Frequency between them,
% we can reduce the number of simulations needed by getting an accurate
% value of Q_Factor to start.
% Therefore we perform a smaller frequency sweep on f1
Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
upperbound = Resonance + 0.01;
lowerbound = Resonance - 0.01;
% Simulate and analyse data with Auto_Sim
[~, Q_Factor] = Auto_Sim(Project, upperbound, lowerbound);
Sweep_Matrix{1, 6}(2,1) = Q_Factor;
% Now we iterate to find all resonators
for b = 1: numel(User_Frequencies)
    User_Frequency = User_Frequencies(b);
    Sweep_Matrix{1, 6}(1,1) = User_Frequency;
    Q_Factor = Sweep_Matrix{1, 6}(2,1);
    % Show progress of iteration on progress bar
    waitbar(Res_Num/numel(User_Frequencies), f, append("Number of Resonators Found: "+num2str(Res_Num)+" / "+num2str(numel(User_Frequencies))+ " : "+  num2str(User_Frequencies(b)*1000)+ "MHz"));
    while true
        % while in loop, parameterise for Q_Factor first then solve for
        % resonant frequency
        
        if Q_Factor < Q_Lowerbound || Q_Factor > Q_Upperbound
            [Project, Sweep_Matrix, All_MKID_Coords, All_GND_Coords] = Q_Block(Project, Sweep_Matrix, Q_Range, All_GND_Coords, All_MKID_Coords);
        end
        
        [Sweep_Matrix] = Frequency_Block(Sweep_Matrix);
        % After exiting Frequency_Block, the reosnant frequency should be
        % as close to the User_Frequency as possible and therefore we dont
        % need to check for it
        % Simulate f1 to more accurate values of Q_Factor with a smaller
        % frequency sweep
        Filename = Sweep_Matrix{1, 4}(2,1);
        Project = SonnetProject(Filename);
       
        Resonance = str2double(cell2mat(Sweep_Matrix{1, 4}(1,1)));
        upperbound = Resonance + 0.01;
        lowerbound = Resonance - 0.01;
        % Name the new structure
        str=append("TestAccuracy",".son");
        % Save the file as "String".son
        Project.saveAs(str);
        % Reinitialize the project.
        Project = SonnetProject(str);
        % Simulate and analyse data with Auto_Sim
        [Resonance, Q_Factor] = Auto_Sim(Project, upperbound, lowerbound);
        % Rename .son and .csv files to resonant frequency and delete old
        % files.
        old_son_file=str;
        str_son=num2str(Resonance*1000)+"MHz.son";
        str_csv_old=erase(str, ".son")+".csv";
        str_csv_new=num2str(Resonance*1000)+"MHz.csv";
        Project.saveAs(str_son);
        movefile(str_csv_old, str_csv_new);
        delete(old_son_file);
        Sweep_Matrix{1, 4}(1,1) = Resonance;
        Sweep_Matrix{1, 6}(2,1) = Q_Factor;
        % Check if resonator passed the checks for correct resonace and
        % Q_Factor
        if Q_Factor <= Q_Upperbound && Q_Factor >= Q_Lowerbound
            % Correct resonator has been found, so break out of loop
            break
        end
        % If failed checks, repeat loop until a correct geometry is found
    end
    % Filename of correct MKID to append to EndResonators
    Filename = convertCharsToStrings(Sweep_Matrix{1, 4}(2,1));
    % Count number of resonators successfully automated so far
    Res_Num = Res_Num + 1;
    % Append values to EndResonators for later.
    EndResonators(Resonance, Q_Factor, Filename, "add");
    % Calculate accuracy values of Resonant Frequency and append to list.
    Accuracy_Perc = [Accuracy_Perc  (100 - (abs((Resonance - User_Frequency)/User_Frequency)*100))];
    Accuracy_Freq = [Accuracy_Freq  (abs(User_Frequencies(b) - Resonance)*1000)];

    % Return the total number of Sonnet simulations performed for the
    % current resonator
    [Counter] = SimCounter("get"); 

    % Add number of simulations to an array to plot later
    simCounts = [simCounts  Counter];

    % Reset the number of simulations performed.
    SimCounter('new'); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%                    :SECTION 4:                  %%%%%
        %%%%%                   Printing Data                 %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write all data to a txt file
% Return all resonant frequencies, Q Factor and Filenames belonging to the
% finished MKIDs.
[all_Resonances, all_QFactors, all_Filenames] = EndResonators(0, 0, 0, "get");

% Create .txt file.
txtfile=fopen("Resonator Data File.txt", "w+");
% Stop timer and calculate elapsed time
elapsedTime = toc;
% Calculate time in hours, minutes, and seconds
hours = num2str(floor(elapsedTime / 3600));
minutes = num2str(floor(mod(elapsedTime, 3600) / 60));
seconds = num2str(mod(elapsedTime, 60));
% Print the value to the file with a "|" separator
% Display runtime in format hours/minutes/seconds
fprintf(txtfile,'%s%s%s%s%s%s%s',"Runtime| ","Hours: ", hours,"  Minutes: ", minutes, "  Seconds: ",seconds);
fprintf(txtfile, "\n");
fprintf(txtfile,"%s%s", "Total Simulations Performed: ", num2str(sum(simCounts)));
fprintf(txtfile, "\n");
fprintf(txtfile,"%s%s", "Average Simulations Performed Per MKID: ", num2str(mean(simCounts)));
fprintf(txtfile, "\n");
fprintf(txtfile,"%s%s", "Mean Accuracy(%) ", num2str(mean(Accuracy_Perc)));
fprintf(txtfile, "\n");
fprintf(txtfile,"%s%s", "Mean Accuracy(MHz) ", num2str((mean(Accuracy_Freq))));
fprintf(txtfile, "\n");
fprintf(txtfile, "\n");
fprintf(txtfile, '%s%s', "|",repmat('_', 1, 6),"FileName", repmat('_', 1, 6));
fprintf(txtfile, '%s%s', "|",repmat('_', 1, 6),"User Resonances(MHz)", repmat('_', 1, 6));
fprintf(txtfile, '%s%s', "|",repmat('_', 1, 6),"Resonances(MHz)", repmat('_', 1, 6));
fprintf(txtfile, '%s%s%s%s%s', "|",repmat('_', 1, 6),"Q-Factor", repmat('_', 1, 6), "|");
fprintf(txtfile, '%s%s%s%s%s', "|",repmat('_', 1, 6),"# of Sims", repmat('_', 1, 6), "|");
for i=1:numel(all_Resonances)
    %%%%%%%%%%%%%%%%%%%%
    % Printing data to .txt
    %%%%%%%%%%%%%%%%%%%%
    fprintf(txtfile, "\n");
    
    % Set resonant frequencies from GHz to MHz and round
    all_Resonances(i) = round(all_Resonances(i)*1e3, 2);
    
    % Round Qc Factors.
    all_QFactors(i)=round(all_QFactors(i));
    % Print values to .txtfile line by line.
    fprintf(txtfile, "%s%23s%33s%26s%26s", all_Filenames(i), num2str(User_Frequencies(i)*1000), num2str(all_Resonances(i)), num2str(all_QFactors(i)), num2str(simCounts(i)));
    %%%%%%%%%%%%%%%%%%%%
    % Storing .son and .csv files
    %%%%%%%%%%%%%%%%%%%%
    % Move all finished MKID geometries and .csv data files to new folder.
    mkdir FinishedMKIDs\Sonnet_Files\
    movefile(all_Filenames(i), "FinishedMKIDs\Sonnet_Files\");
    str_csv=erase(all_Filenames(i),".son") + ".csv";
    mkdir FinishedMKIDs\Excel_Files\
    movefile(str_csv, "FinishedMKIDs\Excel_Files\")
    %%%%%%%%%%%%%%%%%%%%%%%
    % Creating GDSII Files for Prototyping
    %Project = SonnetProject(all_Filenames(i));
    %[GDS_Filename] = GDSII_Maker(Project);
    %mkdir FinishedMKIDs\GDSII_Files\
    %movefile(GDS_Filename, "FinishedMKIDs\GDSII_Files\")
end
% Close .txt file
fclose(txtfile);
% Change directory and make new folder
mkdir ExcessGeometries\
%Moving all excess geometries to seperate folder
movefile *MHz.son ExcessGeometries\
movefile *MHz.csv ExcessGeometries\
waitbar(1, f, "All Resonators Successfully Automated by AEM!");
% Display the automation software has finished successfully.
disp("Resonators Successfully Simulated!");



% Diplaying bar chart for number of simulations performed per resonator.

% Converting resonant frequency to string
User_Frequencies = string(User_Frequencies);

% Plotting a bar chart
figure;
bar(simCounts);
set(gca, 'XTickLabel', User_Frequencies); % Set resonances as x-axis labels
xlabel('Resonant Frequency (GHz)');
ylabel('Number of Simulations Performed');
title('Simulations Performed for each MKID');
xtickangle(90);
grid on
% Improve readability of bar chart
xlim([(min(User_Frequencies)-1) (max(User_Frequencies)+1)]);

% Save bar chart as a pdf
saveas(gcf,'Sim_Distribution.pdf')

end
