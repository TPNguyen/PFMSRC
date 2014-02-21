clc;
clear all;
close all;
fprintf(1,'Computing...\n');
FilterMethod = 2; %1、fisher score 2: Relief-F


SelectFeaNum = 400;
rng('default');
%所有样本均按行排列，行样本，列特征
TrainingSet = [];
TestingSet = [];
TrainingLabel = [];
TestingLabel = [];
%到这里选择数据集%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dataset=8;        %伍个两类问题1:colon  2:Gliomas   3:DLBCL 4：AMLALL 5：Breast 
switch Dataset                   
    case {1}
        load ..\DataSets\BioData\dataSource_colon.mat
        %postive {+1}
        TrainingSet = colon_train';
        TrainingLabel = colon_tnCL(:);
        TestingLabel=colon_ttCL(:);
        TestingSet=colon_test';
         
    case {2}
        load ..\DataSets\BioData\GliomasTrainingTest.mat
        %postive{+2}
    case {3}
        load ..\DataSets\BioData\DLBCLTrainingTest.mat
        %postive{+1}
    case {4}
        load ..\DataSets\BioData\AMLALL.mat
        TrainingSet = totalsample;
        TrainingLabel = totallabel + 1;
    case {5}
        load ..\DataSets\BioData\MLLLeukemia.mat
        TestingLabel = TestLabel;
        TestingSet = TestSet;
        
    case {6}
        load ..\DataSets\BioData\ALLTrainingTest.mat
        
    case {7}
        load ..\DataSets\BioData\SRBCTTrainingTest.mat;
    case {8}
        load ..\DataSets\BioData\LeukemiaGloub.mat;
        TestingLabel=TestLabel;
        TestingSet=TestSet;
end
%========================================
meas   = [TrainingSet; TestingSet];       %the whole dataset
species = [TrainingLabel; TestingLabel];
%=======================================
label = unique(species);
minlabel = label(1);

if sum(label(1) == species) > sum(label(2) == species)
    minlabel = label(2);
end

index = relieff(meas, species, 5);
meas = meas(:, index(1:SelectFeaNum));

indices = crossvalind('Kfold', species, 10);
cp_lda = classperf(species);
cp_ica = classperf(species);
cp_msrc = classperf(species);
cp_sc = classperf(species);
cp_pfmsrc = classperf(species);
auc_meta = [];
auc_sc = [];
auc_pfmsc = [];

alda = [];
aica = [];
amsrc = [];
asc = [];
apfmsrc = [];

for i = 1:10
    test = (indices == i); train = ~test;
    
    alda = [alda, LDASVM(zscore(meas(train, :)), species(train), zscore(meas(test, :)), species(test))];
    aica = [aica, ICASVM(zscore(meas(train, :)), species(train), zscore(meas(test, :)), species(test))];
    
    trainingdata = NormalizeFea(meas(train, :));
    testingdata = NormalizeFea(meas(test, :));
    traininglabel = species(train);
    testinglabel = species(test);
    
    SubClassNum  = CountingSubClassNum(traininglabel);
    minSubClassNum=min(SubClassNum);   % the number of minimum SubClassNum
    nMeta = 8;
    if minSubClassNum < 8
        nMeta = minSubClassNum;
    end
    
        
    [junk, ids, decval] = meta_src(trainingdata', testingdata', traininglabel, testinglabel, nMeta, .1);
    amsrc = [amsrc, sum(ids(:) == testinglabel)/length(testinglabel)];

    [junk, ids, decval] = SRC(trainingdata', testingdata', traininglabel, testinglabel, .1);

    asc = [asc, sum(ids(:) == testinglabel)/length(testinglabel)];

    [junk, ids, decval] = pfsrc(trainingdata', testingdata', traininglabel, testinglabel);
    
    apfmsrc = [apfmsrc, sum(ids(:) == testinglabel)/length(testinglabel)];
%     class_pfmsrc = ids';
%     classperf(cp_msrc, class_msrc, test);
%     classperf(cp_snmfmsrc, class_snmfmsrc, test);
%     classperf(cp_sc, class_sc, test);
%     classperf(cp_pfmsrc, class_pfmsrc, test);
end

alda = mean(alda) / 100;
aica = mean(aica) / 100;
amsrc = mean(amsrc);
asc = mean(asc);
apfmsrc = mean(apfmsrc);

switch Dataset  %三个两类问题1:colon  2:Gliomas   3:DLBCL  %三个多类问题 4:Lung  5:ALL  6:SRBCT
    case {1}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\colonFS.mat');
        else
            %            Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %            Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BincolonRelief.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
    case {2}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\GliomasFinalFS.mat');
        else
            %             Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %             Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BinGliomasFinalRelief.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
    case {3}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\DLBCFinalFS.mat');
        else
            %             Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %             Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BinDLBCFinalRelief.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
        
    case {4}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\DLBCFinalFS.mat');
        else
            %             Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %             Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BinAMLALLRelief.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
    case {5}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\DLBCFinalFS.mat');
        else
            %             Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %             Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BinMLLLeukemia.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
    case {6}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\DLBCFinalFS.mat');
        else
            %             Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %             Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BinALLTrainingTest.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
    case {7}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\DLBCFinalFS.mat');
        else
            %             Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %             Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BinSRBCTTrainingTest.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
    case {8}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
            save('.\results\DLBCFinalFS.mat');
        else
            %             Sensitivity = [cp_sc.Sensitivity, cp_msrc.Sensitivity, cp_snmfmsrc.Sensitivity, cp_pfmsrc.Sensitivity];
            %             Specificity = [cp_sc.Specificity, cp_msrc.Specificity, cp_snmfmsrc.Specificity, cp_pfmsrc.Specificity];
            save('.\results\BinLeukemiaGloub.mat', 'alda', 'aica', 'amsrc', 'asc', 'apfmsrc');
        end
end
fprintf(1,'finished...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%关机了
% system('shutdown -s');