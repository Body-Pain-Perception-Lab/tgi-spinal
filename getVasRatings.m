function [vasResp, RT] = getVasRatings(keys, scr, vars, instruction_n)
%
% Get the participants confidence response - either keyboard or mouse
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 07/02/2022

% Adapted by A G Mitchell on 08/03/2022 (line 45)

%         answer = 0;                 % reset response flag
    vars.control.vasOnset = GetSecs;
    
    % We set a time-out for conf rating, b/c otherwise it's Inf...
    [position, vasTimeStamp, RT, answer] = slideScale(scr.win, ...
        vars.instructions.Question{instruction_n}, ...
        scr.winRect, ...
        vars.instructions.ConfEndPoints, ...
        'scalalength', 0.7,...
        'scalacolor',scr.TextColour,...
        'slidercolor', [0 0 0],...
        'linelength', 15,...
        'width', 6,...
        'device', 'mouse', ...
        'stepsize', 10, ...
        'startposition', 'shuffle', ...
        'range', 2, ...
        'aborttime', vars.task.RespT);
    
%         vars.control.vasOffset = GetSecs;
    %update results
    if answer
        vasResp = position;
    else
        vasResp = NaN;
%             vars.ValidTrial(2) = 1;
    end
        
    % Show rating in command window
    if ~isnan(vasResp)
        disp(['Rating recorded: ', num2str(vasResp)]); 
    else
        disp(['No rating recorded.']);
    end
    % setting a mouse at a random position on the screen before each VAS -
    % for case = 1 only
    SetMouse(round(rand * scr.xPix), round(rand * scr.yPix), scr.win);

    % Draw Fixation
    [~, ~] = Screen('Flip', scr.win);            % clear screen
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    scr = drawFixation(scr); % fixation point
    [~, ~] = Screen('Flip', scr.win);
    WaitSecs(vars.task.feedbackBPtime)
end