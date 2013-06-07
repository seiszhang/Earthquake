clear all
close all
clc

%Earthquake Data
Data=xlsread('Chile,45S-20S,77W-67W.xlsx','All','A15:E200000');
%Data=Data(find(abs(Data(:,2)-(-34))<=3 & abs(Data(:,3)-(-73))<=3),:);%LOCATION!!
%scatter(Data(:,3),Data(:,2))

[Empty,Index]=sort(Data(:,1),'ascend');
Data=Data(Index,:);
clear Empty
clear Index

for loop=1:2
    %Trigger_lower and trigger_upper are the lower and upper range for the trigger events
    if loop==1
        Trigger_Lower=6.5; Trigger_Upper=10;
    elseif loop==2
        Trigger_Lower=6; Trigger_Upper=10;
    end
    %%%%%%%%%%%%%%%%%INPUTS%%%%%%%%%%%%%%%%%%
    %Magnitude Bins
    MgtBins=[4.0 4.5 5.0 5.5 6.0 100];
    MgtBins2=[4.0 4.5 5.0 5.5 6.0 6.5 7 100];
    
    %Intervals
    Interval_Lower=0;
    Interval_Upper=365.25;
    Interval=Interval_Upper-Interval_Lower;
    
    %Waiting Time till next event Bins, X Axis
    TimeBins=[Interval_Lower 30 60 90 120 150 180 Interval_Upper];
    
    TimeBins=[Interval_Lower 30 60 90 120 150 180 210 240 270 Interval_Upper];
    
    Events=length(find( Data(:,5)>=Trigger_Lower & Data (:,5)<Trigger_Upper));%Number of Largest Events pickd
    
    TotalTimeSpan=(Data(size(Data,1),1)-Data(1,1))/365.25
    
    %%%%%%%%%%%%%%% Code for Computation %%%%%%%%%%%%%%%%%%
    
    %Unconditional histograms
    Data3=Data;
    for i=1:length(MgtBins)
        clear CurrentData
        clear Temp
        clear CurrentDataSortedByTime
        clear ppp
        
        %All the events within the Magnitude Bin(i)
        if i<length(MgtBins)
            CurrentData=Data3(find( Data3(:,5)>=MgtBins(i) & Data3(:,5)<MgtBins(i+1)),:);
        else
            CurrentData=Data3(find( Data3(:,5)>=MgtBins(i)),:);
        end
        
        if size(CurrentData,1)>1
            [TimeSorted,Index]=sort(CurrentData(:,1),'ascend');
            CurrentDataSortedByTime=CurrentData(Index,:);
            for j=1:size(CurrentDataSortedByTime,1)-1;
                Temp(j)=CurrentDataSortedByTime(j+1,1)-CurrentDataSortedByTime(j,1);
            end
            UncondFreqDist(i,:)=histc(Temp,TimeBins);
            %UncondTimeSpan=CurrentDataSortedByTime(j+1,1)-CurrentDataSortedByTime(1,1);
            %FinalUncondAnnualFreq(i,:)=UncondFreqDist(i,:)/(UncondTimeSpan);
            
        else
            UncondFreqDist(i,:)=zeros(1,length(TimeBins));
            %FinalUncondAnnualFreq(i,:)=zeros(1,length(TimeBins));
        end
    end
    FinalUncondAnnualFreq=UncondFreqDist/TotalTimeSpan;
    
    %Conditional Distribution
    clear Index
    clear Data2
    clear MgtSorted
    emptycond1=0;
    emptycond2=0;
    notempty=0;
    LessThanOneYear=0;
    
    %Re-sort the data by magnitude
    Data2=Data(find( Data(:,5)>=Trigger_Lower & Data(:,5)<Trigger_Upper),:);
    [MgtSorted,Index]=sort(Data2(:,5),'descend');
    DataSortedByMgt=Data2(Index,:);
    
    CondFreqDist=zeros(length(MgtBins),length(TimeBins),Events);
    CondAnnualFreqDist=CondFreqDist;
    FinalCondFreqDist=zeros(length(MgtBins),length(TimeBins));
    FinalCondAnnualFreq=FinalCondFreqDist;
    
    %compute the frequency distribution
    for k=1:Events
        if Data(length(Data),1)-DataSortedByMgt(k,1) >= Interval_Upper
            clear ConditionalData
            
            %all the data within interval after the trigger event
            ConditionalData=Data(find( Data(:,1)<=(DataSortedByMgt(k,1)+Interval_Upper) & Data(:,1)>=(DataSortedByMgt(k,1)+Interval_Lower)),:);
            
            for i=1:length(MgtBins)
                clear Index
                clear CurrentData
                clear Temp
                clear CurrentDataSortedByTime
                
                %all the data within the magnitude bin(i)
                if i<length(MgtBins)
                    CurrentData=ConditionalData(find( ConditionalData(:,5)>=MgtBins(i) & ConditionalData(:,5)<MgtBins(i+1)),:);
                else
                    CurrentData=ConditionalData(find( ConditionalData(:,5)>=MgtBins(i)),:);
                end
               
                %calculate
                if size(CurrentData,1)>1
                    [TimeSorted,Index]=sort(CurrentData(:,1),'ascend');
                    CurrentDataSortedByTime=CurrentData(Index,:);
                    for j=1:size(CurrentDataSortedByTime,1)-1;
                        Temp(j)=CurrentDataSortedByTime(j+1,1)-CurrentDataSortedByTime(j,1);
                    end
                    notempty=notempty+1;
                    CondFreqDist(i,:,k)=histc(Temp,TimeBins);
                          
                elseif size(CurrentData,1)==1
                    CondFreqDist(i,:,k)=zeros(1,length(TimeBins));
                    emptycond1=emptycond1+1;
                    
                elseif size(CurrentData,1)==0
                    CondFreqDist(i,:,k)=zeros(1,length(TimeBins));
                    %disp('NONE!!!')
                    emptycond2=emptycond2+1;
                end
            end
        else
            CondFreqDist(:,:,k)=zeros(length(MgtBins),length(TimeBins));
            %CondAnnualFreq(:,:,k)=zeros(length(MgtBins),length(TimeBins));
            k;
            LessThanOneYear=LessThanOneYear+1;
        end
        FinalCondFreqDist=CondFreqDist(:,:,k)+FinalCondFreqDist;
        %FinalCondAnnualFreq=FinalCondFreqDist(:,:,k)+FinalCondAnnualFreq;
    end
    notempty;
    emptycond1;
    emptycond2;
    FinalCondAnnualFreq=FinalCondFreqDist/(Events-LessThanOneYear);
    
    %events
    LessThanOneYear;
    Events-LessThanOneYear;
    
    NumberOfEvents_Unconditional=sum(UncondFreqDist,2)';
    NumberOfEvents_Conditional=sum(FinalCondFreqDist,2)';
    
    
    %Plotting
    
    %%%%%%%%%%%%%%%%%%%%%%% Figure 1 %%%%%%%%%%%%%%%%%%
    figure(1)
    subplot(2,3,(loop-1)*3+2)
    
    hb=bar(MgtBins,sum(FinalCondFreqDist,2),'r');
    
    text(MgtBins,sum(FinalCondFreqDist,2),num2str(sum(FinalCondFreqDist,2)),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    set(gca,'XLim',[3.8 6.2])
    set(gca,'YLim',ylim*1.1)
    set(gca,'XTick',[4:0.5:6]);
    set(gca,'YTick',ylim)
    set(gca,'YTickLabel',ylim);
    str = sprintf('Triggers: >%1.1f',Trigger_Lower);
    ylabel(str);
    %make sure the length of each str is 5
    set(gca,'XTickLabel',['4-4.5';'4.5-5';'5-5.5';'5.5-6';' >=6 ']);
    if loop==1
        title(sprintf('Total "Aftershocks" 1 year after trigger, %1d Triggers of >=6.5',Events-LessThanOneYear))
    elseif loop==2
        title(sprintf('Total "Aftershocks" 1 year after trigger, %1d Triggers of >=6',Events-LessThanOneYear))
    end
    
    subplot(2,3,(loop-1)*3+3)
    Comparison2=[histc(Data(:,5),MgtBins)'/TotalTimeSpan;sum(FinalCondAnnualFreq,2)'];
    hb=bar(MgtBins,Comparison2',1);
    set(hb(1),'facecolor','b');
    set(hb(2),'facecolor','r');
    text(MgtBins,Comparison2(1,:)',num2str(Comparison2(1,:)',3),'Color','b',...
        'HorizontalAlignment','right',...
        'VerticalAlignment','bottom')
    text(MgtBins,Comparison2(2,:)',num2str(Comparison2(2,:)',3),'Color','r',...
        'HorizontalAlignment','left',...
        'VerticalAlignment','bottom')
    if loop==1
        title(sprintf('Observed Frequency per Year, %1d Triggers of >=6.5',Events-LessThanOneYear))
        legend('Entire Data Set','After Trigger>=6.5');
    elseif loop==2
        title(sprintf('Observed Frequency per Year, %1d Triggers of >=6',Events-LessThanOneYear))
        legend('Entire Data Set','After Trigger>=6');
    end
    set(gca,'XLim',[3.8 6.2])
    set(gca,'YLim',ylim*1.1)
    set(gca,'XTick',[4:0.5:6]);
    str = sprintf('Triggers: >=%1.1f',Trigger_Lower);
    ylabel(str);
    %make sure the length of each str is 5
    set(gca,'XTickLabel',['4-4.5';'4.5-5';'5-5.5';'5.5-6';' >=6 ']);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%Figure 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(2)
    
    %Pick the magnitude range to compare
    LambdaUnCond=(histc(Data(:,5),MgtBins)/TotalTimeSpan/12);
    
    %credible interval
    alpha  =  1 - 0.90;
    n=histc(Data(:,5),MgtBins);
    T=TotalTimeSpan*12;
    CI_lower = 0.5 * chi2inv (   alpha/2 , 2*n ) / T;
    CI_upper = 0.5 * chi2inv ( 1-alpha/2 , 2*(n+1) ) / T;
    
    %approximation
    z = -norminv(alpha);
    CI_lower_2 = n/T     * ( 1-1/9/n     - z /3/sqrt(n)  ).^3;
    TimeBins2=[0 1 2 3 4 5 6 12 100];
    TimeBins2=[0 1 2 3 4 5 6 7 8 9 12 100];
    for i=3:5
        clear p_value_1;
        clear p_value_2;
        for j=1:length(TimeBins2)-1
            UncondExp(j)=(LambdaUnCond(i)*12)*(expcdf(TimeBins2(j+1),1/LambdaUnCond(i))-expcdf(TimeBins2(j),1/LambdaUnCond(i)));
            
            %compute the p-values between observed vs expected
            if FinalUncondAnnualFreq(i,j)<UncondExp(j)
                p_value_1(j)= poisscdf(FinalUncondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
                p_value_1_2(j)= log(p_value_1(j));
                %poisscdf2(FinalUncondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
            else
                p_value_1(j)= 1-poisscdf(FinalUncondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
                p_value_1_2(j)= log(exp(1)/p_value_1(j));
                %1/poisscdf2(FinalUncondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
            end
            
            %compute the p-value between after trigger vs expected
            if FinalCondAnnualFreq(i,j)<UncondExp(j)
                p_value_2(j)= poisscdf(FinalCondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
                p_value_2_2(j)= log(p_value_2(j));
                %poisscdf2(FinalCondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
            else
                if UncondExp(j)==0
                    p_value_2(j)=-1;
                else
                    p_value_2(j)= 1-poisscdf(FinalCondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
                    p_value_2_2(j)= log(exp(1)/p_value_2(j));
                    %1/poisscdf2(FinalCondAnnualFreq(i,j)*TotalTimeSpan,UncondExp(j)*TotalTimeSpan);
                end
            end
%             i
%             j
%             p_value_1
%             p_value_2
            %prod(p_value_1_2)
            %prod(p_value_2_2)
        end
        if loop==1
            place=char('c5','c10','c15');
        elseif loop==2
            place=char('c22','c27','c32');
        end
        format long g
        xlswrite('p-values.xlsx',[p_value_1(1:length(p_value_1)-1);p_value_2(1:length(p_value_2)-1)],'Chile',place(i-2,:));
        
        
        %plot
        if loop==1
            subplot (2,3,(loop-1)*3+i-2+3)
            hold on
            Comparison=[FinalUncondAnnualFreq(i,:);UncondExp];
            hb=bar(TimeBins,Comparison',1);
            set(hb(1),'facecolor','b');
            set(hb(2),'facecolor','k');
            set(gca,'YLim',ylim*1.2)
            set(gca,'XLim',[Interval_Lower-20 Interval_Upper-85])
            set(gca,'xtick',TimeBins)
            %make sure the length of each str is equal
            set(gca,'XTickLabel',['0-1 ';'1-2 ';'2-3 ';'3-4 ';'4-5 ';'5-6 ';'6-7 ';'7-8 ';'8-9 ';'9-12']);
            str = sprintf('Frequency');
            ylabel(str);
            xlabel('Waiting Time, months')
            
            for m=1:length(TimeBins)-1
                height=max(Comparison(:,m));
                gap=0.05*max(ylim);
                height1=2*gap+height;
                height2=gap+height;
                height3=3*gap+height;
                height4=4*gap+height;
                if round(Comparison(1,m)*1000)/1000>=0.005
                    text(TimeBins(m),height1,num2str(Comparison(1,m)','%1.2f'),'Color','b',...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','bottom')
                else
                    text(TimeBins(m),height1,num2str(0),'Color','b',...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','bottom')
                end
                if round(Comparison(2,m)*1000)/1000>=0.005
                    text(TimeBins(m),height2,num2str(Comparison(2,m)','%1.2f'),'Color','k',...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','bottom')
                else
                    text(TimeBins(m),height2,num2str(0),'Color','k',...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','bottom')
                end
                
            end
            
            h=legend('Entire Data Set','Expected, If Independent');
            set(h,'Fontsize',7)
            if i~=5
                title(sprintf('Magnitude [%1.1f~%1.1f)',MgtBins(i),MgtBins(i+1)));
            else
                title(sprintf('Magnitude >=%1.1f',MgtBins(i)));
            end
            hold off
        end
        annotation('textbox',...
            [0.331161054172768 0.526073619631902 0.401869692532943 0.0567484662576703],...
            'String',{'Chile-Waiting Times,Entire Data Set: Observed vs. Expected'},...
            'FontWeight','bold',...
            'FontSize',14,...
            'FontName','Arial',...
            'FitBoxToText','off');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%Figure 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(3)
    
    %TimeBins2=[0 1 2 3 4 5 6 7 8 9 12 100];
    for i=3:5
        %plot
        subplot (2,3,(loop-1)*3+i-2)
        hold on
        Comparison=[FinalUncondAnnualFreq(i,:);FinalCondAnnualFreq(i,:)];
        hb=bar(TimeBins,Comparison',1);
        set(hb(1),'facecolor','b');
        set(hb(2),'facecolor','r');
        set(gca,'YLim',ylim*1.2)
        set(gca,'XLim',[Interval_Lower-20 Interval_Upper-85])
        set(gca,'xtick',TimeBins)
        %make sure the length of each str is equal
        set(gca,'XTickLabel',['0-1 ';'1-2 ';'2-3 ';'3-4 ';'4-5 ';'5-6 ';'6-7 ';'7-8 ';'8-9 ';'9-12']);
        
        ylabel('Frequency');
        xlabel('Waiting Time, months')
        
        for m=1:length(TimeBins)-1
            height=max(Comparison(:,m));
            gap=0.05*max(ylim);
            height1=2*gap+height;
            height2=gap+height;
            height3=3*gap+height;
            height4=4*gap+height;
            if round(Comparison(1,m)*1000)/1000>=0.005
                text(TimeBins(m),height1,num2str(Comparison(1,m)','%1.2f'),'Color','b',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom')
            else
                text(TimeBins(m),height1,num2str(0),'Color','b',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom')
            end
            if round(Comparison(2,m)*1000)/1000>=0.005
                text(TimeBins(m),height2,num2str(Comparison(2,m)','%1.2f'),'Color','r',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom')
            else
                text(TimeBins(m),height2,num2str(0),'Color','r',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom')
            end
        end
        if i~=5
            title(sprintf('Magnitude [%1.1f~%1.1f)',MgtBins(i),MgtBins(i+1)));
            str = sprintf('After Triggers >=%1.1f',Trigger_Lower);
        else
            title(sprintf('Magnitude >=%1.1f',MgtBins(i)));
            str = sprintf('After Triggers >=%1.1f',Trigger_Lower);
        end
        h=legend('Entire Data Set',str);
        set(h,'Fontsize',8)
        hold off
    end
    annotation('textbox',...
        [0.421937042459737 0.96319018404908 0.182016105417277 0.0337423312883436],...
        'String',{'Observed Frequency per Year'},...
        'FontWeight','bold',...
        'FontSize',12,...
        'FontName','Arial',...
        'FitBoxToText','off');
    
end
%% plotting entire data set histogram

figure(1)
subplot(2,3,1)

Data_Mgts = [histc(Data(:,5),MgtBins2)];
bar(MgtBins2,Data_Mgts,'b')
blank=[' ';' ';' ';' ';' ';' ';' ';' ';];
text(MgtBins2,Data_Mgts(:,1),[num2str(Data_Mgts(:,1),4),blank],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom');
set(gca,'YLim',ylim*1.1)
set(gca,'XLim',[3.8 7.3]);
set(gca,'XTick',[4:0.5:7]);
xlabel('Magnitude');
ylabel('Frequency');
%make sure the length of each str is 5
set(gca,'XTickLabel',['4-4.5';'4.5-5';'5-5.5';'5.5-6';'6-6.5';'6.5-7';' >7.0']);

text(5.5,7000,'Chile,16019 Events');
text(5.5,6000,'2/6/1963-4/16/2013');
title('Histogram of Entire Data Sets, Chile')

