function [hrTrace] = peakAnalysis(signal,Fsample, hrRange, ...
    visualize, visualizeFull, windowSize, increment, vidDuration)

numTraces = size(signal, 1);

% Minimum time separation allowed between detected peaks. Follows from the
% maximum expected heart rate.
MinPeakDistance = 60/hrRange(2);

% Extract the heart rate estimates for each color trace
numWindows = floor((vidDuration - windowSize + 1)/increment);
hrEstimates = zeros(numTraces, numWindows);
avgHR = zeros(numTraces, 1);
for i = 1:numTraces
    [~, locs] = findpeaks(signal(i,:), Fsample, ...
        'MinPeakDistance', MinPeakDistance);
    
    % Convert average distance in-between peaks to a heart rate in BPM for 
    % each heart rate window.
    startTime = 0;
    for window = 1:numWindows
        endTime = startTime + windowSize;
        beats = locs(locs >= startTime & locs <= endTime);
        hrEstimates(i, window) = 60/mean(diff(beats));
        startTime = startTime + increment;
    end
    
    % Also compute the overall averaged heart rate estimation
    avgHR(i) = 60/mean(diff(locs));
end

% Select the hr extracted from the green trace as the guess
hrTrace = hrEstimates(2, :);

if (visualize)
    figure;
    subplot(2, 1, 1);
    findpeaks(signal(2,:), Fsample, 'MinPeakDistance', MinPeakDistance);
    title(sprintf('Peaks of Facial Color Trace: HR = %.1f', avgHR(2)));
    xlabel('Time (s)'); ylabel('Filtered Color Trace');
    subplot(2, 1, 2);
    time = windowSize/2:increment:windowSize/2 + increment*(numWindows-1);
    plot(time, hrTrace);
    xlim([0 vidDuration]);
    title('Heart Rate Trace');
    xlabel('Time (s)'); ylabel('Instantaneous HR (BPM)');
end

if (visualizeFull)
    figure;
    for i = 1:numTraces
        subplot(numTraces,1,i);
        findpeaks(signal(i,:), Fsample, 'MinPeakDistance', MinPeakDistance);
        title(sprintf('Peaks of Trace %d: HR = %.1f', i, avgHR(i)));
    end
    
    figure;
    for i = 1:numTraces
        subplot(numTraces,1,i);
        plot(hrEstimates(i, :));
        title(sprintf('Heart Rate Trace %d', i));
    end
end

