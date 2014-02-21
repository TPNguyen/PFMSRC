function [id, s, minerr] = MSRC(traindata, trainlabels, x, lambda)
% Use the extended SRC to classify data under occlusion

n = size(traindata, 2);
cvx_begin
    variable s(n)
    minimize( sum_square(traindata*s-x)+lambda*norm(s,1) )
cvx_end
classids = unique(trainlabels);
NumClass = length(classids);

r = zeros(NumClass, 1);
for i = 1:NumClass
    classidx = find(trainlabels == classids(i));
    classdata = traindata(:, classidx);
    si = s(classidx);
    err = norm(classdata*si - x);
    r(i) = err;
end

[minerr, id] = min(r);

id = classids(id);
