clear
close all
clc
warning('off','all')

%% Session number
currentFolder = pwd;
[filepath,Sessionnumber] = fileparts(currentFolder);

%% Import Data and Create Folder
mkdir DataPackage;
mkdir DataPackage\Figures;

ViconNames = dir('*.csv');
ViconTablenames = {ViconNames.name};
ViconTname = string(ViconTablenames);
ViconTablename = erase(ViconTname,'.csv');

VRNames = dir('*.txt');
VRTablenames = {VRNames.name};
VRTname = string(VRTablenames);
VRTablename = erase(VRTname,'.txt');

%% Record the Command Window
diary(strcat('./DataPackage/','Readme.txt'))

%% Loop for the section
for Trials = 1:length(ViconTablenames)
    ViconRawdata = readtable(ViconTname(Trials));
    VRRawdata = readtable(VRTname(Trials));
    ViconTime = ViconRawdata.Var1;
    VRTime = VRRawdata.Time*100;
    VRTime = VRTime-VRTime(1);
    ViconLLM_X = ViconRawdata.LLM;
    ViconRLM_X = ViconRawdata.RLM;
    XCOM_X = VRRawdata.XCoM_PosX;
    DTimeindex = round(linspace(1,length(VRTime),length(ViconTime)));
    DTime = VRTime(DTimeindex);
    DXCOM_X = XCOM_X(DTimeindex);
    
    %% Syncing Process
    VRLLMvert = VRRawdata.LLMvert*1000;
    DVRLLMvert = VRRawdata.LLMvert(DTimeindex)*1000;
    Viconvert = ViconRawdata.Var16;
    DTimeSync = DTime;
    
    % lag beteween second peaks VR-Vicon
    [DVRLLMvertmax,DVRLLMvertmaxindex] = max(DVRLLMvert);
    DVRLLMvertmaxindex = islocalmax(DVRLLMvert,'MinSeparation',200,'SamplePoints',DTimeSync);
    DVRLLMvertmax = DVRLLMvert(DVRLLMvertmaxindex);
    DVRLLMvertmaxtime = DTimeSync(DVRLLMvertmaxindex);
    SecondMaxPeak = DVRLLMvertmax(2);
    SecondMaxPeakTime = DVRLLMvertmaxtime(2);
    SecondMaxPeakTimeIndex = round(SecondMaxPeakTime);
    SecondMaxPeakTimeWindow = [SecondMaxPeakTimeIndex-80:SecondMaxPeakTimeIndex+80];
    SecondMaxPeakSync = max(Viconvert(SecondMaxPeakTimeWindow));
    SecondMaxPeakSyncTimeIndex = find(Viconvert==SecondMaxPeakSync);
    SyncTimeLag = SecondMaxPeakTimeIndex-SecondMaxPeakSyncTimeIndex;
    
    figure
    plot(DTimeSync,DVRLLMvert);
    hold on
    plot(ViconTime,Viconvert)
    hold on
    plot(SecondMaxPeakTime,SecondMaxPeak,'*')
    title('Before Syncing')
    legend('VR Data','Vicon Data','SecondMaxPeak')
    
    if SyncTimeLag>0
        DTimeSync(end-SyncTimeLag+1:end)=[];
        DVRLLMvert([1:SyncTimeLag])=[];
    else
        ViconTime(end+SyncTimeLag+1:end)=[];
        Viconvert([1:-SyncTimeLag])=[];
    end
    
    figure
    plot(DTimeSync,DVRLLMvert);
    hold on
    plot(ViconTime,Viconvert)
    title('After Syncing')
    legend('VR Data','Vicon Data')
    
    %% Cross Correlation
    ratio = 1/30; % Set a ratio here
    
    % Left leg Time lag of VR-Vicon (crosscorr)
    [LLMxcf,LLMlags,LLMbounds] = crosscorr(ViconLLM_X,DXCOM_X,length(ViconTime)-1);
    LLMxcfpartial = LLMxcf(round((1-ratio)*length(LLMxcf)/2):end-round((1-ratio)*length(LLMxcf)/2));
    LLMlagspartial = LLMlags(round((1-ratio)*length(LLMlags)/2):end-round((1-ratio)*length(LLMlags)/2));
    [LLMMaxxcfabs,LLMmaxxcfindex] = max(abs(LLMxcfpartial));
    LLMmaxxcflag = LLMlagspartial(LLMmaxxcfindex);
    LLMMaxxcf(Trials) = LLMxcfpartial(LLMmaxxcfindex);
    LLMmaxxcflagtime(Trials) = VRTime(end)*LLMmaxxcflag/length(ViconTime);
    
    % Right leg Time lag of VR-Vicon (crosscorr)
    [RLMxcf,RLMlags,RLMbounds] = crosscorr(ViconRLM_X,DXCOM_X,length(ViconTime)-1);
    RLMxcfpartial = RLMxcf(round((1-ratio)*length(RLMxcf)/2):end-round((1-ratio)*length(RLMxcf)/2));
    RLMlagspartial = RLMlags(round((1-ratio)*length(RLMlags)/2):end-round((1-ratio)*length(RLMlags)/2));
    [RLMMaxxcfabs,RLMmaxxcfindex] = max(abs(RLMxcfpartial));
    RLMmaxxcflag = RLMlagspartial(RLMmaxxcfindex);
    RLMMaxxcf(Trials) = RLMxcfpartial(RLMmaxxcfindex);
    RLMmaxxcflagtime(Trials) = VRTime(end)*RLMmaxxcflag/length(ViconTime);
    
    % Time lag of VR-Vicon (Sync by Second Peak)
    SyncTimeLagConvert(Trials) = SyncTimeLag/length(DTime)*VRTime(end);
    
    figure
    subplot(2,1,1)
    crosscorr(ViconLLM_X,DXCOM_X,length(ViconTime)-1)
    hold on
    maxccfplot = plot(LLMmaxxcflag,LLMMaxxcf(Trials),'b*');
    legend(maxccfplot,'Max CCF')
    title('Left Leg CCF Vs. Time Lag')
    subplot(2,1,2)
    crosscorr(ViconRLM_X,DXCOM_X,length(ViconTime)-1)
    hold on
    maxccfplot = plot(RLMmaxxcflag,RLMMaxxcf(Trials),'b*');
    legend(maxccfplot,'Max CCF')
    title('Right Leg CCF Vs. Time Lag')
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s Cross Correlation Vs. lag.png',ViconTablename(Trials))],'png')
    
    fprintf('%s has Left leg CCF %2.3f with time lag %3.3f\n',ViconTablename(Trials),LLMMaxxcf(Trials),LLMmaxxcflagtime(Trials))
    fprintf('%s has Right leg CCF %2.3f with time lag %3.3f\n',ViconTablename(Trials),RLMMaxxcf(Trials),RLMmaxxcflagtime(Trials))
end

diary off

figure
plot(1:Trials,LLMMaxxcf,'-o',1:Trials,RLMMaxxcf,'-o')
xticks(0:1:Trials+1)
xlim([0 Trials+1])
grid on
legend('Left Leg','Right Leg')
title('Cross Correlation Function Vs. Trial numbers')
xlabel('Trial Numbers (Not Actual Trial Number)')
ylabel('Cross Correlation Function')
saveas(gcf,[pwd,sprintf('./DataPackage/Figures/Overall Cross Correlation Vs. lag.png')],'png')

exportfile = strcat('DataPackage/',Sessionnumber,'DataTable','.xlsx');
xlswrite(exportfile,["LLMCCF","LLM Time Lag","RLMCCF","RLM Time Lag"],'Sheet1','A1')
xlswrite(exportfile,[LLMMaxxcf' LLMmaxxcflagtime' RLMMaxxcf' RLMmaxxcflagtime'],'Sheet1','A2')

movefile('DataPackage',strcat(Sessionnumber,'DataPackage')) % Rename the Package