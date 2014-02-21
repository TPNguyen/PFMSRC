function [Accuracy, auc] = PredictCrossDatasetWithCG(TrainingSet,TrainingLabel,TestingSet,TestingLabel, postive)
[Acc Fc Fg] = LIBSVM(TrainingSet,TrainingLabel,5);
SVMParameter = sprintf('-t 2 -c %d -g %f',Fc,Fg);
% SVMParameter = sprintf('-t 1');
PredictModel = svmtrain(TrainingLabel, TrainingSet, SVMParameter);
[predicted_label, LoocvTemp, decision_values] = svmpredict(TestingLabel,TestingSet,PredictModel);
Accuracy = LoocvTemp(1);
if nargin > 4
    auc = plotroc(TestingLabel, TestingSet, PredictModel);
end

  %Label = predicted_label;
return