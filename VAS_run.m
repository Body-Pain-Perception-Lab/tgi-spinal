%% VAS rating main script
%% A.G. Mitchell - 25.02.2022
% Developed from code by Camila Deolindo & Francesca Fardo

% Last edit - 02.03.2022

%% Load parameters
VAS_loadParams;

% Reseed the random-number generator
SetupRand;

vars.control.devFlag  = 1; % Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor

%% Psychtoolbox settings
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 2);
scr.ViewDist = vars.ViewDist; % viewing distance
[scr, keys  ] = ptbConfig(scr);

%% Open a PTB window
AssertOpenGL;
if vars.c ontrol.devFlag
    [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray, [0 0 1000 1000]); %,[0 0 1920 1080] mr screen dim
else
    [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray); %,[0 0 1920 1080] mr screen dim
end 

% Set text size, dependent on screen resolution
if any(logical(scr.winRect(:)>3000))       % 4K resolution
    scr.TextSize = 65;
else
    scr.TextSize = vars.instructions.textSize;
end
Screen('TextSize', scr.win, scr.TextSize);

% Set priority for script execution to realtime priority:
scr.priorityLevel = MaxPriority(scr.win);
Priority(scr.priorityLevel);

% Determine stim size in pixels
scr.dist        = scr.ViewDist;
scr.width       = scr.MonitorWidth;
scr.resolution  = scr.winRect(3:4);                    % number of pixels of display in horizontal direction

%% Prepare to start
%  try
    % Check if window is already open (if not, open screen window) 
    [scr]=openScreen(scr);
    
    % Dummy calls to prevent delays
    vars.control.RunSuccessfull = 0;
    vars.control.Aborted = 0;
    vars.control.Error = 0;
    vars.control.thisTrial = 1;
    vars.control.abortFlag = 0;
    [~, ~, keys.KeyCode] = KbCheck;

for trial_idx=1:vars.task.NTrialsTotal
    %% Open start screen
    % to control when each trial starts - can remove this if VAS questions
    % need to be continuous  
    DrawFormattedText(scr.win, vars.instructions.StartVas, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    KbStrokeWait;

    %% Run VAS
    % Will loop through the number of VAS questions
    % for each trial (both params are set in VAS_load.params.m)
    % Currently set to 4 VAS questions, for 2 trials
    randQuestion = vars.instructions.QuestionCode (randperm(length(vars.instructions.whichQuestion)));
    for rand_idx=1:length(randQuestion)
        question_type_idx = randQuestion(rand_idx);
        [Results.vasResponse(trial_idx,rand_idx), ...
            Results.vasReactionTime(trial_idx,rand_idx)]= getVasRatings(keys, scr, vars, question_type_idx);
        Results.vasQuestionType(trial_idx, rand_idx ) = vars.instructions.Question(question_type_idx); 
    end 
end

sca;