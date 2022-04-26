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
vars.control.devFlag  = 0; 

VAS_loadParams;
addpath helperFunctions % getting helper functions to path, just incase they are not already added (make sure they are in the same folder)
% path to save data to - should be changed depending on laptop (VAS_loadParams.m)
datPath = vars.filename.path;
runPath = pwd;

% Reseed the random-number generator
SetupRand;

%% Path
if vars.control.devFlag == 0 %only run if not debugging
    % input participant details for filename
    % task is either TGI or control, participant number is a string of 4 digits
    % (e.g. 0001), counterbalance procedure is index 1,2,3 or 4
    vars.filename.ID = string(inputdlg({'Participant number:','Conterbalance procedure:','Task:',...
        'Cold Temp (ºC):', 'Warm/Neutral Temp (ºC):'},...
        'Participant information', [1 30; 1 30; 1 10; 1 30; 1 30]));
    
    % make participant folder in correct path
    ppPath = fullfile(datPath, vars.filename.ID(1));
    mkdir(ppPath);
    
    % get date
    formatout = 'yymmdd';
    vars.filename.date = datestr(now, formatout);
    
    % saving file name with participantID_pseudorandomProcedure_Date
    matName = sprintf('%s_%s_%s_%s_VAS_spinalTGI.mat', vars.filename.ID(1:3), vars.filename.date);
    csv_ratName = sprintf('%s_%s_%s_%s_VASResponse_spinalTGI.csv', vars.filename.ID(1:3), vars.filename.date);
    csv_respName = sprintf('%s_%s_%s_%s_VASRespT_spinalTGI.csv', vars.filename.ID(1:3), vars.filename.date);
    csv_trialName = sprintf('%s_%s_%s_%s_VAStrials_spinalTGI.csv', vars.filename.ID(1:3), vars.filename.date);
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

%% Start screen
Screen('TextSize', scr.win, scr.TextSize);
DrawFormattedText(scr.win, vars.instructions.StartScreen, 'center', 'center', scr.TextColour);
[~, ~] = Screen('Flip', scr.win);
KbStrokeWait;

%% Pseudorandomise information
% get specific procedure order from main file - if in development mode then
% just get the first order
if vars.control.devFlag == 0
    order = str2double(vars.filename.ID(2));
else
    order = 1;
end
% extract trials associated with specific counterbalancing procedure
procedure = vars.task.randomise(vars.task.randomise.procedure==order, :);
    
trial_idx = 0 ; %create a seperate index for individual trials

for block_idx=1:vars.task.NBlocksTotal %loop through blocks (usually 2)
    for pseudo_idx=1:length(procedure.trial_type) %loop through procedure order - 8 different thermode locations
        for rep_idx = 1:vars.task.NTrialReps %loop through trial repeats, 3 trials per thermode location
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
            % StimCount(scr, vars); 

            % run one VAS to rate burning experience
            Screen('TextSize', scr.win, scr.TextSize); % resetting text size
            initial_question = 1; %indexing the initial question for the VAS rating
            [results.vasResponse(trial_idx, initial_question),...
                results.vasReactionTime(trial_idx, initial_question)] = ...
                    getVasRatings(keys, scr, vars, initial_question);  
            results.QuestionType(trial_idx, initial_question) = vars.instructions.Question(initial_question); 

            % Wait a small amount of time (1s) after the first vas rating, to
            % divide up time
            WaitSecs(1)
        
            %% Run VAS
            % Will loop through the number of VAS questions
            % for each trial (both params are set in VAS_load.params.m)
            % Currently set to 3 VAS questions - burning, warm, cold
            % this is used to index which question was addressed in output (see
            % VAS_loadParams.m for details) 
            qCode = vars.instructions.QuestionCode(2:end);
            randQuestion = qCode(randperm(length(vars.instructions.whichQuestion(2:end))));
            for rand_idx=1:length(randQuestion) %loop through VAS questions
                question_type_idx = randQuestion(rand_idx);
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
            results.trialInfo(trial_idx, 1:6) = procedure(pseudo_idx, 1:6);
            results.trialInfo.trial_n(trial_idx) = trial_idx;
            if vars.control.devFlag == 0
                results.trialInfo.coolTemp(trial_idx) = vars.filename.ID(4);
                results.trialInfo.warmTemp(trial_idx) = vars.filename.ID(5);
            end            
            % Play audio to signify the end of vas ratings for the
            % participant
            % make a beep
            myBeep = MakeBeep(500, vars.audio.beepLength, vars.audio.sampRate);
            playAudio(vars,myBeep)
        end
        % Repeat audio to signify a thermode change - a higher beep
        myBeep = MakeBeep(600, vars.audio.beepLength, vars.audio.sampRate);
        WaitSecs(.1) %wait 100ms to load beep
        playAudio(vars,myBeep)
    end
end
sca; % close VAS
ListenChar(0); %enable keypress

%% Saving data
if vars.control.devFlag == 0 % only run when not debugging
    % to path specified in VAS_loadparams.m
    % first raw mat files
    matFile = fullfile(ppPath, matName);
    save(matFile,'vars', 'results'); % saving raw data files as is
    
    % then csv files with key data
    csvFile1 = fullfile(ppPath, csv_ratName);
    csvFile2 = fullfile(ppPath, csv_respName);
    csvFile3 = fullfile(ppPath, csv_trialName);
    % saving VAS response and VAS response time as seperate CSVs
    writematrix(results.vasResponse, csvFile1);
    writematrix(results.vasReactionTime, csvFile2);
    writetable(results.trialInfo, csvFile3)
end
