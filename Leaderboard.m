function [highscores] = Leaderboard()
% Retrieve all scores from file

% Retrieve highscore data from file if file exists
if exist('leaderboard.txt') == 2
	leaderboard = tdfread('leaderboard.txt','tab');
else
	highscores = {};
	return
end

% Parse highscores
[a, ~] = size(leaderboard.Name);
A = cell(a, 2);
for i = 1:a
	% Trim trailing whitespace from name
    A{i, 1} = strtrim(leaderboard.Name(i, :));
    A{i, 2} = leaderboard.Score(i, :);
end
% Sort highscores by scores ascending
highscores = sortrows(A,-2);

return