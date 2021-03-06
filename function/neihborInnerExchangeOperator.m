function [ Neighbor,ifChanged ] = neihborInnerExchangeOperator( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts )
%% initial variables
ifChanged=1;
Neighbor=TotalResult;
SatResult=TotalResult{1,2}{satId,1};
PathCusNum=zeros(QUESTIONOpts.L2Fleet,1); %index:pathId 1:cusNum

PathNotEmpty=[];
for i=1:size(SatResult,1)
    cusNum=size(SatResult{i,1},1);
    if cusNum>0 && size(SatResult{i,1},2)>0
        PathCusNum(i)=cusNum;
        PathNotEmpty=[PathNotEmpty;i];
    end
end
PathNotEmptyNum=size(PathNotEmpty,1);

%% choose 2 path
if PathNotEmptyNum<2
    ifChanged=0;
    return;
elseif PathNotEmptyNum==2
    path1Id=PathNotEmpty(1);
    path2Id=PathNotEmpty(2);
else
    ChosenPath=PathNotEmpty(randperm(PathNotEmptyNum,2));
    path1Id=ChosenPath(1);
    path2Id=ChosenPath(2);
end
Path1=SatResult{path1Id,1};
Path2=SatResult{path2Id,1};
path1CusNum=size(Path1,1);
path2CusNum=size(Path2,1);

%% find two near cus in 2 path
%get every two cus's dist
Dist=zeros(path1CusNum,path2CusNum);
DistSort=zeros(path1CusNum*path2CusNum,1);
for cus1I=1:path1CusNum
    for cus2I=1:path2CusNum
        dist=Cus2CusDist(Path1(cus1I),Path2(cus2I));
        Dist(cus1I,cus2I)=dist;
        DistSort((cus1I-1)*path2CusNum+cus2I)=dist;
    end
end
%find k nearest pair
k=3;
Sort=sort(DistSort);
if size(DistSort,1)<k
    k=size(DistSort,1);
end
NearestIndex=find(DistSort<=Sort(k));
k=size(NearestIndex,1);
NearestPair=zeros(size(NearestIndex,1),2);
for i=1:k
    %transfer to 2d index
    cus1I=floor((NearestIndex(i)-1)/path2CusNum)+1;
    cus2I=mod((NearestIndex(i)-1),path2CusNum)+1;
    NearestPair(i,:)=[Path1(cus1I),Path2(cus2I)];
end
%randomly choose one pair
NPIndex=randi([1,k],1,1);
ChosenPair=NearestPair(NPIndex,:);

%% exchange
%check if overloaded
ifSucceed=0;
while ~ifSucceed && size(NearestPair,1)>0
    load1=0;load2=0;
    for i=1:path1CusNum
        load1=load1+Demand(Path1(i));
    end
    for i=1:path2CusNum
        load2=load2+Demand(Path2(i));
    end
    e=Demand(ChosenPair(1,1))-Demand(ChosenPair(1,2));
    add=0;
    if load1-e>QUESTIONOpts.L2Capacity
        %cus2Id is heavier, so try a adjcent cus in path1
        [ifSucceed,lr]=tryMoreInPath1(Path1,ChosenPair,path1CusNum,load1,load2,e,Demand,QUESTIONOpts.L2Capacity);
        add=1;
    elseif load2+e>QUESTIONOpts.L2Capacity
        [ifSucceed,lr]=tryMoreInPath2(Path2,ChosenPair,path2CusNum,load1,load2,e,Demand,QUESTIONOpts.L2Capacity);
        add=2;
    else
        ifSucceed=1;
    end
    %execute exchanging
    if ifSucceed
        if add==0
            Path1(find(Path1==ChosenPair(1,1),1))=ChosenPair(1,2);
            Path2(find(Path2==ChosenPair(1,2),1))=ChosenPair(1,1);
        elseif add==1 %path1 give 2cus
            [Path1,Path2]=exchange(Path1,Path2,path2CusNum,lr,ChosenPair,add);
        else %path2 give 2 cus
            [Path2,Path1]=exchange(Path2,Path1,path1CusNum,lr,ChosenPair,add);
        end
    else
        %delete this pair from NearestPair
        NearestPair(NPIndex,:)=[];
        if size(NearestPair,1)==0
            ifChanged=0;
            return;
        end
        %randomly choose another pair
        NPIndex=randi([1,size(NearestPair,1)],1,1);
        ChosenPair=NearestPair(NPIndex,:);
    end
end

%% save to result
SatResult{path1Id,1}=Path1;
SatResult{path2Id,1}=Path2;
Neighbor{1,2}{satId,1}=SatResult;
Neighbor{1,3}=fitness(Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);

 %!!check path ~~~~~~~~~~~~~~~~
    for pathId=1:size(Neighbor{1,2}{satId,1},1)
        cusNum=size(Neighbor{1,2}{satId,1}{pathId,1},1);
        if cusNum>0 && size(Neighbor{1,2}{satId,1}{pathId,1},2)~=0
            if checkPathIfOverload(Neighbor{1,2}{satId,1}{pathId,1},Demand,QUESTIONOpts.L2Capacity)
                throw 
            end
        end
    end 
end















%% inner function

function [ifSucceed ]=checkIfCanExchage1(load1,load2,e,tryPos,Path1,Demand,L2Capacity)
if load1-e-Demand(Path1(tryPos))<=L2Capacity && load2+e+Demand(Path1(tryPos))<=L2Capacity
    ifSucceed=1;
else
    ifSucceed=0;
end
end

function [ifSucceed ]=checkIfCanExchage2(load1,load2,e,tryPos,Path2,Demand,L2Capacity)
if load1-e+Demand(Path2(tryPos))<=L2Capacity && load2+e-Demand(Path2(tryPos))<=L2Capacity
    ifSucceed=1;
else
    ifSucceed=0;
end
end

function [ifSucceed,lr]=tryMoreInPath1(Path1,ChosenPair,path1CusNum,load1,load2,e,Demand,L2Capacity)
pos=find(Path1==ChosenPair(1,1),1);
if path1CusNum==1
    %try another pair
    ifSucceed=0;
else
    if pos==1
        %try the right one
        ifSucceed=checkIfCanExchage1(load1,load2,e,pos+1,Path1,Demand,L2Capacity);
        lr=2;
    elseif pos==path1CusNum
        %try the left one
        ifSucceed=checkIfCanExchage1(load1,load2,e,pos-1,Path1,Demand,L2Capacity);
        lr=1;
    else
        %randomly try left or right first
        which=randi([1,2],1,1);
        if which==1
            %try the left one
            ifSucceed=checkIfCanExchage1(load1,load2,e,pos-1,Path1,Demand,L2Capacity);
            lr=1;
        else
            %try the right one
            ifSucceed=checkIfCanExchage1(load1,load2,e,pos+1,Path1,Demand,L2Capacity);
            lr=2;
        end
        if ~ifSucceed
            %try another one
            if which==2
                %try the left one
                ifSucceed=checkIfCanExchage1(load1,load2,e,pos-1,Path1,Demand,L2Capacity);
                lr=1;
            else
                %try the right one
                ifSucceed=checkIfCanExchage1(load1,load2,e,pos+1,Path1,Demand,L2Capacity);
                lr=2;
            end
        end
    end
end %end of try
end

function [ifSucceed,lr]=tryMoreInPath2(Path2,ChosenPair,path2CusNum,load1,load2,e,Demand,L2Capacity)
pos=find(Path2==ChosenPair(1,2),1);
if path2CusNum==1
    %try another pair
    ifSucceed=0;
else
    if pos==1
        %try the right one
        ifSucceed=checkIfCanExchage2(load1,load2,e,pos+1,Path2,Demand,L2Capacity);
        lr=2;
    elseif pos==path2CusNum
        %try the left one
        ifSucceed=checkIfCanExchage2(load1,load2,e,pos-1,Path2,Demand,L2Capacity);
        lr=1;
    else
        %randomly try left or right first
        which=randi([1,2],1,1);
        if which==1
            %try the left one
            ifSucceed=checkIfCanExchage2(load1,load2,e,pos-1,Path2,Demand,L2Capacity);
            lr=1;
        else
            %try the right one
            ifSucceed=checkIfCanExchage2(load1,load2,e,pos+1,Path2,Demand,L2Capacity);
            lr=2;
        end
        if ~ifSucceed
            %try another one
            if which==2
                %try the left one
                ifSucceed=checkIfCanExchage2(load1,load2,e,pos-1,Path2,Demand,L2Capacity);
                lr=1;
            else
                %try the right one
                ifSucceed=checkIfCanExchage2(load1,load2,e,pos+1,Path2,Demand,L2Capacity);
                lr=2;
            end
        end
    end
end %end of try
end


function [Path1,Path2]=exchange(Path1,Path2,pathCusNum,lr,ChosenPair,add)
if add==2
    ChosenPair=fliplr(ChosenPair);
end
if lr==1
    anotherCusId=Path1(find(Path1==ChosenPair(1,1),1)-1);
    Path1(find(Path1==ChosenPair(1,1),1)-1)=[];
    Path1(find(Path1==ChosenPair(1,1),1))=ChosenPair(1,2);
    pos=find(Path2==ChosenPair(1,2),1);
    Path2(find(Path2==ChosenPair(1,2),1))=ChosenPair(1,1);
    Path2(pos)=ChosenPair(1,1);
    if pos==1
        Path2=[anotherCusId;Path2(1:end)];
    else
        Path2=[Path2(1:pos-1);anotherCusId;Path2(pos:end)];
    end
else
    anotherCusId=Path1(find(Path1==ChosenPair(1,1),1)+1);
    Path1(find(Path1==ChosenPair(1,1),1)+1)=[];
    Path1(find(Path1==ChosenPair(1,1),1))=ChosenPair(1,2);
    pos=find(Path2==ChosenPair(1,2),1);
    Path2(find(Path2==ChosenPair(1,2),1))=ChosenPair(1,1);
    Path2(pos)=ChosenPair(1,1);
    if pos==pathCusNum
        Path2=[Path2(1:pos);anotherCusId];
    else
        Path2=[Path2(1:pos);anotherCusId;Path2(pos+1:end)];
    end
end
end