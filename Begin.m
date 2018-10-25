function [tableau, foundation, stock, waste, mask] = Begin()
% Initiate the game

%% Create array filled with all 52 cards
cards = [101:113 201:213 301:313 401:413];

%% Create the Tableau, the 'playing field'
tableau = zeros(20,7);
for k = 0:6 % Go through the matrix in a triangular way
    for i = 1:(7-k)
        place = ceil(rand*length(cards)); %random card (shuffling)
        tableau(i, i+k) = cards(place);
        cards(place) = [];
    end
end

%% Create the mask, which is used to hide cards
mask = ones(20,7);
for k = 1:7 % Go through the matrix in a triangular way
    for i = 1:(7-k)
        mask(i, i+k) = 0;
    end
end

%% Create the Stock with the remaining cards
stock = zeros(1,24);
for i = 1:24
% Randomly shuffle the cards into the stock
    place = ceil(rand*length(cards));
    stock(i) = cards(place);
    cards(place) = [];
end

% Initiate waste to empty
waste = [];
% Initiate foundations to all zero (empty)
foundation = zeros(13, 4);

return
