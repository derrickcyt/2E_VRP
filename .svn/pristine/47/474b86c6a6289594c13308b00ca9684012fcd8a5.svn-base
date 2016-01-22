clear all
close all
clc

addpath('../function');
addpath('..');
%% read data
setName='set2';
filename='E-n51-k5-s11-19.dat';
source=importdata(strcat('../dataset/',setName,'/',filename),'',9999999);
readdata;

Cus2CusDist=calCus2CusDist(CusPos);
Sat2SatDist=calSat2SatDist(SatPos);
Center2SatDist=calCenter2SatDist(CenterPos,SatPos);
Sat2CusDist=calSatCusDist(SatPos,CusPos);

%% read old result
oldResultFileName='28-Dec-2015_E-n51-k5-s11-19.dat';
OldResult=readResult(strcat('../result/test/',oldResultFileName));

%plotResult(OldResult,CusPos,SatPos,CenterPos);


%%  Set ABC Control Parameters
ABCOpts = struct( 'ColonySize',  100, ...   % Number of Employed Bees+ Number of Onlooker Bees
    'SourceSize',20,...
    'OnlookerSize',20,...
    'MaxCycles', 500,...   % Maximum cycle number in order to terminate the algorithm
    'FitGoal',   0, ...  % Error goal in order to terminate the algorithm (not used in the code in current version)
    'Limit',   3, ... % Control paramter in order to abandone the food source
    'RunTime',1); % Number of the runs

%% start iteration
Source=cell(ABCOpts.SourceSize,3);
for i=1:ABCOpts.SourceSize
    Source{i,1}=OldResult;
    Source{i,2}=0;
    Source{i,3}=OldResult;
end

v=1;
GlobalMin=OldResult{1,3};GlobalMinResult=OldResult;
while v<=ABCOpts.MaxCycles
    
    for i=1:ABCOpts.SourceSize
        Source{i,2}=Source{i,2}+1;
        for satId=2:QUESTIONOpts.Satellites
            Neighbor=neighborInnerOperator( Source{i,1},satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,2 );
        end
        if Neighbor{1,3}<Source{i,3}{1,3}
            Source{i,3}=Neighbor;
            Source{i,2}=0;
        end
        if Source{i,2}>ABCOpts.Limit
            Source{i,1}=Source{i,3};
            Source{i,2}=0;
        else
            Source{i,1}=Neighbor;
        end
         
    end
    
    Priotiry=calSourcePriority(Source,GlobalMin,100,ABCOpts);
    for i=1:ABCOpts.OnlookerSize
        which=chooseSource(Priotiry);
        Source{which,2}=Source{which,2}+1;
        for satId=1:QUESTIONOpts.Satellites
            Neighbor=neighborInnerOperator( Source{i,1},satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,2 );
        end
        if Neighbor{1,3}<Source{which,3}{1,3}
            Source{which,3}=Neighbor;
            Source{which,2}=0;
        end
        if Source{which,2}>ABCOpts.Limit
            Source{which,1}=Source{which,3};
            Source{which,2}=0;
        else
            Source{which,1}=Neighbor;
        end
    end
    
    
    %mem best
    for i=1:ABCOpts.SourceSize
        if Source{i,3}{1,3}<GlobalMin
            GlobalMin=Source{i,3}{1,3};
            GlobalMinResult=Source{i,3};
        end
    end
    
    hold off;
    figure(1);
    plotResult(GlobalMinResult,CusPos,SatPos,CenterPos);
    
    fprintf('v=%d GlobalMin=%f\n',v,GlobalMin);
    
    
    v=v+1;
end