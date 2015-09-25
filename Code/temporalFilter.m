function [workCpy] = temporalFilter(traces, Fsample, hrRange, detrendSignal, useICA)
% Averaged channels

% Create a working copy of traces to manipulate
workCpy = traces;
numTraces = size(traces, 1);
numFrames = size(traces, 2);

% Detrend each of the traces
if (detrendSignal)
    for i = 1:numTraces
        workCpy(i, :) = detrend(traces(i, :));
    end
end

% Normalize each of the traces. Formula for normalization:
% x' = (x - mean)/(std deviation).
for i = 1:numTraces
    workCpy(i,:) = (workCpy(i,:) - mean(workCpy(i,:)))/std(workCpy(i,:));
end

% Split the signal into its independent components using the JADE
% algorithm.
if (useICA)
    Bmat = jade(workCpy);
    workCpy = Bmat * workCpy;
end
    

% Convert the traces into frequency space and apply a bandpass filter
% around the expected heart rate range.
workCpy = fft(workCpy, [], 2);

% Convert fft bin scale to hz:
% frequency of bin i in hz = (i - 1)*sampling frequency/(number of bins)
convertFactor = Fsample/numFrames;
freq = 1:numFrames;
freq = (freq-1)*convertFactor;

% Take the limits from the expected heart rate
lo = hrRange(1)/60;
hi = hrRange(2)/60;

% Create a mask to block out frequencies outside of the desired range.
bandpass = (freq > lo & freq < hi);
bandpass = repmat(bandpass, numTraces, 1);
workCpy(~bandpass) = 0;

% Convert temporally filter signal back from the frequency space
workCpy = real(ifft(workCpy, [], 2));
