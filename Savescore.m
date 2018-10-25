function [] = Savescore(score)
% Save score to file

% If the leaderboard file doesn't yet exist, create it
if exist('leaderboard.txt', 'file') ~= 2
	fileID = fopen('leaderboard.txt','w');
	% Print headers to file
	fprintf(fileID, 'Name\tScore\n');
	% Close file
	fclose(fileID);
end

done = 0;
while done ~= 1
	% Create a dialog asking the user to save their score
	Save = questdlg('Do you want to save your highscore?', 'Save highscore', 'Yes', 'No', 'Yes');
	% Parse answer
	switch Save
		case {'yes', 'Yes'}
			check = 0;
			while check < 1
				% Ask user for name
				name = inputdlg(sprintf('What is your nickname? \n(must not exceed 10 characters)'), 'Specify name');
				if strlength(name) > 10
					disp('Sorry, but that name is too long.')
				elseif isempty(strlength(name))
					disp('Okido! Highscore is not saved.')
					return
				else
					check = 1;
				end
			end
			% Open highscore file, will create file if it doesn't exist
			fileID = fopen('leaderboard.txt','a');
			% Print to file in format [name (tab) score]
			fprintf(fileID, '%s\t%i\n', name{1}, score);
			% Close file
			fclose(fileID);
			
			disp('Highscore saved successfully.')
			done = 1;
		case {'no', 'No', 'nope', 'Nope', 'not today', 'no thanks', ''}
			disp('No problem! Highscore is not saved.')
			done = 1;
		otherwise
			disp('You have to answer yes or no.')
	end
end

return