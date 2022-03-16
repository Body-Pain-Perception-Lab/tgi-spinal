%% Define parameters required for VAS presentation for Spinal TGI
%
%
% A G Mitchell 02/03/2022
% Last edit: 07/03/2022

%% Key flags
                                                 
vars.control.inputDevice    = 1;   % Response method for button presses 1 - mouse, 2 - keyboard 
% Now it works only for MOUSE
% need to develop keyboard response

%% Task parameters

%Viewing distance
vars.ViewDist = 56;

%Trials
vars.task.NTrialsTotal       = 3; % Total number of trials
vars.task.NTrialsChange      = 1; % The frequency of thermode change per trial (if thermode is changed every trial, set to 1)

%Times
%vars.task.jitter             = randInRange(1,3,[1,vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 0.25; % this determines how long the feedbacks "button press detected" is shown on the screen
%vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3; %Time to move the thermode to adjacent position
vars.task.RespT              = 8;    % Time to respond
% vars.task.device = 'keyboard'; 
vars.task.device = 'mouse'; %change between either keyboard or mouse, depending on preference

%% Instructions
vars.instructions.textSize = 32;

vars.instructions.StartVas = 'Press a key when stimulation begins';

vars.instructions.Question = {'At the moment, how much is the stimulus BURNING?',...
                               'At the moment, how WARM is the stimulus?',...
                               'At the moment, how COLD is the stimulus?'}; 
                           
vars.instructions.QuestionCode = [1 2 3]; % 1 - burning, 2 - warm, 3 - cold
vars.instructions.whichQuestion = [1 1 1]; %Enable or disable question (1 = enabled) %% not sure this works, needs fixing!

vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR
      
vars.instructions.ThermodeSwitch = 1:vars.task.NTrialsChange:vars.task.NTrialsTotal; %When to ask participant to change thermode position
vars.instructions.Thermode = 'Thank you. Please wait whilst we change the thermode location';

vars.instructions.ConfEndPoints = {'Not at all', 'Extreme'};
%% Waiting during stimulation
vars.waitStim.text = 'When the countdown ends, please rate your experience';
vars.waitStim.secs = 5; %the number of seconds you want to stimulate TGI for
vars.waitStim.textSize = 65;




