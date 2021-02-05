clear
close all
clc

%% Import Data and Create Folder
Rawdata = readtable('Trial03.csv');
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
figure
subplot(2,1,1)
plot(t,LLM_X)
xlabel('Time(s)')
ylabel('Frontal Plane Displacement(cm)')
title('tDCS05 LLM Distance Vs. Time')
subplot(2,1,2)
P2 = abs(ftLLM_X/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f,P1)
xlim([0 5])
ylim([0 20])
xlabel('Frequency')
ylabel('Integration of Displacement')
title('tDCS05 LLM intergrated Distance Vs. Frequency')


figure
subplot(2,1,1)
plot(t,RLM_X)
xlabel('Time(s)')
ylabel('Frontal Plane Displacement(cm)')
title('tDCS05 RLM Distance Vs. Time')
subplot(2,1,2)
ftRLM_X = fft(RLM_X);
P2 = abs(ftRLM_X/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f,P1)
xlim([0 5])
ylim([0 20])
xlabel('Frequency')
ylabel('Integration of Displacement')
title('tDCS05 RLM intergrated Distance Vs. Frequency')

Transformed = real(fft(LLM_X));
figure
subplot(2,1,1)
plot(frames,LLM_X)
subplot(2,1,2)
periodogram(LLM_X,hamming(length(LLM_X)),[],Fs,'centered','power')
ylim([0 20])
xlim([0 10])

Transformed = real(fft(RLM_X));
figure
subplot(2,1,1)
plot(frames,RLM_X)
subplot(2,1,2)
periodogram(RLM_X,hamming(length(RLM_X)),[],Fs,'centered','power')
xlim([0 10])
ylim([0 20])