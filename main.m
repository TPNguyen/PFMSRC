clc;
clear all;
close all;
fprintf(1,'Computing...\n');
FilterMethod = 2; %1、fisher score 2: Relief-F
Dataset=7;        %伍个两类问题1:colon  2:Gliomas   3:DLBCL  4：Breast %三个多类问题 5:MLLL  6:ALL  7:SRBCT 8:LeukemiaGloub

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
        load ..\DataSets\BioData\LeukemiaGloub.mat;
        TestingLabel=TestLabel;
        TestingSet=TestSet;
    case {8}
        load ..\DataSets\BioData\Breast.mat
        TrainingSet = totalsample;
        TrainingLabel = totallabel + 1;

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
MaxTimes=20;                      % the times of resampling in sample set

for iSubClassNum= 5:minSubClassNum - 1  % travase from 5 to  minSubClassNum
    
    Acc_LDASVM1 = [];
    Acc_ICASVM1  =[];
    Acc_MSRC1 = [];
    Acc_SC1 = [];
    Acc_PFMSRC1 = [];
    
    NumPerSubClass = iSubClassNum;    %the number of samples per subclass
    for iTimes=1:MaxTimes
        TrainingSet=[];
        TrainingLabel=[];
        TestingSet=[];
        TestingLabel=[];
        [TrainingSet TrainingLabel TestingSet TestingLabel] = HoldOutTrainingTest(TotalSet,TotalLabel,NumPerSubClass); %redivision of tranining set and testing set
        %%===========================

        
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
        TrainingSet = TrainingSet(:,IX(1:TopGene));
        TestingSet = TestingSet(:,IX(1:TopGene));

        

         TopGene = 20 * 20;
         
         Acc_LDASVM1 = [Acc_LDASVM1 LDASVM(TrainingSet(:,1:TopGene),TrainingLabel,TestingSet(:,1:TopGene),TestingLabel)];     
         Acc_ICASVM1 = [Acc_ICASVM1 ICASVM(TrainingSet(:,1:TopGene),TrainingLabel,TestingSet(:,1:TopGene),TestingLabel);  ];    
         
         [TrainingSet] = NormalizeFea(TrainingSet(:,1:TopGene));
         [TestingSet] = NormalizeFea(TestingSet(:,1:TopGene));

%到这里添加自己的实验代码与比较实验代码
         numofmeta = 0;
         if iSubClassNum > 8
             numofmeta = 8;
         else
             numofmeta = iSubClassNum;
         end
         
         Acc_SC1 = [Acc_SC1 SRC(TrainingSet', TestingSet', TrainingLabel, TestingLabel, .1)];
         Acc_MSRC1 = [Acc_MSRC1 meta_src(TrainingSet', TestingSet', TrainingLabel, TestingLabel, numofmeta, .1)];
         
         Acc_PFMSRC1 = [Acc_PFMSRC1 pfsrc(TrainingSet', TestingSet', TrainingLabel, TestingLabel)];

    
    end   %iTimes
    
    Acc_LDASVM1 =[Acc_LDASVM1 mean(Acc_LDASVM1) std(Acc_LDASVM1)];
    Acc_ICASVM1  =[Acc_ICASVM1  mean(Acc_ICASVM1)  std(Acc_ICASVM1)];
    Acc_MSRC1 = [Acc_MSRC1 mean(Acc_MSRC1) std(Acc_MSRC1)];
    Acc_SC1 = [Acc_SC1 mean(Acc_SC1) std(Acc_SC1)];
    Acc_PFMSRC1 = [Acc_PFMSRC1 mean(Acc_PFMSRC1) std(Acc_PFMSRC1)];
    
    %保存结果
    Acc_LDASVM = [Acc_LDASVM; Acc_LDASVM1];
    Acc_ICASVM = [Acc_ICASVM; Acc_ICASVM1];
    Acc_MSRC = [Acc_MSRC; Acc_MSRC1];
    Acc_SC = [Acc_SC; Acc_SC1];
    Acc_PFMSRC = [Acc_PFMSRC; Acc_PFMSRC1];
    
 iSubClassNum    
end %iSubClassNum  

Acc_LDASVM = [Acc_LDASVM; ] ./ 100;
Acc_ICASVM = [Acc_ICASVM; ] ./ 100;

switch Dataset  %三个两类问题1:colon  2:Gliomas   3:DLBCL  %三个多类问题 4:Lung  5:ALL  6:SRBCT
    case {1}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\colonFS.mat');
        else
           save('.\results\colonRelief.mat'); 
        end    
    case {2}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\GliomasFinalFS.mat');
        else
          save('.\results\GliomasFinalRelief.mat');  
        end
    case {3}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\DLBCFinalFS.mat');
        else
           save('.\results\DLBCFinalRelief.mat'); 
        end    
    case {4}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\MLLLeukemiaFinalFS.mat');
        else
           save('.\results\MLLLeukemiaFinalRelief.mat'); 
        end    
    case {5}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\ALLFinalFS.mat');
        else
           save('.\results\ALLFinalRelief.mat'); 
        end    
    case {6}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\SRBCTFinalFS.mat');
        else
           save('.\results\SRBCTFinalRelief.mat'); 
        end    
    case {7}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\CNSFinalFS.mat');
        else
           save('.\results\LeukemiaGloubRelief.mat'); 
        end   
    case {8}
        if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
           save('.\results\BreastFinalFS.mat');
        else
           save('.\results\BreastRelief.mat'); 
        end  
end
fprintf(1,'finished...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%关机了
% system('shutdown -s');