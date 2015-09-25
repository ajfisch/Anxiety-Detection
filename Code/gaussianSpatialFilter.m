function [blurredFrames, pyrLevel] = gaussianSpatialFilter(frames, bbox, regions, pyrLevel)
% Spatially filter video frames with a gaussian pyramid

% If a bounding box was not provided, just set it to the frame dimensions
% for compatability.
if ~exist('bbox', 'var')
    vidSize = size(frames(1).cdata);
    bbox = [0 0 vidSize(1) vidSize(2)];
end
roiW = bbox(1):bbox(1) + bbox(3);
roiH = bbox(2):bbox(2) + bbox(4);

% Create a mask for the invalid regions, like eyes and mouth. These areas
% will be set to black, and filtered out later.
vidSize = size(frames(1).cdata);
mask = false(vidSize(1), vidSize(2), 3);
if ~isempty(regions)   
    for i = 1:size(regions, 1)
        regionW = regions(i, 1):regions(i, 1) + regions(i, 3);
        regionH = regions(i, 2):regions(i, 2) + regions(i, 4);
        mask(regionH, regionW, :) = true;
    end
end

% If the level of the gaussian pyramid to use is not supplied, find a good
% level to select for use. Go the the third to lowest level possible, but
% no more than 5.
if ~exist('pyrLevel', 'var')
    minDimension = min([bbox(3) bbox(4)]);
    numLevels = floor(log2(minDimension)) - 1;
    pyrLevel = numLevels - 2;
    if pyrLevel > 5
        pyrLevel = 5;
    end
end

% Technically if the determined pyramid level is zero, it won't be
% spatially filtered. However we will still continue to convert the types
% and mark off the invalid regions.
if (pyrLevel <= 0)
    pyrLevel = 0;
end

% Define the MATLAB gaussian pyramid operator
gPyramid = vision.Pyramid('Operation', 'Reduce', 'PyramidLevel', pyrLevel);

% Blur and downsample the first frame so we can get sizing
im = frame2im(frames(1));
im = im2double(im);
im(mask) = 0;
im = im(roiH,roiW,:);
blurIm = step(gPyramid, im);

% Preallocate a matrix for the filtered frames
xdim = size(blurIm, 2);
ydim = size(blurIm, 1);
numFrames = length(frames);
numChannels = 3;
blurredFrames = zeros(numFrames, ydim, xdim, numChannels);
blurredFrames(1,:,:,:) = blurIm;

% Blur and downsample the remaining frames in a gaussian pyramid, and then
% store the desired level in the blurredFrames matrix.
for i = 2:numFrames
    % Convert to image
    im = frame2im(frames(i));
    im = im2double(im);
    
    % Black out invalid areas
    im(mask) = 0; 
    
    % Extract the region of interest
    im = im(roiH,roiW,:);
    
    % Reduce the image
    blurIm = step(gPyramid, im);
    
    % Store reduced image
    blurredFrames(i,:,:,:) = blurIm;
end
end

