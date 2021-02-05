clear
close all
clc

rawdata = readtable('Sample.xlsx');
timeVicon =  rmmissing(rawdata.Time_s_);
LLMX = rmmissing(rawdata.LLM_PosX);
RLMX = -rmmissing(rawdata.RLM_PosX);
timeVR = rawdata.Time0onward;
xCoM = rawdata.XCoM_PosX;

%% MATLAB 1-D function data interpolation
Extrapolation = linspace(0,length(timeVR),length(timeVR));
TimeRangeNew = linspace(0,length(timeVR),length(timeVicon));
extrapotime = Extrapolation*timeVR(end)/length(timeVR);

    %% Left leg
    interpLLMX = interp1(TimeRangeNew,LLMX,Extrapolation)';

    figure
    plot(TimeRangeNew,LLMX,'.')
    hold on
    plot(Extrapolation,interpLLMX)
    title('MATLAB 1-D function data interpolation (Left Leg)')
    legend('Original Data','Interpolation Line')

    [xCorrLLMX,xCorrLLMXlag] = xcorr(interpLLMX,xCoM);
    [maxxCorrLLMX,maxindex] = max(xCorrLLMX);
    maxxCorrLLMXlag = xCorrLLMXlag(maxindex);
    maxxCorrLLMXlaginseconds = maxxCorrLLMXlag/length(timeVR)*timeVR(end);
    fprintf('Max x-corr between Left leg and xCoM is %2.3f with %2.3f seconds \n',maxxCorrLLMX,maxxCorrLLMXlaginseconds)
    figure
    plot(xCorrLLMXlag,xCorrLLMX)
    hold on
    plot(maxxCorrLLMXlag,maxxCorrLLMX,'*')
    title('Interpolated Left and xCoM Correlation Vs. Time(data points) Lag')
    
    %% Right leg
    interpRLMX = interp1(TimeRangeNew,RLMX,Extrapolation)';

    figure
    plot(TimeRangeNew,RLMX,'.')
    hold on
    plot(Extrapolation,interpRLMX)
    title('MATLAB 1-D function data interpolation (Right Leg)')
    legend('Original Data','Interpolation Line')

    [xCorrRLMX,xCorrLLMXlag] = xcorr(interpRLMX,xCoM);
    [maxxCorrRLMX,maxindex] = max(xCorrRLMX);
    maxxCorrRLMXlag = xCorrLLMXlag(maxindex);
    maxxCorrRLMXlaginseconds = maxxCorrRLMXlag/length(timeVR)*timeVR(end);
    fprintf('Max x-corr between Right leg and xCoM is %2.3f with %2.3f seconds \n',maxxCorrRLMX,maxxCorrRLMXlaginseconds)
    figure
    plot(xCorrLLMXlag,xCorrRLMX)
    hold on
    plot(maxxCorrRLMXlag,maxxCorrRLMX,'*')
    title('Interpolated Right and xCoM Correlation Vs. Time(data points) Lag')
    
%% Data DownScale
downscaletime = round(linspace(1,length(timeVR),length(timeVicon)));
timeVRds = timeVR(downscaletime);
xCoMds = xCoM(downscaletime);
[dsxCorrLLMX,dsxCorrLLMXlag] = xcorr(LLMX,xCoMds);
% [value,lags,bounds] = crosscorr(LLMX,xCoMds);
[maxdsxCorrLLMX,maxdsxCorrLLMXindex] = max(dsxCorrLLMX);
maxdsxCorrRLMXlaginseconds = dsxCorrLLMXlag/length(timeVR);
fprintf('Max x-corr between Left leg and xCoM is %2.3f with %2.3f seconds \n',maxdsxCorrLLMX,maxxCorrRLMXlaginseconds)

figure
plot(dsxCorrLLMXlag,dsxCorrLLMX)
hold on
plot(maxdsxCorrLLMX)


figure
crosscorr(LLMX,xCoMds)

