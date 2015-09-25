%% Redness Detection
%input traces is 4xnumFrames matrix with rows being r,g,b,luminance traces
function [HSVtrend] = rednessDetect(traces, frames, frameRate, visualize, visualizeFull)

numFrames = size(traces,2);

%% Color Spaces Setup
% Average saturation and values for colors in the frame that are red
S = zeros(numFrames,1);
V = zeros(numFrames,1);

for frame = 1:numFrames  
    %Get the r,g,b channels for current frame
    im = squeeze(frames(frame,:,:,:));
    
    %Transform into HSV space
    imHSV = rgb2hsv(im);
    h = imHSV(:,:,1);
    hueThreshHigh = .05;
    hueThreshLow = .97;
    hueMask = (h < hueThreshHigh | h > hueThreshLow);
    imHSV(~hueMask) = 0;
    s = imHSV(:,:,2);
    v = imHSV(:,:,3);
    S(frame,1) = mean(mean(s));
    V(frame,1) = mean(mean(v));
end

%% Median Filtering for RGB
yRGB_med = zeros(4,numFrames - 8);
for color = 1:4
    medC = medfilt1(traces(color,:), 30);
    yRGB_med(color,:) = smooth(medC(4:end-5));
end

%find percent difference -> (value - ref)/ref
ref = [min(yRGB_med(1,:)); min(yRGB_med(2,:)); min(yRGB_med(3,:)); min(yRGB_med(4,:))];
refMat = repmat(ref,1,size(yRGB_med,2));
yRGB_med_diff = (yRGB_med - refMat)./refMat * 100;

%% Median Filtering for HSV
sv = [S';V'];
ySV_med = zeros(2,numFrames - 8);
for color = 1:2
    medC = medfilt1(sv(color,:), 30);
    ySV_med(color,:) = smooth(medC(4:end-5));
end

%find percent difference -> (value - ref)/ref
ref = [min(ySV_med(1,:)); min(ySV_med(2,:))];
refMat = repmat(ref,1,size(ySV_med,2));
ySV_med_diff = (ySV_med - refMat)./refMat * 100;

%% Set Outputs
HSVtrend = ySV_med_diff(1, :);

%% Visualize
if (visualize)
    % convert frames to time units
    time = (1:length(HSVtrend))/frameRate;
    figure();
    plot(time, HSVtrend); title('Extracted Blush Measurement');
    xlabel('Time (s)');
    ylabel('Change from Baseline (%)');
end

if (visualizeFull)
    figure();
    subplot(4,1,1); plot(time, yRGB_med_diff(1,:)); title('Trend line for Red Trace');
    subplot(4,1,2); plot(time, yRGB_med_diff(2,:)); title('Trend Line for Green Trace');
    subplot(4,1,3); plot(time, yRGB_med_diff(3,:)); title('Trend Line for Blue Trace');
    subplot(4,1,4); plot(time, yRGB_med_diff(4,:)); title('Trend Line for "Redness"');
    
    figure();
    subplot(2,1,1); plot(time, ySV_med_diff(1,:)); title('Trend line for Saturation after Red-Hue filter');
    subplot(2,1,2); plot(time, ySV_med_diff(2,:)); title('Trend line for Value after Red-Hue filter');
end
