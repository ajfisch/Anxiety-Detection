function [skin] = segmentFacialSkin(im, lighting, visualize, pyrLevel)

% Static variable. Visualization is only done on the first call.
persistent called;

% Separate the image out into its red channel and its converted grayscale
% intensities
redLevel = im(:,:,1);
grayLevel = rgb2gray(im);

% Take the difference between the red intensity and the gray intensity 
imDiff = redLevel - grayLevel;

% Matlab computes the grayscale conversion with:
% val = 0.2989 * R + 0.5870 * G + 0.1140 * B. Pixels that have positive
% difference have a relatively high red component. Loosely this correlates
% with "reddish" looking parts in the image. We will consider all pixels
% that are "reddish" enough to be skin, and those that don't to be parts of
% the face like eyebrows, eyes, hair, shadows, etc.
imDiff = imDiff * 255;
magicLuckyThresholds = [-inf 0 10 30 40 45];
threshold = magicLuckyThresholds(lighting + 1);

% Return a logical mask of pixels that meet this threshold
skin = imDiff > threshold;

% Add any areas in the original image that were completely black (these
% correspond to areas blocked off by the invalid region segmenting)
blackMask = (grayLevel == 0);
skin(blackMask) = false;

if (isempty(called) && visualize)
    fullMask = repmat(skin, 1, 1, 3);
    maskedIm = im;
    maskedIm(~fullMask) = 0;
    maskedIm = imresize(maskedIm, 2^pyrLevel);
    im = imresize(im, 2^pyrLevel);
    figure(20); % This always seems to get closed automatically
    subplot(1,2,1); subimage(im); title('Input Face Image');
    subplot(1,2,2); subimage(maskedIm); title('Segmented Image');
    drawnow;
    pause(2);
    
    % Set called so this won't be repeated
    called = true;
end
    
end

