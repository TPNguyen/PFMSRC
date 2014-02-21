function [ classrate, ids, decval ] = meta_src( traindata, testdata, trainlabels, testlabels, Numeigv, lamda )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%这里的样本按列排放
classids = unique(trainlabels);
NumClass = length(classids);

traindata1=[];
trainlabels1=[];

for k = 1:NumClass
    [eigvector{1,k}, eigvalue] = svd(traindata(:,find(trainlabels==k)), 0);
    traindata1=[traindata1,eigvector{1,k}(:,1:Numeigv)]; 
    Tlabels(1:Numeigv,k)=k;
	trainlabels1=[trainlabels1; Tlabels(1:Numeigv,k)];
end

 traindata=traindata1;
 trainlabels=trainlabels1;
 decval = [];
 ids = [];
 for j = 1:size(testdata, 2)
     y = testdata(:, j);
     [id, s, err] = MSRC(traindata, trainlabels, y, lamda);
     ids(j) = id;
     decval = [decval, err];
 end

classrate = sum(ids(:) == testlabels(:))/ length(testlabels);

