function [AccSVM]=ICASVM(wsTrainingSet,wsTrainingLabel,wsTestingSet,wsTestingLabel)
% 'wsTrainingSet' is the training set, whose each raw is a training sample.
% 'wsTrainingLabel' is the training label.
% 'wsTestingSet' is the test set, whose each raw is a test sample.
% 'wsTestingLabel' is the test label.
% 'Acc' is the result.
 [nSmp, nFea]=size(wsTrainingSet);
% fea_Norm = sum(wsTrainingSet.^2, 2).^.5;
% wsTrainingSet = wsTrainingSet./repmat(fea_Norm, [1 nFea]);

%nClass=length(unique(wsTrainingLabel));

%data = wsTrainingSet;
%options = [];
%options.PCARatio=1;
%[eigvector, eigvalue, elapse] = ICA(wsTrainingLabel,options,data);
wsTrainingSet=zscore(wsTrainingSet);
[TrainICA, TrainA, W] = fastica(wsTrainingSet,'numOfIC', nSmp); %,'lastEig',nSmp
TestA = wsTestingSet * pinv(TrainICA);

AccSVM=PredictCrossDatasetWithCG(zscore(TrainA),wsTrainingLabel,zscore(TestA),wsTestingLabel);

% AccKNN=GetAccuracyWithKNN(zscore(TrainA),wsTrainingLabel,zscore(TestA),wsTestingLabel);      
%Acc=GetAccuracyWithKNN(TrainICA,wsTrainingLabel,TestICA,wsTestingLabel);



return

