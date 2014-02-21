function [ SubClassNum ] = CountingSubClassNum(TotalLabel)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

ClassNum  = max(TotalLabel);
SampleNum = size(TotalLabel,1);
SubClassNum = zeros(ClassNum,1);
for i = 1:SampleNum
    k=TotalLabel(i);
    SubClassNum(k,1)=SubClassNum(k,1)+1;
end

return

