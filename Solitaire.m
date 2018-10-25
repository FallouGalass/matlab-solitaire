% The game
% This is the wrapper that combines all functions into one big game.
%
% Regarding the card numbers, each card is represented by a 3 digit number:
% Digit one: the suit
% Each suit has a unique number, as follows
%	1 - Diamonds
%	2 - Clubs
%	3 - Hearts
%	4 - Spades
% As you can see, all red cards are odd, all black cards even
%
% Digit two and three: the card
% Each card has a unique number, as follows
%	1 - Ace
%	2-10 - Numbers 2-10
%	11 - Jack
%	12 - Queen
%	13 - King
%
% There are additional special (single/double-digit) numbers, as follows
% 1-7 - Columns of the tableau
% 11 - Stock pile
% 12 - Waste pile
% 13 - Foundations
%
% The scoring mechanism can be found at https://en.wikipedia.org/wiki/Klondike_(solitaire)#Scoring

close all;
clear all;
clc;

%% Initiate game
% Disable a deprecation warning for statusbar()
warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% Create and show the window
fig = figure('Visible', 'on',...
	'Resize', 'off',...
	'Menubar', 'none',...
	'Name', 'Solitaire',...
	'Color', [0 0.3451 0.0824],...
	'Position', [200 200 661 681]);
statusbar(fig, 'Statusbar programmed and copyrighted by Yair M. Altman');

% Error defaults to 0, no error
error = 0;
% Declare the two global card variables that'll change when a button is pressed
% These are attached to the solitaire window
% They are set to 0 by default, meaning no card
setappdata(fig, 'from', 0);
setappdata(fig, 'to', 0);

% Randomly divide the playing cards
[tableau, foundation, stock, waste, mask] = Begin();
% Show the game
Render(fig, tableau, foundation, stock, waste, mask);

%% Game loop

win = 0;
score = 0;
% Loop until the game is finished
while ~win
	% Check the move values
	if getappdata(fig, 'from') ~= 0
		if getappdata(fig, 'to') ~= 0
		% If both moves have been filled, parse them
			% Store the moves set in easy variables
			from = getappdata(fig, 'from');
			to = getappdata(fig, 'to');
			
			% In this switch statement, several things happen:
			% - The moves are parsed and executed
			% - The score is increased by the necessary amount
			switch from
				case 11 % Stock
					% Move card from stock to waste
					[stock, waste, error] = Stock(stock, waste, 1);
					% If the waste is recycled, subtract 100 points
					% However, score can't be below zero
					if isempty(waste) && ~isempty(stock)
						score = score - 50;
						if score < 0
							score = 0;
						end
					end
				case 12 % Waste
					if to == 13 % Upon immediate move to foundations
						[foundation, win, error] = Foundation(foundation, waste(end));
						if ~error
							[stock, waste, error] = Stock(stock, waste, 2);
							score = score + 10;
						end
					else % Else it's just a move to the tableau
						[tableau, mask, error] = Tableau(tableau, mask, waste(end), -to);
						if ~error
							[stock, waste, error] = Stock(stock, waste, 2);
							score = score + 5;
						end
					end
				otherwise % Move cards of the tableau
					% Number of masked cards
					unmasked = length(find(mask));
					
					if to < 10 % If recipient is tableau
						[tableau, mask, error] = Tableau(tableau, mask, from, to);
					else % Else recipient is foundations
						% At this point it's not yet known if the card can
						% be moved to the foundations, so keep store the
						% tableau in a temporary variable
						[newTableau, newMask, error] = Tableau(tableau, mask, from, 0);
						if ~error
							[foundation, win, error] = Foundation(foundation, from);
							if ~error
							% If both moves are possible, update tableau
								tableau = newTableau;
								mask = newMask;
								score = score + 10;
							end
						end
					end
					
					% Add five points for every turned tableau card
					score = score + ((length(find(mask)) - unmasked) * 5);
			end
			
			% Render new figure
			Render(fig, tableau, foundation, stock, waste, mask);
			
			% Parse errors
			switch error
				case 0
					% Do nothing
				case 404
					error = sprintf('Card %i does not exist in this stack', error);
				case 500
					error = 'This move is not allowed';
				case 100
					error = 'There is no card in the waste upon request';
				case 1975
					error = 'Column does not exist';
				otherwise
					error = sprintf('Unknown error: %i', error);
			end
			
			% Update status
			if error
				statusbar(fig, sprintf('Error: %s', error));
			else
				statusbar(fig, sprintf('Score: %i', score));
			end
			
			% Reset moves
			setappdata(fig, 'from', 0);
			setappdata(fig, 'to', 0);
		else
			% Give the script a little pause, else it'll hog
			pause(0.1)
		end
	else
		% Give the script a little pause, else it'll hog
		pause(0.1)
	end
	
	% Check whether figure still exists
	% This is done here because the above pause takes up the majority of
	% this loop's execution time
	if ~ishandle(fig)
		% If the figure does not exist, it's been closed, and the game
		% should exit
		return;
	end
end

%% Finalist's dialogs
% Upon reaching this point, the user has won, so display a victory text
uicontrol(fig,...
	'Style', 'text',...
	'String', 'Congratulations! You''ve won',...
	'Fontsize', 32,...
	'ForegroundColor', [1 1 1],...
	'BackgroundColor', [0 0.3451 0.0824],...
	'HorizontalAlignment', 'center',...
	'Position', [150 310 380 100]);

% Save the user's score
Savescore(score);

% Retrieve highscores
highscores = Leaderboard();

% Find out how many to display, with a max of 10
[pos, ~] = size(highscores);
if pos > 10
	pos = 10;
end

% Display highscores
uicontrol(fig,...
	'Style', 'text',...
	'String', 'Top Ten',...
	'Fontsize', 16,...
	'ForegroundColor', [1 1 1],...
	'BackgroundColor', [0 0.3451 0.0824],...
	'HorizontalAlignment', 'center',...
	'Position', [0 280 660 25]);

if pos == 0
% If there are no highscores, say so
	uicontrol(fig,...
		'Style', 'text',...
		'String', '<--There are no highscores yet-->',...
		'Fontsize', 16,...
		'ForegroundColor', [1 1 1],...
		'BackgroundColor', [0 0.3451 0.0824],...
		'HorizontalAlignment', 'center',...
		'Position', [0 255 660 25]);
end

for hs = 1:pos
	% Name and rank
	uicontrol(fig,...
		'Style', 'text',...
		'String', sprintf('%i. %s', hs, highscores{hs, 1}),...
		'Fontsize', 16,...
		'ForegroundColor', [1 1 1],...
		'BackgroundColor', [0 0.3451 0.0824],...
		'HorizontalAlignment', 'left',...
		'Position', [200 (-(hs)*25 + 280) 400 25]);
	% Score
	uicontrol(fig,...
		'Style', 'text',...
		'String', sprintf('%i', highscores{hs, 2}),...
		'Fontsize', 16,...
		'ForegroundColor', [1 1 1],...
		'BackgroundColor', [0 0.3451 0.0824],...
		'HorizontalAlignment', 'left',...
		'Position', [400 (-(hs)*25 + 280) 400 25]);
	
end
