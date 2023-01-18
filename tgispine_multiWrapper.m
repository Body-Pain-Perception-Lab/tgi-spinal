function tgispine_multiWrapper(whichPart)
%
% Project: TGI spine - experiment II
%
% Input: whichPart  optional argument to only run one of the TPL component tasks
%       0   Practice
%       1   Calibration
%       2   Main experiment - first session
%       3   Main experiment - second session
% 
% Sets paths, and calls functions
%
% Alexandra G. Mitchell
% Adapted from code by Camila Sardeto Deolindo
% Last edit: 16.01.2023

% Close existing workspaces
close all; clc;

%% Define general vars across tasks
addpath helperFunctions % getting helper functions to path

% Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor
vars.control.devFlag  = 1; 
% load other relevant parameters
VAS_loadParams;

% path to save data to - should be changed depending on laptop (VAS_loadParams.m)
datPath = vars.filename.path;
runPath = pwd;

%cd(fullfile('.', 'tasks')) % cd to task folder

% Check that PTB installation
%[oldLevelScreen, oldLevelAudio] = checkPTBinstallation;

%% 00 Run Tutorial
if ((nargin < 1) || (whichPart==0))
    vars.control.taskN = 1;
    runPrac = input('Would you like to run a practice? 1-yes 0-no ');
    if runPrac
        %practice
        VAS_practice(vars);
    end
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('Practice completed. Continue to the calibration? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% 01 Run Calibration
rep = 1; %setting repeat loop to one
while rep == 1 
    if ((nargin < 1) || (whichPart==1)) %&& (participant.partsCompleted(taskN) == 0)
        vars.control.taskN = 1;
        VAS_calibration(vars); % Launcher
        participant.partsCompleted(1) = 1;
        % Save metadata
        %save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
        % Continue to next task
        if (nargin < 1) % should it be repeated?
            repeatCal = input('Calibration completed. Do you need to repeat the Calibration Step? 1-yes, 0-no ');
            if repeatCal == 0
                goOn1 = input('Continue to the Main Task? 1-yes, 0-no ');
                rep = 0; %closing repeat loop
                if ~goOn1
                    return
                end
            end
        end
    end
end

%% 02 Run Main Task - first session

if ((nargin < 1) || (whichPart==2)) %&& (participant.partsCompleted(2) == 0)
    vars.control.taskN = 2;
    VAS_run(vars); % Launcher
    participant.partsCompleted(2) = 1;
    % Save metadata
    %save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('Main task part 1 completed, continue to part 2? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% 03 Run Main Task - second session

if ((nargin < 1) || (whichPart==3)) %&& (participant.partsCompleted(2) == 0)
    vars.control.taskN = 3;

    % if vars.RunSuccessfull
    VAS_run(vars); % Launcher
    participant.partsCompleted(3) = 1;
    % Save metadata
    %save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
    % Continue to next task
    done_msg = 'The experiment is completed';
    disp(done_msg)
end

% cd back to previous folder
cd(runPath)

end