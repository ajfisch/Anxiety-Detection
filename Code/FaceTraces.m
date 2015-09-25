function [rgbTraces] = FaceTraces(frames, lighting, visualize, pyrLevel)

numFrames = size(frames, 1);
redTrace = zeros(1, numFrames);
greenTrace = zeros(1, numFrames);
blueTrace = zeros(1, numFrames);
lumTrace = zeros(1, numFrames);

% Average the RGB channels over the whole ROI for each frame
for frame = 1:numFrames
    im = squeeze(frames(frame,:,:,:));
    
    % Separate into components
    red = im(:,:,1);
    green = im(:,:,2);
    blue = im(:,:,3);
    lum = rgb2gray(im);
    
    % Block out non skin areas
    skinMask = segmentFacialSkin(im, lighting, visualize, pyrLevel);
    
    % Store average over whole region of each color component 
    redTrace(frame) = mean(mean(red(skinMask)));
    greenTrace(frame) = mean(mean(green(skinMask)));
    blueTrace(frame) = mean(mean(blue(skinMask)));
    lumTrace(frame) = mean(mean(lum(skinMask)));
end

rgbTraces = [redTrace; greenTrace; blueTrace; lumTrace];
end