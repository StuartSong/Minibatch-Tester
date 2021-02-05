close all
clear
clc

Names = dir('*.txt');
Tablenames = {Names.name};
Tname = string(Tablenames);
Tablename = erase(Tname,'.txt');
Numbers = length(Tablename)/2;

for Trials = 1:Numbers
    VRdata = readtable(Tname(Trials));
    Vicondata = readtable(Tname(Trials+Numbers));
    
    VRLLM = VRdata.LLMvert';
    XCoM_LLM = VRdata.XCoM_PosX;
    ViconLLM = Vicondata.LLM_PosY';
        
    figure
    plot(1:length(VRLLM),VRLLM)
    hold on
    plot(1:length(VRLLM),XCoM_LLM,'r','LineWidth',1)
    hold on
    plot(1:length(VRLLM)/length(ViconLLM):length(VRLLM),ViconLLM,'k','LineWidth',1)
    set(gcf, 'Position', get(0, 'Screensize'));
end

