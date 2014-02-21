function [id, s, minerr] = Srl1g(fea, options)
if (~exist('options','var'))
   options = [];
end
[nsmp, nfea] = size(fea);

if ~isfield(options, 'gnd')
    error('not find class label information.');
end

if ~isfield(options, 'TestSmp')
    error('not find test sample.');
end

[nsmp, nfea] = size(fea);
gnd = options.gnd;

cvx_begin
    variable s(nsmp+nfea)
    minimize (norm(s, 1))
    subject to
        [fea', eye(nfea, nfea)]*s == options.TestSmp
cvx_end

classids = unique(gnd);
NumClass = length(classids);

r = zeros(NumClass, 1);
for i = 1: NumClass
    classidx = find(gnd == classids(i));
    classdata = fea(classidx, :);
    si = s(classidx);
    err = norm(classdata'*si - options.TestSmp);
    r(i) = err;
end

[minerr, id] = min(r);
id = classids(id);