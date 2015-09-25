function [sequence] = dataToOutput(hrEstimate, blushTrend, framesPerWin, framesPerInc)
% Bin HR by difference from the intial heart rate reading. Here we select
% increments of +5 BPM, up to +20 BPM (inluding < 0 and > 20). Likewise
% for binning percentage changes in "blushing." Bin in increments of +.5%
% up to +2% (and < 0% and > 2%). Each tuple out of the 49 possible combos
% is given a unique numeric id.
numHrBins = 7;
numBlushBins = 7;
maxHr = 20;
maxBlush = 2;

% Limited by the number of windows used to take average HR measurements.
% The number of windows is the number of state transitions.
numTransitions = size(hrEstimate, 2);
sequence = zeros(numTransitions, 1);

refHR = min(hrEstimate);
for i = 1:numTransitions
    % Find change in hr from the initial value, and round its divison by 5
    % and increment by 2 to find its bin #. (bin 1 = < 0).
    deltaHR = hrEstimate(i) - refHR;
    if (deltaHR < 0)
        hrBin = 1;
    elseif (deltaHR > maxHr)
        hrBin = numHrBins;
    else
        hrBin = round(deltaHR/5) + 2;
    end
    
    
    % Take the blush evidence as the max percentage change inside the
    % current window time span. Divide by .5 to find bin #.
    windowStart = (i - 1) * framesPerInc + 1;
    % Account for truncation due to median filtering of the frames 
    % used for blush detecton
    if (i == numTransitions) 
        windowEnd = length(blushTrend);
    else
        windowEnd = windowStart + framesPerWin - 1;
    end
   
    measurePoint = round((windowStart + windowEnd)/2);
    deltaBlush = max(blushTrend(measurePoint), [], 2);
    if (deltaBlush < 0)
        blushBin = 1;
    elseif (deltaBlush > maxBlush)
        blushBin = numBlushBins;
    else
        blushBin = round(deltaBlush/0.5)+2;
    end
    
    % Store tuple by its unique index.
    % (Essentially stored as a indexed matrix of hr vs blush).
    sequence(i, 1) = (hrBin - 1) * numBlushBins + blushBin;
end

