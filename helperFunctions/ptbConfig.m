function [scr, keys] = ptbConfig(scr)

%% Display Configuration
% Extracted from screenConfig by Niia Nikolova
% Last edit: 16/06/2020

if length(Screen('Screens')) > 1
    scr.ExternalMonitor = 1;% set to 1 for secondary monitor
    % N.B. It's not optimal to use external monitor for newer Win systems
    % (Windows 7+) due to timing issues
else
    scr.ExternalMonitor = 0;
end

if scr.ExternalMonitor
%     scr.screenID = max(Screen('Screens')); 
    scr.screenID = 1;
    if ~isfield(scr,'MonitorHeight') || isempty(scr.MonitorHeight)
        scr.MonitorHeight = 23; end     % in cm 
    if ~isfield(scr,'MonitorWidth') || isempty(scr.MonitorWidth)
        scr.MonitorWidth = 38; end
    if ~isfield(scr,'ViewDist') || isempty(scr.ViewDist)
        scr.ViewDist = 56; end
    scr.GammaGuess = 2.3;
    
else % Laptop
    scr.screenID = min(Screen('Screens')); 
    if ~isfield(scr,'MonitorHeight') || isempty(scr.MonitorHeight)
        scr.MonitorHeight = 16.5; end
    if ~isfield(scr,'MonitorWidth') || isempty(scr.MonitorWidth)
        scr.MonitorWidth = 23.5; end
    if ~isfield(scr,'ViewDist') || isempty(scr.ViewDist)
        scr.ViewDist = 40; end
    scr.GammaGuess = 2.6;
end

% Colour correction
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');


%% Colours and text params
scr.BackgroundGray = 90;%GrayIndex(scr.screenID);
White = WhiteIndex(scr.screenID);
Black = BlackIndex(scr.screenID);
scr.TextColour = Black;
scr.AccentColour = [255 0 0]; % Red
scr.TaskColours = [11 114 193; 39 154 56; 120 91 45];
scr.bkColor = scr.BackgroundGray;

%% Keyboard Configuration
% Set-up keyboard
KbName('UnifyKeyNames')
keys.Escape = KbName('ESCAPE');
keys.Space = KbName('space');

% In scanner
% keys.Trigger = KbName('5%');
% keys.Left = KbName('3#');
% keys.Right = KbName('4$');

keys.Left = KbName('LeftArrow');
keys.Right = KbName('RightArrow');
keys.Up = KbName('UpArrow');
keys.Down = KbName('DownArrow');

keys.One = KbName('1!');
keys.Two = KbName('2@');
keys.Three = KbName('3#');

keys.KeyCode = zeros(1,256);

end