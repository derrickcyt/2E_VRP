function [ Neighbor ] = neighborOuterOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,cycleNum )
Neighbor=TotalResult;
%this is a standard outer operater.

%choose 2 adjacent sat and select randomly near path near the other sat.In
%this path,choose 1~3 cus to transfer into the other sat.
sat1=0;sat2=0; %chosen satId
if size(SatPos,1)<=2
    sat1=randi([1,2],1,1);sat2=1+mod(sat1,2);
else
    %cal the degree of sat2center
    Sat2CenterDegree=zeros(size(SatPos,1),1);%index:satId 1:degree
    for i=1:size(SatPos,1)
        x=SatPos(i,1)-CenterPos(1);y=SatPos(i,2)-CenterPos(2);
        Sat2CenterDegree(i,1)=getDegree(x,y);
    end
    %randomly choose first sat
    sat1=randi([1,size(SatPos,1)],1,1);
    %get its adjacent sat(the least bigger than its degree)
    TempDegree=Sat2CenterDegree-Sat2CenterDegree(sat1);
    TempDegree=mod(TempDegree,360);
    TempDegree(sat1,1)=+inf;
    sat2=find(TempDegree==min(TempDegree),1);
end

%choose 1~3 cus in a path of sat1 near sat2
%cal the sat2's center
sat2x=0;sat2y=0;sat2CusNum=0;
for i=1:size(Neighbor{1,2}{sat2,1},1)
    if size(Neighbor{1,2}{sat2,1}{i,1},1)==0
        continue;
    end
    for j=1:size(Neighbor{1,2}{sat2,1}{i,1},1)
        sat2CusNum=sat2CusNum+1;
        sat2x=sat2x+CusPos(Neighbor{1,2}{sat2,1}{i,1}(j),1);
        sat2y=sat2y+CusPos(Neighbor{1,2}{sat2,1}{i,1}(j),2);
    end
end
if sat2CusNum>0
    sat2x=sat2x/sat2CusNum;sat2y=sat2y/sat2CusNum;
else
    sat2x=SatPos(sat2,1);sat2y=SatPos(sat2,2);
end

Sat1Cus2Sat2Dist=zeros(size(CusPos,1),2);
Sat1Cus2Sat2Dist(:,2)=+inf;
sat1CusNum=0;
for i=1:size(Neighbor{1,2}{sat1,1},1)
    if size(Neighbor{1,2}{sat1,1}{i,1},1)==0
        continue;
    end
    for j=1:size(Neighbor{1,2}{sat1,1}{i,1},1)
        sat1CusNum=sat1CusNum+1;
        Sat1Cus2Sat2Dist(sat1CusNum,1)=Neighbor{1,2}{sat1,1}{i,1}(j);
    end
end
Sat1Cus2Sat2Dist=Sat1Cus2Sat2Dist(1:sat1CusNum,:);

ChosenCus=zeros(size(Sat1Cus2Sat2Dist,1),1);
%methodId=randi([1,4],1,1);
methodId=0;%temp not use
ifFindSingle=0;
if methodId==1
    %try to find single-cus path in sat1
    ifFindSingle=0;
    for i=1:size(TotalResult{1,2}{sat1,1},1)
        if size(TotalResult{1,2}{sat1,1}{i,1},1)==1 && size(TotalResult{1,2}{sat1,1}{i,1},2)~=0
            ifFindSingle=1;
            ChosenCus=[TotalResult{1,2}{sat1,1}{i,1}(1,1)];
        end
    end
end

if ~ifFindSingle
    if sat1CusNum==0
        %try again
        Neighbor=neighborOuterOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,cycleNum );
        return;
    elseif sat1CusNum>1
        for i=1:size(Sat1Cus2Sat2Dist,1)
            %cal the dist between sat1's cus and sat2
            Sat1Cus2Sat2Dist(i,2)=sqrt((sat2x-CusPos(Sat1Cus2Sat2Dist(i,1),1)).^2+(sat2y-CusPos(Sat1Cus2Sat2Dist(i,1),2)).^2);
        end
        %from candidateNum cus to choose 1~3 cus to transfer
        candidateNum=0;chosenNum=0;
        if size(Sat1Cus2Sat2Dist,1)>7
            candidateNum=5;
            %randomly choose 1~3
            chosenNum=randi([1,3],1,1);
        elseif size(Sat1Cus2Sat2Dist,1)>3
            candidateNum=3;
            %randomly choose 1~2
            chosenNum=randi([1,2],1,1);
        else
            candidateNum=2;
            chosenNum=1;
        end
        %find the min candidateNum cus
        if cycleNum>ABCOpts.RandBeginCycle
            %add some stochastic
            ChosenCus=Sat1Cus2Sat2Dist(randperm(size(Sat1Cus2Sat2Dist,1),chosenNum),1);
        else
            temp=sort(Sat1Cus2Sat2Dist(:,2));
            CandidateIndex=find(Sat1Cus2Sat2Dist(:,2)<=temp(candidateNum));
            ChosenCus=Sat1Cus2Sat2Dist(CandidateIndex(randperm(size(CandidateIndex,1),chosenNum),1),1);
        end
    elseif sat1CusNum==1
        ChosenCus=[Sat1Cus2Sat2Dist(1,1)];
    end
end

%update SatLoad                  sat1->sat2
for i=1:size(ChosenCus,1)
    Neighbor{1,4}(sat1,1)=Neighbor{1,4}(sat1,1)-Demand(ChosenCus(i,1),1);
    Neighbor{1,4}(sat2,1)=Neighbor{1,4}(sat2,1)+Demand(ChosenCus(i,1),1);
end

%remove chosen cus from sat1
for i=1:size(Neighbor{1,2}{sat1,1},1)
    TempOldPath=Neighbor{1,2}{sat1,1}{i,1};
    [C,Ia,Ib]=intersect(TempOldPath,ChosenCus);
    if size(C,1)>0
        TempOldPath(Ia,:)=[];
        Neighbor{1,2}{sat1,1}{i,1}=TempOldPath;
    end
end

%how to insert these cus into sat2
%there is two method:1,new a path;2,insert into the near paths(which path? how many?) in sat2
%-----------temporarily I choose method 1, if sat2 has spare path----------
ifInsert=0;
%find a spare path to insert
%!!!!!!!!!!!!!!!!!!!haven't consider that if Total ChosenCus is overloaded
for i=1:QUESTIONOpts.L2Fleet
    if i>size(Neighbor{1,2}{sat2,1},1) || size(Neighbor{1,2}{sat2,1}{i,1},1)==0
        %check if ChosenCus is overloaded
        load=0;maxCusId=1;
        for j=1:size(ChosenCus)
            load=load+Demand(ChosenCus(j,1),1);
            if Demand(ChosenCus(j,1),1)>Demand(ChosenCus(maxCusId,1),1)
                maxCusId=j;
            end
        end
        if load>QUESTIONOpts.L2Capacity
            %insert 1 biggist cus
            Neighbor{1,2}{sat2,1}{i,1}=[ChosenCus(maxCusId,1)];
            %remove it from ChosenCus
            ChosenCus(maxCusId,:)=[];
        else
            Neighbor{1,2}{sat2,1}{i,1}=ChosenCus;
            ifInsert=1;
            break;
        end
    end
end
if ~ifInsert
    %choose a near path to insert
    %cal the rest space in every path in sat2
    RestSpace=zeros(QUESTIONOpts.L2Fleet,1);%index:pathId 1:restSpace
    sat2PathNum=0;
    for i=1:QUESTIONOpts.L2Fleet
        if i>size(Neighbor{1,2}{sat2,1},1) || size(Neighbor{1,2}{sat2,1}{i,1},1)==0
            RestSpace(i,1)=QUESTIONOpts.L2Capacity;
        else
            sat2PathNum=sat2PathNum+1;
            load=0;
            for j=1:size(Neighbor{1,2}{sat2,1}{i,1},1)
                load=load+Demand(Neighbor{1,2}{sat2,1}{i,1}(j,1),1);
            end
            RestSpace(i,1)=QUESTIONOpts.L2Capacity-load;
        end
    end
    %if there is no path in sat2
    if sat2PathNum==0
        %find a new path to insert
        Neighbor{1,2}{sat2,1}{1,1}=ChosenCus;
    else
        %cal the center of path in sat2
        PathCenter=zeros(size(Neighbor{1,2}{sat2,1},1),2); %index:pathId 1:x 2:y
        for i=1:size(Neighbor{1,2}{sat2,1},1)
            x=0;y=0;
            for j=1:size(Neighbor{1,2}{sat2,1}{i,1},1)
                x=x+CusPos(Neighbor{1,2}{sat2,1}{i,1}(j,1),1);
                y=y+CusPos(Neighbor{1,2}{sat2,1}{i,1}(j,1),2);
            end
            x=x/size(Neighbor{1,2}{sat2,1}{i,1},1);y=y/size(Neighbor{1,2}{sat2,1}{i,1},1);
            PathCenter(i,:)=[x,y];
        end
        
        %cal dist between path and chosen cus
        ChosenCus2PathDist=zeros(size(ChosenCus,1),size(Neighbor{1,2}{sat2,1},1)); % index:chosenCusId colomn:pathId
        for i=1:size(ChosenCus,1)
            for j=1:size(Neighbor{1,2}{sat2,1},1)
                ChosenCus2PathDist(i,j)=sqrt((PathCenter(j,1)-CusPos(ChosenCus(i,1),1)).^2+(PathCenter(j,2)-CusPos(ChosenCus(i,1),2)).^2);
            end
        end
        
        %choose a nearest path to insert
        for i=1:size(ChosenCus,1)
            TempPathDist=ChosenCus2PathDist(i,:)';
            S=sort(TempPathDist);ifInsertPath=0;
            for j=1:size(Neighbor{1,2}{sat2,1},1)
                minPathId=find(TempPathDist==S(j,1),1);
                if RestSpace(minPathId,1)>=Demand(ChosenCus(i,1))
                    %insert
                    Neighbor{1,2}{sat2,1}{minPathId,1}(end+1,1)=ChosenCus(i,1);
                    RestSpace(minPathId,1)=RestSpace(minPathId,1)-Demand(ChosenCus(i,1));
                    ifInsertPath=1;
                    break;
                end
            end
            if ~ifInsertPath
                %try again
                Neighbor=neighborOuterOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,ABCOpts,CenterPos,SatPos,CusPos,cycleNum );
                return;
            end
        end
    end
end

%L1 initial
%greedy selection
L1Result=cell(QUESTIONOpts.Satellites,1); L1Num=0;
SatLoad=Neighbor{1,4};
while size(nonzeros(SatLoad),1)>0
    Sq=[];
    %start from Center. choose a possible and nearest sat
    CandidateSat=find(SatLoad~=0);minIndex=1; % min dist from center or last sat
    for i=1:size(CandidateSat,1)
        if(Center2SatDist(CandidateSat(i))<Center2SatDist(minIndex))
            minIndex=CandidateSat(i);
        end
    end
    currentSatIndex=minIndex;
    if SatLoad(minIndex)<QUESTIONOpts.L1Capacity
        load=SatLoad(minIndex);
        SatLoad(minIndex)=0;
        Sq=[Sq;minIndex,load];
    else
        load=QUESTIONOpts.L1Capacity;
        SatLoad(minIndex)=SatLoad(minIndex)-QUESTIONOpts.L1Capacity;
        L1Num=L1Num+1;
        Sq=[Sq;minIndex,load];
        L1Result(L1Num,1)={Sq};
        continue;
    end
    
    %find more sat adding to this path
    while load<QUESTIONOpts.L1Capacity
        if size(nonzeros(SatLoad),1)==0
            break;
        end
        CandidateSat=find(SatLoad~=0);minIndex=CandidateSat(1);
        for i=1:size(CandidateSat,1)
            if CandidateSat(i)~=minIndex && Sat2SatDist(CandidateSat(i),currentSatIndex)<Sat2SatDist(minIndex,currentSatIndex)
                minIndex=CandidateSat(i);
            end
        end
        space=QUESTIONOpts.L1Capacity-load;
        if space>=SatLoad(minIndex)
            load=load+SatLoad(minIndex);
            Sq=[Sq;minIndex,SatLoad(minIndex)];
            SatLoad(minIndex)=0;
        else
            load=QUESTIONOpts.L1Capacity;
            SatLoad(minIndex)=SatLoad(minIndex)-space;
            Sq=[Sq;minIndex,space];
        end
    end
    
    L1Num=L1Num+1;
    L1Result(L1Num,1)={Sq};
end
Neighbor{1,1}=L1Result;
%update fitness
Neighbor{1,3}=fitness(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);

end

