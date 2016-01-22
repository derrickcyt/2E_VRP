function [ GlobalMinResult ] = CVRPABC( InputResult,satId,CusPos,SatPos,CenterPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts )
GlobalMinResult=InputResult;
GlobalMin=InputResult{1,3};
InputSatResult=InputResult{1,2}{satId,1};
SatCusId=[];
for i=1:size(InputSatResult,1)
    Path=InputSatResult{i,1};
    if size(Path,1)~=0 && size(Path,2)~=0
        for j=1:size(Path,1)
            SatCusId=[SatCusId;Path(j)];
        end
    end
end

%%  Set ABC Control Parameters
ABCOpts = struct( 'ColonySize',  30, ...   % Number of Employed Bees+ Number of Onlooker Bees
    'SourceSize',30,...
    'OnlookerSize',10,...
    'MaxCycles', 200,...   % Maximum cycle number in order to terminate the algorithm
    'Limit',   20, ... % Control paramter in order to abandone the food source
    'RecordLimit', 5,...
    'RunTime',1); % Number of the runs

%% initial
Source=cell(ABCOpts.SourceSize,5);%1:result 2:notImTime 3:SatMinFit 4.SourceBestFit 5.SourceBestResult
FrontSource=cell(ABCOpts.SourceSize,3);%1:not improve times 2:satResultList 3:FrontSatFit
for i=1:ABCOpts.SourceSize
    if i<6
        Source{i,1}=InputResult;
    else
        NewResult=InputResult;
        NewSatResult=initSat(SatCusId,CusPos,SatPos,Demand,QUESTIONOpts.L2Fleet,QUESTIONOpts.L2Capacity);
        NewResult{1,2}{satId,1}=NewSatResult;
        NewResult{1,3}=fitness(NewResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
        Source{i,1}=NewResult;
    end
    SatMinFit=satFit(Source{i,1},satId,Cus2CusDist,Sat2CusDist );
    Source{i,3}=SatMinFit;
    Source{i,2}=0;
    Source{i,4}=InputResult{1,3};
    Source{i,5}=InputResult;
    FrontSource{i,1}=0;
    SatRecord=cell(ABCOpts.RecordLimit,1);
    FrontSource{i,2}=SatRecord;
    SatFitness=zeros(ABCOpts.RecordLimit,1);
    FrontSource{i,3}=SatFitness;
end

v=1;
while v<=ABCOpts.MaxCycles
    for i=1:ABCOpts.SourceSize
        Neighbor=neighborInnerOperator(Source{i,1},satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,4);
        tempSatFit=satFit(Neighbor,satId,Cus2CusDist,Sat2CusDist );
        sourceSatFit=satFit(Source{i,1},satId,Cus2CusDist,Sat2CusDist );
        if tempSatFit<Source{i,3}
            FrontSource{i,1}=0;
            Source{i,1}=Neighbor;
            Source{i,3}=tempSatFit;
            Source{i,2}=0;
            Source{i,4}=fitness(Source{i,1},Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
            Source{i,5}=Neighbor;
        else
            FrontSource{i,1}=FrontSource{i,1}+1;
            if FrontSource{i,1}>ABCOpts.RecordLimit
                %restore
                FrontSource{i,1}=0;
                Source{i,1}{1,2}{satId,1}=FrontSource{i,2}{1,1};
                Source{i,1}{1,3}=fitness(Source{i,1},Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
                Source{i,2}=Source{i,2}+1;
            else
                %take a record
                FrontSource{i,2}{FrontSource{i,1},1}=Source{i,1}{1,2}{satId,1};
                FrontSource{i,3}(FrontSource{i,1},1)=sourceSatFit;
                Source{i,1}=Neighbor;
            end
        end
    end
    
    %mem best
    for i=1:ABCOpts.SourceSize
        if Source{i,4}<GlobalMin
            GlobalMin= Source{i,4};
            GlobalMinResult=Source{i,5};
        end
    end
    hold off;
    figure(1);
    plotResult(Source{20,5},CusPos,SatPos,CenterPos);
    GlobalMin
    v=v+1;
end



end

function [NewSatResult]=initSat(SatCusId,CusPos,SatPos,Demand,L2Fleet,L2Capacity)
NewSatResult=cell(L2Fleet,1);
dividedResult=CVPRDegreeDivide( SatCusId,CusPos,SatPos,Demand,L2Fleet,L2Capacity );
for j=1:L2Fleet
    Path=[];
    for k=1:size(dividedResult,1)
        if dividedResult(k,2)==j
            Path=[Path;dividedResult(k,1)];
        end
    end
    NewSatResult{j,1}=Path;
end
end