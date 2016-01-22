function [ dividedResult ] = CVPRDegreeDivide( SatCusId,CusPos,SatPos,Demand,L2Fleet,L2Capacity )
%return column1:cusId,column2:partId
%cal all the degree of cus2sat
dividedResult=zeros(size(SatCusId,1),2);
Degree=zeros(size(SatCusId,1),1);
coverCus=-1;
for i=1:size(SatCusId,1)
    x=CusPos(SatCusId(i),1)-SatPos(1);
    y=CusPos(SatCusId(i),2)-SatPos(2);
    if x==0 && y==0
        Degree(i)=0;
        coverCus=SatCusId(i);
    else
        Degree(i)=getDegree(x,y);
    end
end

partNum=1;
partLoad=zeros(L2Fleet,1);
k=rand()*360;
Degree=mod((Degree-k),360);
for i=1:size(SatCusId,1)
    %from k to 360+k degree
    minCusIndex=find(Degree==min(Degree),1);
    ifNoMorePart=0;
    if partLoad(partNum)+Demand(SatCusId(minCusIndex,1))>L2Capacity
        if partNum<L2Fleet
            partNum=partNum+1;
        else
            ifNoMorePart=1;
        end
    end
    if ifNoMorePart
        %find spare path to insert
        for j=1:partNum
            if L2Capacity-partLoad(j)>= Demand(SatCusId(minCusIndex,1))
                partLoad(j)=partLoad(j)+Demand(SatCusId(minCusIndex,1));
                dividedResult(i,:)=[SatCusId(minCusIndex,1),partNum];
                break;
            end
        end
    else
        partLoad(partNum)=partLoad(partNum)+Demand(SatCusId(minCusIndex,1));
        dividedResult(i,:)=[SatCusId(minCusIndex,1),partNum];
    end
    Degree=Degree-Degree(minCusIndex);
    Degree(minCusIndex)=+inf;
    
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




