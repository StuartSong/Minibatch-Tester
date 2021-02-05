clear
close all
clc
warning off

%% Import Data and Create Folder
Names = dir('**/*.csv');
Tablenames = {Names.name};
Tname = string(Tablenames);
Tablename = erase(Tname,'.csv');
currentFolder = pwd;
[filepath,Sessionnumber] = fileparts(currentFolder);

figure(1)
suptitle(strcat("tDCS05 LLM ",Sessionnumber,"Frontal Plane Displacement Vs. Frequency"))
figure(2)
suptitle(strcat("tDCS05 RLM ",Sessionnumber,"Frontal Plane Displacement Vs. Frequency"))

for Trials = 1:length(Tablenames)
    %% Import Data and Create Folder
    Rawdata = readtable(Tname(Trials));
    Rawdata_RLM = Rawdata.('RLM');
    RLM_X = abs(Rawdata_RLM(2:end)');
    Rawdata_LLM = Rawdata.('LLM');
    LLM_X = abs(Rawdata_LLM(2:end)');
    frames = 1:length(Rawdata.('RLM'))-1;
    Fs = 100;
    T = 1/Fs;
    L = length(frames);
    t = (0:L-1)*T;
    ftLLM_X = fft(LLM_X);
    
    %% LLM
    figure(1)
    subplot(length(Tablenames),1,Trials)
    P2LLM = abs(ftLLM_X/L);
    P1LLM = P2LLM(1:L/2+1);
    P1LLM(2:end-1) = 2*P1LLM(2:end-1);
    f = Fs*(0:(L/2))/L;
    plot(f,P1LLM)
    xlim([0 5])
    xticks(0:1:5)
    ylim([0 30])
    xlabel('Frequency(Hz)')
    ylabel('Displacement(mm)')
    
    % Center of Mass
    index = f<5&f>0.1;
    f = f(index);
    P1LLM = P1LLM(index);
    h = f(2)-f(1);
    l1 = P1LLM(1:end-1);
    l2 = P1LLM(2:end);
    SingleArea = (l1+l2)*h/2;
    xbar = [];
    for tp = 1:length(l1)
        if l1(tp)<l2(tp)
            a = l1(tp);
            b = l2(tp);
            xbar(tp) = h-(b+2*a)*h/(3*(a+b))+f(tp);
        else
            a = l2(tp);
            b = l1(tp);
            xbar(tp) = ((b+2*a)*h/(3*(a+b)))+f(tp);
        end
    end
    XCOMLLM(Trials) = sum(SingleArea.*xbar)/sum(SingleArea);
    
    
    %% RLM
    figure(2)
    subplot(length(Tablenames),1,Trials)
    ftRLM_X = fft(RLM_X);
    P2RLM = abs(ftRLM_X/L);
    P1RLM = P2RLM(1:L/2+1);
    P1RLM(2:end-1) = 2*P1RLM(2:end-1);
    f = Fs*(0:(L/2))/L;
    plot(f,P1RLM)
    xlim([0 5])
    xticks(0:1:5)
    ylim([0 30])
    xlabel('Frequency(Hz)')
    ylabel('Displacement(mm)')
    
    index = f<5&f>0.1;
    f = f(index);
    P1RLM = P1RLM(index);
    h = f(2)-f(1);
    l1 = P1RLM(1:end-1);
    l2 = P1RLM(2:end);
    SingleArea = (l1+l2)*h/2;
    xbar = [];
    for tp = 1:length(l1)
        if l1(tp)<l2(tp)
            a = l1(tp);
            b = l2(tp);
            xbar(tp) = h-(b+2*a)*h/(3*(a+b))+f(tp);
        else
            a = l2(tp);
            b = l1(tp);
            xbar(tp) = ((b+2*a)*h/(3*(a+b)))+f(tp);
        end
    end
    XCOMRLM(Trials) = sum(SingleArea.*xbar)/sum(SingleArea);
end
XCOMLLM
XCOMRLM