function [ classrate, ids, val] = pfsrc( traindata, testdata, trainlabels, testlabels )
%PFSRC Summary of this function goes here
%   Detailed explanation goes here
%这里的样本按列排放
classids = unique(trainlabels);
NumClass = length(classids);
val = [];
traindata1=[];
trainlabels1=[];

for k = 1:NumClass
    Numeigv = 0;
    [eigvector{1,k}, eigvalue] = svd(traindata(:,find(trainlabels==k)), 0);
    Numeigv = size(eigvector{1,k}, 2);
    traindata1=[traindata1,eigvector{1,k}(:,1:Numeigv)*sqrt(eigvalue)]; 
    Tlabels(1:Numeigv,k)=k;
	trainlabels1=[trainlabels1; Tlabels(1:Numeigv,k)];
end

 traindata=traindata1;
 trainlabels=trainlabels1;
 
 ids = [];
 options = [];
 options.gnd = trainlabels;
 
 for j = 1:size(testdata, 2)
     y = testdata(:, j);
     options.TestSmp = y;
     [id, s, err] = Srl1g(traindata', options);
     ids(j) = id;
     val = [val, err];
 end
classrate = sum(ids(:) == testlabels(:)) / length(testlabels);