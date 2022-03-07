%% Define parameters required for VAS presentation
%
%
% A G Mitchell 02/03/2022
% Last edit: 02/03/2022

%% Key flags
                                                 
vars.control.inputDevice    = 1;   % Response method for button presses 1 - mouse, 2 - keyboard 
% Now it works only for MOUSE
% need to develop keyboard response

%% Task parameters

%Viewing distance
vars.ViewDist = 56;

%Trials
vars.task.NTrialsTotal       = 2; % Total number of trials
%vars.task.NTrialsChange      = 1; % How many trials thermode is changed

%Times
%vars.task.jitter             = randInRange(1,3,[1,vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 0.5; % this determines how long the feedbacks "button press detected" is shown on the screen
%vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3; %Time to move the thermode to adjacent position
vars.task.RespT              = 10;    % Time to respond
vars.task.device = 'keyboard'; 
% vars.task.device = 'mouse'; %change between either keyboard or mouse, depending on preference

%% Instructions
vars.instructions.textSize = 32;

vars.instructions.StartVas = 'Press a key to begin VAS ratings';

vars.instructions.Question = {'At the moment, how much is the stimulus BURNING?',...
                               'At the moment, how UNPLEASANT is the stimulus?',...
                               'At the moment, how WARM is the stimulus?',...
                               'At the moment, how COLD is the stimulus?'}; 
                           
vars.instructions.QuestionCode = [1 2 3 4]; 
vars.instructions.whichQuestion = [1 1 1 1]; %Enable or disable question (1 = enabled)

vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR

vars.instructions.Start = 'Threshold detection \n \n Please position the thermode to location 1. \n \n You will receive a series of stimuli and be asked to rate how you perceived them. Please move the indicator along the line and confirm with a left click, as fast and accurately as possible. \n \n If you do not perceive the sensation that is described in the question, make sure to select the extreme left position (rating = 0/Do not feel it at all).\n \n \n \n  Press SPACE to continue.';
        
%vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position

vars.instructions.ConfEndPoints = {'Not at all', 'Extreme'};
