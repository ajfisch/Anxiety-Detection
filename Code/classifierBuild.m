%Decision tree for classification
function [X,Y,Ymult] = classifierBuild(data)

%set up paramters
numStates = data.numStates;
numOutputs = data.numOutputs;
states = data.states;   %1xnumTrials struct with 1xnumWindows per cell
outputs = data.outputs;  %1xnumTrials struct with numWindows x 1 per cell (HRxBR)

%input variables are a matrix of trials x variables (X)
%labels are matrix of trials by corresponding labels (Y)
numTrials = size(states,2);
idx = 1;
for i = 1:numTrials
    currStateSeq = states{i};
    currOutputSeq = outputs{i};
    for s = 1:length(currStateSeq)
        %set input vector
        %convert the output (1-49) into HR(1-7) and BR(1-7)
        output = currOutputSeq(s);
        BR = mod(output,7);
        if (BR == 0)
            BR = 7;
        end
        HR = (output - BR)/7 + 1;
        
        %bins into "bits"
        blush = zeros(1,7);
        blush(1,BR) = 1;
        hr = zeros(1,7);
        hr(1,HR) = 1;
        
        %set input
        X(idx,:) = [hr, blush];
        
        %set label
        Ymult(idx,1) = (currStateSeq(s));
        Y(idx,1) = (currStateSeq(s) > 2);
        
        %increment id
        idx = idx + 1;
    end
end
        
        
        