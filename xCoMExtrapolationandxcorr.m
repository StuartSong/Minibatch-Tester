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
    VRTime = VRRawdata.Time;
    VRTime = VRTime-VRTime(1);
    ViconLLM_X = ViconRawdata.LLM;
    ViconRLM_X = ViconRawdata.RLM;
    XCOM_X = VRRawdata.XCoM_PosX;
    DTimeindex = round(linspace(1,length(VRTime),length(ViconTime)));
    DTime = VRTime(DTimeindex);
    DXCOM_X = XCOM_X(DTimeindex);
    
    figure
    subplot(2,1,1)
    crosscorr(ViconLLM_X,DXCOM_X,length(ViconTime)-1)
    title('Left Leg CCF Vs. Time Lag')
    subplot(2,1,2)
    crosscorr(ViconRLM_X,DXCOM_X,length(ViconTime)-1)
    title('Right Leg CCF Vs. Time Lag')
    saveas(gcf,[pwd,sprintf('./DataPackage/Figures/%s Cross Correlation Vs. lag.png',ViconTablename(Trials))],'png')
    
    [LLMxcf,LLMlags,LLMbounds] = crosscorr(ViconLLM_X,DXCOM_X,length(ViconTime)-1);
    [LLMMaxxcf(Trials),LLMmaxxcfindex] = max(abs(LLMxcf));
    LLMmaxxcflag = LLMlags(LLMmaxxcfindex);
    LLMmaxxcflagtime(Trials) = VRTime(end)*LLMmaxxcflag/length(ViconTime);
    
    [RLMxcf,RLMlags,RLMbounds] = crosscorr(ViconRLM_X,DXCOM_X,length(ViconTime)-1);
    [RLMMaxxcf(Trials),RLMmaxxcfindex] = max(abs(RLMxcf));
    RLMmaxxcflag = RLMlags(RLMmaxxcfindex);
    RLMmaxxcflagtime(Trials) = VRTime(end)*RLMmaxxcflag/length(ViconTime);
    
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