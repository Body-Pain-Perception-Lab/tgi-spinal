%% VAS rating practice script
%% Adapted by Gosia Basińska form the main script by A.G. Mitchell 
% Developed from code by Camila Deolindo & Francesca Fardo

% Last edit - 07.06.22

% Helpers required: 
% VAS_loadParams.m; getVasRatings.m; SetupRand.m; ptbConfig.m; 
% openScreen.m; StimCount.m; slideScale.m; drawFixation.m;
% angle2pix.m
% probably more...            
        

%% Load parameters
clear all % clearing all old data

% Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor
vars.control.devFlag  = 1; 

VAS_loadParams;
addpath helperFunctions % getting helper functions to path, just incase they are not already added (make sure they are in the same folder)
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

%% Params
vars.task.practiceReps = 6 % to be determined
vars.instructions.PracticeStart = ['During the experiment you will use a scale of 0 - 100\n' ...
    'to rate sensations that you experience.\n\n' ...
    'Please use the following trials to practice how to use the scale.\n\n' ...
    'Use the left and right arrow keys to put the marker at the desired postion.\n' ...
    'Once done, press SPACE to move to the next scale.\n\n' ...
    'Time to answer is limited.\n\n' ...
    'Press any key to continue.']
vars.instructions.PracticeQuestions = {'Please place the marker near the left end of the scale.',...
                               'Please place the marker near the right end of the scale.',...
                               'Please place the marker in the middle of the scale.' }; 

%% Start screen
Screen('TextSize', scr.win, scr.TextSize);
DrawFormattedText(scr.win, vars.instructions.PracticeStart, 'center', 'center', scr.TextColour);
[~, ~] = Screen('Flip', scr.win);
KbStrokeWait;

%% Trial idx
trial_idx = 0 ; %create a seperate index for individual trials

%% Left, middle, right
for lmr_idx = 1:3 % loop through three practice trials with different instructions
    % record number of total trials per participant
    trial_idx = trial_idx+1;
    
    %% Run VAS
    % run one VAS to place the marker
    Screen('TextSize', scr.win, scr.TextSize); % resetting text size
    used_question = lmr_idx; %see vars.instructions.PracticeQuestions
    [results.vasResponse(trial_idx, used_question),...
        results.vasReactionTime(trial_idx, used_question)] = ...
            getVasRatingsPractice(keys, scr, vars, used_question);  
    results.QuestionType(trial_idx, used_question) = vars.instructions.PracticeQuestions(used_question); 
    
    % Wait a small amount of time (1s) after the first vas rating, to
    % divide up time
    WaitSecs(.5)
    
    results.trialInfo(trial_idx, 1) = trial_idx;          
end

%% Play a sound
% notifies the experimenter to use the thermode
myBeep = MakeBeep(500, vars.audio.beepLength, vars.audio.sampRate);
playAudio(vars,myBeep)

%% Runs three trials with a (neutral?) thermode
DrawFormattedText(scr.win, vars.instructions.StartVas, 'center', 'center', scr.TextColour);
[~, ~] = Screen('Flip', scr.win);
KbStrokeWait;

for scale_idx = 2:4 % loops through questions 2-4 from vars.instructions.Question
    trial_idx = trial_idx+1;
    question_type_idx = scale_idx;
    [results.vasResponse(trial_idx, question_type_idx), ...
        results.vasReactionTime(trial_idx, question_type_idx)] = ...
        getVasRatings(keys, scr, vars, question_type_idx)  
    % adding trial numbers to data-frame for later merging
    results.vasResponse(trial_idx, 5) = trial_idx;
    results.vasReactionTime(trial_idx, 5) = trial_idx;
    % making sure that VAS ratings are saved in correct column for each
    % question (sanity check)
    results.QuestionType(trial_idx, question_type_idx) = vars.instructions.Question(question_type_idx); 
end
sca; % close VAS
ListenChar(0); %enable keypress

%% Saving data
%if vars.control.devFlag == 0 %only run if not debugging
%    % to path specified in VAS_loadparams.m
%    % first raw mat files
%    matFile = fullfile(ppPath, matName);
%    save(matFile,'vars', 'results'); % saving raw data files as is
    
%    % then csv files with key data
%    csvFile1 = fullfile(ppPath, csv_ratName);
%    % saving VAS response and VAS response time as seperate CSVs
%    writematrix(results.vasResponse, csvFile1);
%end
