% one script to run the whole classifier shebang so that I dont have to
% re-run entire script every time

function [] = classifyScript(sequence,trainingdata, baselines)

%set up
[X, Y, Ymult] = classifierBuild(trainingdata);

%train for decision tree and SVM
tree = fitctree(X,Y);
treeMult = fitctree(X,Ymult);
SVMModel = fitcsvm(X,Y,'KernelFunction','linear','Standardize',true);

%get both outputs
[dt,dtMult,svm] = classifierRun(tree,treeMult,SVMModel,sequence);

%binary baselines
binarybaselines = double((baselines > 2));

%plot
figure;
subplot(3,2,1); plot(dt); title('Decision Tree');xlabel('Seconds');ylabel('Binary State');
subplot(3,2,3); plot(dtMult); title('Multiclass Decision Tree');xlabel('Seconds');ylabel('State(1-5)');
subplot(3,2,5); plot(svm); title('SVM');xlabel('Seconds');ylabel('Binary State');
subplot(3,2,2); plot(binarybaselines(3:length(dt) + 2)); title('Baseline');xlabel('Seconds');ylabel('Binary State');
subplot(3,2,4); plot(baselines(3:length(dt) + 2)); title('Baseline');xlabel('Seconds');ylabel('State(1-5)');
subplot(3,2,6); plot(binarybaselines(3:length(dt) + 2)); title('Baseline');xlabel('Seconds');ylabel('Binary State');

%plot errors
figure;
errDT = abs(dt - binarybaselines(3:length(dt)+2));
subplot(3,1,1); plot(errDT); 
title(strcat('Decision Tree Error. Mean Error = ',num2str(mean(errDT))));xlabel('Seconds');ylabel('Absolute Error');

errDTmult = abs(dtMult - baselines(3:length(dt)+2));
subplot(3,1,2); plot(errDTmult); 
title(strcat('Multiclass Decision Tree Error. Mean Error = ',num2str(mean(errDTmult))));xlabel('Seconds');ylabel('Absolute Error');

errSVM = abs(svm - binarybaselines(3:length(dt)+2));
subplot(3,1,3); plot(errSVM); 
title(strcat('error SVM. Mean Error = ', num2str(mean(errSVM))));xlabel('Seconds');ylabel('Absolute Error');