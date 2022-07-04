%% VAS rating practice script
%% Adapted by Gosia Basińska form the main script by A.G. Mitchell 
% Developed from code by Camila Deolindo & Francesca Fardo

% Last edit - 27.06.22

% Helpers required: 
% VAS_loadParams.m; getVasRatings.m; SetupRand.m; ptbConfig.m; 
% openScreen.m; StimCount.m; slideScale.m; drawFixation.m;
% angle2pix.m
% probably more...            
        

%% Load parameters
clear all % clearing all old data

% Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor
vars.control.devFlag  = 1; 
addpath helperFunctions % getting helper functions to path, just incase they are not already added (make sure they are in the same folder)
VAS_loadParams;

% path to save data to - should be changed depending on laptop (VAS_loadParams.m)
datPath = vars.filename.path;
runPath = pwd;

% Reseed the random-number generator
SetupRand;

%% Psychtoolbox settings
PsychDefaultSetup(2);
ListenChar(2); %disable keypress
Screen('Preference', 'SkipSyncTests', 2);
scr.ViewDist = vars.ViewDist; % viewing distance
[scr, keys] = ptbConfig(scr, vars);

%% Prepare to start
%  try
% Set text size, dependent on screen reso  luti on  
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

%% Start screen
Screen('TextSize', scr.win, scr.TextSize);
DrawFormattedText(scr.win, vars.instructions.PracticeStart, 'center', 'center', scr.TextColour);
[~, ~] = Screen('Flip', scr.win);
KbStrokeWait;

%% Trial idx
trial_idx = 0 ; %create a seperate index for individual trials

for practiceRep = 1:vars.task.practiceReps %repeats three ratings desired number of times
    %% Play a sound
    % notifies the experimenter to use the thermode
    myBeep = MakeBeep(500, vars.audio.beepLength, vars.audio.sampRate);
    WaitSecs(.1) %wait 100ms to load beep
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
            getVasRatings(keys, scr, vars, question_type_idx);
        % adding trial numbers to data-frame for later merging
        results.vasResponse(trial_idx, 5) = trial_idx;
        results.vasReactionTime(trial_idx, 5) = trial_idx;
        % making sure that VAS ratings are saved in correct column for each
        % question (sanity check)
        results.QuestionType(trial_idx, question_type_idx) = vars.instructions.Question(question_type_idx); 
    end
end
sca; % close VAS
ListenChar(0); %enable keypress
