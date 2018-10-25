function [stock, waste, error] = Stock(stock, waste, action)
% The stock and waste piles
% action = 1: add card to waste
% action = 2: remove card from waste

error = 0;

%% Add a card to the waste
if action == 1
    if isempty(stock)
	% If the pile is empty
        stock = waste;
        waste = [];
		return
    end
    
    waste = [waste, stock(1)]; % Move a card from stock to waste
    stock(1) = [];
end

%% Remove a card from the waste
if action == 2  %Card from waste is used to the tableau
    if isempty(waste)
        error = 100;
	else
        waste(end) = [];
    end
end

return
