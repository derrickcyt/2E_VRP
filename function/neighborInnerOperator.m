function [ Neighbor ] = neighborInnerOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,scheme,Methods )
%find a neighbor in a sat, which won't change the distribution of customers in sat
%this procedure won't change the load distribution in every sat. so it
%don't need to recal the SatLoad(TotalResult{1,4}), just replicate it.

L2Result=TotalResult{1,2};
Neighbor=TotalResult; %replicate firstly

%there are k destorying and recovery method.
%1:randomly choose a customer and break the path that it is belonged to. fix this
%source path and greedy selection a best path to insert.
%2:choose a part of random path and inverse this part in the path. (2-opt)
%3:exchange
%4:try to release a path and merge 2 path
%5:do some path inner opt



%randomly choose one methond
%maybe modify it to probability
if scheme==1
    methodId=randi([1,2],1,1);
elseif scheme==2
    methodId=randi([1,3],1,1);
elseif scheme==3
    methodId=randi([1,4],1,1);
else
    methodId=randi([1,5],1,1);
end
if nargin==11
    methodId=Methods(randi([1,size(Methods,1)],1,1),1);
end
% methodId=3;

CusPath=zeros(size(Cus2CusDist,1),2);%1:cusId 2:pathId
PathNum=0; %amount of paths
SpacePathIds=[];
UsedPathIds=[];
num=0;
for i=1:size(TotalResult{1,2}{satId,1},1)
    if size(TotalResult{1,2}{satId,1}{i,1},1)~=0 && size(TotalResult{1,2}{satId,1}{i,1},2)~=0
        PathNum=PathNum+1;
        UsedPathIds=[UsedPathIds;i];
    else
        SpacePathIds=[SpacePathIds;i];
        continue;
    end
    for j=1:size(TotalResult{1,2}{satId,1}{i,1},1)
        num=num+1;
        CusPath(num,:)=[TotalResult{1,2}{satId,1}{i,1}(j),i];
    end
end
if PathNum<QUESTIONOpts.L2Fleet
    for i=PathNum+1:QUESTIONOpts.L2Fleet
        SpacePathIds=[SpacePathIds;i];
    end
end

CusPath=CusPath(1:num,:);
if PathNum==0
    return;
end
%method 1
if methodId==1
    %randomly choose a customer
    BeginItem=CusPath(randi([1,size(CusPath,1)],1,1),:); %1:cusId 2:pathId
    %delete this cus from source path
    indexInPath=find(L2Result{satId,1}{BeginItem(2),1}==BeginItem(1));
    L2Result{satId,1}{BeginItem(2),1}(indexInPath,:)=[];
    %greedy selection (here maybe too much calculation, choose near path to operate?)
    minFit=+inf;
    for i=1:size(L2Result{satId,1},1)
        for j=1:size(L2Result{satId,1}{i,1},1)+1
            Temp=TotalResult;
            Temp{1,2}=L2Result;
            %insert
            if j==1
                Temp{1,2}{satId,1}{i,1}=[BeginItem(1);L2Result{satId,1}{i,1}];
            elseif j==size(L2Result{satId,1}{i,1},1)+1
                Temp{1,2}{satId,1}{i,1}=[L2Result{satId,1}{i,1};BeginItem(1)];
            else
                Temp{1,2}{satId,1}{i,1}=[L2Result{satId,1}{i,1}(1:j-1);BeginItem(1);L2Result{satId,1}{i,1}(j:end)];
            end
            if checkPathIfOverload(Temp{1,2}{satId,1}{i,1},Demand,QUESTIONOpts.L2Capacity)
                %check if there is 0dist cus
                flag=0;
                for k=1:size(Temp{1,2}{satId,1}{i,1},1)
                    if Sat2CusDist(satId,Temp{1,2}{satId,1}{i,1}(k,1))==0
                        flag=1;
                        if PathNum<QUESTIONOpts.L2Fleet
                            cusId=Temp{1,2}{satId,1}{i,1}(k);
                            %remove this cus
                            Temp{1,2}{satId,1}{i,1}(k)=[];
                            %add to a new path;
                            Temp{1,2}{satId,1}{SpacePathIds(1),1}=[cusId];
                            break;
                        end
                    end
                end
                if checkPathIfOverload(Temp{1,2}{satId,1}{i,1},Demand,QUESTIONOpts.L2Capacity)
                    flag=0;
                end
                if ~flag
                    continue;
                end
            end
            tempFit=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
            
            if tempFit<minFit
                minFit=tempFit;
                Temp{1,3}=tempFit;
                Neighbor=Temp;
            end
        end
    end
    
elseif methodId==2
    %inverse a part of path
    %length limit:2~4
    length=randi([2,4],1,1);
    minFit=+inf;
    for i=1:size(L2Result{satId,1},1)%try every path
        if size(L2Result{satId,1}{i,1},1)>length %  equal is useless
            Temp=Neighbor;
            Temp{1,2}=L2Result;
            Path=Temp{1,2}{satId,1}{i,1};
            %inverse from every position
            for begin=1:size(Temp{1,2}{satId,1}{i,1},1)-length+1
                TTemp=Temp;%restore
                Inverse=flipud(Path(begin:begin+length-1));
                if begin==1
                    TTemp{1,2}{satId,1}{i,1}=[Inverse;Path(begin+length:end)];
                elseif begin+length-1==size(Temp{1,2}{satId,1}{i,1},1)
                    TTemp{1,2}{satId,1}{i,1}=[Path(1:begin-1);Inverse];
                else
                    TTemp{1,2}{satId,1}{i,1}=[Path(1:begin-1);Inverse;Path(begin+length:end)];
                end
                tempFit=fitness(TTemp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
                if tempFit<minFit
                    minFit=tempFit;
                    TTemp{1,3}=tempFit;
                    Neighbor=TTemp;
                    break;
                end
            end
        end
    end
    
    if Neighbor{1,3}>=TotalResult{1,3}
        %try again
        Neighbor=neighborInnerOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,1,[1;3;4]);
        return;
    end
    
elseif methodId==3
    [Neighbor,ifChanged]=neihborInnerExchangeOperator(TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts);
    if ifChanged==0
        Neighbor=neighborInnerOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,1,[1;2;4;5]);
        %     else
        %         %do some optimization
        %         Neighbor=neighborInnerOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,1,[2;5]);
    end
    
elseif methodId==4
    Neighbor=releasePathTry( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos);
    
    if Neighbor{1,3}>TotalResult{1,3}
        Neighbor=neighborInnerOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,2,[2;5]);
    elseif Neighbor{1,3}==TotalResult{1,3}
        Neighbor=neighborInnerOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,2,[1;2;3;5]);
    else
        return;
    end
elseif methodId==5
    %try every path
    for i=1:PathNum
        Path=Neighbor{1,2}{satId,1}{UsedPathIds(i),1};
        if size(Path,1)>1
            Path=PathInnerOperator(Path,satId,Cus2CusDist,Sat2CusDist,3);
            %save
            Neighbor{1,2}{satId,1}{UsedPathIds(i),1}=Path;
        end
    end
    Neighbor{1,3}=fitness(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
    
    if Neighbor{1,3}==TotalResult{1,3}
        %try again
        Neighbor=neighborInnerOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos,3,[1;3;4]);
        return;
    end
    
end


end

