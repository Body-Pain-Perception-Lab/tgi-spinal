%% Define parameters required for VAS presentation for Spinal TGI
%
%
% A G Mitchell 02/03/2022
% Last edit: 17/03/2022

%% Key flags

vars.control.language = 1;  %1 for English 2 for Danish
vars.control.inputDevice =  2;   % Response method for button presses 1 - mouse, 2 - keyboard 
vars.control.fixedTiming = 0; %add if timing of all trials should be same length, regardless of resp
vars.control.audio = 1; %is audio input required? 1 - yes, 0 - no

%% Paths
vars.filename.path = "/Users/au706616/Documents/Experiments/SPINALTGI/"; % this should change depending on computer used

%% Task parameters

%Viewing distance
vars.ViewDist = 56;

%Trials
vars.task.NTrialReps         = 1; %number of repeat trials per condition (i.e. thermode in right place)
vars.task.NBlocksTotal       = 1; %Total number of blocks per pseudorandom procedure (n x 16 trials)
vars.task.NTrialsChange      = 3; % The frequency of thermode change per trial (if thermode is changed every trial, set to 1)
vars.task.practiceReps       = 3; % number of repetitions of three ratings (cold/warm/burning) during practice trials
vars.task.CalibReps          = 20; % set to the max number of trials required to calibrate temperature for TGI, atm this is a guess

%Times
%vars.task.jitter             = randInRange(1,3,[1,vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 0.25; % this determines how long the feedbacks "button press detected" is shown on the screen
%vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3; %Time to move the thermode to adjacent position
vars.task.RespT              = 8;    % Time to respond
vars.task.device = 'keyboard'; 
%vars.task.device = 'mouse'; %change between either keyboard or mouse, depending on preference

% loading counterbalancing file - make sure it is in the file directory you
% are running from
vars.task.randomise = readtable('counterbalancing.csv'); 

%% Instructions
vars.instructions.textSize = 32;
vars.waitStim.secs = 10;
vars.waitStim.textSize = 40;

if vars.control.language == 1
    English_instructions;
elseif vars.control.language == 2
    Danish_instructions;
end

%% Audio parameters - for ptb audio
if vars.control.audio
    InitializePsychSound(1);
end
% Number of channels and Frequency of the sound
vars.audio.nrchannels = 2;
vars.audio.sampRate = 48000;
vars.audio.repetitions = 1; % number of repetitions of the tone
vars.audio.beepLength = 0.2; %in seconds
vars.audio.beepPause = 0.5; % Length of the pause between beeps (seconds)
vars.audio.start = 0; % start delay in secs, start immediately = 0
% Should we wait for the device to really start (1 = yes)
vars.audio.waitForDevice = 1;


