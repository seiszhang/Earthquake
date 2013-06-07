close all
clc
clear all

%Inputs
Data_Chile = xlsread('Chile,45S-20S,77W-67W.xlsx','All','A15:E200000');
Data_Japan = xlsread('Japan,24N-45N,132E-142E.xlsx','All','A15:E200000');

%Magnitude Bins
MgtBins = [4.0 4.5 5.0 5.5 6.0 6.5 7 10];

Data_Mgts = [histc(Data_Chile(:,5),MgtBins) histc(Data_Japan(:,5),MgtBins)];

hb=bar(MgtBins,Data_Mgts);
set(hb(1),'facecolor','b');
set(hb(2),'facecolor','r');
blank=[' ';' ';' ';' ';' ';' ';' ';' ';];
text(MgtBins,Data_Mgts(:,1),[num2str(Data_Mgts(:,1),4),blank],'Color','b',...
        'HorizontalAlignment','right',...
        'VerticalAlignment','bottom');
text(MgtBins,Data_Mgts(:,2),[blank,num2str(Data_Mgts(:,2),4)],'Color','r',...
        'HorizontalAlignment','left',...
        'VerticalAlignment','bottom');
set(gca,'YLim',ylim*1.1)
set(gca,'XLim',[3.8 7.3]);
set(gca,'XTick',[4:0.5:7]);
xlabel('Magnitude');
ylabel('Frequency');
%make sure the length of each str is 5
set(gca,'XTickLabel',['[4, 4.5)';'[4.5, 5)';'[5, 5.5)';'[5.5, 6)';'[6, 6.5)';'[6.5, 7)';' [7.0   ']);

legend('Chile,16019 Events,2/6/1963-4/16/2013','Japan,15250 Events,2/9/1963-4/19/2013'); 
title('Histogram of Entire Data Sets, Chile & Japan')
