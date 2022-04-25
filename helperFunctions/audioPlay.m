%function [] = audioPlay(scr, vars)
%% PsychPortAudio function
% Plays a simple tone for 200ms through psychotoolbox
% will need ptgConfig and a paramater script to run as well
% AG. Mitchell: 22.04.22

%% Audio parameters
InitializePsychSound(1);
% Number of channels and Frequency of the sound
nrchannels = 2;
freq = 48000;
% How many times to we wish to play the sound
repetitions = 1;
% Length of the beep
beepLengthSecs = 1;
% Length of the pause between beeps
beepPauseTime = 1;
% Start immediately (0 = immediately)
startCue = 0;

% Should we wait for the device to really start (1 = yes)
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;

pa = PsychPortAudio('Open');





%end
