close all
clear;
clc

Rawdata = readtable('tDCS08 Obstacle.xlsx');
Headlines = string(Rawdata.Properties.VariableNames);
Legindex = find(contains(Headlines,"Var"));
Leftleg = Headlines([1:Legindex-1]);
Rightleg = Headlines([Legindex+1:end]);
[filepath,Subject] = fileparts(pwd);
filename = strcat(Subject,' Obstacle ANOVA Minitab');

%% Compare for the minimum maximum steps within the subject
Stepindex = Headlines(find(contains(Headlines,"Step")));
for steps = 1:length(Stepindex)
    countarray = histcount(Rawdata.(Stepindex(steps)));
    minsteps = 1;
    while countarray(minsteps) == max(countarray)
       minsteps =  minsteps+1;
       if minsteps-1 == length(countarray)
           break
       end
    end
    minsteps =  minsteps-1;
    Compare(steps) = minsteps;
end
minstep = min(Compare)


%% Left leg
LLStepHindex = Leftleg(find(contains(Leftleg,"Step")));
LLDisHindex = Leftleg(find(contains(Leftleg,"Displacement")));
LLTotalDis = [];
LLTotalTrials = [];
LLTotalSessions = [];
for Sessions = 1:length(LLDisHindex)
    CurrentDis = Rawdata.(LLDisHindex(Sessions));
    LLind = find(Rawdata.(LLStepHindex(Sessions)) == minstep);
    LLDis = [];
    LLTrials = [];
    LLSessions = [];
    for LLindex = 1:length(LLind)
        LLDis = [LLDis;CurrentDis([LLind(LLindex)-minstep+1:LLind(LLindex)])];
        LLTrials = [LLTrials;repmat(LLindex,minstep,1)];
        LLSessions = [LLSessions;repmat(Sessions,minstep,1)];
    end
    LLTotalDis = [LLTotalDis;LLDis];
    LLTotalTrials = [LLTotalTrials;LLTrials];
    LLTotalSessions = [LLTotalSessions;LLSessions];
end

%% Right leg
RLStepHindex = Rightleg(find(contains(Rightleg,"Step")));
RLDisHindex = Rightleg(find(contains(Rightleg,"Displacement")));
RLTotalDis = [];
RLTotalTrials = [];
RLTotalSessions = [];
for Sessions = 1:length(RLDisHindex)
    CurrentDis = Rawdata.(RLDisHindex(Sessions));
    RLind = find(Rawdata.(RLStepHindex(Sessions)) == minstep);
    RLDis = [];
    RLTrials = [];
    RLSessions = [];
    for RLindex = 1:length(RLind)
        RLDis = [RLDis;CurrentDis([RLind(RLindex)-minstep+1:RLind(RLindex)])];
        RLTrials = [RLTrials;repmat(RLindex,minstep,1)];
        RLSessions = [RLSessions;repmat(Sessions,minstep,1)];
    end
    RLTotalDis = [RLTotalDis;RLDis];
    RLTotalTrials = [RLTotalTrials;RLTrials];
    RLTotalSessions = [RLTotalSessions;RLSessions];
end

xlswrite(filename,["Subject" "Session" "Trial" "Leg" "MLdisp"],'Sheet1','A1')
xlswrite(filename,[repmat(string(Subject),length(LLTotalDis),1);repmat(string(Subject),length(RLTotalDis),1)],'Sheet1','A2')
xlswrite(filename,[LLTotalSessions;LLTotalSessions],'Sheet1','B2')
xlswrite(filename,[LLTotalTrials;RLTotalTrials],'Sheet1','C2')
xlswrite(filename,[repmat("Left",length(LLTotalDis),1);repmat("Right",length(RLTotalDis),1)],'Sheet1','D2')
xlswrite(filename,[LLTotalDis;RLTotalDis],'Sheet1','E2')

function [number] = histcount(series)
    for i = 1:max(series)
        count = length(find(series == i));
        number(i) = count;
    end
end