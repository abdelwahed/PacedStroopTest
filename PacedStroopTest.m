function [timerObj,sPortObj] = PacedStroopTest(LogSerialData,Congruence)
% Top level file to run the Stroop Test and capture physiological data 
% 
% Description
%       This is the top level file that runs Stroop Test while capturing the
%       user inputs in a variable. Optionally, Physiological data is also 
%       captured using Wi-MicroDig bluetooth receiver. For the Stroop test, 
%       a figure appears every 3s for a total of "totalRunTime" seconds as 
%       defined in the "argument check" section of this file. The user has 
%       to speak/choose the color of the word irrespective of the word that
%       they can see. 
%
%       One has to set the base folder in "dataDirPath" below where the 
%       test data will be saved. Default is "C:\Users\Public".
%
% Inputs
%       LogSerialData   : This flag sets the need to connect to a serial
%                         port to collect physio data while user is taking
%                         paced stroop test.                              
%                         1= Try to Connect to Serial Port
%                         0= DO NOT try to connect to serial port
%       Congruence      : [OPTIONAL]
%                         If this arguement is provided, totalRunTime value
%                         will be ignored, and based on this value Congruent (C) 
%                         or Incongruent(IC) Stroop Test will run for 60s time.
% Outputs
%       timerObj        : Timer Obj (may be used to stop the timer)
%       serialObj       : Serial Port Obj (may be used to free the serial port)
%
% Deliverables (saved on hard disk)
%       # A data file containing the physiological data -- (ECG, EDA, Skin Temp etc.)
%       # A data file containing Word, Color and User Input
% -------------------------------------------------------------------------
% Copyright (c) 30-Nov-2014
%       Deba Pratim Saha, 
%       Electrical Engineer, M.S.,
%       Ph.D. Student, ECE Virginia Tech.
%       Email: dpsaha@vt.edu
% -------------------------------------------------------------------------

%% Arg Check and Global Specs definitions
global congruenceFlagSet;
if nargin>2 || nargin==0
    error('err:ArgChk','This function takes max of 2 inputs');
else if nargin==1 % Congruence not set by user
        totalRunTime    = 180;   % This value in sec, total 3 mins of test. This
                                 % is divided as 1min of Congruent Stroop Test, 
                                 % 1min test of Incongruent followed by 1min of
                                 % Congruent Stroop Test.
        Congruence      = false; % This value specifies that 3min stroop test will 
                                 % start with 1min each of IC --> C --> IC phases.
                                 
        congruenceFlagSet = false; % Indicates that congruence flag was not passed by user
    else    % Congruence set by user
        totalRunTime    = 60;    % If congruence input is present, it runs for 60s.
        
        congruenceFlagSet = true; % Indicates that congruence flag was passed by user
     end
end

% data dir setting
global dataDirPath;
dataDirPath = ('C:\Users\Public\');

%% Initialise Wi-MicroDig ports and communication protocol
if LogSerialData
    % Free previously used COM ports
    delete(instrfind('Type', 'serial'));

    % Create and Open serial port for Wi-MicroDig
    sPortObj = serial('COM5');
    sPortObj.BytesAvailableFcnCount = 9*5;           % set the property so that BytesAvailableFcn is called when byte count = 9 [for 2 ports of data]
    sPortObj.BytesAvailableFcnMode  = 'byte';        % bytes-available event is generated when BytesAvailableFcnCount # of bytes are available
    fopen(sPortObj);
    serialDataDump = evalin('base','{}');            % create the variable in base workspace

    % setup the digitizer
    fwrite(sPortObj,[240 125 0 90 0 247]);         % send host mode message to digitizer
    fwrite(sPortObj,[240 125 0 34 247]);           % send reset message to digitizer
    fwrite(sPortObj,[240 125 0 3 0 5 247]);        % send interval message to digitizer to set sampling interval to 5 ms for all enabled inputs
    fwrite(sPortObj,[240 125 0 2 64 247]);         % send resolution message to digitizer to set sampling resolution to 10-bit for input 1 
    fwrite(sPortObj,[240 125 0 2 65 247]);         % send resolution message to digitizer to set sampling resolution to 10-bit for input 2

    pause(3);                                      % wait until the digitizer has sent host mode and reset confirmation messages
    b = get(sPortObj, 'BytesAvailable');           % find out how many bytes are in the buffer
    fread(sPortObj,b);                             % empty buffer by reading from it
else
    % Initialise output var in case one doesn't need physio data
    sPortObj = {};
end


%% Get test specific data
FigHandle = figure('Visible','Off');                    % Create an invisible figure now to use UserData field

prompt = {'Enter User ID:','Enter Phase Number:'};
dlgTitle = 'Test Data';
numLines = 1;
defs = {'xx','yyyy'};
answers = inputdlg(prompt,dlgTitle,numLines,defs);

if isempty(strcmp(answers,'{}'))
    error('err:testStat','Please input the test statistics');
else
    set(FigHandle,'UserData',struct('userID',answers(1),...
                                    'PhaseNum',answers(2),...
                                    'dataDirPath',dataDirPath,...
                                    'setFigProps',1));
end

%% Start the actual test and data capturing
if LogSerialData
    fwrite(sPortObj,[240 125 0 1 64 247]);         % send stream message to digitizer to turn on continuous sampling for input 1
    fwrite(sPortObj,[240 125 0 1 65 247]);         % send stream message to digitizer to turn on continuous sampling for input 1
    while get(sPortObj, 'BytesAvailable') < 82 end % wait for digitizer to send confirmation message (6 bytes)
    fread(sPortObj,82);

    sPortObj.BytesAvailableFcn = {@logSerialData};               % set the bytesAvailableFcn to the named callback function
end

timerObj = runStroopTestWtimerWresults(totalRunTime,sPortObj,Congruence,FigHandle);       % Get timer obj which starts the Stroop Test UI
start(timerObj);

    function logSerialData(obj,event)
        sPacket = fread(obj,obj.BytesAvailableFcnCount);
        serialDataDump = [serialDataDump;...
                         {sPacket,clock}];
        assignin('base','serialDataDump',serialDataDump);
    end

end