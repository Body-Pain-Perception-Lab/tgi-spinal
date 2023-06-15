function [scr]=openScreen(scr)
% open screen window
if ~exist('scr','var')
    if ~isfield(scr, 'win')
        % Diplay configuration
        [scr] = displayConfig(scr);
        scr.bkColor = scr.BackgroundGray;
        AssertOpenGL;
        [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray); %,[0 0 1920 1080] mr screen dim
        PsychColorCorrection('SetEncodingGamma', scr.win, 1/scr.GammaGuess);
        
        % Set text size, dependent on screen resolution
        if any(logical(scr.winRect(:)>3000))       % 4K resolution
            scr.TextSize = 65;
        else
            scr.TextSize = textSize;
        end
        Screen('TextSize', scr.win, scr.TextSize);
        
        % Set priority for script execution to realtime priority:
        scr.priorityLevel = MaxPriority(scr.win);
        Priority(scr.priorityLevel);
        
        % Determine stim size in pixels
        scr.dist = scr.ViewDist;
        scr.width  = scr.MonitorWidth;
        scr.resolution = scr.winRect(3);                    % number of pixels of display in horizontal direction
    end
end
end
