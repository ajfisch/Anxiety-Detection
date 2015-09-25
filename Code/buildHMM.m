function [transProb, outputProb] = buildHMM(data, binSize)

%set up paramters
numStates = data.numStates;
numOutputs = data.numOutputs;
states = data.states;   %1xnumTrials struct with 1xnumWindows per cell
outputs = data.outputs;  %1xnumTrials struct with numWindows x 1 per cell

%initializing counts
transCounts = zeros(numStates, numStates);
outputCounts = zeros(numStates, numOutputs);

trials = size(states, 2);
for i = 1:trials
    %get current trial's states and outputs
    stateSeq = states{i};
    outputSeq = outputs{i};
    
    %put the states into transition bins first
%     binSize = 3;
    idx = 1;
    stateIdx = 1;
    for s = 1:length(stateSeq)
        tempBin(idx) = stateSeq(s);
        idx = idx + 1;
        if (idx > binSize || s == length(stateSeq))
            stateBins(stateIdx) = round(mean(tempBin));
            stateIdx = stateIdx + 1;
            idx = 1;
        end
    end
    
    %update transition for thisStateBin->nextStateBin
    for j = 1:length(stateBins)
        currState = stateBins(j);
        if (j < length(stateBins))
            nextState = stateBins(j+1);
            transCounts(currState, nextState) = transCounts(currState, nextState) + 1;
        end
    end
    
    %update transition for state->output
    for j = 1:length(stateSeq)
        currOutput = outputSeq(j);
        outputCounts(currState, currOutput) = outputCounts(currState, currOutput) + 1;
    end
    
    
    %update transition for state->output and thisState->nextState
%     for j = 1:length(stateSeq)
%         currState = stateSeq(j);
%         currOutput = outputSeq(j);
%         outputCounts(currState, currOutput) = outputCounts(currState, currOutput) + 1;
%         if (j < length(stateSeq))
%             nextState = stateSeq(j + 1);
%             transCounts(currState, nextState) = transCounts(currState, nextState) + 1;
%         end
%     end

end
%smooth the transition probabilities (don't want prob. of 0)
transCounts = laplaceSmooth(transCounts);
outputCounts = laplaceSmooth(outputCounts);

%normalize
transProb = normalize(transCounts);
outputProb = normalize(outputCounts);

    function [smoothedCounts] = laplaceSmooth(counts)
        smoothedCounts = zeros(size(counts));
        for row = 1:size(counts, 1)
            for col = 1:size(counts, 2)
                smoothedCounts(row, col) = counts(row, col) + 1;
            end
        end
    end

    function [probs] = normalize(counts)
        probs = zeros(size(counts));
        for row = 1:size(counts, 1)
            countSum = sum(counts(row, :));
            for col = 1:size(counts, 2)
                probs(row, col) = counts(row, col) / countSum;
            end
        end
    end

end
