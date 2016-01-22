function [ dividedResult,ifSuccess ] = degreeDivide( SatCusPos,SatPos,Demand,L2Fleet,L2Capacity,retryTimes )
%return column1:cusId,column2:partId
%cal all the degree of cus2sat
ifSuccess=1;
dividedResult=zeros(size(SatCusPos,1),2);
Degree=zeros(size(SatCusPos,1),1);
coverCus=-1;
for i=1:size(SatCusPos,1)
    x=SatCusPos(i,2)-SatPos(1);
    y=SatCusPos(i,3)-SatPos(2);
    if x==0 && y==0
        Degree(i)=0;
        coverCus=SatCusPos(i,1);
    else
        Degree(i)=getDegree(x,y);
    end
end

partNum=1;
PartLoad=zeros(L2Fleet,1);
k=rand()*360;
Degree=mod((Degree-k),360);
for i=1:size(SatCusPos,1)
    %from k to 360+k degree
    minCusIndex=find(Degree==min(Degree),1);
    ifNoMorePart=0;
    if PartLoad(partNum)+Demand(SatCusPos(minCusIndex,1))>L2Capacity
        if partNum<L2Fleet
            partNum=partNum+1;
        else
            ifNoMorePart=1;
        end
    end
    if ifNoMorePart
        %find spare path to insert
        ifInserted=0;
        for j=1:partNum
            if L2Capacity-PartLoad(j)>= Demand(SatCusPos(minCusIndex,1))
                PartLoad(j)=PartLoad(j)+Demand(SatCusPos(minCusIndex,1));
                dividedResult(i,:)=[SatCusPos(minCusIndex,1),j];
                ifInserted=1;
                break;
            end
        end
        if ~ifInserted
            if nargin==6
                if retryTimes<10
                    dividedResult=degreeDivide( SatCusPos,SatPos,Demand,L2Fleet,L2Capacity,retryTimes+1 );
                else
                    ifSuccess=0;
                    fprintf('bye\n');
                    return;
                end
            else
                dividedResult=degreeDivide( SatCusPos,SatPos,Demand,L2Fleet,L2Capacity );
            end
           % fprintf('again\n');
            return;
        end
    else
        PartLoad(partNum)=PartLoad(partNum)+Demand(SatCusPos(minCusIndex,1));
        dividedResult(i,:)=[SatCusPos(minCusIndex,1),partNum];
    end
    Degree=Degree-Degree(minCusIndex);
    Degree(minCusIndex)=+inf;
    
end

for i=1:partNum
    PathCus=find(dividedResult(:,2)==i);
    load=0;
    for j=1:size(PathCus,1)
        load=load+Demand(dividedResult(PathCus(j),1));
    end
    if load>L2Capacity
        throw 
    end
end

if coverCus~=-1
    if partNum<L2Fleet
        %remove from path
        dividedResult(find(dividedResult(:,1)==coverCus,1),:)=[];
        %add
        dividedResult(size(SatCusPos,1),:)=[coverCus,partNum+1];
    end
end



end

