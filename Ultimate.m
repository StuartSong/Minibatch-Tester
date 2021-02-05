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

%% Prompt for Minibatch Tester
clear button_result
prompt = 'Do you want to optimize Minibatch before processing session Data?';
yesorno(prompt)
% Wait for the answer
while ~exist('button_result','var')
pause(0.01)
end
close %Close the choice window

if button_result == 1
    %% Manually set minibatches for both max and min scan
    Prompt = 'Please Adjust Minibatch Parameters (eg. 170,80,5)';
    ForMB(Prompt);
    while ~exist('lob','var')
    pause(0.01)
    end
    while ~exist('upb','var')
    pause(0.01)
    end
    while ~exist('dM','var')
    pause(0.01)
    end
    close
    batchrange = lob:dM:upb;
    
    %% Run Minibatch Tester
    for Minibatch = batchrange;
        Minibatch
        batchorder = Minibatch/dM-(lob/dM-1);
        ECounter = 0; % Count the points being eliminated
        Displacement = {};

        %% Use Function
        for Trials = 1:length(Tablenames)
            [LLM_X_Max,t_Max,t_Min,LLM_X_Min,ECounter,frames,LLM_X] = DataProcessor(Tname,Trials,Minibatch,ECounter);
            Displacement{Trials} = LLM_X_Max-LLM_X_Min;
        end

        %% Steps Eliminated and Total Steps
        Dis_Cell = Displacement;
        Displacement = cell2mat(Displacement);
        TCounter = length(Displacement); % Total steps detected
        Ratio = ECounter/TCounter;
        ECounter_Total(batchorder) = ECounter
        TCounter_Total(batchorder) = TCounter
        Ratio_Total(batchorder) = ECounter/TCounter
        
    end
    
    %% Export Data into Excel
    Titles = ["Total Eliminated" "Total Counted" "Elimination Ratio"]';
    exportfile = strcat('MiniBatch Results','.xlsx');
    xlswrite(exportfile,Titles,'Sheet1','A1')
    xlswrite(exportfile,ECounter_Total,'Sheet1','B1')
    xlswrite(exportfile,TCounter_Total,'Sheet1','B2')
    xlswrite(exportfile,Ratio_Total,'Sheet1','B3')
    movefile('MiniBatch Results.xlsx','./DataPackage/MiniBatch Results.xlsx')
    
    %% Plot MinibatchTester Result
    figure
    subplot(2,2,1)
    plot(batchrange,ECounter_Total,'-o')
    xlabel('Minibatch')
    ylabel('Points Eliminated')
    title('Points Eliminated Vs. Minibatch')
    grid on
    subplot(2,2,2)
    plot(batchrange,TCounter_Total,'-o')
    xlabel('Minibatch')
    ylabel('Total number of steps')
    title('Total Steps Vs. Minibatch')
    grid on
    subplot(2,2,[3 4])
    plot(batchrange,Ratio_Total,'-o')
    grid on
    xlabel('Minibatch')
    ylabel('Ratio of eliminated over total points')
    title('Elimination Ratio Vs. Minibatch')
    set(gcf, 'Position', get(0, 'Screensize'));
    saveas(gcf,[pwd,sprintf('./DataPackage/Minibatch Results.png',Tablename(Trials))],'png')
    pause(1.5) % Make windows smoother
end

%% Prompt for Session Data Processor
clear button_result
prompt = 'Do you want to process Session Data?';
yesorno(prompt);
while ~exist('button_result','var')
pause(0.01)
end
close

if button_result == 1
    %% Record the Command Window
    diary(strcat('./DataPackage/','Readme.txt'))

    %% Manually set minibatches for both max and min scan
    clear Minibatch
    prompt = 'Please Enter the Minibatch Number';
    PleaseEnter(prompt)
    while ~exist('Minibatch','var')
    pause(0.01)
    end
    close
    Minibatch
    
    %% Ask for outlier elimination
    clear button_result
    prompt = 'Do you want to eliminate the outlier?';
    yesorno(prompt);
    while ~exist('button_result','var')
    pause(0.01)
    end
    close
    clear outliernum
    if button_result == 1
        prompt = 'Please Enter the Outlier Number';
        PleaseEnter(prompt)
        while ~exist('outliernum','var')
        pause(0.01)
        end
        close
    end
            

    %% Run Session Processor
    for Trials = 1:length(Tablenames)
        % Initiallization
        t_Max = [];
        LLM_X_Max = [];
        t_Min = [];
        LLM_X_Min = [];
        
        fprintf('Processing %s\n',Tablename(Trials))
        ECounter = 0; % Count the points being eliminated
        [LLM_X_Max,t_Max,t_Min,LLM_X_Min,ECounter,frames,LLM_X] = DataProcessor(Tname,Trials,Minibatch,ECounter);

        %% Plot coordinates vs. Frames
        Dataplot = figure;
        plot(t_Max,LLM_X_Max,'b*')
        hold on
        plot(t_Min,LLM_X_Min,'r*')
        hold on
        plot(frames,LLM_X)
        legend('Local Maxima','Local Minima','AutoUpdate','off')
        title(sprintf('%s LLM x-coordinate Vs. Frames',Tablename(Trials)))
        xlabel('Number of Frames')
        ylabel('x-coordinate (mm)')
        grid on

        %% Graphic User Interface to get missed points
        DataCoordCounter = 0;
        set(gcf,'currentchar','s')
        % Initialization
        DataCoord_Max = [];
        Approx.maxt = [];
        Approx.max = [];
        Approx.min = [];
        Approx.mint = [];        
        
        while true
            pause(0.5)
            clear button_result
            prompt = 'Mark Maxs and Mins?';
            
            yesorno(prompt)
            % Wait for the answer
            while ~exist('button_result','var')
            pause(0.01)
            end
            close
            
            if button_result == 0
                break
            end
            DataCoordCounter = DataCoordCounter + 1;
            datacursor=datacursormode;
            set(datacursor,'DisplayStyle','datatip','SnapToData','on','Enable','on');
            
            % For Maxma
            display('please click on Maxima')
            waitfor(Dataplot,'CurrentPoint')
            CursorInfo = getCursorInfo(datacursor);
            DataCoord_Max{DataCoordCounter} = CursorInfo.Position;
            hold on
            forplotmax = DataCoord_Max{DataCoordCounter};
            Coordindex = find(forplotmax(1)<frames,1);
            Approx.maxtrange = frames([Coordindex-25:Coordindex+25]);
            Approx.max(DataCoordCounter) = max(LLM_X(Approx.maxtrange));
            Approx.maxindex = find(LLM_X == Approx.max(DataCoordCounter));
            Approx.maxt(DataCoordCounter) = frames(Approx.maxindex);
            plot(Approx.maxt(DataCoordCounter),Approx.max(DataCoordCounter),'b*')
            
            % For Maxima
            display('please click on Minima')
            waitfor(Dataplot,'CurrentPoint')
            CursorInfo = getCursorInfo(datacursor);
            DataCoord_Min{DataCoordCounter}= CursorInfo.Position;
            hold on
            forplotmin = DataCoord_Min{DataCoordCounter};
            Coordindex = find(forplotmin(1)<frames,1);
            Approx.mintrange = frames([Coordindex-25:Coordindex+25]);
            Approx.min(DataCoordCounter) = min(LLM_X(Approx.mintrange));
            Approx.minindex = find(LLM_X == Approx.min(DataCoordCounter));
            Approx.mint(DataCoordCounter) = frames(Approx.minindex);
            plot(Approx.mint(DataCoordCounter),Approx.min(DataCoordCounter),'r*')
        end
        % Collect Point Data from GUI
        guimin{Trials} = Approx.min;
        guimint{Trials} = Approx.mint;
        guimax{Trials} = Approx.max;
        guimaxt{Trials} = Approx.maxt;
        saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s LLM x-coordinate Vs. Frames.png',Tablename(Trials))],'png')

        %% Add GUI data to process data
        for addition = 1:length(guimin{Trials})-1
            % For Max
            addindexmaxt = find(t_Max>guimaxt{Trials}(addition),1)-1;
            t_Max = [t_Max(1:addindexmaxt) guimax{Trials}(addition) t_Max(addindexmaxt:end)];
            LLM_X_Max = [LLM_X_Max(1:addindexmaxt) guimaxt{Trials}(addition) LLM_X_Max(addindexmaxt:end)];
            % For Min
            addindexmint = find(t_Min>guimint{Trials}(addition),1)-1;
            t_Min = [t_Min(1:addindexmint) guimin{Trials}(addition) t_Min(addindexmint:end)];
            LLM_X_Min = [LLM_X_Min(1:addindexmint) guimint{Trials}(addition) LLM_X_Min(addindexmint:end)];
        end
        
        %% Calculate for Displacement
        Displacement{Trials} = LLM_X_Max-LLM_X_Min;

        %% Eliminate small extreme outliers
        if exist('outliernum','var') == 1
            Outlier = find(Displacement{Trials}<=outliernum);
            t_Max(Outlier) = [];
            LLM_X_Max(Outlier) = [];
            t_Min(Outlier) = [];
            LLM_X_Min(Outlier) = [];
            Displacement{Trials} = LLM_X_Max-LLM_X_Min;
        end
        
        %% Process Displacement
        Dis_Mean{Trials} = mean(Displacement{Trials});
        Dis_Std{Trials} = std(Displacement{Trials});
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
    exportfile = strcat('DataPackage/','MB',num2str(Minibatch),Sessionnumber,'DataTable','.xlsx');
    xlswrite(exportfile,[Session_Array,Trial_Array,Step_Array,MLD_Array],'Sheet1','A2')
    xlswrite(exportfile,["Session","Trial","Step","ML_Displacement"],'Sheet1','A1')

    movefile('DataPackage',strcat(Sessionnumber,'DataPackage')) % Rename the Package
end


%% DataProcessor Function
function [LLM_X_Max,t_Max,t_Min,LLM_X_Min,ECounter,frames,LLM_X] = DataProcessor(Tname,Trials,Minibatch,ECounter)
    %% Loop for the section
        Rawdata = readtable(Tname(Trials));

        %% Create Time Vector
        frames = 1:length(Rawdata.('LLM'))-1;

        %% Left Lateral Malleolus
        Rawdata_LLM = Rawdata.('LLM');
        % Flip negative displacement values to positive
        LLM_X = abs(str2double(Rawdata_LLM(2:end))');
        LLM_X_Max_index = islocalmax(LLM_X,'MinSeparation',Minibatch,'SamplePoints',frames);
        LLM_X_Min_index = islocalmin(LLM_X,'MinSeparation',Minibatch,'SamplePoints',frames);
        % Eliminate repeating min values and time frames
        t_Min = unique(frames(LLM_X_Min_index));
        LLM_X_Min = unique(LLM_X(LLM_X_Min_index));
        t_Max = frames(LLM_X_Max_index);
        LLM_X_Max = LLM_X(LLM_X_Max_index);

        %% Eliminate the first max data if max goes first
        First = find(t_Max<t_Min(1));
        t_Max(First) = [];
        LLM_X_Max(First) = [];

        %% If multiple mins between maxs, eliminate them and leave the last one
        if max(t_Max)<max(t_Min)
            t_Minnew = [];
            for p = 1:length(t_Max)
                minindex = find(t_Min>t_Max(p),1);
                t_Minnew(p) = t_Min(minindex-1);
            end
            t_Min = t_Minnew;
            LLM_X_Min = LLM_X(t_Min);
        elseif max(t_Max)>max(t_Min)
            t_Minnew = [];
            for p = 1:length(t_Max)-1
                minindex = find(t_Min>t_Max(p),1);
                t_Minnew(p) = t_Min(minindex-1);
            end
            t_Min = [t_Minnew t_Min(minindex)];
            LLM_X_Min = LLM_X(t_Min);
        end
        t_Min = unique(t_Min,'stable');
        LLM_X_Min = unique(LLM_X_Min,'stable');

        %% If multiple maxs, eliminate them and leave the last one
        for maxindex = 1:length(t_Min)
            if t_Min(maxindex)>t_Max(maxindex)
                t_Max(maxindex) = [];
                LLM_X_Max(maxindex) = [];
                ECounter = ECounter+1;
            end
        end

    %% Find length difference and elinminate extra Max
    if length(LLM_X_Max)-length(LLM_X_Min) > 0
        LLM_X_Max = LLM_X_Max(1:end-1);
        t_Max = t_Max(1:end-1);
    end
end

%% UI control functions
function yesorno(prompt)
newfigure = figure;
newfigure.Position = [500 350 600 300];

% Create three radio buttons in the button group.
button_yes = uicontrol(newfigure,'Style','pushbutton',...
                  'String','Yes',...
                  'FontSize',12,...
                  'Position',[50 50 200 100],...
                  'Callback',@button_yes_callback);
              
              
button_no = uicontrol(newfigure,'Style','pushbutton',...
                  'String','No',...
                  'FontSize',12,...
                  'Position',[350 50 200 100],...
                  'Callback',@button_no_callback);

headline = uicontrol(newfigure,'Style','text',...
                  'String',prompt,...
                  'Position',[0 200 600 30],...
                  'FontSize',12,...
                  'HorizontalAlignment','Center',...
                  'HandleVisibility','off');

% Button Callback Functions
function button_yes_callback(hObject,eventdata,handles)
button = 1;
assignin('base','button_result',button)
end

function hObject = button_no_callback(hObject,eventdata,handels)
button = 0;
assignin('base','button_result',button)
end
end

function PleaseEnter(prompt)
newfigure = figure;
newfigure.Position = [500 350 600 300];
Enterbutton = uicontrol(newfigure,'Style','pushbutton',...
                  'String','Enter',...
                  'FontSize',12,...
                  'Position',[325 50 180 100]);
              
Minibatchbox = uicontrol(newfigure,'Style','edit',...
                  'FontSize',12,...
                  'Position',[100 50 200 100],...
                  'Callback',@editorcallback);

headline = uicontrol(newfigure,'Style','text',...
                  'String',prompt,...
                  'Position',[0 200 600 30],...
                  'FontSize',12,...
                  'HorizontalAlignment','Center',...
                  'HandleVisibility','off');

% Button Callback Functions
function hObject = editorcallback(hObject,eventdata,handels)
button = str2double(get(Minibatchbox, 'String'));
assignin('base','Minibatch',button)
assignin('base','outliernum',button)
end
end

function ForMB(prompt)
newfigure = figure;
newfigure.Position = [500 350 600 300];
Stepsizebox = uicontrol(newfigure,'Style','edit',...
                  'FontSize',12,...
                  'Position',[300 60 100 50],...
                  'Callback',@Stepsizebox_callback);

Stepsizeboxs = uicontrol(newfigure,'Style','text',...
                  'String','Stepsize:',...
                  'FontSize',12,...
                  'Position',[180 45 100 50]);
              
Minbox = uicontrol(newfigure,'Style','edit',...
                  'FontSize',12,...
                  'Position',[300 120 100 50],...
                  'Callback',@Minbox_callback);
              
Minboxs = uicontrol(newfigure,'Style','text',...
                  'String','Min:',...
                  'FontSize',12,...
                  'Position',[180 105 100 50]);

Maxbox = uicontrol(newfigure,'Style','edit',...
                  'FontSize',12,...
                  'Position',[300 180 100 50],...
                  'Callback',@Maxbox_callback);
              
Maxboxs = uicontrol(newfigure,'Style','text',...
                  'String','Max:',...
                  'FontSize',12,...
                  'Position',[180 165 100 50]);

headline = uicontrol(newfigure,'Style','text',...
                  'String',prompt,...
                  'Position',[0 250 600 30],...
                  'FontSize',12,...
                  'HorizontalAlignment','Center',...
                  'HandleVisibility','off');

Enterbutton = uicontrol(newfigure,'Style','pushbutton',...
                  'String','Enter',...
                  'FontSize',12,...
                  'Position',[450 120 100 50]);
              

% Button Callback Functions
function Stepsizebox_callback(hObject,eventdata,handles)
    dM = str2double(get(Stepsizebox, 'String'));
    assignin('base','dM',dM);
end

function hObject = Minbox_callback(hObject,eventdata,handels)
lob = str2double(get(Minbox, 'String'));
assignin('base','lob',lob)
end

function hObject = Maxbox_callback(hObject,eventdata,handels)
upb = str2double(get(Maxbox, 'String'));
assignin('base','upb',upb)
end
end