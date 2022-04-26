function [pah] = playAudio(vars, myBeep)
%% PsychPortAudio function
% Plays a simple tone for 250ms through psychotoolbox
% Requires VAS_loadParams.m to run, with vars.control.audio=1
% 
% AG. Mitchell: 22.04.22

% open PTB audio
pah = PsychPortAudio('Open', [], 1, 1, vars.audio.sampRate, vars.audio.nrchannels);

% Sound settings
PsychPortAudio('Volume', pah, 0.5);

% Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
PsychPortAudio('FillBuffer', pah, [myBeep; myBeep]);

% Start audio playback #1
PsychPortAudio('Start', pah, vars.audio.repetitions, ...
    vars.audio.start, vars.audio.waitForDevice);
WaitSecs(vars.audio.beepPause)
PsychPortAudio('Stop', pah);

PsychPortAudio('Close', pah); % close psychportaudio
end
