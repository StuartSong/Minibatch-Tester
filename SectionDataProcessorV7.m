% This is for fast walking subject with more than sufficient steps
% Information needs to be manually entered:
% Max or Min minibatch

clear
close all
clc

%% Choose Leg to Process
leg = 'RLM';

%% Session number
currentFolder = pwd;
[filepath,Sessionnumber] = fileparts(currentFolder);

%% Import Data and Create Folder
Names = dir('*.csv');
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
    Headlineindex = find(Headlines == leg)+1;
    Headline = Headlines(Headlineindex);

    %% Create Time Vector
    frames = 1:length(Rawdata.(leg))-1;

    %% Lateral Malleolus
    Rawdata_LM_X = Rawdata.(leg);
    Rawdata_LM_Y = Rawdata.(Headline);
    % Flip negative displacement values to positive for X coordinates
    LM_X = abs(str2double(Rawdata_LM_X(2:end))');
    % The back of human is negative and the front is positive
    LM_Y = -str2double(Rawdata_LM_Y(2:end))';
    % Find max index for Y value
    LM_Y_Max_index = islocalmax(LM_Y,'MinSeparation',150,'SamplePoints',frames);
    LM_Y_Min_index = islocalmin(LM_Y,'MinSeparation',150,'SamplePoints',frames);
    LM_Y_Max_index = find(LM_Y_Max_index == 1);
    LM_Y_Min_index = find(LM_Y_Min_index == 1);
    % Eliminate repeating min values and time frames
    LM_Y_Min = LM_Y(LM_Y_Min_index);
    LM_Y_Max = LM_Y(LM_Y_Max_index);
    t_Min_Y = frames(LM_Y_Min_index);
    t_Max_Y = frames(LM_Y_Max_index);

    %% Eliminate the first min data if min goes first
    First = find(t_Min_Y<t_Max_Y(1));
    t_Min_Y(First) = [];
    LM_Y_Min(First) = [];

    %% Eliminate the last min data if min goes last
    Last = find(t_Min_Y>t_Max_Y(end));
    t_Min_Y(Last) = [];
    LM_Y_Min(Last) = [];
    
        %% Find length difference and elinminate extra Max
    if length(LM_Y_Max)-length(LM_Y_Min) > 1
        LM_Y_Max = LM_Y_Max(1:end-1);
        t_Max_Y = t_Max_Y(1:end-1);
    end
    
    %% If multiple mins between maxs, eliminate them and leave the last one
    t_Min_Ynew = [];
    for p = 1:length(t_Max_Y)-2
        minindex = find(t_Min_Y>t_Max_Y(p+1),1);
        t_Min_Ynew(p) = t_Min_Y(minindex-1);
    end
    t_Min_Y = [t_Min_Ynew t_Min_Y(minindex)];
    LM_Y_Min = LM_Y(t_Min_Y);
    t_Min_Y = unique(t_Min_Y,'stable');
    LM_Y_Min = unique(LM_Y_Min,'stable');

    %% If multiple maxs between mins, eliminate them and leave the last one
    for maxindex = 1:length(t_Min_Y)
        if t_Min_Y(maxindex)>t_Max_Y(maxindex+1)
            t_Max_Y(maxindex) = [];
            LM_Y_Max(maxindex) = [];
            fprintf('step% d max has been eliminated\n',maxindex)
        end
    end
    
    %% Eliminate overlapping Extremities
    overlapindex = (t_Max_Y(2:end)-t_Min_Y < 2);
    t_Min_Y(overlapindex) = [];
    LM_Y_Min(overlapindex) = [];
    t_Max_Y(logical([0 overlapindex])) = [];
    LM_Y_Max(logical([0 overlapindex])) = [];
    
    %% Find X extrimities within window created by Y extremities
    t_Min_X = [];
    t_Max_X = [];
    LM_X_Max = [];
    LM_X_Min = [];
    correction = 20; % correction for adduction at swing
    for Search = 1:length(t_Min_Y)
        if t_Min_Y(Search)+correction < max(frames)
            Window_Min = t_Max_Y(Search):t_Min_Y(Search)+correction;
        else
            t_Min_X(end) = []
            t_Max_X(end) = [];
            LM_X_Max(end) = [];
            LM_X_Min(end) = [];
%             Window_Min = t_Max_Y(Search):t_Min_Y(Search);
        end
        [LM_X_Min(Search),LM_X_Min_index] = min(LM_X(Window_Min));
        t_Min_X(Search) = Window_Min(LM_X_Min_index);
        
        Window_Max = t_Min_Y(Search):t_Max_Y(Search+1);
        [LM_X_Max(Search),LM_X_Max_index] = max(LM_X(Window_Max));
        t_Max_X(Search) = Window_Max(LM_X_Max_index);
    end
    
    %% Eliminate misaligning due to correction
    misalign = find((t_Max_X-t_Min_X)<0);
    t_Max_X(misalign) = [];
    LM_X_Max(misalign) = [];
    t_Min_X(misalign) = [];
    LM_X_Min(misalign) = [];

    Displacement{Trials} = LM_X_Max-LM_X_Min;
    
    %% Eliminate the outlier
    Outlier = find(Displacement{Trials}<=2);
    t_Max_X(Outlier) = [];
    LM_X_Max(Outlier) = [];
    t_Min_X(Outlier) = [];
    LM_X_Min(Outlier) = [];
    Displacement{Trials} = LM_X_Max-LM_X_Min;
    Dis_Mean{Trials} = mean(Displacement{Trials});
    Dis_Std{Trials} = std(Displacement{Trials});
%     
%     figure
%     plot(frames,LM_Y,t_Max_Y,LM_Y_Max,'b*',t_Min_Y,LM_Y_Min,'r*')
%     
    figure
    DataPlot = plot(frames,LM_X,t_Max_X,LM_X_Max,'b*',t_Min_X,LM_X_Min,'r*');
    title(sprintf('%s %s x-coordinate Vs. Frames',Tablename(Trials),leg))
    xlabel('Number of Frames')
    ylabel('x-coordinate (mm)')
    grid on
    legend([DataPlot(2) DataPlot(3)],{'Local Maxima','Local Minima'})
    set(gcf, 'Position', get(0, 'Screensize'));
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s %s x-coordinate Vs. Frames.png',Tablename(Trials),leg)],'png')

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
    grid on
    set(gcf, 'Position', get(0, 'Screensize'));
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
    set(gcf, 'Position', get(0, 'Screensize'));
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

    movefile('DataPackage',strcat(Sessionnumber,leg,'DataPackage')) % Rename the Package