   clc;
   clear all;
   Dataset=5;
   FilterMethod=5;
   set(gca,'FontSize',14);
   switch Dataset  %1:MLLLeukemia  2: Gliomas  3:LeukemiaGloub  4:DLBCL 5:ALL 6:SRBCT
       case {1}
           if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
               load('.\results\MLLLeukemiaFinalMRMR.mat');
           else
               load('.\results\feaMLLLeukemiaFinalRelief.mat');
           end
           wsXLabel='Number of top Genes';
           title('MLLLeukemia');
       case {2}
           if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
               load('.\results\GliomasFinalMRMR.mat');
           else
               load('.\results\feaGliomasFinalRelief.mat');
           end
           wsXLabel='Number of top Genes';
           title('Gliomas');
       case {3}
           if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
               load('.\results\LeukemiaGloubFinalMRMR.mat');
           else
               load('.\results\feaAMLALL.mat');
           end
           wsXLabel='Number of top Genes';
           title('Leukemia');
       case {4}
           if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
               load('.\results\DLBCLFinalMRMR.mat');
           else
               load('.\results\feaDLBCFinalRelief.mat');
           end
           wsXLabel='Number of top Genes';
           title('DLBCL');
       case {5}
           if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
               load('.\results\ALLFinalMRMR.mat');
           else
               load('.\results\feaALLFinalRelief.mat');
           end
           wsXLabel='Nnumber of top Genes';
           title('ALL');
       case {6}
           if FilterMethod==1;   %1: Rank Sum Test %2: Relief-F
               load('.\results\SRBCTFinalMRMR.mat');
           else
               load('.\results\feaSRBCTFinalRelief.mat');
           end
           wsXLabel='Number of top Genes';
           title('SRBCT');
       case {7}
           if FilterMethod == 1
               load('...');
           else
               load('.\results\feaLeukemiaGloubRelief.mat');
           end
           wsXLabel='Number of top Genes';
           title('LeukemiaGloub');
       case {8}
           if FilterMethod == 1
               load('...');
           else
               load('.\results\feacolonRelief.mat');
           end
           wsXLabel='Number of top Genes';
           title('COLON');
   end
%    [r c]=size(Acc_SC);
%    X_Coord =(1:c);
   X_Coord=40:20:400;
   
%    figure1=figure('PaperSize',[16.98 25.68]);
%    axes('Parent',figure1,'Position',[0.1 0.1 0.87 0.87]);

box('on');
hold on;
plot(X_Coord,Acc_LDASVM(end,:)','-go');
hold on;
plot(X_Coord,Acc_ICASVM(end,:)','-r^');
hold on
plot(X_Coord, Acc_SC(end, :)', '-m*');
hold on
plot(X_Coord, Acc_MSRC(end, :)', '--bd');
hold on
plot(X_Coord, Acc_PFMSRC(end, :)', '-kv');
hold on

grid on
legend('LDASVM','ICASVM','SRC','MSRC-SVD','PFMSRC', 'Location' , 'SouthEast');
xlabel(wsXLabel,'fontsize',14);
ylabel('Prediction accuracy','fontsize',14);
axis tight
% ylim([0, 1]);
% xlim([5, X_Coord(end)]);