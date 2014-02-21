function [Acc]=LDASVM(wsTrainingSet,wsTrainingLabel,wsTestingSet,wsTestingLabel)
% 'wsTrainingSet' is the training set, whose each raw is a training sample.
% 'wsTrainingLabel' is the training label.
% 'wsTestingSet' is the test set, whose each raw is a test sample.
% 'wsTestingLabel' is the test label.
% 'Acc' is the result.
[nSmp, nFea]=size(wsTrainingSet);
fea_Norm = sum(wsTrainingSet.^2, 2).^.5;
wsTrainingSet = wsTrainingSet./repmat(fea_Norm, [1 nFea]);

nClass=length(unique(wsTrainingLabel))-1;
rate=[];

data = wsTrainingSet;
options = [];
options.PCARatio=1;
[eigvector, eigvalue, elapse] = LDA(wsTrainingLabel,options,data);

      ReducedDim=nClass;
      Y = data*eigvector(:,1:ReducedDim);
      YT =wsTestingSet*eigvector(:,1:ReducedDim); 
      rate(1,1)=ReducedDim;
      rate(1,2)=PredictCrossDatasetWithCG(zscore(Y),wsTrainingLabel,zscore(YT),wsTestingLabel);

Acc=rate(1,2);
return