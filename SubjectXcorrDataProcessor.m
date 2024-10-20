clear
clc
warning off

%% Subject loop Sort
LocalInformation = dir;
AllCurrentNames = {LocalInformation.name};
FolderNames = string(AllCurrentNames(4:end))
SubjectNumbers = double(erase(FolderNames,"tDCS"));

%% Create Variables
BigLoopSubject = [];
BigLoopSession = [];
BigLoopCCF = [];
BigLoopTLag = [];
BigLoopBGLeg = [];
BigLoopTrial = [];

RightAffectedList = [1 2 3 4 6];

%% Loop for Subject
for SubjectLoop = 1:10
    %% Sorting Process
    LocalInformation = dir(strcat(FolderNames(SubjectLoop),"\*.xlsx"));
    Tablenames = {LocalInformation.name};
    SessionName = string(Tablenames);
    Sortname = double(erase(SessionName,[".xlsx","Manual","Session","DataTable"]));
    [Sortedname Index] = sort(Sortname);
    NewNameSequence = SessionName(Index);
    NewNameSequence = NewNameSequence(1:3);
    %% Session loop
    SessionCCF = [];
    SessionTLag = [];
    SessionNumber = [];
    SessionGBLeg = [];
    SessionTrial = [];
    
        for SessionLoop = 1:length(NewNameSequence)
            Data = readtable(strcat(FolderNames(SubjectLoop),"\",NewNameSequence(SessionLoop)));
            
            LLMCCF = [];
            LLMTimeLag = [];
            RLMCCF = [];
            RLMTimeLag = [];
            Trial = [];
            
            for stack = 1:length(Data.Var1)
                LLMCCF = [LLMCCF;Data.Var1(stack);Data.Var2(stack);Data.Var3(stack)];
                LLMTimeLag = [LLMTimeLag;Data.Var4(stack);Data.Var5(stack);Data.Var6(stack)];
                RLMCCF = [RLMCCF;Data.Var7(stack);Data.Var8(stack);Data.Var9(stack)];
                RLMTimeLag = [RLMTimeLag;Data.Var10(stack);Data.Var11(stack);Data.Var12(stack)];
                Trial = [Trial;stack*ones(3,1)];
            end
            
            GLeg = repmat(string("Good Leg"),[length(LLMCCF) 1]);
            BLeg = repmat(string("Bad Leg"),[length(RLMCCF) 1]);
            Sessionnumber = SessionLoop*ones(2*length(RLMTimeLag),1);
            
            SessionNumber = [SessionNumber;Sessionnumber];
            SessionTrial = [SessionTrial;Trial;Trial];
            SessionCCF = [SessionCCF;LLMCCF;RLMCCF];
            SessionTLag = [SessionTLag;LLMTimeLag;RLMTimeLag];
            
            if ismember(SubjectLoop,RightAffectedList)
                SessionGBLeg = [SessionGBLeg;GLeg;BLeg];
            else
                SessionGBLeg = [SessionGBLeg;BLeg;GLeg];
            end
        end
        
    subject = SubjectNumbers(SubjectLoop)*ones(length(SessionCCF),1);

    BigLoopSubject = [BigLoopSubject;subject];
    BigLoopSession = [BigLoopSession;SessionNumber];
    BigLoopBGLeg = [BigLoopBGLeg;SessionGBLeg];
    BigLoopCCF = [BigLoopCCF;SessionCCF];
    BigLoopTLag = [BigLoopTLag;SessionTLag];
    BigLoopTrial = [BigLoopTrial;SessionTrial];

end

%% Create Excel
filename = "V2 CrossCorrelation and Time Lag for both Legs";

xlswrite(filename,["Subject","Session","Trial","Good or Bad Leg","XCorr","TLag",],'Sheet1','A1');

xlswrite(filename,[BigLoopSubject BigLoopSession BigLoopTrial BigLoopBGLeg...
    BigLoopCCF BigLoopTLag],'Sheet1','A2');
