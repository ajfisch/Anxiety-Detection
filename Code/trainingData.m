%script to load data and save it
function [baselines] = trainingData()

victims = {'Cara','Cecilia','Sara', 'Celina', 'Max', 'Adam','Michelle',...
            'Leah','Lucas'};
victims = cellstr(victims);

responseMat = [ 1, 1, 2, 1, 2, 2, 0;
                1, 1, 3, 1, 2, 2, 0;
                1, 2, 3, 2, 3, 3, 0;
                1, 1, 4, 2, 2, 2, 2;
                1, 2, 2, 1, 4, 4, 0;
                2, 2, 3, 3, 3, 3, 0;
                1, 1, 2, 2, 4, 4, 0;
                1, 1, 2, 3, 4, 4, 0;
                1, 1, 3, 2, 2, 3, 3];

questionTimes = [5, 9, 13, 21, 30, 35, 0;
                 4, 8, 14, 21, 28, 33, 0;
                 6, 14, 23, 29, 36, 40, 0;
                 4, 11, 17, 26, 35, 40, 45;
                 5, 16, 24, 31, 44, 50, 0;
                 5, 10, 15, 24, 32, 37, 0;
                 5, 10, 17, 24, 28, 33, 0;
                 5, 11, 16, 26, 35, 40, 0;
                 5, 12, 19, 26, 32, 40, 45];
                 
                 
                 
numQuestions = 6;
numVictims = 9;

x = 1:numQuestions;
dir = 'data';

figure;
for v=1:numVictims
    %adjust based on how many questions there were
    values = responseMat(v,:);
    values = values(values ~= 0);
    times = questionTimes(v,:);
    times = times(times ~= 0);
    endTime = max(times, [], 2);
  
    % Interpolate for points every second 
    points = 3:endTime;
    interpolated = zeros(1, length(points) + 10);
    
    interpolated(1, 1:length(points)) = interp1(times, values, points, 'spline');
    interpolated(interpolated < 1) = 1;
    interpolated(length(points):end) = values(end);
    interpolated = round(interpolated);
    points = 3:length(interpolated) + 2;
    
    %save to output
    baselines(v,1:length(interpolated)) = interpolated;
    
    %save the data
%     filepath = fullfile(dir, victims{v});
%     save(filepath,'interpolated');
    
    %visualize the data 
    subplot(5,2,v)
    plot(times, values, 'o');
    hold on;
    plot(points, interpolated);
    ylim([0 5]);
    title(strcat('',victims{v}));
end