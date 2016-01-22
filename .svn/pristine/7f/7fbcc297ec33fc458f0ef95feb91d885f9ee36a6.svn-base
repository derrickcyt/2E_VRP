
addpath('../function');
addpath('..');
addpath('../expfunction');

%%  Set ABC Control Parameters
ABCOpts = struct( 'ColonySize',  200, ...   % Number of Employed Bees+ Number of Onlooker Bees
    'SourceSize',100,...
    'OnlookerSize',100,...
    'MaxCycles', 50,...   % Maximum cycle number in order to terminate the algorithm
    'FitGoal',   0, ...  % Error goal in order to terminate the algorithm (not used in the code in current version)
    'Limit',   20, ... % Control paramter in order to abandone the food source
    'RandBeginCycle', 50,...
    'RandBeginCycle2',70,...
    'RecordLimit', 2,...
    'RecordLimit2',3,...
    'RunTime',1); % Number of the runs

setName='set2';
filename='E-n51-k5-s11-19.dat';
source=importdata(strcat('../dataset/',setName,'/',filename),'',9999999);
readdata;

%read best result
refFilename='11_19_mine.txt';
BestResult=readResult(strcat('../result/reference/',refFilename));

ABCOpts.Limit=size(CusPos,1)*2;
%ABCOpts.Limit=2;

Cus2CusDist=calCus2CusDist(CusPos);
Sat2SatDist=calSat2SatDist(SatPos);
Center2SatDist=calCenter2SatDist(CenterPos,SatPos);
Sat2CusDist=calSatCusDist(SatPos,CusPos);

RunTimeMinResult=cell(ABCOpts.RunTime,2);%1:result 2:fit
for run=1:ABCOpts.RunTime
    
    %% initial
    InitResultSet=cell(ABCOpts.SourceSize,1);
    for i=1:ABCOpts.SourceSize
        TotalResult=initResult( CusPos,SatPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts );
        InitResultSet{i,1}=TotalResult;
        %plotResult(TotalResult,CusPos,SatPos,CenterPos);
    end
    currentFit=TotalResult{1,3};
    GlobalMin=currentFit;GlobalMinResult=TotalResult;
    
    %initial ABCOpts.SourceSize result
    if run==1
        Source=cell(ABCOpts.SourceSize,8);%index:sourceId 1:result 2:not improve times 3:L1Sources 4:L1 not improve times 5:if rand source 6:minFit 7:minResult
    end
    for i=1:ABCOpts.SourceSize
        outOptTimes=randi([0,floor(QUESTIONOpts.Customers/4)],1,1);
        Neighbor=InitResultSet{i,1};
        if outOptTimes>0
            for j=1:outOptTimes
                Neighbor=neighborOuterOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,0 );
            end
        end
        minFit=Neighbor{1,3};minResult=Neighbor;
        L1Source=cell(10,1);
        for j=1:10
            L1Neighbor=layer1NeighborOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,1,QUESTIONOpts);
            L1Source{j,1}=L1Neighbor;
            if L1Neighbor{1,3}<minFit
                minFit=L1Neighbor{1,3};
                minResult=L1Neighbor;
            end
        end
        for satId=1:size(L1Neighbor{1,2},1)
            for j=1:10
                Neighbor=neighborInnerOperator(minResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,1);
                if Neighbor{1,3}<minFit
                    minFit=Neighbor{1,3};
                    minResult=Neighbor;
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
        Source{i,8}=outOptTimes;
    end
    
    fprintf('finished initialization.\n');
    
    
%% start iterate
    v=0;randNum=0;innerOptSchemeId=1;
    while v<= ABCOpts.MaxCycles
        
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
            fprintf('caling source %d,',i);
            fprintf('before fit=%f\n',Source{i,1}{1,3});
            %for every sat
            for satId=1:size(Source{i,1}{1,2},1)
                Neighbor=CVRPABC( Source{i,1},satId,CusPos,SatPos,CenterPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts );
                if Neighbor{1,3}<Source{i,1}{1,3}
                    Source{i,1}=Neighbor;
                    Source{i,2}=0;
                else
                    Source{i,2}=Source{i,2}+ABCOpts.Limit/2;
                end
            end
            fprintf('after fit=%f\n',Source{i,1}{1,3});
        end
        
        %% for each onlooker
        Priotiry=calSourcePriority(Source,GlobalMin,100,ABCOpts);
        for i=1:ABCOpts.OnlookerSize
            which=chooseSource(Priotiry);
            %which=mod(i,size(Source,1))+1;
            %for every sat
            for satId=1:size(Source{which,1}{1,2},1)
                Neighbor=CVRPABC( Source{i,1},satId,CusPos,SatPos,CenterPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts );
                if Neighbor{1,3}<Source{i,1}{1,3}
                    Source{i,1}=Neighbor;
                    Source{i,2}=0;
                else
                    Source{i,2}=Source{i,2}+ABCOpts.Limit/2;
                end
            end
        end
        
        %% for each source, check if it should be replaced by another one
        replaceNum=0;
        for i=1:size(Source,1)
            if Source{i,2}>ABCOpts.Limit
                replaceNum=replaceNum+1;
                Neighbor=Source{i,1};
                if Source{i,5}==0
                    Neighbor=neighborOuterOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,v );
                elseif Source{i,5}==1
                    Neighbor=neighborOuterRandOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CenterPos,SatPos,CusPos,v );
                else
                    outOptTimes=randi([0,1],1,1);
                    Neighbor=GlobalMinResult;
                    if outOptTimes==1
                        Neighbor=neighborOuterOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,0 );
                    end
                end
                %here may be not the best
                L1Source=cell(10,1);
                minFit=Neighbor{1,3};minResult=Neighbor;
                for j=1:10
                    L1Neighbor=layer1NeighborOperator(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,1,QUESTIONOpts);
                    L1Source{j,1}=L1Neighbor;
                    if L1Neighbor{1,3}<minFit
                        minFit=L1Neighbor{1,3};
                        minResult=L1Neighbor;
                    end
                end
                
                for satId=1:size(L1Neighbor{1,2},1)
                    for j=1:10
                        Neighbor=neighborInnerOperator(minResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,innerOptSchemeId);
                        if Neighbor{1,3}<minFit
                            minFit=Neighbor{1,3};
                            minResult=Neighbor;
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
        fprintf('replaceNum=%d\n',replaceNum);
        fprintf('%s %s %d %f\r\n',setName,filename,v,GlobalMin);
%         hold off;
%         figure(1);
%         plotResult(GlobalMinResult,CusPos,SatPos,CenterPos);
        v=v+1;
        if GlobalMin<ABCOpts.FitGoal
            break;
        end
        
        sameSList= checkSatCusAllocWithBest( Source,BestResult,QUESTIONOpts );
        if size(sameSList,1)>0
            for sId=1:size(sameSList,1)
                fprintf('%f-%f-%f ',Source{sameSList(sId,1),1}{1,3},Source{sameSList(sId,1),6},Source{sameSList(sId,1),2});
            end
            fprintf('\n');
        end
        
    end
    RunTimeMinResult{run,1}=GlobalMinResult;
    RunTimeMinResult{run,2}=GlobalMin;
    if GlobalMin<ABCOpts.FitGoal
        break;
    end
    
end

%GlobalMin
%overlimitTimes
%overlimitRecord=overlimitRecord(1:overlimitTimes,:)
%plotResult(GlobalMinResult,CusPos,SatPos,CenterPos);
minId=1;
for i=1:run
    if RunTimeMinResult{i,2}<RunTimeMinResult{minId,2}
        minId=i;
    end
end




printResult(RunTimeMinResult{minId,1},outputPath,filename,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand);




