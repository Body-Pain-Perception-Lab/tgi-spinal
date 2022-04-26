%% Define parameters required for VAS presentation for Spinal TGI
%
%
% A G Mitchell 02/03/2022
% Last edit: 17/03/2022

%% Key flags
                                                 
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

vars.instructions.StartScreen = ['For each trial, you will experience thermal stimulation on your skin.\n\n' ...
    'At the beginning of the trial, please rate the most intense burning sensation you are experiencing from\n' ...
    'either probe A or B at the beginning of stimulation on a scale of 0 - 100.\n\n' ...
    'After this you will then be asked how much probe A or B\n' ...
    'is BURNING, feels WARM or feels COLD on a scale of 0 - 100.\n\n' ...
    '0 represents no burning/warm/cold sensation, and 100 an extreme burning/warm/cold sensation.\n'...
    'Please use the entire length of the scale and rate 0 if you experience none of the associated sensation.\n\n'...
    'It is important that you only rate the sensation coming from ONE probe, as instructed by the experimenter.\n\n' ...
    'When you are ready, press and key to begin.'];

vars.instructions.StartVas = 'When instructed by the experimenter, press a key to start rating';

vars.instructions.Question = {'At the moment, what is the strongest BURNING sensation you are feeling?',...
                               'At the moment, how much is the stimulus BURNING?',...
                               'At the moment, how WARM is the stimulus?',...
                               'At the moment, how COLD is the stimulus?' }; 
                           
vars.instructions.QuestionCode = [1 2 3 4]; % 1 - initial burn, 2 - burning, 3 - warm, 4 - cold
vars.instructions.whichQuestion = [1 1 1 1]; %Enable or disable question (1 = enabled) %% not sure this works, needs fixing!

vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR
      
vars.instructions.ThermodeSwitch = 2:vars.task.NTrialsChange:(vars.task.NBlocksTotal*16); %When to ask participant to change thermode position (starting from 2)
vars.instructions.Thermode = 'Please wait whilst we change the location of the thermode. Press a key when done.';

vars.instructions.ConfEndPoints = {'Not at all', 'Extreme'};    
%% Waiting during stimulation
vars.waitStim.text = 'When the countdown ends, please rate your experience. Press SPACE when done.';
vars.waitStim.secs = 5; %the number of seconds you want to stimulate TGI for
vars.waitStim.textSize = 65;

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


