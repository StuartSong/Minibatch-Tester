clear
close all
clc

%% Import Data and Create Folder
Names = dir('**/*.csv');
Tablenames = {Names.name};
Tname = string(Tablenames);
Tablename = erase(Tname,'.csv');

figure(1)
suptitle('tDCS05 LLM Session 14 Frontal Plane Displacement Vs. Frequency')
figure(2)
suptitle('tDCS05 RLM Session 14 Frontal Plane Displacement Vs. Frequency')

for Trials = 1:length(Tablenames)
    %% Import Data and Create Folder
    Rawdata = readtable(Tname(Trials));
    Rawdata_RLM = Rawdata.('RLM');
    RLM_X = abs(str2double(Rawdata_RLM(2:end))');
    Rawdata_LLM = Rawdata.('LLM');
    LLM_X = abs(str2double(Rawdata_LLM(2:end))');
    frames = 1:length(Rawdata.('RLM'))-1;
    
    
    
    Fs = 100;
    T = 1/Fs;
    L = length(frames);
    t = (0:L-1)*T;
    ftLLM_X = fft(LLM_X);

    figure(1)
    subplot(length(Tablenames),1,Trials)
    periodogram(LLM_X,hamming(length(LLM_X)),[],Fs,'centered','power')
%     
%     
%     P2 = abs(ftLLM_X/L);
%     P1 = P2(1:L/2+1);
%     P1(2:end-1) = 2*P1(2:end-1);
%     f = Fs*(0:(L/2))/L;
%     plot(f,P1)
%     xlim([0 5])
%     ylim([0 20])
    xlabel('Frequency(Hz)')
    ylabel('Displacement(mm)')
%     title(sprintf('%s',Tablename(Trials)))


    figure(2)
    subplot(length(Tablenames),1,Trials)
    periodogram(RLM_X,hamming(length(RLM_X)),[],Fs,'centered','power')
    
%     ftRLM_X = fft(RLM_X);
%     P2 = abs(ftRLM_X/L);
%     P1 = P2(1:L/2+1);
%     P1(2:end-1) = 2*P1(2:end-1);
%     f = Fs*(0:(L/2))/L;
%     plot(f,P1)
%     xlim([0 5])
%     ylim([0 20])
    xlabel('Frequency(Hz)')
    ylabel('Displacement(mm)')
%     title(sprintf('%s',Tablename(Trials)))
end
% 
% Transformed = real(fft(LLM_X));
% figure
% subplot(2,1,1)
% plot(frames,LLM_X)
% subplot(2,1,2)
% periodogram(LLM_X,hamming(length(LLM_X)),[],Fs,'centered','power')
% 
% Transformed = real(fft(RLM_X));
% figure
% subplot(2,1,1)
% plot(frames,RLM_X)
% subplot(2,1,2)
% periodogram(RLM_X,hamming(length(RLM_X)),[],Fs,'centered','power')