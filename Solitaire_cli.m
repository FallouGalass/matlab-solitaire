close all;
clear all;
clc;

[tableau, foundation, stock, waste, mask] = Begin;
% [tableau, mask, error] = Tableau(tableau, mask, card, move)
% [stock, waste, error] = Stock(stock, waste, action)
% [foundation, win, error] = Foundation(foundation, card)
moves = 0;
win = 0;

while win == 0
    foundation
    waste
    gametableau = tableau.*mask
	Render(fig, tableau, foundation, stock, waste, mask);
    
    a = input('Your options are:\n(1) take card from stock\n(2) take card from waste to tableau\n(3) move card in tableau\n(4) move card from tableau to foundation\n(5) move card from waste to foundation\nYour choice: ');
    moves = moves+1; %every move counts as a score, even wrong moves! So make wise decisions ;)
    if a == 1
        if isempty(stock) && isempty(waste)
            disp('There are no more cards available.')
        else
            [stock, waste, error] = Stock(stock, waste, 1);
        end
    elseif a == 2
        b = input('To which column do you want to move the card in the tableau? ');
        if b >= 1
            [tableau, mask, error] = Tableau(tableau, mask, waste(end), -b); %adds the last waste card to the tableau, if possible
            if error == 500
                disp('That is not a valid move.')
            elseif error == 1975
                disp('That column does not exist.')
            else
                [stock, waste, error] = Stock(stock, waste, 2); %if it was a succesfull move, the card is removed from the waste
            end
        else
            disp('That column does not exist.')
        end
    elseif a == 3
        card = input('Which card would you like to move? ');
        move = input('To which column would you like to move it? ');
        if move >= 1
            [tableau, mask, error] = Tableau(tableau, mask, card, move); %executes that move
            if error == 303
                disp('That card does not exist.')
            elseif error == 1975
                disp('That column does not exist.')
            end
        else
            disp('That column does not exist.')
        end
    elseif a == 4
        card = input('Which card would you like to move to the foundations? ');
        [foundation, win, error] = Foundation(foundation, card);
        if error == 123
            disp('The card cannot be moved to the foundation.')
        else
            [tableau, mask, error] = Tableau(tableau, mask, card, 0); %removes that card from the tableau
        end
    elseif a == 5
        [foundation, win, error] = Foundation(foundation, waste(end)); %adds card to foundation
        if error == 123
            disp('The card cannot be moved to the foundation.')
        else
            [stock, waste, error] = Stock(stock, waste, 2); %if it was a succesfull move, the card is removed from the waste
        end
    elseif a == 9999 %cheat method to stop playing if you've had enough
        win = 1;
    else
        disp('That choice does not exist.')
    end
end

score = num2str(moves);
disp('YOU WIN!') %end of the game, you win!
disp(['It took you ',score,' moves.']) %displaying total score

Savescore(score); %asking if the score needs to be saved
disp('The current leaderboard is:')
[highscore] = Leaderboard() %displays the current leaderboard (all scores)
