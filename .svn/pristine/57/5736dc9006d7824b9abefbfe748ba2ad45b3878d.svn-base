function [ Neighbor ] = neighborOuterRandOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CenterPos,SatPos,CusPos,cycleNum )
Neighbor=TotalResult;
%this is a standard outer operater.

%randomly choose 2 sat and select randomly near path in one sat.In
%this path,choose serveral cus to transfer into the other sat.
sat1=0;sat2=0; %chosen satId
if size(SatPos,1)<=2
    sat1=randi([1,2],1,1);sat2=1+mod(sat1,2);
else
	ChooseResult=randperm(size(SatPos,1),2);
	sat1=ChooseResult(1);sat2=ChooseResult(2);
end

%choose 1~3 cus from sat1
CandidateCus=[];
for i=1:size(Neighbor{1,2}{sat1,1},1)
    if size(Neighbor{1,2}{sat1,1}{i,1},1)~=0
        CandidateCus=[CandidateCus;Neighbor{1,2}{sat1,1}{i,1}];
    end
end
if size(CandidateCus,1)==0
    Neighbor=neighborOuterRandOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CenterPos,SatPos,CusPos,cycleNum);
    return;
end
ChosenNum=randi([1,3],1,1);
if size(CandidateCus,1)<3
    ChosenNum=randi([1,size(CandidateCus,1)],1,1);
end
ChosenCus=CandidateCus(randperm(size(CandidateCus,1),ChosenNum),1);

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
for i=1:size(Neighbor{1,2}{sat2,1},1)
    if size(Neighbor{1,2}{sat2,1}{i,1},1)==0
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
    for i=1:size(Neighbor{1,2}{sat2,1},1)
        if size(Neighbor{1,2}{sat2,1}{i,1},1)==0
            RestSpace(i,1)=QUESTIONOpts.L2Capacity;
        else
            load=0;
            for j=1:size(Neighbor{1,2}{sat2,1}{i,1},1)
                load=load+Demand(Neighbor{1,2}{sat2,1}{i,1}(j,1),1);
            end
            RestSpace(i,1)=QUESTIONOpts.L2Capacity-load;
        end
    end
    
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
            Neighbor=neighborOuterRandOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CenterPos,SatPos,CusPos,cycleNum );
            return;
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

