function [ GlobalMinResult ] = runOneData( setName,filename,outputPath,ABCOpts )

addpath('function');
addpath('expfunction');

% %%  Set ABC Control Parameters
% ABCOpts = struct( 'ColonySize',  100, ...   % Number of Employed Bees+ Number of Onlooker Bees
%     'SourceSize',50,...
%     'OnlookerSize',50,...
%     'MaxCycles', 1000,...   % Maximum cycle number in order to terminate the algorithm
%     'FitGoal',   goal+0.1, ...  % Error goal in order to terminate the algorithm (not used in the code in current version)
%     'Limit',   50, ... % Control paramter in order to abandone the food source
%     'RandBeginCycle', 200,...
%     'RecordLimit', 2,...
%     'RecordLimit2',2,...
%     'InitLayer1OptTimes',10,...
%     'InitInnerOptTimes',10,...
%     'EmptySatSourceNum',4,...
%     'SatLimit',50/3,...%sat not improve limit
%     'RunTime',1); % Number of the runs

%% read data
source=importdata(strcat('dataset/',setName,'/',filename),'',9999999);
readdata;

%read best result
% refFilename='2_3_mine.txt';
% BestResult=readResult(strcat('result/reference/',refFilename));

%ABCOpts.Limit=ceil(size(CusPos,1)*2/QUESTIONOpts.Satellites);
%ABCOpts.Limit=2;
%ABCOpts.InitInnerOptTimes=size(CusPos,1);
%ABCOpts.MaxCycles=size(CusPos,1)*5;
%ABCOpts.RandBeginCycle=ceil(ABCOpts.MaxCycles/2);


Cus2CusDist=calCus2CusDist(CusPos);
Sat2SatDist=calSat2SatDist(SatPos);
Center2SatDist=calCenter2SatDist(CenterPos,SatPos);
Sat2CusDist=calSatCusDist(SatPos,CusPos);

RunTimeMinResult=cell(ABCOpts.RunTime,2);%1:result 2:fit
for run=1:ABCOpts.RunTime
    
    fprintf('start initializing.\n');
    %% initial
    empty2Num=0;
    if QUESTIONOpts.Satellites>2
        EmptyPair=nchoosek(1:QUESTIONOpts.Satellites,2);
        empty2Num=size(EmptyPair,1);
    end
    InitResultSet=cell(ABCOpts.SourceSize,2);%1:result 2:ifEmptySat
    distInitNum=ABCOpts.SourceSize-QUESTIONOpts.Satellites*ABCOpts.EmptySatSourceNum-empty2Num*ABCOpts.EmptySatSourceNum;
    %noempty
    for i=1:distInitNum
        TotalResult=initResult( CusPos,SatPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts);
        InitResultSet{i,1}=TotalResult;
        InitResultSet{i,2}=0;
    end
    %1empty
    for i=distInitNum+1:distInitNum+QUESTIONOpts.Satellites*ABCOpts.EmptySatSourceNum;
        ifTryEmpty=1;
        emptySatId=mod(ABCOpts.SourceSize-i+1,QUESTIONOpts.Satellites)+1;
        TotalResult=initResult( CusPos,SatPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ifTryEmpty,emptySatId);
        InitResultSet{i,1}=TotalResult;
        InitResultSet{i,2}=1;
    end
    %2empty
    for i=distInitNum+QUESTIONOpts.Satellites*ABCOpts.EmptySatSourceNum+1:ABCOpts.SourceSize
        ifTryEmpty=1;
        emptySatId=mod(ABCOpts.SourceSize-i+1,size(EmptyPair,1))+1;
        TotalResult=initResult( CusPos,SatPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ifTryEmpty,EmptyPair(emptySatId));
        InitResultSet{i,1}=TotalResult;
        InitResultSet{i,2}=1;
    end
    currentFit=TotalResult{1,3};
    GlobalMin=currentFit;GlobalMinResult=TotalResult;
    
    %initial ABCOpts.SourceSize result
    if run==1
        Source=cell(ABCOpts.SourceSize,8);%index:sourceId 1:result 2:not improve times 3:L1Sources 4:L1 not improve times 5:if rand source 6:minFit 7:minResult
    end
    SourceSatMin=zeros(ABCOpts.SourceSize,QUESTIONOpts.Satellites);
    SourceSatNIT=zeros(ABCOpts.SourceSize,QUESTIONOpts.Satellites);%source each sat not improve times
    SourceL1Min=zeros(ABCOpts.SourceSize,1);
    FrontSource=cell(ABCOpts.SourceSize,4);%1:not improve times 2:satNum 3:satResultList 4:FrontSatFit
    
    
    for i=1:ABCOpts.SourceSize
        outOptTimes=randi([0,floor(QUESTIONOpts.Customers/(2*QUESTIONOpts.Satellites))],1,1);
        Neighbor=InitResultSet{i,1};
        if outOptTimes>0 && InitResultSet{i,2}==0
            for j=1:outOptTimes
                Neighbor=neighborOuterOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,0 );
            end
        end
        
        minFit=Neighbor{1,3};minResult=Neighbor;
        L1Source=cell(10,1);
        for j=1:ABCOpts.InitLayer1OptTimes
            L1Neighbor=layer1NeighborOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,1,QUESTIONOpts);
            L1Source{j,1}=L1Neighbor;
            if L1Neighbor{1,3}<minFit
                minFit=L1Neighbor{1,3};
                minResult=L1Neighbor;
            end
        end
        
        
        for satId=1:QUESTIONOpts.Satellites
            if size(minResult{1,2}{satId,1},1)==0
                continue;
            end
            notImTimes=0;limit=5;
            for j=1:ABCOpts.InitInnerOptTimes
                if notImTimes>limit
                    break;
                end
                Neighbor=neighborInnerOperator(minResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,1);
                
                if Neighbor{1,3}<minFit
                    notImTimes=0;
                    minFit=Neighbor{1,3};
                    minResult=Neighbor;
                else
                    notImTimes=notImTimes+1;
                end
            end
            
        end
        Source{i,1}=minResult;
        Source{i,2}=0;
        Source{i,3}=L1Source;
        Source{i,4}=0;
        Source{i,5}=0;
        Source{i,6}=minResult{1,3};%minFit
        Source{i,7}=minResult;
        
        SourceL1Min(i,1)=layer1Fit( minResult,Center2SatDist,Sat2SatDist );
        NotImproveTimes=zeros(size(L1Neighbor{1,2},1),1);
        FrontSource{i,1}=NotImproveTimes;
        FrontSource{i,2}=size(L1Neighbor{1,2},1);
        SatRecord=cell(size(L1Neighbor{1,2},1),ABCOpts.RecordLimit);
        FrontSource{i,3}=SatRecord;
        SatFitness=zeros(QUESTIONOpts.Satellites,ABCOpts.RecordLimit);
        FrontSource{i,4}=SatFitness;
        for satId=1:size(L1Neighbor{1,2},1)
            SourceSatMin(i,satId)=satFit(Source{i,1},satId,Cus2CusDist,Sat2CusDist );
        end
        fprintf('.');
        if mod(i,50)==0
            fprintf('\n');
        end
    end
    fprintf('\nfinished initialization.\nstart iteration.\n');
    
    %% start iterate
    v=0;randNum=0;innerOptSchemeId=4;
    while v<= ABCOpts.MaxCycles
        if v>ABCOpts.RandBeginCycle
            ABCOpts.RecordLimit=ABCOpts.RecordLimit2;
            innerOptSchemeId=4;
        end
        
        %% for each source
        for i=1:size(Source,1)
            %for L1 improve opt
            if Source{i,4}<50
                for j=1:size(Source{i,3},1)
                    L1Temp=layer1NeighborOperator(Source{i,3}{j,1},Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,1,QUESTIONOpts);
                    if L1Temp{1,3}<Source{i,3}{j,1}{1,3}
                        Source{i,3}{j,1}=L1Temp;
                        Source{i,4}=Source{i,4}-3;
                        SourceL1Min(i,1)=layer1Fit( L1Temp,Center2SatDist,Sat2SatDist );
                    else
                        Source{i,4}=Source{i,4}+1;
                    end
                end
            end
            
            %for every sat
            for satId=1:size(Source{i,1}{1,2},1)
                if size(Source{i,1}{1,2}{satId,1},1)==0 || SourceSatNIT(i,satId)>ABCOpts.SatLimit
                    continue;
                end
                Temp=neighborInnerOperator(Source{i,1},satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,innerOptSchemeId);
                tempSatFit=satFit(Temp,satId,Cus2CusDist,Sat2CusDist );
                sourceSatFit=satFit(Source{i,1},satId,Cus2CusDist,Sat2CusDist );
                if ABCOpts.RecordLimit>0 %if launched torelation
                    %compare satfit instead of total fit
                    if tempSatFit>=sourceSatFit
                        FrontSource{i,1}(satId,1)=FrontSource{i,1}(satId,1)+1;%add times
                        if FrontSource{i,1}(satId,1)>ABCOpts.RecordLimit %if reach the limit
                            SourceSatNIT(i,satId)=SourceSatNIT(i,satId)+1;
                            %restore
                            FrontSource{i,1}(satId,1)=0;
                            Temp{1,2}{satId,1}=FrontSource{i,3}{satId,1};
                            Temp{1,3}=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);%update total fit
                            Source{i,2}=Source{i,2}+1;%add punish
                        else
                            %take a record
                            FrontSource{i,3}{satId,FrontSource{i,1}(satId,1)}=Source{i,1}{1,2}{satId,1};%save current source
                            FrontSource{i,4}(satId,FrontSource{i,1}(satId,1))=sourceSatFit;%save current sat fit
                            %Source{i,2}=Source{i,2}+0.5;%add punish
                        end
                        Source{i,1}=Temp;%replace source
                    else
                        if tempSatFit<SourceSatMin(i,satId)
                            SourceSatNIT(i,satId)=0;
                            Source{i,2}=Source{i,2}-10;%add big award
                            %save this min sat
                            SourceSatMin(i,satId)=tempSatFit;
                            tempMin=SourceL1Min(i,1);
                            for t=1:size(Source{i,1}{1,2},1)
                                tempMin=tempMin+SourceSatMin(i,t);
                            end
                            Source{i,6}=tempMin;
                            Source{i,7}{1,2}{satId,1}=Temp{1,2}{satId,1};
                            Source{i,7}{1,3}=tempMin;
                        end
                        if FrontSource{i,1}(satId,1)==0 %if no record
                            Source{i,2}=Source{i,2}-2;%add award
                        else
                            if tempSatFit<FrontSource{i,4}(satId,1)%if better than the first record, reset it.
                                SourceSatNIT(i,satId)=0;
                                FrontSource{i,1}(satId,1)=0;
                                Source{i,2}=Source{i,2}-2;%add award
                            else
                                FrontSource{i,1}(satId,1)=FrontSource{i,1}(satId,1)+1;%add times
                                if FrontSource{i,1}(satId,1)>ABCOpts.RecordLimit %if reach the limit
                                    SourceSatNIT(i,satId)=SourceSatNIT(i,satId)+1;%sat not improve Limit
                                    %restore
                                    FrontSource{i,1}(satId,1)=0;
                                    Temp{1,2}{satId,1}=FrontSource{i,3}{satId,1};
                                    Temp{1,3}=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);%update total fit
                                    %Source{i,2}=Source{i,2}-1;%add award
                                else
                                    %take a record
                                    FrontSource{i,3}{satId,FrontSource{i,1}(satId,1)}=Source{i,1}{1,2}{satId,1};%save current source
                                    FrontSource{i,4}(satId,FrontSource{i,1}(satId,1))=sourceSatFit;%save current sat fit
                                    %Source{i,2}=Source{i,2}-0.5;%add award
                                end
                            end
                        end
                        Source{i,1}=Temp;%replace source
                    end
                else %if not launched torelation
                    if tempSatFit>=sourceSatFit
                        Source{i,2}=Source{i,2}+1;%if not launch torelation, add normal punish
                    else
                        Source{i,1}=Temp;
                        Source{i,2}=Source{i,2}-2;%give award
                    end
                end
            end
            if Source{i,2}<0
                Source{i,2}=0;
            end
            
        end
        
        %% for each onlooker
        Priotiry=calSourcePriority(Source,GlobalMin,100,ABCOpts);
        for i=1:ABCOpts.OnlookerSize
            which=chooseSource(Priotiry);
            %which=mod(i,size(Source,1))+1;
            %for every sat
            for satId=1:size(Source{which,1}{1,2},1)
                if size(Source{which,1}{1,2}{satId,1},1)==0 || SourceSatNIT(which,satId)>ABCOpts.SatLimit
                    continue;
                end
                Temp=neighborInnerOperator(Source{which,1},satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,innerOptSchemeId);
                tempSatFit=satFit(Temp,satId,Cus2CusDist,Sat2CusDist );
                sourceSatFit=satFit(Source{which,1},satId,Cus2CusDist,Sat2CusDist );
                if ABCOpts.RecordLimit>0 %if launched torelation
                    %compare satfit instead of total fit
                    if tempSatFit>=sourceSatFit
                        FrontSource{which,1}(satId,1)=FrontSource{which,1}(satId,1)+1;%add times
                        if FrontSource{which,1}(satId,1)>ABCOpts.RecordLimit %if reach the limit
                            %SourceSatNIT(which,satId)=SourceSatNIT(which,satId)+1;
                            %restore
                            FrontSource{which,1}(satId,1)=0;
                            Temp{1,2}{satId,1}=FrontSource{which,3}{satId,1};
                            Temp{1,3}=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);%update total fit
                            %Source{which,2}=Source{which,2}+1;%add punish
                        else
                            %take a record
                            FrontSource{which,3}{satId,FrontSource{which,1}(satId,1)}=Source{which,1}{1,2}{satId,1};%save current source
                            FrontSource{which,4}(satId,FrontSource{which,1}(satId,1))=sourceSatFit;%save current sat fit
                            %Source{which,2}=Source{which,2}+0.5;%add punish
                        end
                        Source{which,1}=Temp;%replace source
                    else
                        if tempSatFit<SourceSatMin(which,satId)
                            %SourceSatNIT(which,satId)=0;
                            %Source{which,2}=Source{which,2}-10;%add award
                            SourceSatMin(which,satId)=tempSatFit;
                            tempMin=SourceL1Min(which,1);
                            for t=1:size(Source{which,1}{1,2},1)
                                tempMin=tempMin+SourceSatMin(which,t);
                            end
                            Source{which,6}=tempMin;
                            Source{which,7}{1,2}{satId,1}=Temp{1,2}{satId,1};
                            Source{which,7}{1,3}=tempMin;
                        end
                        if FrontSource{which,1}(satId,1)==0 %if no record
                            %Source{which,2}=Source{which,2}-2;%add award
                        else
                            if tempSatFit<FrontSource{which,4}(satId,1)%if better than the first record, reset it.
                                %SourceSatNIT(which,satId)=0;
                                FrontSource{which,1}(satId,1)=0;
                                %Source{which,2}=Source{which,2}-2;%add award
                            else
                                FrontSource{which,1}(satId,1)=FrontSource{which,1}(satId,1)+1;%add times
                                if FrontSource{which,1}(satId,1)>ABCOpts.RecordLimit %if reach the limit
                                    %SourceSatNIT(which,satId)=SourceSatNIT(which,satId)+1;
                                    %restore
                                    FrontSource{which,1}(satId,1)=0;
                                    Temp{1,2}{satId,1}=FrontSource{which,3}{satId,1};
                                    Temp{1,3}=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);%update total fit
                                    %Source{which,2}=Source{which,2}-1;%add award
                                else
                                    %take a record
                                    FrontSource{which,3}{satId,FrontSource{which,1}(satId,1)}=Source{which,1}{1,2}{satId,1};%save current source
                                    FrontSource{which,4}(satId,FrontSource{which,1}(satId,1))=sourceSatFit;%save current sat fit
                                    %Source{which,2}=Source{which,2}-0.5;%add award
                                end
                            end
                        end
                        Source{which,1}=Temp;%replace source
                    end
                    
                else %if not launched torelation
                    if tempSatFit>=sourceSatFit
                        Source{which,2}=Source{which,2}+1;%if not launch torelation, add normal punish
                    else
                        Source{which,1}=Temp;
                        Source{which,2}=Source{which,2}-2;%give award
                    end
                end
                
            end
            if Source{which,2}<0
                Source{which,2}=0;
            end
        end
        
        
        %%  find same fit source amount
        %use a list to memorize historic fit in order to keep source diverse
        %floor(cusNum/10):to keep more diff sources
        FitList=zeros(10,2);%index:sourceId 1:fit 2:times
        fitNum=0;
        for i=1:ABCOpts.SourceSize
            fitFind=find(FitList(:,1)==Source{i,6});
            if size(fitFind,1)>0
                if FitList(fitFind(1),2)>floor(QUESTIONOpts.Customers/10)
                    Source{i,2}=ABCOpts.Limit+1;
                else
                    FitList(fitFind,2)=FitList(fitFind,2)+1;
                end
            else
                fitNum=fitNum+1;
                FitList(fitNum,:)=[Source{i,6},1];
            end
        end
        
        
        %% for each source, check if it should be replaced by another one
        replaceNum=0;
        for i=1:size(Source,1)
            ReachSatNum=0;
            for j=1:QUESTIONOpts.Satellites
                if SourceSatNIT(i,j)>ABCOpts.SatLimit
                    ReachSatNum=ReachSatNum+1;
                end
            end
            if Source{i,2}>ABCOpts.Limit || ReachSatNum>=QUESTIONOpts.Satellites
                SourceSatNIT(i,:)=0;
                replaceNum=replaceNum+1;
                %if randomly change
                if v>ABCOpts.RandBeginCycle&&randNum<ABCOpts.SourceSize/15&&Source{i,5}==0
                    Source{i,5}=1;
                    randNum=randNum+1;
                end
                Neighbor=Source{i,1};
                if Source{i,5}==0
                    Neighbor=neighborOuterOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,v );
                    if QUESTIONOpts.Satellites>2
                        Neighbor=neighborOuterOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,v );
                    end
                elseif Source{i,5}==10
                    Neighbor=neighborOuterRandOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CenterPos,SatPos,CusPos,v );
                elseif Source{i,5}==1
                    Source{i,5}=0;
                    randNum=randNum-0.5;
                    outOptTimes=randi([0,2],1,1);
                    Neighbor=GlobalMinResult;
                    if outOptTimes==1
                        Neighbor=neighborOuterOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,0 );
                    end
                end
                %here may be not the best
                L1Source=cell(10,1);
                minFit=Neighbor{1,3};minResult=Neighbor;
                for j=1:ABCOpts.InitLayer1OptTimes
                    L1Neighbor=layer1NeighborOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,1,QUESTIONOpts);
                    L1Source{j,1}=L1Neighbor;
                    if L1Neighbor{1,3}<minFit
                        minFit=L1Neighbor{1,3};
                        minResult=L1Neighbor;
                    end
                end
                
                for satId=1:size(L1Neighbor{1,2},1)
                    notImTimes=0;limit=10;
                    for j=1:ABCOpts.InitInnerOptTimes
                        if notImTimes>limit
                            break;
                        end
                        Neighbor=neighborInnerOperator(minResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,innerOptSchemeId);
                        if Neighbor{1,3}<minFit
                            notImTimes=0;
                            minFit=Neighbor{1,3};
                            minResult=Neighbor;
                        else
                            notImTimes=notImTimes+1;
                        end
                    end
                end
                Source{i,1}=minResult;
                Source{i,2}=0;
                Source{i,3}=L1Source;
                Source{i,4}=0;
                Source{i,5}=0;
                Source{i,6}=minResult{1,3};%minFit
                Source{i,7}=minResult;
                SourceL1Min(i,1)=layer1Fit( minResult,Center2SatDist,Sat2SatDist );
                NotImproveTimes=zeros(size(L1Neighbor{1,2},1),1);
                FrontSource{i,1}=NotImproveTimes;
                FrontSource{i,2}=size(L1Neighbor{1,2},1);
                SatRecord=cell(size(L1Neighbor{1,2},1),ABCOpts.RecordLimit);
                FrontSource{i,3}=SatRecord;
                SatFitness=zeros(QUESTIONOpts.Satellites,ABCOpts.RecordLimit);
                FrontSource{i,4}=SatFitness;
                for satId=1:size(L1Neighbor{1,2},1)
                    SourceSatMin(i,satId)=satFit(Source{i,1},satId,Cus2CusDist,Sat2CusDist );
                end
            end
        end
        
        
        %memory best
        minFit=1;
        for i=1:size(Source,1)
            %memory L1 best
            L1Min=1;
            for j=2:size(Source{i,3},1)
                if Source{i,3}{j,1}{1,3}<Source{i,3}{L1Min,1}{1,3}
                    L1Min=j;
                end
            end
            Source{i,1}{1,1}=Source{i,3}{L1Min,1}{1,1};
            Source{i,1}{1,3}=fitness(Source{i,1},Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
            if Source{i,6}<Source{minFit,6}
                minFit=i;
            end
        end
        %if Source{minFit,1}{1,3}<GlobalMin
        if Source{minFit,6}<GlobalMin
            GlobalMin=Source{minFit,6};
            GlobalMinResult=Source{minFit,7};
        end
        fprintf('%s\t%s\t%d\t%f\treplaceNum=%d\n',setName,filename,v,GlobalMin,replaceNum);
%         hold off;
%         figure(1);
%         plotResult(GlobalMinResult,CusPos,SatPos,CenterPos);
        v=v+1;
        if GlobalMin<ABCOpts.FitGoal
            break;
        end
        
        %                 sameSList= checkSatCusAllocWithBest( Source,BestResult,QUESTIONOpts );
        %                 if size(sameSList,1)>0
        %                     for sId=1:size(sameSList,1)
        %                         fprintf('%f-%f-%f ',Source{sameSList(sId,1),1}{1,3},Source{sameSList(sId,1),6},Source{sameSList(sId,1),2});
        %                     end
        %                     fprintf('\n');
        %                 end
        
    end
    RunTimeMinResult{run,1}=GlobalMinResult;
    RunTimeMinResult{run,2}=GlobalMin;
    if GlobalMin<ABCOpts.FitGoal
        break;
    end
    
end

minId=1;
for i=1:run
    if RunTimeMinResult{i,2}<RunTimeMinResult{minId,2}
        minId=i;
    end
end

printResult(RunTimeMinResult{minId,1},outputPath,filename,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand);

end

