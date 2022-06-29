%% VAS rating main script
%% A.G. Mitchell - 25.02.2022
% Developed from code by Camila Deolindo & Francesca Fardo

% Last edit - 22.04.22

% Helpers required: 
% VAS_loadParams.m; getVasRatings.m; SetupRand.m; ptbConfig.m; 
% openScreen.m; StimCount.m; slideScale.m; drawFixation.m;
% angle2pix.m
% probably more...            
        

%% Load parameters
clear all % clearing all old data

% Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor
vars.control.devFlag  = 1; 

addpath helperFunctions 
VAS_loadParams;
% getting helper functions to path, just incase they are not already added (make sure they are in the same folder)
% path to save data to - should be changed depending on laptop (VAS_loadParams.m)
datPath = vars.filename.path;
runPath = pwd;

% Reseed the random-number generator
SetupRand;

%% Set up participant info
if vars.control.devFlag == 0 %only run if not debugging
    % input participant details for filename
    % task is either TGI or control, participant number is a string of 4 digits
    % (e.g. 0001), counterbalance procedure is index 1,2,3 or 4
    vars.filename.calib = string(inputdlg({'Participant number:', 'Task:'},...
        'Participant information', [1 30; 1 10]));
    
    % make participant folder in correct path
    ppPath = fullfile(datPath, vars.filename.calib(1));
    mkdir(ppPath);
    
    % get date
    formatout = 'yymmdd';
    vars.filename.date = datestr(now, formatout);
    
    % saving file name with participantID_pseudorandomProcedure_Date
    matName = sprintf('%s_%s_%s_CALIB_spinalTGI.mat', vars.filename.calib(1,:), vars.filename.date);
    csv_ratName = sprintf('%s_%s_%s_CALIB_spinalTGI.csv', vars.filename.calib(1,:), vars.filename.date);
end

%% Psychtoolbox settings
PsychDefaultSetup(2);
ListenChar(2); %disable keypress
Screen('Preference', 'SkipSyncTests', 2);
scr.ViewDist = vars.ViewDist; % viewing distance
[scr, keys] = ptbConfig(scr, vars);

%% Prepare to start
%  try
% Set text size, dependent on screen resolution
if any(logical(scr.winRect(:)>3000))       % 4K resolution
    scr.TextSize = 65;
else
    scr.TextSize = vars.instructions.textSize;
end
% Check if window is already open (if not, open screen window) 
[scr]=openScreen(scr);

% Dummy calls to prevent delays
vars.control.RunSuccessfull = 0;
vars.control.Aborted = 0;
vars.control.Error = 0;
vars.control.thisTrial = 1;
vars.control.abortFlag = 0;
[~, ~, keys.KeyCode] = KbCheck;

%% Preparing to present VAS  
trial_idx = 0 ; %create a seperate index for individual trials
for test_idx = 1:4 % loop thorugh the number of calib 'tests' you do (atm, 2 on each arm)
    for rep_idx = 1:vars.task.CalibReps %loop through trial repeats, 3 trials per thermode location
        % record number of total trials per participant
        trial_idx = trial_idx+1;
        %% Open VAS screen
        % to control when each trial starts - can remove this if VAS questions
        % need to be continuous  
        
        DrawFormattedText(scr.win, vars.instructions.StartVas, 'center', 'center', scr.TextColour);
        [~, ~] = Screen('Flip', scr.win);
        KbStrokeWait;
    
        % run countdown during TGI stimulation - number of seconds defined in
        % VAS_loadParams.m
        StimCount(scr, vars); 
    
        %% Run VAS
        % run one VAS to rate burning experience
        Screen('TextSize', scr.win, scr.TextSize); % resetting text size
        initial_question = 1; %indexing the initial question for the VAS rating
        [results.vasResponse(trial_idx, initial_question),...
            results.vasReactionTime(trial_idx, initial_question)] = ...
                getVasRatings(keys, scr, vars, initial_question);  
        results.QuestionType(trial_idx, initial_question) = vars.instructions.Question(initial_question); 
    
        % Wait a small amount of time (1s) after the first vas rating, to
        % divide up time
        WaitSecs(.5)
    
        results.trialInfo(trial_idx, 1) = trial_idx;  
    
        % break the loop if VAS rating is above 15, then participant is
        % experiencing TGI
        if results.vasResponse(trial_idx, initial_question) > 15
            % Play audio to signify that the participant has rated above 15
            myBeep = MakeBeep(500, vars.audio.beepLength, vars.audio.sampRate);
            playAudio(vars,myBeep)
            break
        end
    end     
end

sca; % close VAS
ListenChar(0); %enable keypress

%% Saving data
if vars.control.devFlag == 0 %only run if not debugging
    % to path specified in VAS_loadparams.m
    % first raw mat files
    matFile = fullfile(ppPath, matName);
    save(matFile,'vars', 'results'); % saving raw data files as is
    
    % then csv files with key data
    csvFile1 = fullfile(ppPath, csv_ratName);
    % saving VAS response and VAS response time as seperate CSVs
    writematrix(results.vasResponse, csvFile1);
end
