function [TrainingSet TrainingLabel TestingSet TestingLabel] = HoldOutTrainingTest(TotalSet,TotalLabel,NumPerClass)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%ClassNum = max(TotalLabel);
ClassNum = length(unique(TotalLabel));
[SampleNum GeneNum] = size(TotalSet);
TrainingTestingDivision = zeros(SampleNum,1);

RandSamples = randperm(SampleNum)';
TotalSet = TotalSet(RandSamples,:);
TotalLabel = TotalLabel(RandSamples,:);
for i=1:ClassNum
   TempNumPerClass=0; 
   for j=1:SampleNum
       if TotalLabel(j,1)==i
          TrainingTestingDivision(j,1)=1;
          TempNumPerClass=TempNumPerClass+1;
       end
       if TempNumPerClass==NumPerClass
          break;
       end    
   end    
end
TrainingSet  =TotalSet(find(TrainingTestingDivision==1),:);
TrainingLabel=TotalLabel(find(TrainingTestingDivision==1),:);
TestingSet   =TotalSet(find(TrainingTestingDivision==0),:);
TestingLabel =TotalLabel(find(TrainingTestingDivision==0),:);

%%============================   resort TrainingSet and TestingSet
[SampleP LabelIDX]=sort(TrainingLabel);
TrainingSet=TrainingSet(LabelIDX,:);
TrainingLabel = TrainingLabel(LabelIDX,:);

[SampleP LabelIDX] = sort(TestingLabel);
TestingSet  = TestingSet(LabelIDX,:);
TestingLabel = TestingLabel(LabelIDX,:);

%%===========================

return