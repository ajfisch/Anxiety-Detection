%running the decision tree

function [statesDT,statesDTmult,statesSVM] = classifierRun(tree,treeMult,SVMModel, sequence)

%check if svm model is given
if ~exist('SVMModel','var')
    runSVM = 0;
else
    runSVM = 1;
end

%check if multiple output tree is given
if ~exist('treeMult','var')
    runDtMult = 0;
else
    runDtMult = 1;
end

for i = 1:length(sequence)
    %get the current output
    output = sequence(i);
    
    %extract BR,HR from the output
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
    X = [hr, blush];
    
    %set outputs
    statesDT(i) = predict(tree,X);
    
    if(runDtMult)
        statesDTmult(i) = predict(treeMult,X);
    end
    
    if (runSVM)
        statesSVM(i) = predict(SVMModel,X);
    end
end


    