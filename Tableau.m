function [tableau, mask, error] = Tableau(tableau, mask, card, move)
% The main pile of the game

%% Initiation
error = 0;
originaltableau = tableau;
% move: 0 goes to remove
% move > 0 goes to move to column
% move < 0 goes to add to column
% note: this means move only contains a column, not a specific place!

%% Move cards
if move < 0
	%% Add card (from waste)
	move = -move; % Make the move positive, to turn it into a column
	if move <= 7 && move >= 1
	% Check if that column exists (in range of tableau)
		stop = 0;
		rowmove = 1;
		while stop == 0
			% Find first empty spot under the existing cards
			if tableau(rowmove, move) ~= 0
				rowmove = rowmove +1;
			else
			% If empty spot is found
				value1 = mod(card,100); % Find the value of the first card
				permission = 0;
				% Allow only kings to be placed on empty columns
				if value1 == 13 && rowmove == 1
					permission = 1;
				elseif rowmove ~= 1
					value2 = mod(tableau(rowmove-1, move), 100); % Find the value of the second card
					% Find the suit of the cards
					suit1 = int32(card/100);
					suit2 = int32(tableau(rowmove-1, move) / 100);
					% Only allow stacking if suits are differently colored
					if mod(suit1, 2) ~= mod(suit2, 2) && (value1 + 1) == value2
						permission = 1;
					end
				end
				if permission == 1
				% If the suits are not the same (ie black and red) and if the card value is directly below the other;
				% OR if it is a king to the first position
					tableau(rowmove, move) = card; % Paste the card under it
					stop = 1;
				else
				% Otherwise the cards may not be stacked
					error = 500; % Invalid move
					stop = 1;
				end
			end
		end
	else
        error = 1975; % The column that the card is moving to does not exist
    end
elseif move == 0
	%% Remove card/Move to foundations
	if ismember(card,tableau)
	% If card is in tableau
        [rowcard, columncard] = find(tableau == card);
        if tableau(rowcard+1, columncard) == 0
		% If card is the top card of that column
			% Remove it
            tableau(rowcard, columncard) = 0;
            if rowcard ~= 1
			% If the card is not the first in its column
				% Update the mask to show the card under it
                mask(rowcard-1, columncard) = 1;
            end
        else
            error = 500; % Invalid move
        end
    else
        error = 404; % Card not found
    end
else % else card > 0
	%% Move card(s) to different column
	if ismember(card, tableau)
	% If card is in tableau
        if move <= 7
		% If the given column exists
            [rowcard, columncard] = find(tableau == card); % Find coordinates of card that needs to be moved
            originalrowcard = rowcard;
            stop = 0;
            copy = [];
            while stop == 0 % Establish which cards need to be moved
                if tableau(rowcard,columncard) == 0 || rowcard == 20
				% Check if the end of the pile has been reached
                    stop = 1;
				else
				% If not reached, add card to transport stack
                    copy = [copy, tableau(rowcard, columncard)]; % Save (copy) all the cards below the selected card
                    tableau(rowcard,columncard) = 0; % After being copied, remove the card
                    rowcard = rowcard + 1;
                end
            end
            stop = 0;
            rowmove = 1;
            while stop == 0
                if tableau(rowmove, move) ~= 0 % Find first empty spot under the existing cards
                    rowmove = rowmove + 1;
                else
                    value1 = mod(card, 100); % Find the value of the first card
                    permission = 0;
                    if value1 == 13 && rowmove == 1
                        permission = 1;
                    elseif columncard ~= move && rowmove ~= 1
                        value2 = mod(tableau(rowmove-1,move), 100); % Find the value of the second card
						% Find the suit of the cards
                        suit1 = int32(card/100);
                        suit2 = int32(tableau(rowmove-1, move) / 100);
						% If suits are opposite color, and card is next in
						% line, allow stacking
                        if mod(suit1, 2) ~= mod(suit2, 2) && (value1 + 1) == value2
                            permission = 1;
                        end
                    else
                        permission = 0;
                    end
                    if permission == 1
                        % If the suits are not the same (ie black and red) and if the card value is directly below the other;
                        % OR if it is a king being moved to the first position
                        for i = 1:length(copy) % Then paste the cards one-by-one under them
                            tableau(rowmove +i -1, move) = copy(i);
                            stop = 1;
                        end
                        if originalrowcard ~= 1 % Update the mask to show the card under it
                            mask(originalrowcard -1, columncard) = 1;
                        end
                    else % Otherwise the cards may not be placed on top of each other
                        error = 500; % Invalid move
                        stop = 1;
                        tableau = originaltableau; % Undo the deleting of cards
                    end
                end
            end
        else
            error = 1975; %the column that it is moving to does not exist
        end
    else
        error = 404; % Card not found in this stack
    end
end

return
