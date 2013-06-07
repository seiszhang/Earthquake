clear all
close all
clc

%Earthquake Data
%Earthquake Data
Data=xlsread('Japan,24N-45N,132E-142E.xlsx','All','A15:E200000');
%scatter(Data(:,3),Data(:,2))

[Empty,Index]=sort(Data(:,1),'descend');
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
    Interval_Upper=365;
    Interval=abs(Interval_Upper-Interval_Lower);
        
    %Waiting Time till next event Bins, X Axis
    TimeBins=[Interval_Lower 30 60 90 120 150 180 Interval_Upper];
       
    Events=length(find( Data(:,5)>=Trigger_Lower & Data (:,5)<Trigger_Upper))%Number of Largest Events pickd
    
    TotalTimeSpan=abs((Data(size(Data,1),1)-Data(1,1))/365.25);
    
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
    
    %%%%%Conditional Distribution
    clear Index
    clear Data2
    clear MgtSorted
    emptycond1=0;
    emptycond2=0;
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
        if DataSortedByMgt(k,1)-Data(size(Data,1),1) >= Interval_Upper
            %clear ConditionalData
            
            %all the data within interval after the trigger event
            ConditionalData=Data(find( Data(:,1)>=(DataSortedByMgt(k,1)-Interval_Upper) & Data(:,1)<=(DataSortedByMgt(k,1)-Interval_Lower)),:);
            
            for i=1:length(MgtBins)
                clear Index
                clear CurrentData
                clear Temp
                %clear CurrentDataSortedByTime
                
                %all the data within the magnitude bin(i)
                if i<length(MgtBins)
                    CurrentData=ConditionalData(find( ConditionalData(:,5)>=MgtBins(i) & ConditionalData(:,5)<=MgtBins(i+1)),:);
                else
                    CurrentData=ConditionalData(find( ConditionalData(:,5)>=MgtBins(i)),:);
                end
                
                %calculate
                if size(CurrentData,1)>1
                    [TimeSorted,Index]=sort(CurrentData(:,1),'descend');
                    CurrentDataSortedByTime=CurrentData(Index,:);
                    for j=1:size(CurrentDataSortedByTime,1)-1;
                        Temp(j)=-(CurrentDataSortedByTime(j+1,1)-CurrentDataSortedByTime(j,1));
                    end
             
                    CondFreqDist(i,:,k)=histc(Temp,TimeBins);

                    
                elseif size(CurrentData,1)==1
                    CondFreqDist(i,:,k)=zeros(1,length(TimeBins));
                  
                    emptycond1=emptycond1+1;
                    
                else
                    CondFreqDist(i,:,k)=zeros(1,length(TimeBins));
                   
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
    
    bar(MgtBins,sum(FinalCondFreqDist,2))
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
    set(gca,'XTickLabel',['4-4.5';'4.5-5';'5-5.5';'5.5-6';' >6  ']);
    if loop==1
        title(sprintf('Total "Aftershocks" 1 year before trigger, %1d Triggers of >6.5',Events-LessThanOneYear))
    elseif loop==2
        title(sprintf('Total "Aftershocks" 1 year before trigger, %1d Triggers of >6',Events-LessThanOneYear))
    end
     
    subplot(2,3,(loop-1)*3+3)
    Comparison2=[histc(Data(:,5),MgtBins)'/TotalTimeSpan;sum(FinalCondAnnualFreq,2)'];
    bar(MgtBins,Comparison2',1);
    text(MgtBins,Comparison2(1,:)',num2str(Comparison2(1,:)',3),'Color','b',...
        'HorizontalAlignment','right',...
        'VerticalAlignment','bottom')
    text(MgtBins,Comparison2(2,:)',num2str(Comparison2(2,:)',3),'Color','r',...
        'HorizontalAlignment','left',...
        'VerticalAlignment','bottom')        
    if loop==1
        title(sprintf('Observed Frequency per Year, before %1d Triggers of >6.5',Events-LessThanOneYear))
        legend('Entire Data Set','After Trigger>6.5'); 
    elseif loop==2
        title(sprintf('Observed Frequency per Year, before %1d Triggers of >6',Events-LessThanOneYear))
        legend('Entire Data Set','After Trigger>6'); 
    end
    set(gca,'XLim',[3.8 6.2])
    set(gca,'YLim',ylim*1.1)
    set(gca,'XTick',[4:0.5:6]);
    str = sprintf('Triggers: >%1.1f',Trigger_Lower);
    ylabel(str);
    %make sure the length of each str is 5
    set(gca,'XTickLabel',['4-4.5';'4.5-5';'5-5.5';'5.5-6';' >6  ']);
    
    
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
    CI_upper_2 = (n+1)/T * ( 1-1/9/(n+1) + z /3/sqrt(n+1)).^3;
    
    TimeBins2=[0 1 2 3 4 5 6 12 100];
    if loop==1
        for i=3:5
            subplot (2,3,(loop-1)*3+i-2+3)
            hold on
            for j=1:length(TimeBins2)-1
                UncondExp(j)=(LambdaUnCond(i)*12)*(expcdf(TimeBins2(j+1),1/LambdaUnCond(i))-expcdf(TimeBins2(j),1/LambdaUnCond(i)));
                UncondExp_lower(j) = (LambdaUnCond(i)*12)*(expcdf(TimeBins2(j+1),1/(CI_lower(i)))-expcdf(TimeBins2(j),1/(CI_lower(i))));
                UncondExp_upper(j) = (LambdaUnCond(i)*12)*(expcdf(TimeBins2(j+1),1/(CI_upper(i)))-expcdf(TimeBins2(j),1/(CI_upper(i))));
            end
            
            Comparison=[FinalUncondAnnualFreq(i,:);UncondExp];
            hb=bar(TimeBins,Comparison',1);
            set(hb(1),'facecolor','b');
            set(hb(2),'facecolor','k');
            set(gca,'YLim',ylim*1.2)
            set(gca,'XLim',[Interval_Lower-20 Interval_Upper-150])
            set(gca,'xtick',TimeBins)
            %make sure the length of each str is equal
            set(gca,'XTickLabel',['- 0-1 ';'- 1-2 ';'- 2-3 ';'- 3-4 ';'- 4-5 ';'- 5-6 ';'- 6-12']);
            str = sprintf('Frequency');
            ylabel(str);
            xlabel('Waiting Time, months')
            
            for m=1:length(TimeBins)
                height=max(Comparison(:,m));
                gap=0.05*max(ylim);
                height1=2*gap+height;
                height2=gap+height;
                height3=height;
                text(TimeBins(m),height1,num2str(Comparison(1,m)','%1.2f'),'Color','b',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom')
                text(TimeBins(m),height2,num2str(Comparison(2,m)','%1.2f'),'Color','k',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom')
            end
            
            h=legend('Entire Data Set','Expected, If Independent');
            set(h,'Fontsize',7)
            if i~=5
                title(sprintf('Magnitude %1.1f~%1.1f',MgtBins(i),MgtBins(i+1)));
            else
                title(sprintf('Magnitude >%1.1f',MgtBins(i)));
            end
            hold off
        end
    end
    annotation('textbox',...
    [0.331161054172768 0.526073619631902 0.381869692532943 0.0567484662576703],...
    'String',{'Waiting Times for Entire Data Set: Observed vs Expected'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%Figure 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(3)
    
    TimeBins2=[0 1 2 3 4 5 6 12 100];
    for i=3:5
        subplot (2,3,(loop-1)*3+i-2)
        hold on
        Comparison=[FinalUncondAnnualFreq(i,:);FinalCondAnnualFreq(i,:)];
        hb=bar(TimeBins,Comparison',1);
        set(hb(1),'facecolor','b');
        set(hb(2),'facecolor','r');      
        set(gca,'YLim',ylim*1.2)
        set(gca,'XLim',[Interval_Lower-20 Interval_Upper-150])
        set(gca,'xtick',TimeBins)
        %make sure the length of each str is equal
        set(gca,'XTickLabel',['- 0-1 ';'- 1-2 ';'- 2-3 ';'- 3-4 ';'- 4-5 ';'- 5-6 ';'- 6-12']);

        ylabel('Frequency');
        xlabel('Waiting Time, months')
        
        for m=1:length(TimeBins)
            height=max(Comparison(:,m));
            gap=0.05*max(ylim);
            height1=2*gap+height;
            height2=gap+height;
            height3=height;
            text(TimeBins(m),height1,num2str(Comparison(1,m)','%1.2f'),'Color','b',...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom')
            text(TimeBins(m),height2,num2str(Comparison(2,m)','%1.2f'),'Color','r',...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom')    
        end
        if i~=5
            title(sprintf('Magnitude %1.1f~%1.1f',MgtBins(i),MgtBins(i+1)));
            str = sprintf('After Triggers >%1.1f',Trigger_Lower);
        else
            title(sprintf('Magnitude >%1.1f',MgtBins(i)));
            str = sprintf('After Triggers >%1.1f',Trigger_Lower);
        end
        h=legend('Entire Data Set',str);
        set(h,'Fontsize',8)
        hold off
    end
annotation('textbox',...
    [0.369228404099561 0.961656441717791 0.287433382137628 0.030674846625767],...
    'String',{'Observed Frequency per Year before Trigger'},...
    'FontWeight','bold',...
    'FontSize',12,...
    'FontName','Arial',...
    'FitBoxToText','off');
end

%% plotting entire data set histogram

figure(1)
subplot(2,3,1)

Data_Mgts = [histc(Data(:,5),MgtBins2)];
bar(MgtBins2,Data_Mgts)
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

text(5.5,7000,'Japan,15039 Events'); 
text(5.5,6000,'2/9/1963-9/21/2012'); 
title('Histogram of Entire Data Sets, Japan')


