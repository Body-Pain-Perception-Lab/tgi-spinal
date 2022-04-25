%function [] = audioPlay(scr, vars)
%% PsychPortAudio function
% Plays a simple tone for 250ms through psychotoolbox
% Uses code from ptbConfig (with an audio set up, where vars.control.audio
% (in VAS_loadParams.m) needs to be set to 1, 
% to make sure audio features are set up)
% 
% AG. Mitchell: 22.04.22

%% Audio parameters
InitializePsychSound(1);
% Number of channels and Frequency of the sound
nrchannels = 2;
sampRate = 48000;
% How many times to we wish to play the sound
repetitions = 1;
beepLengthSecs = 0.25;
beepPauseTime = 0.5; % Length of the pause between beeps
startCue = 0; %Start immediately (0 = immediately)
% Should we wait for the device to really start (1 = yes)
waitForDeviceStart = 1;

% open PTB audio
pah = PsychPortAudio('Open', [], 1, 1, sampRate, nrchannels);

% Sound settings
PsychPortAudio('Volume', pah, 0.5);
myBeep = MakeBeep(450, beepLengthSecs, sampRate); % Make a beep 

% Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
PsychPortAudio('FillBuffer', pah, [myBeep; myBeep]);

% Start audio playback #1
PsychPortAudio('Start', pah, repetitions, startCue, waitForDeviceStart);
WaitSecs(beepPauseTime)
PsychPortAudio('Stop', pah);




%end
