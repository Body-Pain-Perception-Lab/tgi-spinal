%% VAS rating main script
%% A.G. Mitchell - 25.02.2022
% Developed from code by Camila Deolindo & Francesca Fardo

% Last edit - 28.03.22

% Helpers required: 
% VAS_loadParams.m; getVasRatings.m; SetupRand.m; ptbConfig.m; 
% openScreen.m; StimCount.m; slideScale.m; drawFixation.m;
% angle2pix.m
% probably more...            
        

%% Load parameters
clear all % clearing all old data

VAS_loadParams;
addpath helperFunctions % getting helper functions to path, just incase they are not already added (make sure they are in the same folder)

% Reseed the random-number generator
SetupRand;   

vars.control.devFlag  = 0; % Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor

%% Path
if vars.control.devFlag == 0 %only run if not debugging
    % path to save data to - should be changed depending on laptop
    % (VAS_loadParams.m)
    datPath = vars.filename.path;
    % input participant details for filename
    % task is either TGI or control, participant number is a string of 4 digits
    % (e.g. 0001), counterbalance procedure is index 1,2,3 or 4
    vars.filename.ID = string(inputdlg({'Participant number:','Conterbalance procedure:','Task:'},...
                 'Participant information', [1 30; 1 30; 1 10]));
    
    % make participant folder - do this later
    %ppPath = [datPath vars.filename.ID];
    %mkdir ppPath
    
    % get date
    formatout = 'yymmdd';
    vars.filename.date = datestr(now, formatout);
    
    % saving file name with participantID_pseudorandomProcedure_Date
    matName = sprintf('%s_%s_%s_%s_VAS_spinalTGI.mat', vars.filename.ID, vars.filename.date);
    csv_ratName = sprintf('%s_%s_%s_%s_VASResponse_spinalTGI.csv', vars.filename.ID, vars.filename.date);
    csv_respName = sprintf('%s_%s_%s_%s_VASRespT_spinalTGI.csv', vars.filename.ID, vars.filename.date);
    csv_trialName = sprintf('%s_ %s_%s_%s_VAStrials_spinalTGI.csv', vars.filename.ID, vars.filename.date);
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

for block_idx=1:vars.task.NBlocksTotal
    for pseudo_idx=1:length(procedure.trial_type)
        % record number of total trials per participant
        trial_idx = trial_idx+1;
        %% Open start screen
        % to control when each trial starts - can remove this if VAS questions
        % need to be continuous  
    
        Screen('TextSize', scr.win, scr.TextSize);
        DrawFormattedText(scr.win, vars.instructions.StartVas, 'center', 'center', scr.TextColour);
        [~, ~] = Screen('Flip', scr.win);
        KbStrokeWait;
    
        % run countdown during TGI stimulation - number of seconds defined in
        % VAS_loadParams.m
        StimCount(scr, vars);  
    
        %% Run VAS
        % Will loop through the number of VAS questions
        % for each trial (both params are set in VAS_load.params.m)
        % Currently set to 3 VAS questions - burning, warm, cold
        % this is used to index which question was addressed in output (see
        % VAS_loadParams.m for details) 
        randQuestion = vars.instructions.QuestionCode(randperm(length(vars.instructions.whichQuestion)));
    
        Screen('TextSize', scr.win, scr.TextSize); % resetting text size
        for rand_idx=1:length(randQuestion) 
            question_type_idx = randQuestion(rand_idx);
            [results.vasResponse(trial_idx, question_type_idx), ...
                results.vasReactionTime(trial_idx, question_type_idx)] = ...
                getVasRatings(keys, scr, vars, question_type_idx);  
            % adding trial numbers to data-frame for later merging
            results.vasResponse(trial_idx, 4) = trial_idx;
            results.vasReactionTime(trial_idx, 4) = trial_idx;
            % making sure that VAS ratings are saved in correct column for each
            % question (sanity check)
            results.QuestionType(trial_idx, question_type_idx) = vars.instructions.Question(question_type_idx); 

        end 
        % adding pseudorandomised info from the trial - extracted from
        % counterbalance csv file
        results.trialInfo(trial_idx, 1:6) = procedure(pseudo_idx, 1:6);
        results.trialInfo.trial_tot(trial_idx) = trial_idx;
        % display text for thermode location switch, need to refine this
        % step when counterbalancing procedure is finalised
        if bitget(trial_idx,1) %if the trial index is odd, no thermode switch
        else
            DrawFormattedText(scr.win, vars.instructions.Thermode, 'center', 'center', scr.TextColour);
            [~, ~] = Screen('Flip', scr.win);
            
            KbStrokeWait;
        end
    end
end
sca; % close VAS
ListenChar(0); %enable keypress

%% Saving data
if vars.control.devFlag == 0 % only run when not debugging
    % to path specified in VAS_loadparams.m
    % first raw mat files
    matFile = fullfile(datPath, matName);
    save(matFile,'vars', 'results'); % saving raw data files as is
    
    % then csv files with key data
    csvFile1 = fullfile(datPath, csv_ratName);
    csvFile2 = fullfile(datPath, csv_respName);
    csvFile3 = fullfile(datPath, csv_trialName);
    % saving VAS response and VAS response time as seperate CSVs
    writematrix(results.vasResponse, csvFile1);
    writematrix(results.vasReactionTime, csvFile2);
    writetable(results.trialInfo, csvFile3)
end
