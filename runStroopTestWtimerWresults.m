function t=runStroopTestWtimerWresults(totalRunTime,sPortObj,Congruence,FigHdl)
%% Produce a figure running the Stroop Test
% 
% Description
%       A figure appears every 3s for a total of "totalRunTime" seconds, that runs
%       the Stroop Test. The user has to speak/choose the color of the word
%       irrespective of the word that they can see. 
%       
%       If this file is run stand-alone (i.e. without calling the main function), 
%       then you have to issue a start command to the timerObj that is output 
%       from this function. For example -
%       t=runStroopTestWtimerWresults(totalRunTime,[OPTIONAL]); 
%       start(t);
%
% Inputs
%       totalRunTime    : Total time (in s) this test needs to run
%       sPortObj        : *OPTIONAL*
%                       : This object can be used for passing any serial
%                       object, which can be killed when the timer StopFcn 
%                       is executed
%       Congruence      : [OPTIONAL][String]
%                         (as mentioned in parentheses)
%                         If this arguement is provided, based on this value 
%                         Congruent (C) or Incongruent(IC) or Randomised(R) 
%                         Stroop Test will run.
%       FigHdl          : *OPTIONAL*
%                       : This is the figure handle for the test figures    
% Outputs
%       t               : Timer Object Handle if the code is in execution 
%                          (in case you need to kill the timer)
%                       : UserData Structure if the execution has ended
% -------------------------------------------------------------------------
% Copyright (c) 13-Nov-2014
%       Deba Pratim Saha, 
%       Electrical Engineer, M.S.,
%       Ph.D. Student, ECE Virginia Tech.
%       Email: dpsaha@vt.edu
% -------------------------------------------------------------------------

%% Argument Checking and Global Vars
if nargin>4
    error('err:ArgChk','This function takes 4 inputs, the 2nd,3rd and 4th inputs are optional');
end
if nargin<4
    FigHdl = 1;
end
if nargin<3
    Congruence = 'IC';
end
if nargin<2
    sPortObj = {};
end

%% Define the words and colors
global words;
words = ['YELLOW ';'MAGENTA';'CYAN   ';'RED    ';'GREEN  ';'BLUE   ';'BLACK  ']; %1
global colors;
colors = [1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1;0 0 0]; %2
global randomStroopArray;
randomStroopArray = repmat([false false true true false true false true true false],1,6);
global stroopFigHdl;

switch Congruence
    case 'C'
        Congruence = true;  %Congruent stroop test flag
        randomStroopFlag = false; %Randomised stroop test flag
    case 'IC'
        Congruence = false;  %InCongruent stroop test flag
        randomStroopFlag = false; %Randomised stroop test flag
    case 'R'
        Congruence = randomStroopArray(1);  %InCongruent stroop test flag 
        randomStroopFlag = true; %Randomised stroop test flag                    
end

% Set figure userdata based on the congruence props
FigHdl = figure(FigHdl); set(FigHdl,'Visible','Off');
fUserdata = get(FigHdl,'UserData');
fUserdata.('randomStroopFlag') = randomStroopFlag;
set(FigHdl,'UserData',fUserdata);

global dataDirPath;
global congruenceFlagSet;

%% Create Timer
secondsFigureChange = 3;                            
secondsCongruenceInterval = ceil(totalRunTime/3);
propCongruence = Congruence;

t = timer;
t.UserData = struct('Congruence',propCongruence,...
                    'tCongruenceCount',0,...
                    'tEntryCount',0,...
                    'CongruenceInterval',secondsCongruenceInterval,...
                    'testData',{{'DUMMY'}});
t.StartFcn = @phaseTimerStart;
t.TimerFcn = @nextFigure;
t.StopFcn = @phaseTimerCleanup;
t.Period = secondsFigureChange;     
t.StartDelay = secondsFigureChange;
t.TasksToExecute = ceil(totalRunTime/secondsFigureChange);
t.ExecutionMode = 'fixedSpacing';

% start(t);

    %% Run the test
    function phaseTimerStart(mTimer,~)
        tUserdata = mTimer.UserData;
%         fprintf('Starting StroopTest with Congruence = %d\n',tUserdata.Congruence);
        [stroopFigHdl] = StroopTest(words,colors,tUserdata.Congruence,1,FigHdl);
    end

    function nextFigure(mTimer,~)
        tUserdata = mTimer.UserData;
        tUserdata.tCongruenceCount = tUserdata.tCongruenceCount + 1;       % Var to determine congruence change
        tUserdata.tEntryCount = tUserdata.tEntryCount + 1;                 % Timer callback entry count
        tUserdata.testData{tUserdata.tEntryCount,:} = get(stroopFigHdl,'UserData'); % Append the user's test data
        
        % Figure Modification starts for next cycle
        delete(findobj(stroopFigHdl,'Tag','StroopString'));                % Delete the StroopString by finding the text
        btnGrpObj = findobj(stroopFigHdl,'Tag','existingBtnGrp');          % Find the buttongroup object
        set(get(btnGrpObj,'Children'),'Enable','Inactive');                        % Deactivate the buttons until next figures appears
        
        % Check the user choice and display RIGHT/WRONG
        colorShown = tUserdata.testData{tUserdata.tEntryCount,1}.inputColor;
        userChoiceString = tUserdata.testData{tUserdata.tEntryCount,1}.choice;
        colorIndex  = find(ismember(words,userChoiceString,'rows'));
        colorEvaluation = isequal(colors(colorIndex,:),colorShown);
        
        if ~isempty(findobj(stroopFigHdl,'Tag','evalMsg'))                  % delete any previous msg
            delete(findobj(stroopFigHdl,'Tag','evalMsg')); end  
        
        if colorEvaluation
            disp('correct');
            text(stroopFigHdl.Number,0.1,0.1,'Correct Choice!!','Tag','evalMsg');
        else
            disp('wrong');
            text(stroopFigHdl.Number,0.1,0.1,'Wrong Choice','Tag','evalMsg');
        end
            
		% Check Stroop Test version - Random or Planned
        if tUserdata.testData{tUserdata.tEntryCount,1}.randomStroopFlag
            tUserdata.Congruence = randomStroopArray(tUserdata.tEntryCount);
        end
        

        % Check whether to change the Congruence value
        if ~congruenceFlagSet
            if (tUserdata.tCongruenceCount * (mTimer.Period)...
                    >= tUserdata.CongruenceInterval)
                tUserdata.Congruence = ~ tUserdata.Congruence;
                tUserdata.tCongruenceCount = 0;
            end
        end
        
        mTimer.UserData = tUserdata;
        
%         fprintf('Next Stroop Figure with EntryCount = %d and Congruence = %d\n',...
%             tUserdata.tCongruenceCount,tUserdata.Congruence);
        [stroopFigHdl] = StroopTest(words,colors,tUserdata.Congruence,1,stroopFigHdl);
    end
    

    function phaseTimerCleanup(mTimer,~)
        disp('Clearing Timer and all figures');
        close(stroopFigHdl);
        
        % Save the Stroop Test Data
        tUserdata = mTimer.UserData;
        delete(mTimer);
        stroopDataDump  = evalin('base','{}');                         % Create an empty var in base WS
        assignin('base','stroopDataDump',tUserdata.testData);          % Assign value to var
        stroopDataDump  = evalin('base','stroopDataDump');             % Get the updated value from base WS
		
        % Close the serial port object, if valid obj was passed from main
        if exist('sPortObj','var') && ~isempty(sPortObj)
            serialDataDump  = evalin('base','serialDataDump');  % Get the value from base workspace
            if isvalid(sPortObj)
                fclose(sPortObj);
                delete(sPortObj);
                clear sPortObj;
            end
        end
                
        % Choose to save test data
        saveQuestion = questdlg('Do you want to save all test data?','Save Test Data');
        switch saveQuestion
            case 'Yes'
                folderName = strcat(dataDirPath,'user_',stroopDataDump{end}.userID);
                disp(folderName);
                if ~exist(folderName,'dir')
                    mkdir(strcat(folderName,'\stroop'));
                end
                fileName = strcat(folderName,'\stroop','\user_',stroopDataDump{end}.userID,'_phase_',stroopDataDump{end}.PhaseNum,'_',datestr(clock,30),'.mat');
                fileID = fopen(fileName,'w');                 
                
                if exist('sPortObj','var') && ~isempty(sPortObj)
                    % Save both physio and stroop data variables
                    save (fileName,'stroopDataDump','serialDataDump');
                else
                    % Save only stroop data variables
                    save (fileName,'stroopDataDump');
                end
                fclose(fileID);
                
            case 'No'
                disp('YOUR DATA IS NOT SAVED');
                
            case 'Cancel'
        end
    end
end