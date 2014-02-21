function [classrate, ids, val] = SRC(traindata, testdata, trainlabels, testlabels, lamda)
classids = unique(trainlabels);

val = [];
ids = [];
for j = 1:size(testdata, 2)
    y = testdata(:, j);
    [id, s, err] = MSRC(traindata, trainlabels, y, lamda);
    ids(j) = id;
    val = [val, err];
end

classrate = sum(ids(:) == testlabels(:))/ length(testlabels);
