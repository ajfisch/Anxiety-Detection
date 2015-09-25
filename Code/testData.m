%testData

function [baselines] = testData()

victims = {'test1', 'test2'};
victims = cellstr(victims);

responseMat = [ 1, 1, 3, 3, 2, 2, 0;
                1, 1, 2, 2, 3, 3, 0];

questionTimes = [5, 10, 17, 26, 33, 39, 0;
                 4, 10, 16, 25, 33, 40, 0];
             
numVictims = size(responseMat,1);

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
    
    %visualize the data 
    subplot(5,2,v)
    plot(times, values, 'o');
    hold on;
    plot(points, interpolated);
    ylim([0 5]);
    title(strcat('Interp for ', victims{v}));
end
            
            
            
            