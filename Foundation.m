function [foundation, win, error] = Foundation(foundation, card)
% The goal of the game

%% Initialization
error=0;

value = mod(card, 100); % Find the value of the card
suit = int32(card/100); % Find the suit of the card (this will be the column of the card)

%% Checks whether move is possible
stop = 0;
row = 1;
% Move card to the first empty spot
while stop == 0
    if foundation(row, suit) ~= 0
	% If current element in column is not empty
        row = row + 1;
	else
	% Else check whether move is allowed
        stop = 1;
        if row == value
		% If the card belongs here
            foundation(row,suit) = card; % Place card
        else
            error = 500; % Invalid move
        end
    end
end

%% Check whether game is finished
if foundation(13,1) == 113 && foundation(13,2) == 213 && foundation(13,3) == 313 && foundation(13,4) == 413
    win = 1; % If all the king cards have been placed, the game is over!
else
    win = 0;
end

return