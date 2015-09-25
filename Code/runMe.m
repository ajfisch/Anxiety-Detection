%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN SCRIPT TO RUN OUR ALGORITHM
% COS429: Computer Vision Final Project
% Using Eulerian Video Magnification and Color-Trace Tracking to Percieve 
% Anxiety 
% By: Adam Fisch and Max Shatkhin
% Date: 1/13/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Location of the video file
pathToFileDir = '../Videos';
fileName = 'test2.mp4';

%Test or train?
test = 1;

%Choose number of subject
if (test)
    %For being able to computer error against baselines
    %Corresponds to row of user-feedback response matrix
    victimNumber = 2;
else
    %Cara,Cecilia,Sara,Celina,Max,Adam,Michelle,Leah,Lucas
    victimNumber = 5;
end

% Rating of the video lighting from 0 -> 5
lighting = 3;

% Based on the situation, improve accuracy by giving a more precise
% estimate of the valid range for the subject's heart rate. If no better
% bounding can be inferred, use 40 to 200 BPM.
expectedHRRange = [40 120]; % At rest adult

% Choose whether or not to visualize results. visualizeFull shows plots of
% different data metrics for comparison, not just the final ones used.
visualize = true;
visualizeFull = false;

% Choose whether or not to render a magnified version of the input
render = false;

% Choose whether to apply detrending to the hr signal
detrendSignal = true;

% Choose whether to do ICA on the hr signal
useICA = false;

% Choose hr analysis window size and window increment in seconds
windowSize = 6;
increment = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ INPUT VIDEO FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Loading Video... (this might take a long time)');
framesObj = readVideoFrames(fullfile(pathToFileDir, fileName));
frames = framesObj.frames;
vidHeight = framesObj.vidHeight;
vidWidth = framesObj.vidWidth;
frameRate = framesObj.frameRate;
vidDuration = framesObj.duration;
disp('Finished.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USER SELECT FACIAL REGION OF INTEREST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('User selecting facial region of interest...');
% Get a face bounding box
initFrame = frame2im(frames(1));
warning('off','images:initSize:adjustingMag');
figure;
imshow(initFrame);
button = questdlg('Please select the region of interest', ...
    'Face Box', 'Continue', 'Cancel', 'Continue');
if (strcmpi(button, 'Cancel'))
    close;
    disp('Analysis canceled.');
    return;
end
rect = imrect;
bbox = round(rect.getPosition);

% Remove large areas like the eyes and mouth if they appear
noiseRegions = 0;
invalidRegion = [];
while (true)
    message = 'Box significant noisy areas, such as the eyes and mouth';
    button = questdlg(message, 'Reduce Noise', 'Create New Box', 'Done', 'Done');
    if (strcmpi(button, 'Done'))
        break;
    end
    noiseRegions = noiseRegions + 1;
    rect = imrect;
    invalidRegion(noiseRegions,:) = round(rect.getPosition);
end
close;
pause(0.2);
disp('Finished.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND FACIAL COLOR TRACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Tracing facial colors...');
fprintf('\tSpatially filtering...\n');
[blurredFrames, pyrLevel] = gaussianSpatialFilter(frames, bbox, invalidRegion);
fprintf('\tAveraging pixel values...\n');
traces = FaceTraces(blurredFrames, lighting, visualize, pyrLevel);

if (visualize)
    figure;
    plot(traces(2,:));
    title('Raw Color Trace');
    xlabel('Frame Number'); ylabel('Color Value');
end
if (visualizeFull)
    figure;
    numTraces = size(traces, 1);
    for i = 1:numTraces
        subplot(numTraces, 1, i); plot(traces(i,:));
        title(sprintf('Raw Trace %d', i));
    end
    disp('Finished.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMPORALLY FILTER AND CLEAN TRACES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Temporally filtering traces...');
cleanTraces = temporalFilter(traces, frameRate, expectedHRRange, detrendSignal, useICA);
disp('Finished.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT THE HEART RATE AND REDNESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Hr and Blush Estimates...');
hrEstimate = peakAnalysis(cleanTraces, frameRate, expectedHRRange, ...
    visualize, visualizeFull, windowSize, increment, vidDuration);
blushEstimate = rednessDetect(traces, blurredFrames, frameRate, ...
    visualize, visualizeFull);
disp('Finished');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLUSTER DATA TO OUTPUT CATEGORIES
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate frames per window and frames per increment
fpw = round(frameRate * windowSize);
fpi = round(frameRate * increment);
sequence = dataToOutput(hrEstimate, blushEstimate, fpw, fpi);

%Get baselines from user feedbacks
if (test)
    baselines = testData();
else
    baselines = trainingData();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HMM LIKELY STATES ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('trainData');
binSize = 3;
[transProb, outputProb] = buildHMM(trainingdata, binSize);

% run hmmviterbi
states = hmmviterbi(sequence,transProb, outputProb);

%plot results
figure;
subplot(3,1,1)
time = 3:length(states)+2;
plot(time, states); ylabel('State #');xlabel('Time');title('HMM output');

%plot baseline
subplot(3,1,2)
plot(baselines(victimNumber,:));
title('Baseline');xlabel('Time');ylabel('State #');

%plot error
subplot(3,1,3)
errHMM = abs(states - baselines(victimNumber,1:length(states)));
plot(errHMM); title(strcat('HMM error.  Mean Error = ', num2str(mean(errHMM))));
xlabel('Time');title('Absolute Error');ylabel('Error');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decision Tree/SVM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Running Classifier script');
classifyScript(sequence, trainingdata, baselines(victimNumber,:));
disp('Finished.');
