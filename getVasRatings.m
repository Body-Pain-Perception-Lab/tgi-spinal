function [vasResp, RT] = getVasRatings(keys, scr, vars, instruction_n)
%
% Get the participants confidence response - either keyboard or mouse
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 07/02/2022

switch vars.control.inputDevice 
    case 1 % Mouse response
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
%         vars.control.vasTime = vasTimeStamp;
%         vars.control.vasRT = RT;
        
        % Show rating in command window
        if ~isnan(vasResp)
            disp(['Rating recorded: ', num2str(vasResp)]); 
        else
            disp(['No rating recorded.']);
        end

%     case 2 % Keyboard response
%         
%         % Rate confidence: 1 Unsure, 2 Sure, 3 Very sure
%         
%         Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
%         DrawFormattedText(scr.win, [vars.InstructionConf], 'center', 'center', scr.TextColour);
%         [~, StartConf] = Screen('Flip', scr.win);
%         vars.ConfOnset = StartConf;
%         
%         % loop until valid key is pressed or ConfT is reached
%         while (GetSecs - StartConf) <= vars.ConfT
%             
%             % KbCheck for response
%             if keys.KeyCode(keys.One)==1
%                 % update results
%                 vars.ConfResp = 1;
%                 vars.ValidTrial(2) = 1;
%             elseif keys.KeyCode(keys.Two)==1
%                 % update results
%                 vars.ConfResp = 2;
%                 vars.ValidTrial(2) = 1;
%             elseif keys.KeyCode(keys.Three)==1
%                 % update results
%                 vars.ConfResp = 3;
%                 vars.ValidTrial(2) = 1;
%             elseif keys.KeyCode(keys.Escape)==1
%                 vars.abortFlag = 1;
%                 
%             else
%                 % DrawText: Please press a valid key...
%             end
%             
%             [~, EndConf, keys.KeyCode] = KbCheck;
%             WaitSecs(0.001);
%         
%             if ~vars.fixedTiming
%                 % Stop waiting when a rating is made
%                 if(vars.ValidTrial(2)), WaitSecs(0.2); break; end
%             end
%             
%             % Compute response time
%             vars.ConfRatingT = (EndConf - StartConf);
%             
%         end
%         
%         % show brief feedback
%         if ~isnan(vars.ConfResp)
%             switch vars.ConfResp
%                 case 1
%                 feedbackXPos = ((scr.winRect(3)/2)-350);
%                 case 2
%                 feedbackXPos = ((scr.winRect(3)/2));
%                 case 3
%                 feedbackXPos = ((scr.winRect(3)/2)+350);
%             end
%             
%             feedbackString = 'O';
%             Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
%             DrawFormattedText(scr.win, [vars.InstructionConf], 'center', 'center', scr.TextColour);
%             DrawFormattedText(scr.win, feedbackString, feedbackXPos, ((scr.winRect(4)/2)+200), scr.AccentColour);
%             [~, ~] = Screen('Flip', scr.win);
%             WaitSecs(0.5);
%             
%             disp(['Rating ', num2str(instruction_n), ' recorded: ', num2str(vars.ConfResp)]);
%             
%         else
%             disp(['No rating ', num2str(instruction_n), ' recorded.']);
%         end
        
end
  % Draw Fixation
        [~, ~] = Screen('Flip', scr.win);            % clear screen
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        scr = drawFixation(scr); % fixation point
        [~, ~] = Screen('Flip', scr.win);
        WaitSecs(0.2)
end