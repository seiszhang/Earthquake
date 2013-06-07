clear all
close all
clc

%Earthquake Data
Data=xlsread('Japan,24N-45N,132E-142E.xlsx','All','A15:E200000');
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
    TimeBins=[Interval_Lower linspace(1,30,30) 60 90 120 150 180 Interval_Upper];
    
    TimeBins=[Interval_Lower linspace(1,30,30) 60 90 120 150 180 210 240 270 Interval_Upper];
    
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
                        if Temp==0
                            Temp
                        end
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
    Events-LessThanOneYear
    
    NumberOfEvents_Unconditional=sum(UncondFreqDist,2)';
    NumberOfEvents_Conditional=sum(FinalCondFreqDist,2)';
    
    
    %Plotting
      
    %%%%%%%%%%%%%%%%%%%%%%%%%Figure 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeBins2=[linspace(0,1,31) 2 3 4 5 6 12 100];
    TimeBins2=[linspace(0,1,31) 2 3 4 5 6 7 8 9 12 100];

    %%%%%%%%%%%%%%%%%%%%%%%%%Figure 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i=3:5
        %plot
        subplot (2,3,(loop-1)*3+i-2)
        hold on
        Comparison=[FinalUncondAnnualFreq(i,:);FinalCondAnnualFreq(i,:)];
        hb=bar(TimeBins(1:30),Comparison(:,1:30)',1);
        set(hb(1),'facecolor','b');
        set(hb(2),'facecolor','r');
        set(gca,'YLim',ylim*1.2)
        set(gca,'XLim',[-1 TimeBins(30)])
        %set(gca,'xtick',TimeBins)
        %make sure the length of each str is equal
        %set(gca,'XTickLabel',['0-1 ';'1-2 ';'2-3 ';'3-4 ';'4-5 ';'5-6 ';'6-7 ';'7-8 ';'8-9 ';'9-12']);
        
        ylabel('Frequency');
        xlabel('Waiting Time, days')
        
%         for m=1:length(TimeBins)-1
%             height=max(Comparison(:,m));
%             gap=0.05*max(ylim);
%             height1=2*gap+height;
%             height2=gap+height;
%             height3=3*gap+height;
%             height4=4*gap+height;
%             if round(Comparison(1,m)*1000)/1000>=0.005
%                 text(TimeBins(m),height1,num2str(Comparison(1,m)','%1.2f'),'Color','b',...
%                     'HorizontalAlignment','center',...
%                     'VerticalAlignment','bottom')
%             else
%                 text(TimeBins(m),height1,num2str(0),'Color','b',...
%                     'HorizontalAlignment','center',...
%                     'VerticalAlignment','bottom')
%             end
%             if round(Comparison(2,m)*1000)/1000>=0.005
%                 text(TimeBins(m),height2,num2str(Comparison(2,m)','%1.2f'),'Color','r',...
%                     'HorizontalAlignment','center',...
%                     'VerticalAlignment','bottom')
%             else
%                 text(TimeBins(m),height2,num2str(0),'Color','r',...
%                     'HorizontalAlignment','center',...
%                     'VerticalAlignment','bottom')
%             end
%         end
        if i~=5
            title(sprintf('Magnitude %1.1f~%1.1f',MgtBins(i),MgtBins(i+1)));
            str = sprintf('After Triggers >%1.1f',Trigger_Lower);
        else
            title(sprintf('Magnitude >%1.1f',MgtBins(i)));
            str = sprintf('After Triggers >%1.1f',Trigger_Lower);
        end
        h=legend('Entire Data Set',str);
        set(h,'Fontsize',8)
    end
    annotation('textbox',...
        [0.421937042459737 0.96319018404908 0.182016105417277 0.0337423312883436],...
        'String',{'Observed Frequency/yr, 1st month'},...
        'FontWeight','bold',...
        'FontSize',12,...
        'FontName','Arial',...
        'FitBoxToText','off');   
end

