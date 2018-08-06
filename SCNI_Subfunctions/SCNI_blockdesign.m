function Blocks = SCNI_BlockDesign(NoCond, BlocksPerCond, StimPerCond, StimPerBlock)

%========================== SCNI_BlockDesign.m ============================
% Initializes a pseudorandom sequence of blocks using a Latin square.
% Stimulus order is conterbalanced across blocks within a run.
%
% INPUTS:   NoCond:         double indicating number of conditions
%           BlocksPerCond:  desired number of blocks of each condition
%           StimPerCond:    number of unique stimuli per condition
%           StimPerBlock:   number of stimulus presentations per block
%
% HISTORY:
%   2017-01-23 - Adapted from APMSubfunctions by murphyap@mail.nih.gov
%==========================================================================

while 1                                     % Until acceptable sequence is generated...
    [M,R] = latsq(NoCond);                  % Generate randomized Latin square sequence
    R = reshape(R,[1,numel(R)]);         	% Reshape matrix into vector
%     R = reshape(R-1,[1,numel(R)]);         	% Reshape matrix into vector
    ImmediateReps = find(diff(R)==0);    	% Find any consecutive repetitions
    if NoCond <= 2
        break;
    end
    if isempty(ImmediateReps)
        if BlocksPerCond > NoCond           
            if R(1)~=R(end)                   
                R = repmat(R,[1,2]);        % Repeat sequence 
                break;
            end
        else
            break;
        end
    end
end
Blocks.Total     	=  NoCond*BlocksPerCond;
while Blocks.Total>numel(R)
    R        = repmat(R,[1,2]);
end
Blocks.Order         = R(1:Blocks.Total);
Blocks.Number        = 1;                           	% Reset block number
Blocks.TrialNumber   = 1;
for b = 1:Blocks.Total
    Blocks.Stimorder(b,:)	= randperm(StimPerCond, min([StimPerCond, StimPerBlock]));   	% Create a pseudo-random permutation of stimulus order
end