clear
clc
warning off

%% Subject loop Sort
LocalInformation = dir;
AllCurrentNames = {LocalInformation.name};
FolderNames = string(AllCurrentNames(5:end))
SubjectNumbers = double(erase(FolderNames,"tDCS"));

%% Create Variables
BigLoopSubject = [];
BigLoopSession = [];
BigLoopLLMCCF = [];
BigLoopLLMTLag = [];
BigLoopRLMCCF = [];
BigLoopRLMTLag = [];
BigLoopGLegCCF = [];
BigLoopGLegTLag = [];
BigLoopBLegCCF = [];
BigLoopBLegTLag = [];

RightAffectedList = [1 2 3 4 6];

%% Loop for Subject
for SubjectLoop = 1:length(FolderNames)
    %% Sorting Process
    LocalInformation = dir(strcat(FolderNames(SubjectLoop),"\*.xlsx"));
    Tablenames = {LocalInformation.name};
    SessionName = string(Tablenames);
    Sortname = double(erase(SessionName,[".xlsx","Manual","Session","DataTable"]));
    [Sortedname Index] = sort(Sortname);
    NewNameSequence = SessionName(Index);
    NewNameSequence = NewNameSequence(1:3);
    %% Session loop
    SessionLLMCCF = [];
    SessionLLMTLag = [];
    SessionRLMCCF = [];
    SessionRLMTLag = [];
    SessionNumber = [];
    
    for SessionLoop = 1:length(NewNameSequence)
        Data = readtable(strcat(FolderNames(SubjectLoop),"\",NewNameSequence(SessionLoop)));
        
        LLMCCF = Data.LLMCCF;
        LLMTimeLag = Data.LLMTimeLag;
        RLMCCF = Data.RLMCCF;
        RLMTimeLag = Data.RLMTimeLag;
        Sessionnumber = SessionLoop*ones(length(RLMTimeLag),1);
        
        SessionLLMCCF = [SessionLLMCCF;LLMCCF];
        SessionLLMTLag = [SessionLLMTLag;LLMTimeLag];
        SessionRLMCCF = [SessionRLMCCF;RLMCCF];
        SessionRLMTLag = [SessionRLMTLag;RLMTimeLag];
        SessionNumber = [SessionNumber;Sessionnumber];
    end
    subject = SubjectNumbers(SubjectLoop)*ones(length(SessionLLMCCF),1);

    BigLoopSubject = [BigLoopSubject;subject];
    BigLoopSession = [BigLoopSession;SessionNumber];
    BigLoopLLMCCF = [BigLoopLLMCCF;SessionLLMCCF];
    BigLoopLLMTLag = [BigLoopLLMTLag;SessionLLMTLag];
    BigLoopRLMCCF = [BigLoopRLMCCF;SessionRLMCCF];
    BigLoopRLMTLag = [BigLoopRLMTLag;SessionRLMTLag];
    
    if ismember(SubjectLoop,RightAffectedList)
        BigLoopGLegCCF = [BigLoopGLegCCF;SessionLLMCCF];
        BigLoopGLegTLag = [BigLoopGLegTLag;SessionLLMTLag];
        BigLoopBLegCCF = [BigLoopBLegCCF;SessionRLMCCF];
        BigLoopBLegTLag = [BigLoopBLegTLag;SessionRLMTLag];
    else
        BigLoopGLegCCF = [BigLoopGLegCCF;SessionRLMCCF];
        BigLoopGLegTLag = [BigLoopGLegTLag;SessionRLMTLag];
        BigLoopBLegCCF = [BigLoopBLegCCF;SessionLLMCCF];
        BigLoopBLegTLag = [BigLoopBLegTLag;SessionLLMTLag];
    end
end

%% Create Excel
filename = "CrossCorrelation and Time Lag for both Legs";

xlswrite(filename,["Subject","Session","LLMXCorr","LLMTLag","RLMXCorr",...
    "RLMTLag","GLegXCorr","GLegTLag","BLegXCorr","BLegTLag"],'Sheet1','A1');

xlswrite(filename,[BigLoopSubject BigLoopSession BigLoopLLMCCF...
    BigLoopLLMTLag BigLoopRLMCCF BigLoopRLMTLag BigLoopGLegCCF...
    BigLoopGLegTLag BigLoopBLegCCF BigLoopBLegTLag],'Sheet1','A2');