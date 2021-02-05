clear
close all
clc

warning('off','all')

%% Adjust Minibatch value
Minibatch = 600;

%% Session number
currentFolder = pwd;
[filepath,Sessionnumber] = fileparts(currentFolder);

%% Import Data and Create Folder
Names = dir('*.txt');
Tablenames = {Names.name};
mkdir DataPackage;
mkdir DataPackage\Figures;
Tname = string(Tablenames);
Tablename = erase(Tname,'.txt');

%% Record the Command Window
diary(strcat('./DataPackage/','Readme.txt'))

%% Loop for the section
for Trials = 1:length(Tablenames)
    %% Inport Data
    fprintf('Processing %s\n',Tablename(Trials))
    Rawdata = readtable(Tname(Trials));

    %% Create Time Vector
    frames = 1:length(Rawdata.XCoM_PosX);

    %% Extrapolated center of mass in x-direction
    XCoM_X = Rawdata.XCoM_PosX';
    XCoM_X = XCoM_X-min(XCoM_X);
    % Find max index for XCoM
    XCoM_X_Max_index = islocalmax(XCoM_X,'MinSeparation',Minibatch,'SamplePoints',frames);
    XCoM_X_Min_index = islocalmin(XCoM_X,'MinSeparation',Minibatch,'SamplePoints',frames);
    XCoM_X_Max_index = find(XCoM_X_Max_index == 1);
    XCoM_X_Min_index = find(XCoM_X_Min_index == 1);
    % Eliminate repeating min values and time frames
    XCoM_X_Min = XCoM_X(XCoM_X_Min_index);
    XCoM_X_Max = XCoM_X(XCoM_X_Max_index);
    t_Min_X = frames(XCoM_X_Min_index);
    t_Max_X = frames(XCoM_X_Max_index);
    %% Eliminate the first max data if max goes first
    First = find(t_Max_X<t_Min_X(1));
    t_Max_X(First) = [];
    XCoM_X_Max(First) = [];

    %% If multiple mins between maxs, eliminate them and leave the last one
    if max(t_Max_X)<max(t_Min_X)
        t_Min_Xnew = [];
        for p = 1:length(t_Max_X)
            minindex = find(t_Min_X>t_Max_X(p),1);
            t_Min_Xnew(p) = t_Min_X(minindex-1);
        end
        t_Min_X = t_Min_Xnew;
        XCoM_X_Min = XCoM_X(t_Min_X);
    elseif max(t_Max_X)>max(t_Min_X)
        t_Min_Xnew = [];
        for p = 1:length(t_Max_X)-1
            minindex = find(t_Min_X>t_Max_X(p),1);
            t_Min_Xnew(p) = t_Min_X(minindex-1);
        end
        t_Min_X = [t_Min_Xnew t_Min_X(minindex)];
        XCoM_X_Min = XCoM_X(t_Min_X);
    end
    t_Min_X = unique(t_Min_X,'stable');
    XCoM_X_Min = unique(XCoM_X_Min,'stable');

    %% If multiple maxs between mins, eliminate them and leave the last one
    for maxindex = 1:length(t_Min_X)
        if t_Min_X(maxindex)>t_Max_X(maxindex)
            t_Max_X(maxindex) = [];
            XCoM_X_Max(maxindex) = [];
            fprintf('step% d max has been eliminated\n',maxindex)
        end
    end

    %% Find length difference and elinminate extra Max
    if length(XCoM_X_Max)-length(XCoM_X_Min) > 0
        XCoM_X_Max = XCoM_X_Max(1:end-1);
        t_Max_X = t_Max_X(1:end-1);
    end
    Displacement{Trials} = XCoM_X_Max-XCoM_X_Min;
    MaxXCoM{Trials} = XCoM_X_Max;
    MinXCoM{Trials} = XCoM_X_Min;
    
%     %% Eliminate the outlier
%     Outlier = find(Displacement{Trials}<=20);
%     t_Max_X(Outlier) = [];
%     LLM_X_Max(Outlier) = [];
%     t_Min_X(Outlier) = [];
%     LLM_X_Min(Outlier) = [];
%     Displacement{Trials} = LLM_X_Max-LLM_X_Min;

    Dis_Mean{Trials} = mean(Displacement{Trials});
    Dis_Std{Trials} = std(Displacement{Trials});
    
    %% Plot coordinates vs. Frames
    Dataplot = figure;
    plot(t_Max_X,XCoM_X_Max,'b*')
    hold on
    plot(t_Min_X,XCoM_X_Min,'r*')
    hold on
    plot(frames,XCoM_X)
    legend('Local Maxima','Local Minima','AutoUpdate','off')
    title(sprintf('%s XCoM_X coordinates Vs. Frames',Tablename(Trials)))
    xlabel('Number of Frames')
    ylabel('XCom_X (m)')
    grid on
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s XCoM_X coordinates Vs. Frames.png',Tablename(Trials))],'png')
end

    %% XCoM_X Displacement
    Dis_Cell = Displacement;
    Dis_Mean = cell2mat(Dis_Mean); % Average
    Dis_Std = cell2mat(Dis_Std); % Standard Deviation
    Displacement = cell2mat(Displacement);
    Diff_STD = std(Displacement);
    Diff_Mean = mean(Displacement);

    %% Plot Displacement
    figure
    histogram(Displacement)
    title('Histogram of XCoM_X Displacement')
    xlabel('XCoM_X Displacement (m)')
    ylabel('Number of appearance')
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s XCoM_X Displacement Vs. Frames.png',Sessionnumber)],'png')

    %% Plot Average and Errorbar for each Trial
    figure
    bar([2:length(Tablename)+1],Dis_Mean)
    hold on
    eb = errorbar([2:length(Tablename)+1],Dis_Mean,Dis_Std,'.');
    eb.Color = 'k';
    grid on
    xlabel('Trial Number')
    ylabel('Average XCoM_X Displacement (m)')
    title('Average XCoM_X Displacement vs. Trial Number')
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s Average XCoM_X Displacement vs. Trial Number.png',Sessionnumber)],'png')

    %% Create Data Table

    diary off % End Recording the Command Window
    exportfile = strcat('DataPackage/','MB',num2str(Minibatch),Sessionnumber,'DataTable','.xlsx');
    xlswrite(exportfile,repmat(["Max","Min","Displacement","Mean Displacement","STD",""]',length(Tablenames),1),'Sheet1','B2');
    for excelindex = 1:length(Tablenames)
        xlswrite(exportfile,{string(Tablename{excelindex})},'Sheet1',strcat("A",string(6*excelindex-4)));
        xlswrite(exportfile,MaxXCoM{excelindex},'Sheet1',strcat("C",string(6*excelindex-4)));
        xlswrite(exportfile,MinXCoM{excelindex},'Sheet1',strcat("C",string(6*excelindex-3)));
        xlswrite(exportfile,Dis_Cell{excelindex},'Sheet1',strcat("C",string(6*excelindex-2)));
        xlswrite(exportfile,Dis_Mean(excelindex),'Sheet1',strcat("C",string(6*excelindex-1)));
        xlswrite(exportfile,Dis_Std(excelindex),'Sheet1',strcat("C",string(6*excelindex)));
    end
    
    
    movefile('DataPackage',strcat(Sessionnumber,'DataPackage')) % Rename the Package