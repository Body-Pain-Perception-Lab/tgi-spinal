 function Multi_wrapper(whichPart)
%
% Project: TGI spine - part II
%
% Input: whichPart  optional argument to only run one of the TPL component tasks
%       0   Practice
%       1   Calibration
%       2   Main experiment
%
% Sets paths, and calls functions
%
% Camila Sardeto Deolindo and Francesca Fardo
% Last edit: 21/07/2022

%% TPL tasks wrapper

% Close existing workspaces
close all; clc;
%% Define general vars across tasks
vars.dir.projdir = pwd;
vars.control.devFlag  = 0;              % Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor
vars.control.stimFlag = 1;              % Development flag 2. Set to 0 when developing the task without a stimulator
vars.ID.subNo = input('What is the subject number (e.g. 0001)?   ');
vars.ID.sesNo = input('What is the session number (e.g. 0001)?   ');
vars.control.language = input('Which language: English (1) or Danish (2)?   ');
vars.control.startTrialN = 1;

% check for data dir
if ~exist('data', 'dir')
    mkdir('data')
end

% Define subject No if the value is missing 
if isempty(vars.ID.subNo)
    vars.ID.subNo = 9999; % debugging                                            
end

% Define session No if the value is missing 
if isempty(vars.ID.sesNo)
    vars.ID.sesNo = 1; % debugging                                            
end

vars.ID.subIDstring = sprintf('%04d', vars.ID.subNo);
vars.ID.sesIDstring = sprintf('%01d', vars.ID.sesNo);
%% Prepare metadata
participant.MetaDataFileName = strcat(vars.ID.subIDstring, '_metaData'); 
participant.partsCompleted = zeros(1,4);

% Check if the subject folder already exists in data dir
vars.dir.OutputFolder = fullfile(vars.dir.projdir, 'data', ['sub_',vars.ID.subIDstring], filesep);
if ~exist(vars.dir.OutputFolder, 'dir') 
    mkdir(vars.dir.OutputFolder)
else
    try load(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant'); end
end

%% Set up paths
addpath(vars.dir.OutputFolder);
addpath(genpath('stimuli'));
addpath(genpath('..\LibTcsMatlab2021a'));

%% Check that PTB is installed
[oldLevelScreen, oldLevelAudio] = checkPTBinstallation;
%% Open a PTB window
scr.ViewDist = 56; 
[scr] = displayConfig(scr);
AssertOpenGL;
if vars.control.devFlag
    [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray, [0 0 1000 1000]); %,[0 0 1920 1080] mr screen dim
else
    [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray); %,[0 0 1920 1080] mr screen dim
end
% PsychColorCorrection('SetEncodingGamma', scr.win, 1/scr.GammaGuess);

% Set text size, dependent on screen resolution
if any(logical(scr.winRect(:)>3000))       % 4K resolution
    scr.TextSize = 65;
else
    scr.TextSize = 28;
end
Screen('TextSize', scr.win, scr.TextSize);

% Set priority for script execution to realtime priority:
scr.priorityLevel = MaxPriority(scr.win);
Priority(scr.priorityLevel);

% Determine stim size in pixels
scr.dist        = scr.ViewDist;
scr.width       = scr.MonitorWidth;
scr.resolution  = scr.winRect(3:4);                    % number of pixels of display in horizontal direction

%% 00 Run Tutorial
if ((nargin < 1) || (whichPart==0))
    vars.control.taskN = 1;
    runTutorial = input('Would you like to run a tutorial? 1-yes 0-no ');
    if runTutorial
        cd(fullfile('.', 'tasks', '00_tutorial'))
        addpath(genpath('helpers'))
        tutorial_MT (scr,vars);
    end
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('Tutorial completed. Continue to the main tasks? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% 01 Run TGI Multidimensional Thresholding (FAST)
if ((nargin < 1) || (whichPart==1)) %&& (participant.partsCompleted(taskN) == 0)
    vars.control.taskN = 1;
    cd(fullfile('.', 'tasks', '01_tgiMulti'))
    addpath(genpath('code'))
    tgiMulti_Launcher(scr, vars); % Launcher
    participant.partsCompleted(1) = 1;
    % Save metadata
    save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('TGI Multidimensional threshold task completed. Continue to Cold/Warm Thresholding? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% 02 Cold and Warm Pain Thresholds

if ((nargin < 1) || (whichPart==2)) %&& (participant.partsCompleted(2) == 0)
    vars.control.taskN = 2;
    vars.control.whichMethodCW = input('Which method would you like to use to estimate Burning thresholds? (1)Psi (otherwise)Method of Limits    ');
    
    switch vars.control.whichMethodCW
        case 1
            vars.control.whichBlock = input('Which Sensation would you like to threshold now? (0)Cold (1)Warm    ');
            cd(fullfile('.', 'tasks', '02a_PsiThr'))
            PsiThreshold_Launcher(scr,vars); % Launcher
         otherwise
            cd(fullfile('.', 'tasks', '02b_MethodLimits'))
            limitsThreshold_Launcher(scr,vars); % Launcher
    end
    % if vars.RunSuccessfull
    participant.partsCompleted(2) = 1;
    % Save metadata
    save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('Cold and Warm Pain Thresholds completed. Continue to Psi-TGI Thresholding? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% Finish up
% Copy data files to 1_VMP_aux
% copy2VMPaux(participant.subNo);

% Close screen etc
rmpath(genpath('code'));
rmpath(vars.dir.OutputFolder);
sca;
ShowCursor;
fclose('all'); %Not working Screen('CloseAll')%
Priority(0);
ListenChar(0);          % turn on keypresses -> command window

%% Restore PTB verbosity
Screen('Preference', 'Verbosity', oldLevelScreen);
PsychPortAudio('Verbosity', oldLevelAudio);

end