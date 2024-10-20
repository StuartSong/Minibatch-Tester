% This is for fast walking subject with more than sufficient steps
% Information needs to be manually entered:
% Max or Min minibatch

clear
close all
clc

%% Session number
currentFolder = pwd;
[filepath,Sessionnumber] = fileparts(currentFolder);

%% Import Data and Create Folder
Names = dir('**/*.csv');
Tablenames = {Names.name};
mkdir DataPackage;
mkdir DataPackage\Figures;
Tname = string(Tablenames);
Tablename = erase(Tname,'.csv');

%% Record the Command Window
diary(strcat('./DataPackage/','Readme.txt'))

%% Loop for the section
for Trials = 1:length(Tablenames)
    %% Inport Data
    fprintf('Processing %s\n',Tablename(Trials))
    Rawdata = readtable(Tname(Trials));
    Headlines = string(Rawdata.Properties.VariableNames);
    Headlineindex = find(Headlines == 'RLM')+1;
    Headline = Headlines(Headlineindex);

    %% Create Time Vector
    frames = 1:length(Rawdata.('RLM'))-1;

    %% Left Lateral Malleolus
    Rawdata_RLM_X = Rawdata.('RLM');
    Rawdata_RLM_Y = Rawdata.(Headline);
    % Flip negative displacement values to positive for X coordinates
    RLM_X = abs(str2double(Rawdata_RLM_X(2:end))');
    % The back of human is negative and the front is positive
    RLM_Y = -str2double(Rawdata_RLM_Y(2:end))';
    % Find max index for Y value
    RLM_Y_Max_index = islocalmax(RLM_Y,'MinSeparation',100,'SamplePoints',frames);
    RLM_Y_Min_index = islocalmin(RLM_Y,'MinSeparation',100,'SamplePoints',frames);
    RLM_Y_Max_index = find(RLM_Y_Max_index == 1);
    RLM_Y_Min_index = find(RLM_Y_Min_index == 1);
    % Eliminate repeating min values and time frames
    RLM_Y_Min = RLM_Y(RLM_Y_Min_index);
    RLM_Y_Max = RLM_Y(RLM_Y_Max_index);
    t_Min_Y = frames(RLM_Y_Min_index);
    t_Max_Y = frames(RLM_Y_Max_index);

    %% Eliminate the first min data if min goes first
    First = find(t_Min_Y<t_Max_Y(1));
    t_Min_Y(First) = [];
    RLM_Y_Min(First) = [];

    %% Eliminate the last min data if min goes last
    Last = find(t_Min_Y>t_Max_Y(end));
    t_Min_Y(Last) = [];
    RLM_Y_Min(Last) = [];
    
    %% Find X extrimities within window created by Y extremities
    t_Min_X = [];
    t_Max_X = [];
    RLM_X_Max = [];
    RLM_X_Min = [];
    for Search = 1:length(t_Min_Y)
        Window_Min = t_Max_Y(Search):t_Min_Y(Search)+30; % +30: correction for adduction at swing
        [RLM_X_Min(Search),RLM_X_Min_index] = min(RLM_X(Window_Min));
        t_Min_X(Search) = Window_Min(RLM_X_Min_index);
        
        Window_Max = t_Min_Y(Search):t_Max_Y(Search+1);
        [RLM_X_Max(Search),RLM_X_Max_index] = max(RLM_X(Window_Max));
        t_Max_X(Search) = Window_Max(RLM_X_Max_index);
    end
    
    %% Eliminate misaligning due to correction
    misalign = find((t_Max_X-t_Min_X)<0);
    t_Max_X(misalign) = [];
    RLM_X_Max(misalign) = [];
    t_Min_X(misalign) = [];
    RLM_X_Min(misalign) = [];

    Displacement{Trials} = RLM_X_Max-RLM_X_Min;
    
    %% Eliminate the outlier
    Outlier = find(Displacement{Trials}<=2);
    t_Max_X(Outlier) = [];
    RLM_X_Max(Outlier) = [];
    t_Min_X(Outlier) = [];
    RLM_X_Min(Outlier) = [];
    Displacement{Trials} = RLM_X_Max-RLM_X_Min;
    Dis_Mean{Trials} = mean(Displacement{Trials});
    Dis_Std{Trials} = std(Displacement{Trials});

    figure
    DataPlot = plot(frames,RLM_X,t_Max_X,RLM_X_Max,'b*',t_Min_X,RLM_X_Min,'r*');
    title(sprintf('%s RLM x-coordinate Vs. Frames',Tablename(Trials)))
    xlabel('Number of Frames')
    ylabel('x-coordinate (mm)')
    grid on
    legend([DataPlot(2) DataPlot(3)],{'Local Maxima','Local Minima'})
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s RLM x-coordinate Vs. Frames.png',Tablename(Trials))],'png')

end

    %% X-axis Displacement
    Dis_Cell = Displacement;
    Dis_Mean = cell2mat(Dis_Mean); % Average
    Dis_Std = cell2mat(Dis_Std); % Standard Deviation
    Displacement = cell2mat(Displacement);
    Diff_STD = std(Displacement);
    Diff_Mean = mean(Displacement);

    %% Plot Displacement
    figure
    histogram(Displacement)
    title('Histogram of Horizontal Displacement')
    xlabel('Horizontal Displacement (mm)')
    ylabel('Number of appearance')
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s Histogram Horizontal Displacement Vs. Frames.png',Sessionnumber)],'png')

    %% Plot Average and Errorbar for each Trial
    figure
    bar([2:length(Tablename)+1],Dis_Mean)
    hold on
    eb = errorbar([2:length(Tablename)+1],Dis_Mean,Dis_Std,'.');
    eb.Color = 'k';
    grid on
    xlabel('Trial Number')
    ylabel('Average x-diaplacement (mm)')
    title('Average x-diaplacement vs. Trial Number')
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s Average x-diaplacement vs. Trial Number.png',Sessionnumber)],'png')

    %% Create Data Table
    MLD_Array = Dis_Cell{1}';
    Step_Array = [1:length(Dis_Cell{1})]';
    Trial_Array = repmat(Tablename(1),length(Dis_Cell{1}),1);
    Session_Array = repmat(Sessionnumber,length(Dis_Cell{1}),1);
    tab = 0;
    while tab < Trials-1
        tab = tab+1;
        MLD_Array = [MLD_Array; Dis_Cell{tab+1}'];
        Step_Array = [Step_Array;[1:length(Dis_Cell{tab+1})]'];
        Trial_Array = [Trial_Array;repmat(Tablename(tab+1),length(Dis_Cell{tab+1}),1)];
        Session_Array = [Session_Array;repmat(Sessionnumber,length(Dis_Cell{tab+1}),1)];
    end

    diary off % End Recording the Command Window
    exportfile = strcat('DataPackage/',Sessionnumber,'DataTable','.xlsx');
    xlswrite(exportfile,[Session_Array,Trial_Array,Step_Array,MLD_Array],'Sheet1','A2')
    xlswrite(exportfile,["Session","Trial","Step","ML_Displacement"],'Sheet1','A1')

    movefile('DataPackage',strcat(Sessionnumber,'DataPackage')) % Rename the Package
