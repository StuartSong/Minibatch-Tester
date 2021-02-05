clear
close all
clc

%% Import Data
Names = dir('**/*.csv');
Tablenames = {Names.name};
Tname = string(Tablenames);

%% Manually set minibatches for both max and min scan
upb = 170;
lob = 80;
dM = 5;
batchrange = [lob:dM:upb];

for Minibatch = batchrange;
    Minibatch
    batchorder = Minibatch/dM-(lob/dM-1);

%% Empty Existed Values
ECounter = 0; % Count the points being eliminated
Displacement = {};

    %% Loop for the section
    for Trials = 1:length(Tablenames)
        Rawdata = readtable(Tname(Trials));

        %% Create Time Vector
        frames = 1:length(Rawdata.('LLM'))-1;

        %% Right Lateral Malleolus
        Rawdata_RLM = Rawdata.('RLM');
        % Flip negative displacement values to positive
        RLM_X = abs(str2double(Rawdata_RLM(2:end))');
        RLM_X_Max_index = islocalmax(RLM_X,'MinSeparation',Minibatch,'SamplePoints',frames);
        RLM_X_Min_index = islocalmin(RLM_X,'MinSeparation',Minibatch,'SamplePoints',frames);
        % Eliminate repeating min values and time frames
        t_Min = unique(frames(RLM_X_Min_index));
        RLM_X_Min = unique(RLM_X(RLM_X_Min_index));
        t_Max = frames(RLM_X_Max_index);
        RLM_X_Max = RLM_X(RLM_X_Max_index);

        %% Eliminate the first max data if max goes first
        First = find(t_Max<t_Min(1));
        t_Max(First) = [];
        RLM_X_Max(First) = [];

        %% If multiple mins between maxs, eliminate them and leave the last one
        if max(t_Max)<max(t_Min)
            t_Minnew = [];
            for p = 1:length(t_Max)
                minindex = find(t_Min>t_Max(p),1);
                t_Minnew(p) = t_Min(minindex-1);
            end
            t_Min = t_Minnew;
            RLM_X_Min = RLM_X(t_Min);
        elseif max(t_Max)>max(t_Min)
            t_Minnew = [];
            for p = 1:length(t_Max)-1
                minindex = find(t_Min>t_Max(p),1);
                t_Minnew(p) = t_Min(minindex-1);
            end
            t_Min = [t_Minnew t_Min(minindex)];
            RLM_X_Min = RLM_X(t_Min);
        end
        t_Min = unique(t_Min,'stable');
        RLM_X_Min = unique(RLM_X_Min,'stable');

        %% If multiple maxs, eliminate them and leave the last one
        for maxindex = 1:length(t_Min)
            if t_Min(maxindex)>t_Max(maxindex)
                t_Max(maxindex) = [];
                RLM_X_Max(maxindex) = [];
                ECounter = ECounter+1;
            end
        end

    %% Find length difference and elinminate extra Max
    if length(RLM_X_Max)-length(RLM_X_Min) > 0
        RLM_X_Max = RLM_X_Max(1:end-1);
        t_Max = t_Max(1:end-1);
    end
    Displacement{Trials} = RLM_X_Max-RLM_X_Min;
    
    %% Eliminate the outlier
    Outlier = find(Displacement{Trials}<=20);
    t_Max(Outlier) = [];
    RLM_X_Max(Outlier) = [];
    t_Min(Outlier) = [];
    RLM_X_Min(Outlier) = [];
    Displacement{Trials} = RLM_X_Max-RLM_X_Min;
    end

    %% X-axis Displacement
    Dis_Cell = Displacement;
    Displacement = cell2mat(Displacement);

    %% Steps Eliminated and Total Steps
    TCounter = length(Displacement); % Total steps detected
    Ratio = ECounter/TCounter;
    ECounter_Total(batchorder) = ECounter;    
    TCounter_Total(batchorder) = TCounter;
    Ratio_Total(batchorder) = ECounter/TCounter;
end

%% Export Data into Excel
Titles = ["Total Eliminated" "Total Counted" "Elimination Ratio"]';
exportfile = strcat('MiniBatch Results','.xlsx');
xlswrite(exportfile,Titles,'Sheet1','A1')
xlswrite(exportfile,ECounter_Total,'Sheet1','B1')
xlswrite(exportfile,TCounter_Total,'Sheet1','B2')
xlswrite(exportfile,Ratio_Total,'Sheet1','B3')

%% Plot Data
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
saveas(gcf,[pwd,sprintf('./MiniBatch Results.png')],'png')
