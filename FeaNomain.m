clc;
clear all;
close all;
fprintf(1,'Computing...\n');
FilterMethod = 2; %1、fisher score 2: Relief-F
Dataset=8;        %伍个两类问题1:colon  2:Gliomas   3:DLBCL 4：CNS 5：Breast %三个多类问题 4:Lung  5:ALL  6:SRBCT

rng(0);
%所有样本均按行排列，行样本，列特征
TrainingSet = [];
TestingSet = [];
TrainingLabel = [];
TestingLabel = [];


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
          load ..\DataSets\BioData\MLLLeukemia.mat
%           TrainingSet = totaldata;
%           TrainingLabel = totallabel;
          TestingLabel = TestLabel;
          TestingSet = TestSet;

    case {5}
         load ..\DataSets\BioData\ALLTrainingTest.mat

    case {6}
          load ..\DataSets\BioData\SRBCTTrainingTest.mat;
    case {7}
        load ..\DataSets\BioData\AMLALL.mat
        TrainingSet = totalsample;
        TrainingLabel = totallabel + 1;
    case {8}
        load ..\DataSets\BioData\LeukemiaGloub.mat
        TestingLabel = TestLabel;
        TestingSet = TestSet;

end
%========================================
TotalSet   = [TrainingSet; TestingSet];       %the whole dataset
TotalLabel = [TrainingLabel; TestingLabel];
%=======================================
%两种基于模型的方法
Acc_LDASVM = []; 
Acc_ICASVM  =[];
%两种元样本的稀疏表达方法
Acc_MSRC = [];
%稀疏表达
Acc_SC = [];
%本文提出的无参数稀疏表达方法
Acc_PFMSRC = [];


SubClassNum  = CountingSubClassNum(TotalLabel);
minSubClassNum=min(SubClassNum);   % the number of minimum SubClassNum 
MaxTimes=10;                      % the times of resampling in sample set

iSubClassNum= 10;  % travase from 5 to  minSubClassNum
    

    
NumPerSubClass = iSubClassNum;    %the number of samples per subclass
for iTimes=1:MaxTimes
    TrainingSet=[];
    TrainingLabel=[];
    TestingSet=[];
    TestingLabel=[];
    [TrainingSet TrainingLabel TestingSet TestingLabel] = HoldOutTrainingTest(TotalSet,TotalLabel,NumPerSubClass); %redivision of tranining set and testing set
    %%===========================
    Acc_LDASVM1 = [];
    Acc_ICASVM1  =[];
    Acc_MSRC1 = [];
    Acc_SC1 = [];
    Acc_PFMSRC1 = [];
    
    %%==================Gene Filters
    %
    switch FilterMethod
        case {1}
            disp('method 1 none');
            return;
        case {2}
            idx_top = relieff(TrainingSet, TrainingLabel, 5);
        case {3}
            disp('method 3 none.');
            return;
    end
    IX = idx_top(:);
    TopGene = size(IX);
    TrainingSetNew = TrainingSet(:,IX(1:TopGene));
    TestingSetNew = TestingSet(:,IX(1:TopGene));
    
    
    
    TopGene = 20 * 20;
    for nfea = 40:20:TopGene
        Acc_LDASVM1 = [Acc_LDASVM1 LDASVM(TrainingSetNew(:,1:nfea),TrainingLabel,TestingSetNew(:,1:nfea),TestingLabel)];
        Acc_ICASVM1 = [Acc_ICASVM1 ICASVM(TrainingSetNew(:,1:nfea),TrainingLabel,TestingSetNew(:,1:nfea),TestingLabel);  ];
        
        [TrainingSetnorm] = NormalizeFea(TrainingSetNew(:,1:nfea));
        [TestingSetnorm] = NormalizeFea(TestingSetNew(:,1:nfea));
        
        %到这里添加自己的实验代码与比较实验代码
        numofmeta = 0;
        if iSubClassNum > 8
            numofmeta = 8;
        else
            numofmeta = iSubClassNum;
        end
        
        Acc_SC1 = [Acc_SC1 SRC(TrainingSetnorm', TestingSetnorm', TrainingLabel, TestingLabel, .1)];
        Acc_MSRC1 = [Acc_MSRC1 meta_src(TrainingSetnorm', TestingSetnorm', TrainingLabel, TestingLabel, numofmeta, .1)];
        
        Acc_PFMSRC1 = [Acc_PFMSRC1 pfsrc(TrainingSetnorm', TestingSetnorm', TrainingLabel, TestingLabel)];
        
        
    end   %iTimes
    
    %保存结果
    Acc_LDASVM = [Acc_LDASVM; Acc_LDASVM1];
    Acc_ICASVM = [Acc_ICASVM; Acc_ICASVM1];
    Acc_MSRC = [Acc_MSRC; Acc_MSRC1];
    Acc_SC = [Acc_SC; Acc_SC1];
    Acc_PFMSRC = [Acc_PFMSRC; Acc_PFMSRC1];
    
    iTimes
end %iSubClassNum

Acc_LDASVM = [Acc_LDASVM; ] ./ 100;
Acc_ICASVM = [Acc_ICASVM; ] ./ 100;

Acc_LDASVM = [Acc_LDASVM; mean(Acc_LDASVM)];
Acc_ICASVM = [Acc_ICASVM; mean(Acc_ICASVM)];
Acc_MSRC = [Acc_MSRC; mean(Acc_MSRC)];
Acc_SC = [Acc_SC; mean(Acc_SC)];
Acc_PFMSRC = [Acc_PFMSRC; mean(Acc_PFMSRC)];

switch Dataset  %三个两类问题1:colon  2:Gliomas   3:DLBCL  %三个多类问题 4:Lung  5:ALL  6:SRBCT
    case {1}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\colonFS.mat');
        else
           save('.\results\feacolonRelief.mat'); 
        end    
    case {2}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\GliomasFinalFS.mat');
        else
          save('.\results\feaGliomasFinalRelief.mat');  
        end
    case {3}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\DLBCFinalFS.mat');
        else
           save('.\results\feaDLBCFinalRelief.mat'); 
        end    
    case {4}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\MLLLeukemiaFinalFS.mat');
        else
           save('.\results\feaMLLLeukemiaFinalRelief.mat'); 
        end    
    case {5}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\ALLFinalFS.mat');
        else
           save('.\results\feaALLFinalRelief.mat'); 
        end    
    case {6}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\SRBCTFinalFS.mat');
        else
           save('.\results\feaSRBCTFinalRelief.mat'); 
        end    
    case {7}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\AMLALL.mat');
        else
           save('.\results\feaAMLALL.mat'); 
        end   
    case {8}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\LeukemiaGloubRelief.mat');
        else
           save('.\results\feaLeukemiaGloubRelief.mat');  
        end
end
fprintf(1,'finished...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%关机了
% system('shutdown -s');