%function pseudo_thermodes(keys, scr, vars)
%% Pseudorandomise thermodes
% A function to ensure effective counterbalancing of thermode location for
% the spinal TGI study
% Created by A.G. Mitchell on 17.03.2022
% Last edited:

% NB: this functions runs with an associated 'counterbalancing' file, where
% specific procedures are indicated by a number

% get specific procedure order from main file
order = str2double(vars.filename.ID(2));

% isolate trials for that specific procecure so can easily index
procedure = vars.task.randomise(:,1);

%% NEED TO FIGURE OUT HOW TO EXTRACT MEANINGFUL INFORMATION FROM A TABLE

A(A(:,1)==0,2)

switch order
    case 1
    case 2
    case 3
    case 4
end
%end
