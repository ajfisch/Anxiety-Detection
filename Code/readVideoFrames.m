function [framesObj] = readVideoFrames(fileName, frames)
% Process a video file and store individual frames.

% Read in the video file
vidObj = VideoReader(fileName);
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
numChannels = 3;

if ~exist('frames', 'var')
    % Allocate space for the frame struct and read in all frames
    colorData = zeros(vidHeight, vidWidth, numChannels, 'uint8');
    frames = struct('cdata', colorData, 'colormap', []);
    
    k = 1;
    while hasFrame(vidObj)
        frames(k).cdata = readFrame(vidObj);
        k = k+1;
    end
end

% Store the video file in a preprocessed format
framesObj.frames = frames;
framesObj.vidHeight = vidHeight;
framesObj.vidWidth = vidWidth;
framesObj.frameRate = vidObj.FrameRate;
framesObj.channels = numChannels;
framesObj.duration = vidObj.Duration;
end

