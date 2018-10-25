function [] = Render(fig, tableau, foundation, stock, waste, mask)
% Show the game

	%% Initialization
	% Empty the given figure
	clf(fig);

	%% Render stock
	% Create the card button
	% The stock card is always invisible
	uicontrol(fig,...
		'Style', 'pushbutton',...
		'String', length(stock),...
		'FontSize', 14,...
		'ForegroundColor', [0 0 1],...
		'Position', [20 550 80 110],...
		'Callback', {@StockCallback, fig});
	
	%% Render waste
	% Check whether waste contains cards
	if isempty(waste)
		% Create disabled button as placeholder
		uicontrol(fig,...
			'Style', 'togglebutton',...
			'BackgroundColor', [0 0.5 0.125],...
			'Position', [110 550 80 110],...
			'Enable', 'off');
	else
		% Retrieve card text and color
		[text, color] = CardChars(waste(end));

		% Create the card button
		uicontrol(fig,...
			'Style', 'togglebutton',...
			'String', text,...
			'FontSize', 14,...
			'ForegroundColor', color,...
			'Position', [110 550 80 110],...
			'Callback', {@WasteCallback, fig});
	end
	
	%% Render foundation
	for col = 1:4
		% Retrieve the uppermost card of the current column
		card = foundation(find(foundation(:, col), 1, 'last'), col);
			if isempty(card)
			% If the current foundation stack has no cards yet
				[text, color] = CardChars(col * 100);
				
				uicontrol(fig,...
					'Style', 'togglebutton',...
					'BackgroundColor', [0 0.5 0.125],...
					'String', text(1),... % Only show the suit
					'FontSize', 32,...
					'ForegroundColor', color,...
					'Position', [((col)*90 + 200) 550 80 110],...
					'Callback', {@FoundationCallback, fig});
				
				
			else
				% Retrieve card text and color
				[text, color] = CardChars(card);
				
				% Create the card button
				uicontrol(fig,...
					'Style', 'togglebutton',...
					'String', text,...
					'FontSize', 14,...
					'ForegroundColor', color,...
					'Position', [((col)*90 + 200) 550 80 110],...
					'Callback', {@FoundationCallback, fig});
			end
	end
	
	%% Render tableau
	for col = 1:7
		for row = 1:20
			card = tableau(row, col);
			if card ~= 0
			% If there are still more cards available
				% Find necessary card height
				height = 20;
				if row == 20 || tableau(row+1, col) == 0
					height = 110;
				end
				
				if mask(row, col) == 1
				% If card is not masked
					% Retrieve card text and color
					[text, color] = CardChars(card);

					% Create the card button
					uicontrol(fig,...
						'Style', 'togglebutton',...
						'String', text,...
						'FontSize', 14,...
						'ForegroundColor', color,...
						'Position', [((col-1)*90 + 20) (-(row-1)*20 + 420 + (110 - height)) 80 height],...
						'Callback', {@TableauCallback, fig, card, col});
				else
				% Else card is masked and shouldn't be shown
					uicontrol(fig,...
						'Style', 'togglebutton',...
						'Enable', 'off',...
						'String', '---',...
						'FontSize', 14,...
						'Position', [((col-1)*90 + 20) (-(row-1)*20 + 420 + (110 - height)) 80 height]);
				end
			elseif card == 0 && row == 1
			% Display a placeholder if the row is empty
				uicontrol(fig,...
					'Style', 'togglebutton',...
					'BackgroundColor', [0 0.5 0.125],...
					'Position', [((col-1)*90 + 20) (-(row-1)*20 + 420) 80 110],...
					'Callback', {@TableauCallback, fig, 0, col});
			else
			% Else break this for-loop and continue with the next column
				break
			end
		end
	end

return;


%% Additional functions
function [text, color] = CardChars(card)
% Return the correct characters to print on a button
%% CardChars()
	% Set the icon and color for the card suit
	switch int32(card / 100)
		case 1 % Diamonds
			text = char(9830);
			color = [1 0 0];
		case 2 % Clubs
			text = char(9827);
			color = [0 0 0];
		case 3 % Hearts
			text = char(9829);
			color = [1 0 0];
		case 4 % Spades
			text = char(9824);
			color = [0 0 0];
	end

	% Set the card number
	switch mod(card, 100)
		case 1 % Ace
			text = [text 'A'];
		case 11 % Jack
			text = [text 'J'];
		case 12 % Queen
			text = [text 'Q'];
		case 13 % King
			text = [text 'K'];
		otherwise % Number
			text = [text int2str(mod(card, 100))];
	end
return

function [] = TableauCallback(src, event, fig, card, col)
% Callback function for when a togglebutton in the tableau is toggled
%% TableauCallback()
	if src.Value == 1
		% Assign card to correct variable
		if getappdata(fig, 'from') == 0 
			if card ~= 0
				setappdata(fig, 'from', card);
				% Change card background color
				src.BackgroundColor = [0.8 0.8 1];
			else
				% Toggle empty row button back to off
				src.Value = 0;
			end
		else
			setappdata(fig, 'to', col);
			% Change card background color
			src.BackgroundColor = [0.8 0.8 1];
		end
	else
		if card ~= 0
			src.BackgroundColor = [0.94 0.94 0.94];
		else
			src.BackgroundColor = [0 0.5 0.125];
		end
		setappdata(fig, 'from', 0);
	end
	
return

function [] = FoundationCallback(src, event, fig)
% Callback function for when a togglebutton is toggled in the foundations
%% FoundationCallback()
	% Assign card to correct variable
	% Only allow selection when a card has already been selected
	if getappdata(fig, 'from') == 0 
		% Toggle empty row button back to off
		src.Value = 0;
	else
		setappdata(fig, 'to', 13);
		% Change card background color
		src.BackgroundColor = [0.8 0.8 1];
	end
return

function [] = StockCallback(src, event, fig)
% Callback function for when the stock button is pressed
%% StockCallback()
	setappdata(fig, 'from', 11);
	setappdata(fig, 'to', 12);

return

function [] = WasteCallback(src, event, fig)
% Callback function for when the waste button is toggled
%% WasteCallback()
	if src.Value == 1
		% Change card background color
		src.BackgroundColor = [0.8 0.8 1];
		
		% Assign variable
		setappdata(fig, 'from', 12);
	else
		src.BackgroundColor = [0.94 0.94 0.94];
		setappdata(fig, 'from', 0);
	end
	% 'to' will be set in the tableau or foundation callback
return
